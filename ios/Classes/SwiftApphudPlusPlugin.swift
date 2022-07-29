import Flutter
import UIKit
import ApphudSDK
import SwiftKeychainWrapper

public class SwiftApphudPlusPlugin: NSObject, FlutterPlugin {
    static let backgroundNotificationRuleNameKey: String = "apphud_plus_backgroundNotificationRuleName"
    
    static let notificationName: String = "apphud_plus_foregroundNotification"
    
    var paywallsDidLoad = false
    
    static var observer: NSObjectProtocol?
    var channel: FlutterMethodChannel?
    
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "apphud_plus", binaryMessenger: registrar.messenger())
        observer = nil
        let instance = SwiftApphudPlusPlugin()
        instance.channel = channel
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
            guard let arg = call.arguments as? [String], arg.count == 1 else {
                return
            }
            findProductByID(productID: arg.first!, completion: {
                product in
                result(product != nil)
            })
        case "purchaseProductWithId":
            guard let arg = call.arguments as? [String], arg.count == 1 else {
                return }
            findProductByID(productID: arg.first!, completion: { product in
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
                    channel.invokeMethod("onNotification", arguments: [notification.userInfo!["rule_name"]])
                }
                result("Callback invoked")
            }
            result("Initialized")
            
        case "checkBackgroundNotification":
            let ruleName = KeychainWrapper.standard.string(forKey: SwiftApphudPlusPlugin.backgroundNotificationRuleNameKey)
            KeychainWrapper.standard.remove(forKey: KeychainWrapper.Key(rawValue: SwiftApphudPlusPlugin.backgroundNotificationRuleNameKey))
            result(ruleName)
        default:
            return
        }
    }
    
    public static func handleBackgroundNotifications(_ apsInfo: [AnyHashable: Any]) {
        if let ruleName = apsInfo["rule_name"] as? String {
            KeychainWrapper.standard.set(ruleName, forKey: backgroundNotificationRuleNameKey)
        }
    }
    
    public static func handleForegroundNotifications(_ apsInfo: [AnyHashable: Any]) {
        if let ruleName = apsInfo["rule_name"] as? String {
            NotificationCenter.default.post(name: NSNotification.Name(notificationName), object: nil, userInfo: ["rule_name": ruleName])
        }
    }
    
    deinit {
        KeychainWrapper.standard.remove(forKey: KeychainWrapper.Key(rawValue: SwiftApphudPlusPlugin.backgroundNotificationRuleNameKey))
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



