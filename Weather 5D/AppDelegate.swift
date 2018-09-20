//
//  AppDelegate.swift
//  Weather 5D
//
//  Created by Aldo Bergamini on 19/09/2018.
//  Copyright © 2018 iBat Inc. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var appCoordinator: AppCoordinator?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        if let rootViewController = self.window?.rootViewController {
            
            self.appCoordinator = AppCoordinator(targetViewController: rootViewController)
            self.appCoordinator?.start()
            
            return true
        }
        
        return false
    }
}

