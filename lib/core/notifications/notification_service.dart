import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../../data/models/wishlist_model.dart';

class NotificationService {
  NotificationService(this._plugin);

  final FlutterLocalNotificationsPlugin _plugin;

  Future<void> init() async {
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings();
    await _plugin.initialize(
      const InitializationSettings(android: androidInit, iOS: iosInit),
    );

    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
    await _plugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(alert: true, badge: true, sound: true);
  }

  Future<void> showGoalCompleted(WishlistModel goal) async {
    const androidDetails = AndroidNotificationDetails(
      'wishlist_goals',
      'Goal Notifications',
      channelDescription: 'Notifies when a savings goal is reached',
      importance: Importance.high,
      priority: Priority.high,
    );
    const details = NotificationDetails(
      android: androidDetails,
      iOS: DarwinNotificationDetails(),
    );
    await _plugin.show(
      goal.id.hashCode,
      'Goal reached! 🎉',
      '"${goal.name}" has hit its target.',
      details,
    );
  }
}
