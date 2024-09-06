import 'package:easy_upi/exceptions/easy_upi_exception.dart';
import 'package:easy_upi/models/upi_app.dart';
import 'package:easy_upi/models/upi_response.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'easy_upi_platform_interface.dart';

/// An implementation of [EasyUpiPlatform] that uses method channels.
class MethodChannelEasyUpi extends EasyUpiPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('easy_upi');

  @override
  Future<List<UpiApp>> getAllUpiApps({required String upiUri}) async {
    final List<Map<dynamic, dynamic>>? apps =
        await methodChannel.invokeListMethod<Map<dynamic, dynamic>>('getAllUpiApps', {'upiUri': upiUri});
    if (apps == null) {
      throw EasyUpiException('Failed to get UPI apps');
    }
    return apps.map((app) => UpiApp.fromMap(Map<String, dynamic>.from(app))).toList();
  }

  @override
  Future<UpiResponse> startTransaction({
    required UpiApp app,
  }) async {
    try {
      final String? response = await methodChannel.invokeMethod('startTransaction', {
        'app': app.packageName,
      });
      if (response == null) {
        throw EasyUpiException('No response received from app');
      }
      return UpiResponse(response);
    } on PlatformException catch (e) {
      throw _handlePlatformException(e);
    }
  }

  Exception _handlePlatformException(PlatformException e) {
    switch (e.code) {
      case 'app_not_installed':
        return EasyUpiAppNotInstalledException();
      case 'invalid_parameters':
        return EasyUpiInvalidParametersException(e.message ?? 'Invalid parameters');
      case 'user_canceled':
        return EasyUpiUserCancelledException();
      default:
        return EasyUpiException(e.message ?? 'Unknown error occurred');
    }
  }
}
