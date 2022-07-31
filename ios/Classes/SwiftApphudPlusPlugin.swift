import Flutter
import UIKit
import ApphudSDK
import SwiftKeychainWrapper
import os

public class SwiftApphudPlusPlugin: NSObject, FlutterPlugin {
    static let backgroundNotificationInfoKey: String = "apphud_plus_backgroundNotificationInfo"
    static let notificationName: String = "apphud_plus_foregroundNotification"
    
    var paywallsDidLoad = false
    
    static var observer: NSObjectProtocol?
    var channel: FlutterMethodChannel?
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "apphud_plus", binaryMessenger: registrar.messenger())
        observer = nil
        let instance = SwiftApphudPlusPlugin()
        instance.channel = channel
        /// Set local variable once the paywalls are loaded
        paywallsDidLoadCallback {
            instance.paywallsDidLoad = true
        }
        registrar.addMethodCallDelegate(instance, channel: channel)
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        
        switch call.method {
        case "pawallsLoaded":
            result(self.paywallsDidLoad)
            return
        case "hasProductWithId":
            guard let arg = call.arguments as? String else {
                return
            }
            findProductByID(productID: arg, completion: {
                product in
                result(product != nil)
            })
        case "purchaseProductWithId":
            guard let arg = call.arguments as? String else {
                return }
            findProductByID(productID: arg, completion: { product in
                if let product = product {
                    Apphud.purchase(product, callback: {
                        purchaseResult in
                        if let subscription = purchaseResult.subscription, subscription.isActive() {
                            result("activeSubscription")
                        } else if let purchase = purchaseResult.nonRenewingPurchase, purchase.isActive() {
                            result("activePurchase")
                        } else {
                            result(purchaseResult.error?.localizedDescription)
                        }
                    })
                }
            })
        case "listenForNotifications":
            if SwiftApphudPlusPlugin.observer != nil {
                NotificationCenter.default.removeObserver(SwiftApphudPlusPlugin.observer!)
                SwiftApphudPlusPlugin.observer = nil
            }
            
            SwiftApphudPlusPlugin.observer = NotificationCenter.default.addObserver(forName: NSNotification.Name(SwiftApphudPlusPlugin.notificationName), object: nil, queue: OperationQueue.main) {
                notification in
                if let channel = self.channel {
                    guard let notificationPayload = notification.userInfo,
                          let jsonData = try? JSONSerialization.data(withJSONObject: notificationPayload, options: []),
                          let jsonString = String(data: jsonData, encoding: String.Encoding.utf8) else { return }
                    
                    channel.invokeMethod("onNotification", arguments: jsonString)
                }
            }
            result(true)
            
        case "checkBackgroundNotification":
            let notificationPayload = KeychainWrapper.standard.string(forKey: SwiftApphudPlusPlugin.backgroundNotificationInfoKey)
            KeychainWrapper.standard.remove(forKey: KeychainWrapper.Key(rawValue: SwiftApphudPlusPlugin.backgroundNotificationInfoKey))
            result(notificationPayload)
        default:
            return
        }
    }
    
    public static func handleBackgroundNotifications(_ apsInfo: [AnyHashable: Any]) {
        
        guard let jsonData = try? JSONSerialization.data(withJSONObject: apsInfo, options: []),
              let jsonString = String(data: jsonData, encoding: String.Encoding.utf8) else { return }
        
        KeychainWrapper.standard.set(jsonString, forKey: backgroundNotificationInfoKey)
        
    }
    
    public static func handleForegroundNotifications(_ apsInfo: [AnyHashable: Any]) {
            NotificationCenter.default.post(name: NSNotification.Name(notificationName), object: nil, userInfo: apsInfo)
    }
    
    deinit {
        KeychainWrapper.standard.remove(forKey: KeychainWrapper.Key(rawValue: SwiftApphudPlusPlugin.backgroundNotificationInfoKey))
        if #available(iOS 14, *) {
            Logger(subsystem: "com.glebosotov.apphud_plus", category: "SwiftApphudPlusPlugin.swift").info("Removing notification info from last terminated state")
        }
    }
}


fileprivate func findProductByID(productID: String,  completion: @escaping (ApphudProduct?)->Void) {
    
    Apphud.paywallsDidLoadCallback({
        paywalls in
        let paywallWithProduct = paywalls.first(where: { $0.products.contains(where: { $0.productId == productID })})
        if paywallWithProduct == nil {
            completion(nil)
        } else {
            let product = paywallWithProduct?.products.first(where: { $0.productId == productID })
            completion(product)
        }
    })
}

fileprivate func paywallsDidLoadCallback(completion: @escaping ()->Void) {
    Apphud.paywallsDidLoadCallback({ _ in
        completion()
    })
}



