//
//  AppDelegate.swift
//  gapo_entry_test
//
//  Created by Trung Nguyen on 14/06/2022.
//

import UIKit
import DTMvvm

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        let dependencyManager = DependencyManager.shared
        dependencyManager.registerDefaults()
        
        let window = UIWindow(frame: UIScreen.main.bounds)
        let navVC = UINavigationController()
        
//        if let notificationViewController: NotificationListViewController = AllBoards.main.storyboard.instantiate() {
//            navVC.setViewControllers([notificationViewController], animated: false)
//        }
        
        let vc = NewNotificationListVC(viewModel: NewNotificationListVM(model: nil))
        navVC.setViewControllers([vc], animated: false)
        
        
        self.window = window
        
        window.rootViewController = navVC
        window.makeKeyAndVisible()
        
        return true
    }

}

