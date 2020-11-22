//
//  DateFormatter+Extensions.swift
//  covid19-sounds
//
//  Authors:
//
//    Andreas Grammenos
//
//  Copyright © 2020 Computer Lab / Mobile Systems Group. All rights reserved.
//

import Foundation

/// Useful extensios in the `DateFormatter` class
///
extension DateFormatter {
  /// This is a convenience constructor used to initialise the `dateFormat` with the desired date format
  ///
  /// - Parameter `dateFormat`: the `DateFormatter` compatible format as a `String` to use.
  ///
  convenience init(dateFormat: String) {
    self.init()
    self.dateFormat = dateFormat
  }
}
