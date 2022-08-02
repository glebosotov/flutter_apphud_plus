import 'dart:async';
import 'dart:convert';

import 'package:apphud_plus/notification_model.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '/apphud_plus.dart';
import 'apphud_plus_platform_interface.dart';
import 'listener.dart';

/// An implementation of [ApphudPlusPlatform] that uses method channels.
class MethodChannelApphudPlus extends ApphudPlusPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('apphud_plus');

  final List<ValueSetter<String>> _callbacksRaw = <ValueSetter<String>>[];
  final List<ValueSetter<ApphudNotificationPayload>> _callbacksModel =
      <ValueSetter<ApphudNotificationPayload>>[];

  ApphudPlusListener? _listener;
  late final StreamController<bool> _streamController;

  MethodChannelApphudPlus() {
    methodChannel.setMethodCallHandler(_handleMethod);
    _streamController = StreamController<bool>.broadcast(
        onListen: () async =>
            _streamController.sink.add(await paywallsDidLoad()));
  }

  @override
  Future<ApphudNotificationPayload?> getBackgroundNotificationPayload() async {
    final result =
        await methodChannel.invokeMethod<String>('checkBackgroundNotification');
    if (result == null) {
      return null;
    }
    return ApphudNotificationPayload.fromJson(json.decode(result));
  }

  @override
  Future<String?> getBackgroundNotificationPayloadRaw() async {
    final result =
        await methodChannel.invokeMethod<String>('checkBackgroundNotification');
    return result;
  }

  @override
  Future<void> addForegroundNotificationListener(
      ValueSetter<String> callback) async {
    _callbacksRaw.add((p0) => callback);
  }

  @override
  Future<void> addForegroundNotificationListenerRaw(
      ValueSetter<ApphudNotificationPayload> callback) async {
    _callbacksModel.add((p0) => callback);
  }

  @override
  Future<PurchaseResult> purchase(String productId) async {
    final result = await methodChannel.invokeMethod<String>(
        'purchaseProductWithId', productId);
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
    final result = await methodChannel.invokeMethod<bool>('pawallsLoaded');
    if (result == null) {
      throw Exception('paywallsDidLoad returned null');
    }
    return result;
  }

  @override
  Future<bool> hasProductWithId(String productId) async {
    final result =
        await methodChannel.invokeMethod<bool>('hasProductWithId', productId);
    if (result == null) {
      throw Exception('hasProductWithId returned null');
    }
    return result;
  }

  @override
  void setListener(ApphudPlusListener listener) {
    _listener = listener;
    Future.value(() async {
      final stateOfPaywalls = await paywallsDidLoad();
      if (stateOfPaywalls) {
        listener.paywallsDidLoadCallback(stateOfPaywalls);
      }
    });
  }

  @override
  StreamController<bool> paywallsDidLoadStream() {
    Future.value(() async => _streamController.add(await paywallsDidLoad()));
    return _streamController;
  }

  @override
  Future<bool> hasActiveSubscription() async {
    return await methodChannel.invokeMethod<bool>('hasSubscription') ?? false;
  }

  /// Calls every method in [_callbacksRaw]
  Future<dynamic> _handleMethod(MethodCall call) async {
    switch (call.method) {
      case 'onNotification':
        final String notificationData = call.arguments;

        for (var callback in _callbacksRaw) {
          callback(notificationData);
        }
        for (var callback in _callbacksModel) {
          try {
            callback(ApphudNotificationPayload.fromJson(
                jsonDecode(notificationData)));
          } catch (e) {
            rethrow;
          }
        }
        break;
      case 'paywallsDidLoadStream':
        _listener?.paywallsDidLoadCallback(call.arguments == true);
        _streamController.add(call.arguments == true);
        break;

      default:
        throw ('Undefined method ${call.method}');
    }
  }
}
