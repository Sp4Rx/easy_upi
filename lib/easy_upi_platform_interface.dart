import 'package:easy_upi/models/upi_app.dart';
import 'package:easy_upi/models/upi_response.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'easy_upi_method_channel.dart';

abstract class EasyUpiPlatform extends PlatformInterface {
  /// Constructs a EasyUpiPlatform.
  EasyUpiPlatform() : super(token: _token);

  static final Object _token = Object();

  static EasyUpiPlatform _instance = MethodChannelEasyUpi();

  /// The default instance of [EasyUpiPlatform] to use.
  ///
  /// Defaults to [MethodChannelEasyUpi].
  static EasyUpiPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [EasyUpiPlatform] when
  /// they register themselves.
  static set instance(EasyUpiPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }

  Future<List<UpiApp>> getAllUpiApps({required String upiUri}) {
    throw UnimplementedError('getAllUpiApps() has not been implemented.');
  }

  Future<UpiResponse> startTransaction({
    required UpiApp app,
  }) {
    throw UnimplementedError('startTransaction() has not been implemented.');
  }
}
