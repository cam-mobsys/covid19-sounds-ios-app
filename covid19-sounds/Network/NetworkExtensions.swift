//
//  NetworkExtensions.swift
//  covid19-sounds
//
//  Authors:
//
//    Andreas Grammenos
//
//  Copyright © 2020 Computer Lab / Mobile Systems Group. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

/// This is an extension to Alamofire that enables the usage of SwiftyJSON
/// directly as a request parameter; it implements the `ParameterEncoding`
/// protocol.
///
struct SwiftyJSONParameters: ParameterEncoding {
  /// the raw json as a string
  private let rawJSON: String
  /// The default constructor of our class, throws an error if a null json
  /// is encountered.
  ///
  /// - Parameter json: the body `JSON` to be embedded in the request
  ///
  /// - Throws: in case `JSON` is null then an error is thrown.
  ///
  init(json: JSON) throws {
    guard json.rawString() == nil else {
      throw NSError(domain: "Alamofire parameter conversion failed, " +
        "cause: JSON is null.", code: 1, userInfo: nil)
    }
    rawJSON = json.rawString()!
  }
  /// This function is responsible for encoding the request to the actual
  /// `http` body; it does that by embedded the raw `JSON` value into the
  /// body of the request verbatim.
  ///
  /// - Parameter urlRequest: the request object
  ///
  /// - Parameter parameters: the optional parameters
  ///
  func encode(_ urlRequest: URLRequestConvertible,
              with parameters: Parameters?) throws -> URLRequest {
    // setup a mutable `URLRequest`
    var urlRequest = try urlRequest.asURLRequest()
    // now set the type suitable for `POST`ing `JSON`
    if urlRequest.value(forHTTPHeaderField: "Content-Type") == nil {
      urlRequest.setValue("application/json",
                          forHTTPHeaderField: "Content-Type")
    }
    // add the actual `JSON` to the body using utf8 encoding
    urlRequest.httpBody = rawJSON.data(using: .utf8)
    // finally return the prepared `URLRequest`
    return urlRequest
  }
}
