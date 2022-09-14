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
        return PurchaseResult(type: PurchaseResultType.activeSubscription);
      case 'activePurchase':
        return PurchaseResult(type: PurchaseResultType.activePurchase);
      default:
        if (result == null) {
          return PurchaseResult(type: PurchaseResultType.unknownError);
        }
        final regExp = RegExp('SKErrorDomain error [0-9]+');
        if (result.contains(regExp)) {
          final errorCodeString = regExp.firstMatch(result)![0];
          if (errorCodeString == null) {
            return PurchaseResult(type: PurchaseResultType.unknownError);
          }
          final errorCode = int.parse(errorCodeString.split(' ')[2]);
          switch (errorCode) {
            case 0:
              return PurchaseResult(
                  type: PurchaseResultType.skErrorUnknown, error: result);
            case 1:
              return PurchaseResult(
                  type: PurchaseResultType.skErrorClientInvalid, error: result);
            case 2:
              return PurchaseResult(
                  type: PurchaseResultType.skErrorPaymentCancelled,
                  error: result);
            case 3:
              return PurchaseResult(
                  type: PurchaseResultType.skErrorPaymentInvalid,
                  error: result);
            case 4:
              return PurchaseResult(
                  type: PurchaseResultType.skErrorPaymentNotAllowed,
                  error: result);
            case 5:
              return PurchaseResult(
                  type: PurchaseResultType.skErrorStoreProductNotAvailable,
                  error: result);
            case 6:
              return PurchaseResult(
                  type: PurchaseResultType.skErrorCloudServicePermissionDenied,
                  error: result);
            case 7:
              return PurchaseResult(
                  type: PurchaseResultType
                      .skErrorCloudServiceNetworkConnectionFailed,
                  error: result);
            case 8:
              return PurchaseResult(
                  type: PurchaseResultType.skErrorCloudServiceRevoked,
                  error: result);
            case 9:
              return PurchaseResult(
                  type:
                      PurchaseResultType.skErrorPrivacyAcknowledgementRequired,
                  error: result);
            case 10:
              return PurchaseResult(
                  type: PurchaseResultType.skErrorUnauthorizedRequestData,
                  error: result);
            case 11:
              return PurchaseResult(
                  type: PurchaseResultType.skErrorInvalidOfferIdentifier,
                  error: result);
            case 12:
              return PurchaseResult(
                  type: PurchaseResultType.skErrorInvalidOfferPrice,
                  error: result);
            case 13:
              return PurchaseResult(
                  type: PurchaseResultType.skErrorInvalidSignature,
                  error: result);
            case 14:
              return PurchaseResult(
                  type: PurchaseResultType.skErrorMissingOfferParams,
                  error: result);
            case 15:
              return PurchaseResult(
                  type: PurchaseResultType.skErrorIneligibleForOffer,
                  error: result);
            case 16:
              return PurchaseResult(
                  type: PurchaseResultType.skErrorOverlayCancelled,
                  error: result);
            case 17:
              return PurchaseResult(
                  type: PurchaseResultType
                      .skErrorOverlayPresentedInBackGroundScene,
                  error: result);
            case 18:
              return PurchaseResult(
                  type: PurchaseResultType.skErrorOverlayTimeout,
                  error: result);
            case 19:
              return PurchaseResult(
                  type: PurchaseResultType.skErrorUnsupportedPlatform,
                  error: result);
            default:
              return PurchaseResult(
                  type: PurchaseResultType.unknownError, error: result);
          }
        }
        return PurchaseResult(
            type: PurchaseResultType.unknownError, error: result);
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
