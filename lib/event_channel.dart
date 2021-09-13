import 'package:flutter/services.dart';

/// Set up event channels that listen to Android or IOS native code.
/// Already set up event stream handler in native code.

class EventHandling {
  static const dataStream =
      const EventChannel('platform_channel_events/connectivity');
  static const dataReady =
      const EventChannel('platform_channel_events/dataReady');
}
