//
//  CommonUtils.swift
//  Runner
//
//  Created by Ruijie Li on 24/7/2024.
//

import Foundation
import SwiftUI

@available(iOS 13.0, *)
func hexStringToColor(hex: String) -> Color {
  var cString: String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()

  if (cString.hasPrefix("#")) {
    cString.remove(at: cString.startIndex)
  }

  if ((cString.count) != 6) {
    return Color.gray
  }

  var rgbValue: UInt64 = 0
  Scanner(string: cString).scanHexInt64(&rgbValue)

  return Color(
    red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
    green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
    blue: CGFloat(rgbValue & 0x0000FF) / 255.0
  )
}
