//
//  AudioDeniedPermissionView.swift
//  covid19-sounds
//
//
//  Authors (by order of contribution):
//
//    Andreas Grammenos
//    Api Hastanasombat
//
//  Copyright © 2020 Computer Lab / Mobile Systems Group. All rights reserved.
//

import Foundation
import SwiftUI

/// View that is responsible for notifying the user about audio recording permissions.
///
/// It also checks if the user has allowed access to the microphone and if not it prompts the
/// user to do so. If access is granted it returns to the previous view before the one that
/// this permission issue occurred.
///
struct AudioPermissionDeniedView: View {
  /// show the notification in case we are not granted.
  @State private var showGrantedAlert = false
  /// the audio recorder instance for testing permissions.
  @ObservedObject private var audioRecorder = AudioRecorder()
  /// The `AppStatus` instance passed as an environment object.
  @EnvironmentObject private var appStatusInstance: AppStatus
  /// the presentation mode which is responsible for programmatically  going 'back'.
  @Environment(\.presentationMode) private var presentationMode
  //
  /// the `View` body definition.
  var body: some View {
    VStack {
      //
      TextViewFactory("⚠️", size: 50)
      //
      Spacer().frame(maxHeight: 20)
      //
      TextViewFactory("Microphone access denied")
      //
      Spacer().frame(maxHeight: 40)
      //
      TextViewFactory("Please allow microphone access", padding: .all)
      //
      Spacer().frame(maxHeight: 40)
      //
      Button {
        log.info("Tapped check access in denied view.")
        // check if we have granted the permissions, if not display the
        // alert box
        self.audioRecorder.requestRecordingPermissions(grantedHandler: {
          log.info("Microphone access granted - returning to initial view.")
          self.presentationMode.wrappedValue.dismiss()
        }, deniedHandler: {
          log.error("Microphone access is still denied - presenting alert.")
          self.showGrantedAlert = true
        })
      } label: {
        // Button contents
        HStack {
          Text("Check access").font(.custom("Next", size: 23))
        }
      }
      .buttonStyle(GradientBackgroundStyle())
      .alert(isPresented: $showGrantedAlert, content: {
        log.info("Presenting microphone access denied alert.")
        return Alert(title: Text("Warning"),
                     message: Text("Microphone access is denied, please enable through phone settings"),
                     dismissButton: .default(Text("Ok")))
      })
    }
    .modifier(AppBackgroundStyle())
    //
  }
  //
}

// only render this in debug mode
#if DEBUG
struct TestAudioPermissionDeniedView_Previews: PreviewProvider {
  static var previews: some View {
    AudioPermissionDeniedView()
      .environmentObject(debugAppStatusInstance)
      .environment(\.locale, .init(identifier: debugLocale))
  }
}
#endif
