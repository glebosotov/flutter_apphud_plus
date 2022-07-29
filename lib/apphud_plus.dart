import 'package:flutter/material.dart';

import 'apphud_plus_platform_interface.dart';

enum PurchaseResult {
  activeSubscription,
  activePurchase,
  error,
}

class ApphudPlus {
  Future<String?> getBackgroundNotificationRuleName() async {
    return ApphudPlusPlatform.instance.getBackgroundNotificationRuleName();
  }

  Future<void> addForegroundNotificationListener(
      ValueSetter<String> callback) async {
    return ApphudPlusPlatform.instance
        .addForegroundNotificationListener(callback);
  }

  Future<PurchaseResult> purchase(String productId) async {
    return ApphudPlusPlatform.instance.purchase(productId);
  }

  Future<bool> paywallsDidLoad() async {
    return ApphudPlusPlatform.instance.paywallsDidLoad();
  }

  Future<bool> hasProductWithId(String productId) async {
    return ApphudPlusPlatform.instance.hasProductWithId(productId);
  }
}
