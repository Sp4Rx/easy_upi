import 'package:easy_upi/models/upi_app.dart';
import 'package:easy_upi/models/upi_response.dart';
import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:easy_upi/easy_upi.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _easyUpiPlugin = EasyUpi();
  List<UpiApp> _upiApps = [];

  @override
  void initState() {
    super.initState();
    // initPlatformState();
    _loadUpiApps();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    String platformVersion;
    // Platform messages may fail, so we use a try/catch PlatformException.
    // We also handle the message potentially returning null.
    try {
      platformVersion = await _easyUpiPlugin.getPlatformVersion() ?? 'Unknown platform version';
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {});
  }

  Future<void> _loadUpiApps() async {
    try {
      const upiUrl =
          'upi://pay?pa=bauvatest@kaypay&pn=BauvaTest&am=1.00&tr=1725566170360183655&tn=Account%20Verification&cu=INR&mode=04';

      final apps = await _easyUpiPlugin.getAllUpiApps(upiUri: upiUrl);
      setState(() {
        _upiApps = apps;
      });
    } catch (e) {
      print('Error loading UPI apps: $e');
    }
  }

  Future<void> _startTransaction(UpiApp app) async {
    try {
      final response = await _easyUpiPlugin.startTransaction(app: app);
      _showResponse(response);
    } catch (e) {
      _showError(e.toString());
    }
  }

  void _showResponse(UpiResponse response) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Transaction Result'),
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Status: ${response.status}'),
            Text('Transaction ID: ${response.transactionId ?? 'N/A'}'),
            Text('Reference ID: ${response.transactionRefId ?? 'N/A'}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showError(String message) {
    print(message);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Easy UPI Example'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: _upiApps.length,
                  itemBuilder: (context, index) {
                    final app = _upiApps[index];
                    return ListTile(
                      leading: Image.memory(app.icon, width: 40, height: 40),
                      title: Text(app.name),
                      onTap: () => _startTransaction(app),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
