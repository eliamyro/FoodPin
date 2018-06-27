//
//  UIColor-Ext.swift
//  FoodPin
//
//  Created by Elias Myronidis on 26/6/18.
//  Copyright © 2018 Elias Myronidis. All rights reserved.
//

import UIKit

extension UIColor {
    convenience init(red: Int, green: Int, blue: Int) {
        let redValue = CGFloat(red) / 255.0
        let greenValue = CGFloat(green) / 255
        let blueValue = CGFloat(blue) / 255
        self.init(red: redValue, green: greenValue, blue: blueValue, alpha: 1.0)
    }
}
