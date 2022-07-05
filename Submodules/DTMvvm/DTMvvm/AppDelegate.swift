//
//  AppDelegate.swift
//  DTMvvm
//
//  Created by apolo2 on 7/21/21.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        DependencyManager.shared.registerDefaults()
        
        window = UIWindow(frame: UIScreen.main.bounds)
        
        let page = ExampleMenuPage(viewModel: HomeMenuPageViewModel())
        let rootPage = NavigationPage(rootViewController: page)
        rootPage.statusBarStyle = .default
        window?.rootViewController = rootPage
        window?.makeKeyAndVisible()
        
        return true
    }

}

