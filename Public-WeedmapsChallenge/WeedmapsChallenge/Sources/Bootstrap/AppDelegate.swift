//
//  Copyright © 2018 Weedmaps, LLC. All rights reserved.
//

import UIKit
import CoreLocation

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
        let yellowPagesAPI = YelpAPI(urlSession: URLSession.shared, decoder: JSONDecoder())
        let searchViewModel = SearchViewModel(api: yellowPagesAPI)
        locationManager.delegate = searchViewModel
        locationManager.requestWhenInUseAuthorization()
        locationManager.startMonitoringSignificantLocationChanges() // need to eventually stop tracking this

        let homeViewController = HomeViewController(viewModel: searchViewModel)
        searchViewModel.delegate = homeViewController
        let navigationController = UINavigationController(rootViewController: homeViewController)
        let window = UIWindow()
        window.rootViewController = navigationController
        self.window = window
        self.window?.makeKeyAndVisible()

        return true
    }
}

