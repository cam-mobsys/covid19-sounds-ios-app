//
//  NetworkLibrary.swift
//  covid19-sounds
//
//  Authors:
//
//    Andreas Grammenos
//
//  Copyright © 2020 Computer Lab / Mobile Systems Group. All rights reserved.
//

import Foundation
import SwiftyJSON
import CoreData
import Alamofire

/// This library is supposed to send stuff back.
///
class NetworkManager {
  /// private constructor for singleton.
  private init() {}
  /// the public singleton instance.
  static let shared = NetworkManager()
  /// http OK code (200).
  private let HTTP_200: Int = 200
  /// http NOT FOUND code (404).
  private let HTTP_404: Int = 404
  /// http BAD REQUEST code (400).
  private let HTTP_400: Int = 400
  /// http UNAUTHORIZED code (401).
  private let HTTP_401: Int = 401
  /// http INTERNAL SERVER ERROR code (500).
  private let HTTP_500: Int = 500
  /// json tags for username.
  private let usernameTag = "username"
  /// json tags for password.
  private let passwordTag = "password"
  /// flag that indicates if refreshing a token failed and thus have to
  /// fall back to username/password combination to get a new one.
  private var attemptedRefreshButFailed = false
  /// This function is responsible to create a user using the Legacy OAuth protocol.
  /// Meaning via client_{id,secret} pair along with a username/password. For
  /// convenience the backend autogenerates a strong password for the username
  /// passed along with the request.
  ///
  /// Optionally, a completion handler function can be passed which is called upon
  /// function end.
  ///
  /// - Parameter `handler`: a function that invoked upon function end.
  ///
  func createUser(completionHandler: (() -> Void)?) {
    log.info("Attempting to create the app user")
    // get a populated request
    let req = authUtils.createUserRequest()
    // try to execute the request
    req.responseJSON(completionHandler: { resp in
      switch resp.result {
      case .success:
        self.responseHandler(resp: resp,
                             dataHandler: self.parseUserFromResponseData,
                             completionHandler: completionHandler)
      case .failure(let err):
        self.failureHandler(err)
      }
    })
  }
  /// This function is responsible for performing the token exchange with the remote server.
  /// Note that is is the one-stop function to be used for exchanging credentials as it handles
  /// both first time token generation as well as its refresh.
  ///
  /// - Parameter completionHandler: the handler to be called upon success, if any.
  ///
  func tokenExchange(completionHandler: (() -> Void)?) {
    log.info("Trying to exchange to retrieve an access token.")
    // sanity check
    if !authUtils.canExchangeToken() {
      log.error("Cannot exchange token when either username or password is empty...")
      appStatus.currentError = .tokenError
      return
    }
    //
    // check if we have a access token
    if !authUtils.haveAccessToken() || attemptedRefreshButFailed {
      log.info("There is no available access token, attempting to get a new one.")
      // if we do not, then try to retrieve one.
      self.fetchAccessToken(completionHandler: completionHandler)
    } else {
      log.info("There is an access token, attempting to refresh it.")
      // otherwise, try to refresh the token.
      self.refreshAccessToken(completionHandler: completionHandler)
    }
  }
  /// This function is responsible for refreshing the token using the `refresh_token`;
  /// if this action fails then the `attemptedRefreshButFailed` is raised which forces
  /// the use of user credentials to get completely new token set.
  ///
  /// - Parameter completionHandler: the completion handler to be called upon success, if provided.
  ///
  private func refreshAccessToken(completionHandler: (() -> Void)?) {
    // refresh token, since we already have an access token
    let req = authUtils.refreshTokenRequest()
    // execute the request
    req.responseJSON(completionHandler: { resp in
      switch resp.result {
      case .success:
        self.responseHandler(resp: resp,
                             dataHandler: self.parseRefreshTokenFromResponseData,
                             completionHandler: completionHandler)
      case .failure(let err):
        self.failureHandler(err)
      }
    })
  }
  /// This function is responsible for fetching the token using the actual user credentials; it fetches a complete
  /// token set which can then be used for refresh. It is also the fall-back method in case refreshing fails for some
  /// reason.
  ///
  /// - Parameter completionHandler: the completion handler to be called upon sucess, if provided.
  ///
  private func fetchAccessToken(completionHandler: (() -> Void)?) {
    // get a new token from scratch
    let req = authUtils.accessTokenRequest()
    // execute the request
    req.responseJSON(completionHandler: { resp in
      switch resp.result {
      case .success:
        self.responseHandler(resp: resp,
                             dataHandler: self.parseAccessTokenFromResponseData,
                             completionHandler: completionHandler)
      case .failure(let err):
        self.failureHandler(err)
      }
    })
  }
  /// This function parses the response `data` field converting it to `JSON`, which is returned.
  ///
  /// - Parameter `resp`: the `AFDataResponse<Any>` to get the json data from.
  ///
  /// - Returns: the `JSON` data that was parsed
  ///
  private func jsonFromData(resp: AFDataResponse<Any>) -> JSON {
    // set json to be equal to null
    var json = JSON.null
    // attempt to get the JSON response to see response details, if we can
    do {
      json = try JSON(data: resp.data!)
    } catch {
      log.error("Error - JSON from response could not be parsed")
      json = JSON(["error": "JSON from response could not be parsed"])
    }
    return json
  }
  //
  // MARK: - File upload
  //
  /// This function is responsible for uploading the files to the remote vantage point. The request is constructed
  /// with all relevant information and then it is executed.
  ///
  func uploadFiles() {
    log.info("Trying to upload the files to server")
    let req = self.createFileUploadRequest()
    // response json
    req.responseJSON(completionHandler: { resp in
      self.responseHandler(resp: resp,
                           dataHandler: self.uploadFilesResponseHandler)
    })
  }
  /// This function is responsible for constructing the `UploadRequest` for creating the user.
  ///
  /// - Returns: the initialised `UploadRequest` instance for the user creation.
  ///
  private func createFileUploadRequest() -> UploadRequest {
    return  AF.upload(multipartFormData: { multipartFormData in
      // deal with questionnaires
      self.appendDailyQuestionnares(data: multipartFormData)
      self.appendInitialQuestionnares(data: multipartFormData)
      //
      // deal with audio files
      multipartFormData.append(dailyQuestionnaireInstance.breathingAudio,
                               withName: dailyQuestionnaireInstance.formAudioFilename(type: .breathe))
      multipartFormData.append(dailyQuestionnaireInstance.coughingAudio,
                               withName: dailyQuestionnaireInstance.formAudioFilename(type: .cough))
      multipartFormData.append(dailyQuestionnaireInstance.readingAudio,
                               withName: dailyQuestionnaireInstance.formAudioFilename(type: .read))
    }, to: ServerDetails.uploadBinaryURL, method: .put, headers: oauth.getAuthorisationHeader())
  }
  /// This function is responsible for appending the daily questionnaire to the request object, which is of
  /// type `MultipartFormData`. Note that the append happens _in place_.
  ///
  /// - Parameter data: the `MultipartFormData` instance which contains the `data` to be uploaded.
  ///
  private func appendDailyQuestionnares(data: MultipartFormData) {
    // try to append the json data
    let json = dailyQuestionnaireInstance.toJSON()
    #if DEBUG
    log.info("Daily JSON is: \(json.debugDescription)")
    #endif
    data.append(Data(json.rawString()!.utf8),
                withName: DailyQuestionnaireInstance.jsonFilename,
                fileName: DailyQuestionnaireInstance.jsonFilename)
  }
  /// This function is responsible for appending the initial questionnaire to the request object, which is of
  /// type `MultipartFormData`. Note that the append happens _in place_.
  ///
  /// - Parameter data: the `MultipartFormData` instance which contains the `data` to be uploaded.
  ///
  private func appendInitialQuestionnares(data: MultipartFormData) {
    // check if the user has already uploaded the initial
    if userInstance.hasUploadedInitial() {
      log.info("Initial seems to have been already uploaded - skipping.")
      return
    } else {
      log.info("Initial seems to be part of the upload - appending.")
    }
    // try to append the json data
    let json = initialQuestionnaireInstance.toJSON()
    #if DEBUG
    log.info("Initial JSON is: \(json.debugDescription)")
    #endif
    data.append(Data(json.rawString()!.utf8),
                withName: InitialQuestionnaireInstance.jsonFilename,
                fileName: InitialQuestionnaireInstance.jsonFilename)
  }
  //
  // MARK: - Response Parsers
  //
  /// This function is responsible for prasing a `JSON` response - it returns the `JSON` content as
  /// an optional.
  ///
  /// - Parameter resp: the `AFDataResponse<Any>` object to parse the `JSON` from
  ///
  /// - Returns: the parsed `JSON` data as an optional.
  ///
  private func parseJSONResponse(resp: AFDataResponse<Any>) -> JSON? {
    // try to unwrap the response object
    guard let respContent = resp.response else {
      log.error("Response could not be unwrapped - possibly invalid/corructed.")
      log.warning("Network error occurred, raising attemptedRefreshButFailed flag to get fresh credentials")
      self.attemptedRefreshButFailed = true
      return nil
    }
    // get the status code
    let statusCode = respContent.statusCode
    // try to extract the request json
    let respJSON = jsonFromData(resp: resp)
    //
    // check the status code
    if statusCode != HTTP_200 {
      log.error("Request could not be completed HTTP code returned was: \(statusCode), " +
                  "reason: \(respJSON[0].description).")
      log.warning("Network error occurred, raising attemptedRefreshButFailed flag to get fresh credentials")
      self.attemptedRefreshButFailed = true
      // set failed as well
      appStatus.setFailedButCanTryAgain(errorType: .receivedDataError)
      return nil
    }
    // notify we received a valid reply
    log.info("Received a valid reply - parsing details.")
    //
    // finally return the status code and json
    return respJSON
  }
  /// This function is responsible for setting the username and password received
  /// as a reply from the backend.
  ///
  /// - Parameter `data`: the `JSON` data to be used
  ///
  private func parseUserFromResponseData(data: JSON) {
    log.info("Parsing user response.")
    userInstance.username = data[usernameTag].string!
    userInstance.password = data[passwordTag].string!
    // sanity check for debuging reasons
    log.info("Retrieved username: \(userInstance.username) and pass: \(userInstance.password)")
    //  check if we can save
    userInstance.save()
    log.info("Finished parsing user response.")
  }
  /// This function is responsible for handling the request response from the server; we expect that the server
  /// will always return `JSON` based replies and will contain the received data length, which is logged.
  ///
  /// - Parameter resp: the `JSON` responsne received from the server.
  ///
  private func uploadFilesResponseHandler(resp: JSON) {
    log.info("Uploaded files SUCESSFULLY, length of uploaded bits: \(resp["received_data_length"])")
    // now set to just uploaded status
    appStatus.setToJustUploaded()
  }
  /// This function is responsible for handling the request response from the sever during a token exchange.
  /// It is expected that the response will always be of type `JSON`.
  ///
  /// - Parameter data: the `JSON` data that was returned.
  ///
  func parseAccessTokenFromResponseData(data: JSON) {
    log.info("Parsing access token response.")
    log.info("Access token JSON: \(data.description)")
    //
    // parse token from the response
    parseAccessTokenFromResponse(data)
    // finally log that parsing was complete
    log.info("Finished parsing access token response.")
  }
  /// This function is responsible for handling the request response from the sever during a token refresh exchange.
  /// It is expected that the response will always be of type `JSON`.
  ///
  /// - Parameter data: the `JSON` data that was returned.
  ///
  func parseRefreshTokenFromResponseData(data: JSON) {
    log.info("Parsing refresh access token response.")
    log.info("Refresh token JSON: \(data.description)")
    // parse token from the response
    parseAccessTokenFromResponse(data)
    // finally log that parsing was complete
    log.info("Finished parsing refresh token response.")
  }
  /// This helper function is used to extract the token information from the `JSON` data received
  /// which also stores it to the `OAuth` instance. After successful parse the `CoreData` store
  /// is also updated to reflect the new values received.
  ///
  /// - Parameter data; the `JSON` data received that contain the token information.
  ///
  private func parseAccessTokenFromResponse(_ data: JSON) {
    guard
      let access_token = data["access_token"].rawString(),
      let refresh_token = data["refresh_token"].rawString(),
      let expires_in = data["expires_in"].rawString(),
      let completed_time = userInstance.completedTime
      else {
        log.error("Invalid values during unwrap encountered - cannot save.")
        return
    }
    // try convert before setting
    if let exp_in = utils.addIntervalToDate(interval: expires_in,
                                         date: completed_time) {
      oauth.accessToken = access_token
      oauth.refreshToken = refresh_token
      oauth.expiresIn = exp_in
      oauth.refreshedAt = completed_time
    } else {
      log.error("Adding expires in interval to current timestamp failed - cannot save.")
      return
    }
    // now save
    oauth.save()
  }
  //
  // MARK: - Response Handlers
  //
  /// The general response handler for all `Alamofire` requests executed; it contains the actual
  /// response received of type `AFDAtaReponse`, the data handler which is the function that parses
  /// the data received within the response as well as an optional completion handler to be executed upon
  /// completion, if provided.
  ///
  /// - Parameter resp: the actual response instance.
  ///
  /// - Parameter dataHandler: the function that handles the data contained within the response.
  ///
  /// - Parameter completionHandler: the optional completion handler that is fired upon completion.
  ///
  private func responseHandler(resp: AFDataResponse<Any>,
                               dataHandler: @escaping ((JSON) -> Void),
                               completionHandler: (() -> Void)? = nil) {
    // try to fetch the response http code and json content
    guard let respJSON = parseJSONResponse(resp: resp) else { return }
    // invoke the data handler
    dataHandler(respJSON)
    // invoke the handler
    invokeHandler(completionHandler)
  }
  /// This function is called upon a failure within Alamofire.
  ///
  /// - Parameter err: the error occurred which is of type: `AFError`
  ///
  private func failureHandler(_ err: AFError) {
    if let errMsg = err.errorDescription {
      log.error("Failed with error: \(errMsg)")
    } else {
      log.error("Failed with error: unknown.")
    }
    //
    // in case of a hard network error, raise the flag to get new token
    log.warning("Hard Network error occurred, raising attemptedRefreshButFailed flag to get fresh credentials")
    self.attemptedRefreshButFailed = true
    // set the error type to be network error
    appStatus.setFailedButCanTryAgain(errorType: .networkError)
  }
  /// This function is responsible for unwrapping and invoking a handler
  ///
  /// - Parameter handler: the function handler to be invoked
  ///
  private func invokeHandler(_ handler: (() -> Void)?) {
    // check if we have a post execution hadler, if so invoke it otherwise return
    if let handler = handler {
      log.info("Valid handler provided - invoking")
      handler()
      log.info("Finished handler invokation.")
    } else {
      log.warning("Nil function handler provided - not invoking")
    }
  }
}
