class UpiResponse {
  final String? transactionId;
  final String? responseCode;
  final String? approvalRefNo;
  final String? status;
  final String? transactionRefId;
  final String responseString;

  UpiResponse(this.responseString)
      : transactionId = _extractValue(responseString, 'txnId'),
        responseCode = _extractValue(responseString, 'responseCode'),
        approvalRefNo = _extractValue(responseString, 'ApprovalRefNo'),
        status = _extractStatus(responseString),
        transactionRefId = _extractValue(responseString, 'txnRef');

  static String? _extractValue(String responseString, String key) {
    final regex = RegExp('$key=([^&]*)');
    final match = regex.firstMatch(responseString);
    return match?.group(1);
  }

  static String? _extractStatus(String responseString) {
    final statusValue = _extractValue(responseString, 'Status');
    if (statusValue == null) return null;
    if (statusValue.toLowerCase().contains('success')) return 'success';
    if (statusValue.toLowerCase().contains('fail')) return 'failure';
    if (statusValue.toLowerCase().contains('submit')) return 'submitted';
    return 'other';
  }
}
