//
//  AppDelegate.swift
//  SettingsBundle
//
//  Created by Tam Nguyen M. on 3/25/19.
//  Copyright © 2019 Tam Nguyen M. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    static let shared: AppDelegate = {
        guard let shared = UIApplication.shared.delegate as? AppDelegate else {
            fatalError("Cannot cast `UIApplication.shared.delegate` to `AppDelegate`.")
        }
        return shared
    }()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.backgroundColor = .white
        window?.makeKeyAndVisible()

        SettingsManager.shared.configAppSetting()
        window?.rootViewController = WelcomeVC()
        return true
    }

    func restart() {
        SettingsManager.shared.configAppSetting()
        window?.rootViewController = WelcomeVC()
    }
}
