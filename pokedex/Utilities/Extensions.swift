//
//  Extensions.swift
//  pokedex
//
//  Created by Howard Chang on 9/10/19.
//  Copyright © 2019 Howard Chang. All rights reserved.
//

import UIKit

extension UIColor {
    static func rgb(red: CGFloat, green: CGFloat, blue: CGFloat) -> UIColor {
        return UIColor(red: red/255, green: green/255, blue: blue/255, alpha: 1)
    }
    
    static func mainColor() -> UIColor {
        return UIColor.rgb(red: 255, green: 88, blue: 85)
    }
}
