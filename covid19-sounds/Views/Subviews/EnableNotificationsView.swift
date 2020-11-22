//
//  EnableNotificationsView.swift
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

/// The enable nofication `View` which is showed at the end of the survey.
///
struct EnableNotificationsView: View {
  /// the `View` body definition.
  var body: some View {
    VStack {
      //
      TextViewFactory("Enable survey notifications?")
      //
      Spacer().frame(height: 20)
      //
      Button(action: {
        log.info("Trying to enable notifications")
        // attempt to register the notification observer
        notificationManager.registerNotificationObserver(register: true)
        // Check notification settings
        notificationManager.checkNotificationSettings()
      }, label: {
        Text("Enable")
          .font(.custom("Next", size: 23))
      })
      .buttonStyle(GradientBackgroundStyle(minWidth: 150))
      //
    }
  }
}

// only render this in debug mode
#if DEBUG
struct EnableNotificationsView_Previews: PreviewProvider {
  static var previews: some View {
    EnableNotificationsView()
      .environment(\.locale, .init(identifier: debugLocale))
  }
}
#endif
