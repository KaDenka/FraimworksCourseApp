//
//  AppDelegate.swift
//  FrameworksCourseApp
//
//  Created by Denis Kazarin on 10.03.2022.
//

import UIKit
import GoogleMaps
import RealmSwift
import SwiftUI
import UserNotifications

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        GMSServices.provideAPIKey("AIzaSyB2qMiCgbUGU_LIiAS7tjltBn3_FoIFJsc")
        
        let config = Realm.Configuration(
            schemaVersion: 6,  migrationBlock: { migration, oldSchemaVersion in
                if (oldSchemaVersion < 1) {}
            })
        Realm.Configuration.defaultConfiguration = config
        
        //MARK: -- Local Notification
        
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            guard granted else { return }
            self.sendNotificationRequest(content: self.makeNotificationContent(), trigger: self.makeIntervalNotificationTrigger())
            
        }
        
        return true
    }
    
    //MARK: Notifications Funcs
    
    func makeNotificationContent() -> UNNotificationContent {
        
        let content = UNMutableNotificationContent()
        content.title = "Don't forget about Your App"
        content.subtitle = "Need to enter to Your App"
        content.body = "It's time to make some routes!"
        content.badge = 1
        
        return content
    }
    
    func makeIntervalNotificationTrigger() -> UNNotificationTrigger {
        
        return UNTimeIntervalNotificationTrigger(timeInterval: 70, repeats: true)
    }
    
    func sendNotificationRequest(content: UNNotificationContent, trigger: UNNotificationTrigger) {
        
        let request = UNNotificationRequest(identifier: "appAlarm", content: content, trigger: trigger)
        let center = UNUserNotificationCenter.current()
        center.add(request) { error in
            if let error = error {
                print(error.localizedDescription)
            }
        }
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

