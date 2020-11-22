//
//  EndViewTopTextView.swift
//  covid19-sounds
//
//  Authors:
//
//    Andreas Grammenos
//
//  Copyright © 2020 Computer Lab / Mobile Systems Group. All rights reserved.
//

import Foundation
import SwiftUI

/// The view containing the top part of the end view, which contains the regards, the completed text, as well as the
/// notification view. The notification view is used to dynamically display the according logic depending on user
/// choice regarding the installation of notifications.
///
struct EndViewTopTextView: View {
  // the observable object for notification manager used to update
  // the text according to user selection.
  @ObservedObject private var notifications = notificationManager
  //
  /// the `View` body definition.
  var body: some View {
    VStack {
      //
      Spacer().frame(height: 30)
      //
      TextViewFactory("Thank you!", size: 30, padding: [.vertical, .horizontal])
      //
      Spacer().frame(height: 20)
      //
      TextViewFactory("completedReportText", padding: [.vertical, .horizontal])
      //
      Spacer().frame(height: 40)
      //
      if notifications.notificationAuthorisation == .authorized {
        TextViewFactory("notificationScheduledText", padding: [.vertical, .horizontal])
      } else if notifications.notificationAuthorisation == .denied {
        TextViewFactory("disabledNotificationText")
      } else {
        EnableNotificationsView()
      }
      //
    }
    .frame(minWidth: 0,
           maxWidth: .infinity,
           minHeight: 0,
           maxHeight: .infinity,
           alignment: .center)
  }
}

// only render this in debug mode
#if DEBUG
struct EndViewTopTextView_Previews: PreviewProvider {
  static var previews: some View {
    EndViewTopTextView()
  }
}
#endif
