import 'dart:async';

import 'package:apphud_plus/notification_model.dart';
import 'package:flutter/material.dart';

import 'apphud_plus_platform_interface.dart';
import 'listener.dart';

class PurchaseResult {
  final PurchaseResultType type;
  final String? error;

  PurchaseResult({
    required this.type,
    this.error,
  });

  @override
  String toString() {
    return 'PurchaseResult{type: $type, error: $error}';
  }
}

enum PurchaseResultType {
  activeSubscription,
  activePurchase,
  unknownError,
  skErrorUnknown,
  skErrorClientInvalid,
  skErrorPaymentCancelled,
  skErrorPaymentInvalid,
  skErrorPaymentNotAllowed,
  skErrorStoreProductNotAvailable,
  skErrorCloudServicePermissionDenied,
  skErrorCloudServiceNetworkConnectionFailed,
  skErrorCloudServiceRevoked,
  skErrorPrivacyAcknowledgementRequired,
  skErrorUnauthorizedRequestData,
  skErrorInvalidOfferIdentifier,
  skErrorInvalidOfferPrice,
  skErrorInvalidSignature,
  skErrorMissingOfferParams,
  skErrorIneligibleForOffer,
  skErrorOverlayCancelled,
  skErrorInvalidConfiguration,
  skErrorOverlayPresentedInBackGroundScene,
  skErrorOverlayTimeout,
  skErrorUnsupportedPlatform,
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
  /// Returns [PurchaseResult] with [PurchaseResultType.activeSubscription] if the user now has a subscription,
  /// [PurchaseResultType.activePurchase] if the user made a purchase,
  /// other [PurchaseResult] if the purchase failed for any reason (Run with Xcode
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

  /// Create your implementation of [ApphudPlusListener]
  /// and set it with [setListener].
  ///
  /// Currently, the only supported callback is [paywallsDidLoad].
  void setListener(ApphudPlusListener listener) {
    ApphudPlusPlatform.instance.setListener(listener);
  }

  /// Stream will get [true] when paywalls did load
  /// and [false] if an error occured.
  StreamController<bool> paywallsDidLoadStream() =>
      ApphudPlusPlatform.instance.paywallsDidLoadStream();

  /// Returns true if the user has an active subscription.
  Future<bool> hasActiveSubscription() async {
    return ApphudPlusPlatform.instance.hasActiveSubscription();
  }
}
