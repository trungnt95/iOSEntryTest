//
//  AppDelegate.swift
//  gapo_entry_test
//
//  Created by Trung Nguyen on 14/06/2022.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        let window = UIWindow(frame: UIScreen.main.bounds)
        let navVC = UINavigationController()
        
        if let notificationViewController: NotificationListViewController = AllBoards.main.storyboard.instantiate() {
            navVC.setViewControllers([notificationViewController], animated: false)
        }
        
        self.window = window
        
        window.rootViewController = navVC
        window.makeKeyAndVisible()
        
        return true
    }

}

