import 'package:flutter_test/flutter_test.dart';
import 'package:easy_upi/easy_upi.dart';
import 'package:easy_upi/easy_upi_platform_interface.dart';
import 'package:easy_upi/easy_upi_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockEasyUpiPlatform
    with MockPlatformInterfaceMixin
    implements EasyUpiPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final EasyUpiPlatform initialPlatform = EasyUpiPlatform.instance;

  test('$MethodChannelEasyUpi is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelEasyUpi>());
  });

  test('getPlatformVersion', () async {
    EasyUpi easyUpiPlugin = EasyUpi();
    MockEasyUpiPlatform fakePlatform = MockEasyUpiPlatform();
    EasyUpiPlatform.instance = fakePlatform;

    expect(await easyUpiPlugin.getPlatformVersion(), '42');
  });
}
