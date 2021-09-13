import 'package:flutter/services.dart';

class EventHandling {
  static const dataStream =
      const EventChannel('platform_channel_events/connectivity');
  static const dataReady =
      const EventChannel('platform_channel_events/dataReady');
}
