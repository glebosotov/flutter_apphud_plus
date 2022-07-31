# apphud_plus

  

This package is an (iOS-only) alternative and a companion to [the official Apphud package](https://pub.dev/packages/apphud).

Features
- Listen for notifications in **foreground and background** (terminated app state)
	- get notification data either in String or custom class
- Purchase products by product ID
- Check that a product with certain ID exists
- Check that paywalls are loaded 
  

## Getting Started
### In `AppDelegate.swift`
import `ApphudSDK` and `apphud_plus`
Add the following lines in the `application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?)` method before the `return`
```swift
 Apphud.start(apiKey: "YOUR_API_KEY")
 registerForNotifications()
```

Add the following code below, customize it to your taste
```swift
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

```

Check out `example/lib/main.dart` for examples of Flutter code and make sure to read documentation of the methods in the `apphud_plus.dart`

#### You probably will not be able to make purchases using the example app, since it does not have bundle id, however, some functionality is available if you insert your API key in the `AppDelegate.swift`