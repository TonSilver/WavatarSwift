//
//  AppDelegate.swift
//  WavatarSwift
//
//  Created by Anton Serebryakov on 09/29/2017.
//  Copyright (c) 2017 Anton Serebryakov. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        let window = UIWindow(frame: UIScreen.main.bounds)
        window.rootViewController = UINavigationController(rootViewController: ListVC())
        self.window = window
        window.makeKeyAndVisible()
        
        return true
    }
    
}

