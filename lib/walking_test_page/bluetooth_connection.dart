import 'dart:async';
import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:timber_test1/app_bar.dart';
import 'package:timber_test1/method_channel.dart';
import 'package:timber_test1/walking_test_page/walking_test_page.dart';

/// Let usr choose a metawear board to connect to via bluetooth. This
/// uses the native page from Android to select a device.

class Metawear extends StatefulWidget {
   @override
  State<StatefulWidget> createState() => _MetawearState();
}

class _MetawearState extends State<Metawear> {
  bool isConnected = false;
  String text = 'Connect to metawear board';
  String status = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar('Bluetooth connection'),
      body: Container(
        padding: EdgeInsets.all(20),
        alignment: Alignment.center,
        child: Column(
          children: [
            ElevatedButton(
                child: Text(text),
                onPressed: () async {
                  if (!isConnected) {
                    isConnected = await _getAndroidNativeView();
                  } else {
                    _disconnect();
                    isConnected = false;
                  }
                  setState(() {
                    if (isConnected) {
                      text = 'Disconnect';
                      status = 'connected';
                    } else {
                      text = 'Connect to metawear board';
                      status = 'disconnected';
                    }
                  });
                }),
            Text("Bluetooth connection status: " + status),
            SizedBox(
              height: 30,
            ),
            ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => Walking()));
                },
                child: Text('Start walking test'))
          ],
        ),
      ),
    );
  }
// Go to Android native view to connect the board
// if connected return true otherwise return false
  Future<bool> _getAndroidNativeView() async {
    try {
      final bool result =
          await MethodHandling.platform.invokeMethod('getNativeView');
      return result;
    } on PlatformException catch (e) {
      print("Failed to get native view: '${e.message}'.");
      return false;
    }
  }

  Future<void> _disconnect() async {
    try {
      await MethodHandling.platform.invokeMethod('disconnectBle');
    } on PlatformException catch (e) {
      print("Failed to disconnect from bluetooth: '${e.message}'.");
    }
  }
  //To be implemented
  void _getIOSNativeView() {}
}
