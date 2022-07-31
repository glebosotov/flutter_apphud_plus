import 'package:apphud_plus/notification_model.dart';
import 'package:flutter/material.dart';

import 'apphud_plus_platform_interface.dart';

enum PurchaseResult {
  activeSubscription,
  activePurchase,
  error,
}

class ApphudPlus {
  /// Checks if anynotifications were processed by Apphud in the background
  /// state and returns data in [ApphudNotificationPayload].
  ///
  /// Make sure to add `SwiftApphudPlusPlugin.handleBackgroundNotifications` to
  /// AppDelegate.swift (check README)
  Future<ApphudNotificationPayload?> getBackgroundNotificationData() async {
    return ApphudPlusPlatform.instance.getBackgroundNotificationPayload();
  }

  /// Checks if anynotifications were processed by Apphud in the background
  /// state and returns data in [String].
  ///
  /// Make sure to add `SwiftApphudPlusPlugin.handleBackgroundNotifications` to
  /// AppDelegate.swift (check README)
  Future<String?> getBackgroundNotificationString() async {
    return ApphudPlusPlatform.instance.getBackgroundNotificationPayloadRaw();
  }

  /// Registers a callback function for foreground notifications processed by Apphud
  /// The callback will have [String] data.
  ///
  /// Make sure to add `SwiftApphudPlusPlugin.handleForegroundNotifications` to
  /// AppDelegate.swift (check README)
  Future<void> addForegroundNotificationListenerRaw(
      ValueSetter<String> callback) async {
    return ApphudPlusPlatform.instance
        .addForegroundNotificationListener(callback);
  }

  /// Registers a callback function for foreground notifications processed by Apphud
  /// The callback will have [ApphudNotificationPayload] data.
  ///
  /// Make sure to add `SwiftApphudPlusPlugin.handleForegroundNotifications` to
  /// AppDelegate.swift (check README)
  Future<void> addForegroundNotificationListener(
      ValueSetter<ApphudNotificationPayload> callback) async {
    return ApphudPlusPlatform.instance
        .addForegroundNotificationListenerRaw(callback);
  }

  /// Initiates purchase of a product.
  ///
  /// Returns [PurchaseResult] with [PurchaseResult.activeSubscription] if the user now has a subscription,
  /// [PurchaseResult.activePurchase] if the user made a purchase,
  /// [PurchaseResult.error] if the purchase failed for any reason (Run with Xcode
  /// for more datails).
  Future<PurchaseResult> purchase(String productId) async {
    return ApphudPlusPlatform.instance.purchase(productId);
  }

  /// Returns true if [SKProduct]s are loaded from AppStore.
  Future<bool> paywallsDidLoad() async {
    return ApphudPlusPlatform.instance.paywallsDidLoad();
  }

  /// Returns true if the product with [productId] is available in Apphud products.
  Future<bool> hasProductWithId(String productId) async {
    return ApphudPlusPlatform.instance.hasProductWithId(productId);
  }
}
