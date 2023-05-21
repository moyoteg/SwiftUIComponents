//
//  ImageExtensions.swift
//  SwiftUIComponents
//
//  Created by Moi Gutierrez on 2/8/20.
//

import Foundation
import SwiftUI

import CloudyLogs

public extension Image {

    static func getSafeImage(named: String) -> SwiftUI.Image {
        
        if let uiImage = UIImage(named: named) {
            return SwiftUI.Image(uiImage: uiImage)
        } else {
            return SwiftUI.Image("circle.slash")
        }
    }
}

public extension UIImageView {
  func setImageColor(color: UIColor) {
    let templateImage = self.image?.withRenderingMode(.alwaysTemplate)
    self.image = templateImage
    self.tintColor = color
  }
}
