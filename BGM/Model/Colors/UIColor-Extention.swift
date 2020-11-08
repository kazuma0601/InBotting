//
//  UIColor-Extention.swift
//  BGM
//
//  Created by 岩崎一真 on 2020/10/06.
//

import UIKit

extension UIColor {
    
    static func rgb(red: CGFloat, green: CGFloat, blue: CGFloat) -> UIColor {
        return self.init(red: red / 255, green: green / 255, blue: blue / 255, alpha: 1)
    }
}
