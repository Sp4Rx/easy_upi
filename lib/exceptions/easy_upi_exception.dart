class EasyUpiException implements Exception {
  final String message;
  EasyUpiException(this.message);
  @override
  String toString() => 'EasyUpiException: $message';
}

class EasyUpiAppNotInstalledException extends EasyUpiException {
  EasyUpiAppNotInstalledException() : super('App not installed in user device');
}

class EasyUpiInvalidParametersException extends EasyUpiException {
  EasyUpiInvalidParametersException([super.message = 'Incorrect parameters provided for transaction']);
}

class EasyUpiUserCancelledException extends EasyUpiException {
  EasyUpiUserCancelledException() : super('User cancelled the transaction');
}
