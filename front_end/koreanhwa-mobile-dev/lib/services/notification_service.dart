import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  static bool _initialized = false;

  /// Initialize notification service
  static Future<void> initialize() async {
    if (_initialized) return;

    // Initialize timezone
    tz.initializeTimeZones();

    // Android initialization settings
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS initialization settings
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Request permissions
    await _requestPermissions();

    _initialized = true;
  }

  static Future<void> _requestPermissions() async {
    final androidImplementation = _notifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    
    // Android 13+ requires notification permission
    await androidImplementation?.requestNotificationsPermission();
  }

  static void _onNotificationTapped(NotificationResponse response) {
    // Handle notification tap
    // You can navigate to specific screen here
  }

  /// Schedule quiet hours (disable notifications during this time)
  static Future<void> setQuietHours({
    required bool enabled,
    required String startTime, // Format: "HH:mm"
    required String endTime, // Format: "HH:mm"
  }) async {
    // This is a placeholder - quiet hours are typically handled
    // by checking the time before showing notifications
    // You can implement this logic in your notification scheduling
  }

  /// Show immediate notification (for testing)
  static Future<void> showNotification({
    required String title,
    required String body,
  }) async {
    await initialize();

    await _notifications.show(
      999,
      title,
      body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'general',
          'Thông báo chung',
          channelDescription: 'Thông báo chung của ứng dụng',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
    );
  }
}

