import 'package:flutter/services.dart';
import 'package:flutter/material.dart';

/// This creates a method channel that can handle method calls from
/// Android or IOS native code. Already set up method call handler on the
/// native side.

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
