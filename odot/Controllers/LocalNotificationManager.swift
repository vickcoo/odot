//
//  LocalNotificationManager.swift
//  odot
//
//  Created by vick on 2023/11/3.
//

import Foundation
import UIKit
import UserNotifications
import OSLog

struct LocalNotificationManager {
    
    /// Show a alert to direct to notification settings
    /// - Parameter viewController: Which controller would you want to use
    static func openNotificationSettings(viewController: UIViewController) {
        let title = String(localized: "Open Notification")
        let message = String(localized: "Allow Odot to send reminder notification, under Odot in your settings.")
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: String(localized: "Cancel"), style: .cancel))
        alertController.addAction(UIAlertAction(title: String(localized: "Settings"), style: .default, handler: { action in
            if let url = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(url)
            }
        }))
        
        viewController.present(alertController, animated: true)
    }
    
    /// Request autherization of notification
    static func autherizeLocalNotification() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            guard error == nil else {
                let logger = Logger()
                logger.error("\(error!.localizedDescription)")
                return
            }
        }
    }
    
    /// Get authorization of notification status
    /// - Parameter status: Closure
    static func authorizationStatus(completed: @escaping (UNAuthorizationStatus) -> ()) {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            completed(settings.authorizationStatus)
        }
    }
    
    /// Send a request for notification by calendar trigger
    /// - Parameters:
    ///   - title: The localized text that provides the notification’s primary description.
    ///   - subtitle: The localized text that provides the notification’s secondary description.
    ///   - body: The localized text that provides the notification’s main content.
    ///   - badgeNumber: The number that your app’s icon displays.
    ///   - sound: The sound that plays when the system delivers the notification.
    ///   - date: The date that you want to notifiy
    /// - Returns: The notification id
    static func setCalendarNotification(title: String, subtitle: String, body: String, badgeNumber: NSNumber?, sound: UNNotificationSound, date: Date) -> String {
        let content = UNMutableNotificationContent()
        content.title = title
        content.subtitle = subtitle
        content.body = body
        content.badge = badgeNumber
        content.sound = sound
        
        var dateComponent = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: date)
        dateComponent.second = 0
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponent, repeats: false)
        
        let notificationID = UUID().uuidString
        let request = UNNotificationRequest(identifier: notificationID, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            let logger = Logger()
            if let error = error {
                logger.error("\(error.localizedDescription)")
            } else {
                logger.log("Notification scheduled \(notificationID), title: \(title)")
            }
        }
        
        return notificationID
    }
}
