import UIKit
import Flutter
import ApphudSDK
import apphud_plus

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        GeneratedPluginRegistrant.register(with: self)
        Apphud.start(apiKey: "YOUR_API_KEY")
        /// Ask for notification permission and listen for remote notifications
        registerForNotifications()
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
}

extension AppDelegate {
    
    func registerForNotifications() {
        UNUserNotificationCenter.current().delegate = self
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound])    { (granted, error) in
            // handle if needed
        }
        UIApplication.shared.registerForRemoteNotifications()
    }
    
    /// Send device information to Apphud
    override func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Apphud.submitPushNotificationsToken(token: deviceToken, callback: nil)
    }
    
    /// Handle registration errors
    override func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
    }
    
    /// Background notifications
    override func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        if Apphud.handlePushNotification(apsInfo: response.notification.request.content.userInfo) {
            SwiftApphudPlusPlugin.handleBackgroundNotifications(response.notification.request.content.userInfo)
        } else {
            // Handle other types of push notifications
        }
        completionHandler()
    }
    
    /// Foreground notificationa
    override func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        if Apphud.handlePushNotification(apsInfo: notification.request.content.userInfo) {
            SwiftApphudPlusPlugin.handleForegroundNotifications(notification.request.content.userInfo)
        } else {
            // Handle other types of push notifications
        }
        completionHandler([]) // return empty array to skip showing notification banner
    }
}
