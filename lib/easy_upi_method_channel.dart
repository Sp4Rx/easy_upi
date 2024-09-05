import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'easy_upi_platform_interface.dart';

/// An implementation of [EasyUpiPlatform] that uses method channels.
class MethodChannelEasyUpi extends EasyUpiPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('easy_upi');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }
}
