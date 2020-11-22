//
//  String+Extensions.swift
//  covid19-sounds
//
//  Authors:
//
//    Andreas Grammenos
//
//  Copyright © 2020 Computer Lab / Mobile Systems Group. All rights reserved.
//

import Foundation

/// Necessary or convenient string extensions
///
extension String {
  /// This function returns an `NSLocalizedString` from `String` as this is
  /// not natively supported as of yet.
  ///
  /// This is as per:  https://stackoverflow.com/q/25081757
  ///
  /// - Parameter `withComment`: a comment that can be used for the translator.
  ///
  /// - Returns: `NSLocalizedString` from the `self` `String` instance.
  ///
  func localized(withComment comment: String? = nil) -> String {
    return NSLocalizedString(self, comment: comment ?? "")
  }
}
