//
//  Copyright © 2018 Weedmaps, LLC. All rights reserved.
//

import UIKit
import CoreLocation
import Foundation

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    private lazy var locationManager: CLLocationManager = {
        let locationManger = CLLocationManager()
        locationManger.desiredAccuracy = kCLLocationAccuracyThreeKilometers
        locationManger.pausesLocationUpdatesAutomatically = true
        locationManger.activityType = .otherNavigation
        return locationManger
    }()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        let decoder = JSONDecoder()
        let fileManager = FileManager.default
        let searchCache = WeedmapsSearchCache(fileManager: fileManager)
        let yellowPagesAPI = YelpAPI(urlSession: URLSession.shared, decoder: decoder)
        let searchViewModel = SearchViewModel(api: yellowPagesAPI, searchCache: searchCache)
        locationManager.delegate = searchViewModel
        locationManager.requestWhenInUseAuthorization()
        locationManager.startMonitoringSignificantLocationChanges() // need to eventually stop tracking this

        let homeViewController = HomeViewController(viewModel: searchViewModel, mainQueue: WeedmapsMainQueue())
        searchViewModel.delegate = homeViewController
        let navigationController = UINavigationController(rootViewController: homeViewController)
        let window = UIWindow()
        window.rootViewController = navigationController
        self.window = window
        self.window?.makeKeyAndVisible()

        return true
    }
}

