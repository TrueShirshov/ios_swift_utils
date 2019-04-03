//
//  AppDelegate.swift
//
//  Created by Vladimir Benkevich on 27/07/2018.
//  Copyright © 2018
//

import UIKit
import JetLib

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {

        UIViewController.swizzleViewAppearances()

        return true
    }
}

