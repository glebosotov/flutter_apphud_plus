import 'package:flutter_test/flutter_test.dart';
import 'package:apphud_plus/apphud_plus.dart';
import 'package:apphud_plus/apphud_plus_platform_interface.dart';
import 'package:apphud_plus/apphud_plus_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockApphudPlusPlatform 
    with MockPlatformInterfaceMixin
    implements ApphudPlusPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final ApphudPlusPlatform initialPlatform = ApphudPlusPlatform.instance;

  test('$MethodChannelApphudPlus is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelApphudPlus>());
  });

  test('getPlatformVersion', () async {
    ApphudPlus apphudPlusPlugin = ApphudPlus();
    MockApphudPlusPlatform fakePlatform = MockApphudPlusPlatform();
    ApphudPlusPlatform.instance = fakePlatform;
  
    expect(await apphudPlusPlugin.getPlatformVersion(), '42');
  });
}
