//
//  UINavigationController-Ext.swift
//  FoodPin
//
//  Created by Elias Myronidis on 26/6/18.
//  Copyright © 2018 Elias Myronidis. All rights reserved.
//

import UIKit

extension UINavigationController {
    
    // Which view controller to use for determining status bar style.
    open override var childViewControllerForStatusBarStyle: UIViewController? {
        return topViewController
    }
}
