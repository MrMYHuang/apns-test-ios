//
//  AppDelegate.swift
//  test
//
//  Created by 黃孟遠 on 2022/8/29.
//

import UIKit
import Combine
import UserNotifications

@main
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    // Modify to your provider server.
    let apnsProviderRegDeviceUrl = "http://192.168.0.201:3000/regDevice"

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        let authOptions = UNAuthorizationOptions.init(arrayLiteral: .alert, .badge, .sound)
        UNUserNotificationCenter.current().requestAuthorization(options: authOptions) { (success, error) in
            if let error = error {
                print("Error: ", error)
                return
            }
            DispatchQueue.main.async {
                UNUserNotificationCenter.current().delegate = self
                UIApplication.shared.registerForRemoteNotifications()
            }
        }
        return true
    }
    
    var store = Set<AnyCancellable>()
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        var req = URLRequest(url: URL(string: apnsProviderRegDeviceUrl)!)
        req.httpMethod = "POST"
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let deviceTokenHex = deviceToken.reduce("", {$0 + String(format: "%02x", $1)})
        debugPrint(deviceTokenHex)
        req.httpBody = try! JSONSerialization.data(withJSONObject: [
            "deviceToken": deviceTokenHex
        ])
        URLSession.shared.dataTaskPublisher(for: req).sink(receiveCompletion: { done in
            debugPrint("Complete")
        }, receiveValue: { (data, res) in
            debugPrint("Done")
        }).store(in: &store)
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        debugPrint(error)
    }
    
    // Allow push notification when app is in foreground.
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.sound, .banner])
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }

}

