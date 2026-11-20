import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'notification_service.dart';

part 'notification_provider.g.dart';

@riverpod
FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin(Ref ref) =>
    FlutterLocalNotificationsPlugin();

@riverpod
NotificationService notificationService(Ref ref) {
  return NotificationService(ref.watch(flutterLocalNotificationsPluginProvider));
}
