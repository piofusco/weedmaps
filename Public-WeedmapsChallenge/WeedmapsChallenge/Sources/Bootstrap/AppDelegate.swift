//
//  Copyright © 2018 Weedmaps, LLC. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        let homeViewController = HomeViewController()
        let navigationController = UINavigationController(rootViewController: homeViewController)
        let window = UIWindow()
        window.rootViewController = navigationController
        self.window = window
        self.window?.makeKeyAndVisible()

        return true
    }
}

