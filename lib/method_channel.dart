import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:timber_test1/repository/dataRepository.dart';

class MethodHandling {
  static const platform = const MethodChannel('example.flutter.dev/battery');
  static GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  // Receive method invocations from platform and return results.
  static void initMethodHandler() {
    platform.setMethodCallHandler((MethodCall call) async {
      switch (call.method) {
        default:
          throw MissingPluginException();
      }
    });
  }
}
