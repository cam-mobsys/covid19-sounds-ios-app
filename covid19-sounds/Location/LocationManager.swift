//
//  LocationManager.swift
//  covid19-sounds
//
//  Authors:
//
//    Andreas Grammenos
//
//  Copyright © 2020 Computer Lab / Mobile Systems Group. All rights reserved.
//

import Foundation
import CoreLocation
import Combine

/// This class does location stuff.
///
class LocationManager: NSObject, CLLocationManagerDelegate, ObservableObject {
  /// This enumeration holds the types of tracking supported
  /// these are currently:
  ///
  /// - `trackingBest`: the best available on device
  /// - `trackingMeters`: use a user-specified distance sensitivity
  /// - `trackingSignificant`: track significant updates (as iOS sees fit)
  ///
  enum TrackingType {
    case trackingBest
    case trackingMeters
    case trackingSignificant
  }
  /// Implements the observable object notification
  private let didChange = PassthroughSubject<Void, Never>()
  /// if enabled the value for the deferred distance between each measurement.
  private let deferDist: Double = 100
  /// if enabled the value for the deferred time out between each measurement.
  private let deferTimeout: Double = 60
  ///
  private let trackingDistanceFilter: Double = 100
  /// the type of tracking enabled as per `TrackingType` enum.
  private var trackingPreferrence: TrackingType = TrackingType.trackingMeters
  /// flag that shows if the tracking has started.
  private var trackingStarted: Bool = false
  /// flag that shows if we have enabled the slow mode, this saved battery.
  private var slowModeFlag: Bool = false
  /// counter that tracks the number of measurements recorded.
  private var trackingCount: Int = 0
  /// value that indicates the time between current and last measurement.
  private var lastMotion: TimeInterval = 0
  /// flag that indicates we want a single location and then stop.
  private var singleShotUpdate: Bool = false
  /// flag that indicates if we require background location updates.
  private var allowBackgroundUpdates: Bool = false
  /// the location buffer that stores the received locations of type `CLLocation`.
  private var locationBuffer: CLLocation?
  /// the handler which is called when a new batch of `CLLocation` are received.
  private var locationHandler: (() -> Void)?
  /// the latest location stored - note: this can be different from the _most recent_ one within the location handler.
  @Published private var currentLocation: CLLocation? { willSet { didChange.send() } }
  /// holds whether location permission has been given
  @Published var locationPermission: CLAuthorizationStatus = .notDetermined
  /// contains the `CLLocationManager` instance
  private let locationManager = CLLocationManager()
  /// Our default constructor that instantiates a vanilla instance of the location manager
  ///
  override init() {
    super.init()
    locationManager.delegate = self
  }
  /// An overloaded constructor that allows us to configure `singleShotUpdate` variable
  /// on initialisation
  ///
  /// - Parameter `singleShotUpdate`: a `Bool` variable showing if we need single shot location updates or not.
  ///
  init(singleShotUpdate: Bool) {
    super.init()
    self.singleShotUpdate = singleShotUpdate
    locationManager.delegate = self
  }
  /// This function checks if the location status is authorised or not; it returns `true` for both `.authorizedAlways`
  /// and `.authorizedWhenInUse`.
  ///
  /// - Returns: `true` if can access location currently, even once, and `false` otherwise.
  ///
  func accessAuthorized() -> Bool {
    return locationPermission == .authorizedAlways ||
      locationPermission == .authorizedWhenInUse
  }
  /// This function checks if accessing the location is undetermined (i.e.: in `.notDetermined` state)
  ///
  /// - Returns: `true` if accessing the location is `.notDetermined`, `false` otherwise.
  ///
  func accessNotDetermined() -> Bool {
    return locationPermission == .notDetermined
  }
  /// This function combined the `accessAuthorized` and `accessNotDetermined` and returns
  /// `true` if either is `true`.
  ///
  /// - Returns: `true` if `accessAuthorized` or `accessNotDetermined` are `true`, `false` otherwise.
  ///
  func accessAuthorizedOrUnknown() -> Bool {
    return accessAuthorized() || accessNotDetermined()
  }
  /// This function is responsible for requesting the location permission from the user.
  ///
  func requestWhenInUseAuthorization() {
    locationManager.requestWhenInUseAuthorization()
  }
  /// Function that compares to CLLocation entries which can be used to sort
  /// an array of said locations in ascending order (older -> newer); in essence
  /// we return the result of: ( this < that )
  ///
  /// - Parameter this: object that is used to compare the left side
  ///
  /// - Parameter that: object that is used to compare the right side
  ///
  /// - Returns: true if this is _LESS_ than that.
  ///
  func sortTimeComparator(this: CLLocation, that: CLLocation) -> Bool {
    return this.timestamp < that.timestamp
  }
  /// location manager delegate
  ///
  /// - Parameter manager: the `CLLocationManager` object.
  ///
  /// - Parameter locations: the `locations` array containing the number of
  ///                       gathered `CLLocation`s.
  ///
  func locationManager(_ manager: CLLocationManager,
                       didUpdateLocations locations: [CLLocation]) {
    // tag the last measurement
    lastMotion = Date().timeIntervalSince1970
    currentLocation = locations[0]
    log.verbose("Location update received at " + utils.getTimeStampForInterval(interval: lastMotion) + ".")
    // increase the tracking count
    trackingCount += 1
    //
    // check if we have one shot
    if self.singleShotUpdate {
      log.info("Requiring single shot updates, which were received; stoppping location tracking.")
      // if so, stop tracking the location
      self.stopTrackingLocation()
    }
  }
  /// Handler for when location permission changes
  ///
  /// - Parameter manager: the `CLLocationManager` object.
  ///
  /// - Parameter status: the `CLAuthorizationStatus` status based on user choice.
  ///
  func locationManager(_ manager: CLLocationManager,
                       didChangeAuthorization status: CLAuthorizationStatus) {
    log.info("Location permission changed")
    switch status {
    // No permission status available
    case .notDetermined:
      log.info("Location permission changed to location permission to: .notDetermined")
      self.locationPermission = status
    // Permission denied, move on
    case .restricted, .denied:
      log.info("Location permission denied, setting location permission to: .locationPermission")
      self.locationPermission = status
    // Allowed, proceed to get location
    case .authorizedAlways, .authorizedWhenInUse:
      log.info("Location permission authorised, setting location permission to: .locationPermission")
      self.locationPermission = status
    // Unknown status, maybe from future updates
    @unknown default:
      log.warning("Unknown Location Permission Status")
    }
  }
  /// Sets the location handler to a function that is called after we receive a location
  /// sample/
  ///
  /// - Parameter locationHandler: sets the internal location handler object to the designated function.
  ///
  func setLocationHandler(locationHandler: (() -> Void)?) {
    self.locationHandler = locationHandler
  }
  /// Function that returns an optional with the most recently tracked location
  /// as a `CLLocation` optional.
  ///
  /// - Returns: an optional `CLLocation` object
  ///
  func getMostRecentLocation() -> CLLocation? {
    return self.locationBuffer
  }
  /// This function is responsible for tracking the location over time
  ///
  func startTrackingLocation() {
    // check if tracking has already started.
    if trackingStarted {
      log.info("Skipping, tracking already startted")
      return
    } else {
      log.info("Starting location tracking")
    }
    self.trackingStarted = true
    //
    // Don't pause location updates
    locationManager.pausesLocationUpdatesAutomatically = false
    //
    // check if we have enabled single shot updates
    if singleShotUpdate {
      log.info("Single Shot location is enabled - we stop after 1 delegate update.")
    }
    //
    // check if we have a valid location handler
    if let handler = self.locationHandler {
      log.info("Valid location handler is present - invoking.")
      handler()
    } else {
      log.info("No location handler is present - skipping invokation.")
    }
    //
    // select which tracking method to use.
    switch trackingPreferrence {
    case TrackingType.trackingBest:
      trackLocationWithParams(acc: kCLLocationAccuracyBest,
                              distFilter: kCLDistanceFilterNone)
    case TrackingType.trackingMeters:
      trackLocationWithParams(acc: kCLLocationAccuracyBestForNavigation,
                              distFilter: trackingDistanceFilter)
    case TrackingType.trackingSignificant:
      trackSignificantLocation()
    }
  }
  /// This function starts the location tracking and takes as parameters
  /// the desired tracking accuracy and distance filter.
  ///
  /// - Parameter acc: the desired accuracy, in meters
  ///
  /// - Parameter distFilter: the desired distance filter.
  ///
  func trackLocationWithParams(acc: Double, distFilter: Double) {
    locationManager.distanceFilter = distFilter
    locationManager.desiredAccuracy = acc
    locationManager.startUpdatingLocation()
  }
  /// This function starts tracking the significant updates in location
  /// -- what "significant" means is defined by iOS itself.
  ///
  func trackSignificantLocation() {
    locationManager.distanceFilter = kCLDistanceFilterNone
    locationManager.startMonitoringSignificantLocationChanges()
  }
  /// This function is responsible for stopping location tracking; it stops
  /// based on the tracking method used (either normal or significant).
  ///
  func stopTrackingLocation() {
    if !trackingStarted {
      log.info("Cannot stop location tracking, as it has not started")
      return
    } else {
      log.info("Stoping location tracking")
    }
    trackingStarted = false
    switch trackingPreferrence {
    case .trackingBest, .trackingMeters:
      locationManager.stopUpdatingLocation()
    case .trackingSignificant:
      locationManager.stopMonitoringSignificantLocationChanges()
    }
  }
  /// This function is responsible for updating the location tracking type
  /// preferrence.
  ///
  /// - Parameter newPreference: the new tracking preference which can be
  ///                               any of the three `TrackingType` entries.
  ///
  func setTrackingPreferrence(newPreferrence: TrackingType) {
    trackingPreferrence = newPreferrence
  }
  /// This function is responsible for getting us the current cached location
  ///
  /// - Returns: the current location stored in our buffer which is updated
  ///             roughly every 5-6 seconds.
  ///
  func getCurrentLocation() -> CLLocation? {
    return currentLocation
  }
  /// This function is responsible for checking if we have a valid location
  ///
  /// - Returns: true if we have a valid location, false otherwise.
  ///
  func haveValidLocation() -> Bool {
    if currentLocation == nil {
      return false
    } else {
      return true
    }
  }
  /// This function returns true if we are in a stationary position and can
  /// enable slow mode.
  ///
  /// - Returns: true if we can, false otherwise
  ///
  func canEnableSlowMode() -> Bool {
    return slowModeFlag
  }
  /// This function returns location formatted as a string using the following format:
  ///   "latitude,longitude,accuracy". If the location is not available it returns a string
  ///   That says "unavalable"
  ///
  ///   - Returns: the formatted location string, "unavailable" otherwise.
  ///
  func locationToString() -> String {
    guard let unwrappedCurrentLocation = currentLocation else {
      log.error("Location could not be unwrapped - maybe permission error?")
      // now return the correct
      return "unavailable"
    }
    // we can use the unwrapped value to construct the desired string
    return "\(unwrappedCurrentLocation.coordinate.latitude)," +
      "\(unwrappedCurrentLocation.coordinate.longitude)," +
      "\(unwrappedCurrentLocation.horizontalAccuracy)"
  }
}
