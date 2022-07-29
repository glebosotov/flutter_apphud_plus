import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '/apphud_plus.dart';
import 'apphud_plus_platform_interface.dart';

/// An implementation of [ApphudPlusPlatform] that uses method channels.
class MethodChannelApphudPlus extends ApphudPlusPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('apphud_plus');

  final List<ValueSetter<String>> _callbacks = <ValueSetter<String>>[];

  MethodChannelApphudPlus() {
    methodChannel.setMethodCallHandler(_handleMethod);
  }

  @override
  Future<String?> getBackgroundNotificationRuleName() async {
    final result =
        await methodChannel.invokeMethod('checkBackgroundNotification');
    return result;
  }

  @override
  Future<void> addForegroundNotificationListener(
      ValueSetter<String> callback) async {
    _callbacks.add((p0) => callback);
  }

  @override
  Future<PurchaseResult> purchase(String productId) async {
    final result =
        await methodChannel.invokeMethod('purchaseProductWithId', [productId]);
    switch (result) {
      case 'activeSubscription':
        return PurchaseResult.activeSubscription;
      case 'activePurchase':
        return PurchaseResult.activePurchase;
      default:
        return PurchaseResult.error;
    }
  }

  @override
  Future<bool> paywallsDidLoad() async {
    final result = await methodChannel.invokeMethod('pawallsLoaded');
    return result;
  }

  @override
  Future<bool> hasProductWithId(String productId) async {
    final result = await methodChannel.invokeMethod('hasProductWithId');
    return result;
  }

  /// Calls every method in [_callbacks]
  Future<dynamic> _handleMethod(MethodCall call) async {
    switch (call.method) {
      case 'onNotification':
        final String ruleName = call.arguments.first;
        for (var callback in _callbacks) {
          callback(ruleName);
        }
        break;

      default:
        throw ('Undefined method ${call.method}');
    }
  }
}
