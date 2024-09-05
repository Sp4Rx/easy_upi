
import 'easy_upi_platform_interface.dart';

class EasyUpi {
  Future<String?> getPlatformVersion() {
    return EasyUpiPlatform.instance.getPlatformVersion();
  }
}
