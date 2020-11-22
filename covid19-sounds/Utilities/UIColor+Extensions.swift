//
//  UIColorExtensions.swift
//  covid19-sounds
//
//  Authors:
//
//    Andreas Grammenos
//
//  Copyright © 2020 Computer Lab / Mobile Systems Group. All rights reserved.
//

import Foundation
import UIKit

/// This is convenicene methods to convert hex to `UIColor` instances and vice-versa, it was adopted from
/// a gist by user pvroosendaal in github an was enhanced to remove deprecated methods in iOS 13.
///
extension UIColor {
  //
  convenience init(hexString: String) {
    let hexString = hexString.trimmingCharacters(in: .whitespacesAndNewlines)
    let scanner = Scanner(string: hexString)
    // check if we have a dash at start and skip that location -
    // i.e.: start from position 1 instead of 0
    if hexString.hasPrefix("#") {
      scanner.currentIndex = scanner.string.index(after: scanner.currentIndex)
    }
    //
    var color: UInt64 = 0
    scanner.scanHexInt64(&color)
    //
    let mask = 0x000000FF
    let redInt = Int(color >> 16) & mask
    let greenInt = Int(color >> 8) & mask
    let blueInt = Int(color) & mask
    //
    let red   = CGFloat(redInt) / 255.0
    let green = CGFloat(greenInt) / 255.0
    let blue  = CGFloat(blueInt) / 255.0
    //
    self.init(red: red, green: green, blue: blue, alpha: 1)
  }
  /// the hex string representation for the `UIColor` provided.
  var hexString: String {
    //
    var redFloat: CGFloat = 0
    var greenFloat: CGFloat = 0
    var blueFloat: CGFloat = 0
    var alphaFloat: CGFloat = 0
    //
    getRed(&redFloat, green: &greenFloat, blue: &blueFloat, alpha: &alphaFloat)
    //
    let rgb: Int = (Int)(redFloat * 255) << 16 | (Int)(greenFloat * 255) << 8 | (Int)(blueFloat * 255) << 0
    //
    return String(format: "#%06x", rgb)
  }
  /// This function takes an unsigned hex integer and extracts
  /// the RGBA values from it
  ///
  /// - Parameter rgbValue: the hex value that we have to convert to
  ///                       `UIColor`
  ///
  /// - Returns: a valid `UIColor` instance if the conversion is successful.
  ///
  func getUIcolorFromRBG(rgbValue: UInt) -> UIColor? {
    let red = CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0
    let green = CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0
    let blue = CGFloat((rgbValue & 0x0000FF)) / 255.0
    let alpha = CGFloat(1.0)
    return UIColor(red: red, green: green, blue: blue, alpha: alpha)
  }
  /// This function takes a string representation of a hex number containing
  /// RBGA color values and returns the corresponding `UIColor` for these
  /// values if the conversion is successful and `nil` otherwise.
  ///
  /// - Parameter str: the string containing the hex number
  ///
  /// - Returns: a valid `UIColor` instance if the conversion is successful.
  ///
  func getUIColorFromString(str: String) -> UIColor? {
    guard let hexFromStr = UInt(str, radix: 16) else {
      return nil
    }
    return getUIcolorFromRBG(rgbValue: hexFromStr)
  }
}
