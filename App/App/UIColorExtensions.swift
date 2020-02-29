//
//  UIColorExtensions.swift
//  App
//
//  Created by r.gladkikh on 29.02.2020.
//  Copyright © 2020 r.gladkikh. All rights reserved.
//

import Foundation
import UIKit

extension UIColor {
    static func fromRGBA(red r: Int, green g: Int, blue b: Int, alpha a: Int = 255) -> UIColor {
        return UIColor(red: CGFloat(r) / 255.0,
                       green: CGFloat(g) / 255.0,
                       blue: CGFloat(b) / 255.0,
                       alpha: CGFloat(a) / 255)
    }
}
