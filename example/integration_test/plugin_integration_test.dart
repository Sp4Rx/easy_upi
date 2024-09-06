// This is a basic Flutter integration test.
//
// Since integration tests run in a full Flutter application, they can interact
// with the host side of a plugin implementation, unlike Dart unit tests.
//
// For more information about Flutter integration tests, please see
// https://flutter.dev/to/integration-testing

import 'package:easy_upi/models/upi_app.dart';
import 'package:easy_upi_example/main.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:easy_upi/easy_upi.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('getAllUpiApps correct upiUri test', (WidgetTester tester) async {
    final EasyUpi plugin = EasyUpi();
    final List<UpiApp> apps = await plugin.getAllUpiApps(upiUri: upiUrl);
    expect(apps.isNotEmpty, true);
  });

  testWidgets('getAllUpiApps wrong upiUri test', (WidgetTester tester) async {
    final EasyUpi plugin = EasyUpi();
    final List<UpiApp> apps = await plugin.getAllUpiApps(upiUri: 'wrong upiUri');
    expect(apps.isNotEmpty, false);
  });
}
