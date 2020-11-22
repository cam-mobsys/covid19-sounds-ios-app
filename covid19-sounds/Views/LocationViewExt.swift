//
//  LocationView.swift
//  covid19-sounds
//
//  Authors (by order of contribution):
//
//    Andreas Grammenos
//    Api Hastanasombat
//
//  Copyright © 2020 Computer Lab / Mobile Systems Group. All rights reserved.
//

import CoreLocation
import SwiftUI

/// Handles the gathering of the location as well as the
///
struct LocationViewExt: View {
  /// the `LocationManager` instance as an `EnvironmentObject`.
  @EnvironmentObject private var loc: LocationManager
  /// the variable that is used to check if we are fetching location or uploading.
  @ObservedObject private var buttonState = uploadButtonState
  //
  /// the `View` definition
  var body: some View {
    //
    ZStack {
      VStack {
        Spacer()
        //
        if loc.accessAuthorizedOrUnknown() {
          //
          TextViewFactory("locationProbeText", padding: .all)
          //
        } else {
          //
          TextViewFactory("locationProbeDeniedText", padding: .all)
          //
        }
        //
        Spacer().frame(height: 80)
        //
        UploadButtonView()
        //
        Spacer()
        //
      }
      .modifier(AppBackgroundStyle())
      .disabled(buttonState.loading)
      .blur(radius: buttonState.loading ? 3 : 0)
      .onAppear(perform: {
        log.info("Location view appeared reseting button counter")
        log.info("Button state loading is: \(buttonState.loading)")
      })
      .onDisappear(perform: {
        log.info("Disabling loading flag")
        // disable loading
        uploadButtonState.loading = false
      })
      //
      // Actual Activity indicator view
      //
      ActivityIndicatorView()
    }
  }
}

// only render this in debug views
#if DEBUG
struct LocationViewExt_Previews: PreviewProvider {
  static var previews: some View {
    LocationViewExt()
      .environmentObject(debugLocationManagerInstance)
      .environmentObject(debugUserInstance)
      .environmentObject(debugAppStatusInstance)
      .environmentObject(debugLocationManagerInstance)
      .environment(\.locale, .init(identifier: debugLocale))
  }
}
#endif
