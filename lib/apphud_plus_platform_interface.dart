import 'package:apphud_plus/apphud_plus.dart';
import 'package:flutter/material.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'apphud_plus_method_channel.dart';

abstract class ApphudPlusPlatform extends PlatformInterface {
  /// Constructs a ApphudPlusPlatform.
  ApphudPlusPlatform() : super(token: _token);

  static final Object _token = Object();

  static ApphudPlusPlatform _instance = MethodChannelApphudPlus();

  /// The default instance of [ApphudPlusPlatform] to use.
  ///
  /// Defaults to [MethodChannelApphudPlus].
  static ApphudPlusPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [ApphudPlusPlatform] when
  /// they register themselves.
  static set instance(ApphudPlusPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getBackgroundNotificationRuleName() async {
    throw UnimplementedError();
  }

  Future<void> addForegroundNotificationListener(
      ValueSetter<String> callback) async {
    throw UnimplementedError();
  }

  Future<PurchaseResult> purchase(String productId) async {
    throw UnimplementedError();
  }

  Future<bool> paywallsDidLoad() async {
    throw UnimplementedError();
  }

  Future<bool> hasProductWithId(String productId) async {
    throw UnimplementedError();
  }
}