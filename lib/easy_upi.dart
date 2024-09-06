import 'dart:async';

import 'package:easy_upi/models/upi_app.dart';
import 'package:easy_upi/models/upi_response.dart';
import 'easy_upi_platform_interface.dart';

class EasyUpi {
  Future<List<UpiApp>> getAllUpiApps({required String upiUri}) {
    return EasyUpiPlatform.instance.getAllUpiApps(upiUri: upiUri);
  }

  Future<UpiResponse> startTransaction({
    required UpiApp app,
  }) async {
    return EasyUpiPlatform.instance.startTransaction(app: app);
  }
}
