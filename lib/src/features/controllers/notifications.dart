import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static bool _initialized = false;

  static Future<void> init() async {
    if (_initialized) return;

    // 1. SETUP TIMEZONE (WAJIB ADA LOKASI)
    try {
      tz.initializeTimeZones();
      
      // --- FIX UTAMA: Tetapkan lokasi ke Kuala Lumpur ---
      // Tanpa baris ini, tz.local akan crash di sesetengah phone
      final location = tz.getLocation('Asia/Kuala_Lumpur');
      tz.setLocalLocation(location);
      
      print('NotificationService: Timezone set to Asia/Kuala_Lumpur');
    } catch (e) {
      print('NotificationService: Timezone failed, falling back to UTC. Error: $e');
      // Fallback kalau KL tak jumpa
      try {
        tz.setLocalLocation(tz.UTC);
      } catch (e2) {
        print("Fatal Timezone Error: $e2");
      }
    }

    // 2. SETUP ANDROID
    // Pastikan fail 'ic_launcher' wujud dalam folder android/app/src/main/res/mipmap/
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // 3. SETUP IOS
    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
      defaultPresentAlert: true,
      defaultPresentBanner: true,
      defaultPresentSound: true,
    );

    const InitializationSettings settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notificationsPlugin.initialize(settings);
    _initialized = true;
    print("NotificationService: Initialized!");
  }

  // Helper untuk schedule
  static Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
  }) async {
    
    // Safety check: Pastikan masa adalah masa depan
    DateTime scheduled = scheduledDate;
    if (scheduled.isBefore(DateTime.now())) {
      scheduled = DateTime.now().add(const Duration(seconds: 5));
    }

    try {
      await _notificationsPlugin.zonedSchedule(
        id,
        title,
        body,
        // Guna tz.local yang dah kita set ke KL tadi
        tz.TZDateTime.from(scheduled, tz.local),
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'scholarship_channel_v8', // Tukar ID lagi untuk refresh
            'Scholarship Reminders',
            channelDescription: 'Notification for scholarship deadlines',
            importance: Importance.max,
            priority: Priority.max,
            fullScreenIntent: true,
            ticker: 'ticker',
            visibility: NotificationVisibility.public,
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBanner: true,
            presentSound: true,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.dateAndTime,
      );
      print("Notification Scheduled for: $scheduled");

    } catch (e) {
      print("Error Scheduling Notification: $e");
      // Kalau schedule gagal (sebab timezone dsb), kita tunjuk notification terus (Show Now)
      // supaya app tak crash
      await showNow(id: id, title: title, body: body);
    }
  }

  // Fallback function: Tunjuk terus tanpa jadual
  static Future<void> showNow({
    required int id,
    required String title,
    required String body,
  }) async {
    await _notificationsPlugin.show(
        id,
        title,
        body,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'scholarship_channel_v8',
            'Scholarship Reminders',
            importance: Importance.max,
            priority: Priority.max,
          ),
          iOS: DarwinNotificationDetails(),
        ));
  }

  static Future<void> setScholarshipReminder(String scholarshipName, DateTime? deadlineDate) async {
    DateTime now = DateTime.now();
    int baseId = scholarshipName.hashCode.abs();

    if (deadlineDate == null) {
      // Case: N/A deadline, remind after 1 week
      DateTime notifyDate = now.add(const Duration(days: 7));
      await scheduleNotification(
        id: baseId,
        title: "Scholarship Reminder 🎓",
        body: "You saved '$scholarshipName'. Apply now before it's too late!",
        scheduledDate: notifyDate,
      );
      print("Scheduled 1-week-later notification for $scholarshipName (N/A deadline)");
    } else {
      // Case: Real deadline, remind 1 week before and 1 day before
      DateTime oneWeekBefore = deadlineDate.subtract(const Duration(days: 7));
      DateTime oneDayBefore = deadlineDate.subtract(const Duration(days: 1));

      // Only schedule if in the future
      if (oneWeekBefore.isAfter(now)) {
        await scheduleNotification(
          id: baseId + 1,
          title: "Scholarship Reminder 🎓",
          body: "1 week left to apply for '$scholarshipName'!",
          scheduledDate: oneWeekBefore,
        );
        print("Scheduled 1-week-before notification for $scholarshipName");
      }
      if (oneDayBefore.isAfter(now)) {
        await scheduleNotification(
          id: baseId + 2,
          title: "Scholarship Reminder 🎓",
          body: "1 day left to apply for '$scholarshipName'!",
          scheduledDate: oneDayBefore,
        );
        print("Scheduled 1-day-before notification for $scholarshipName");
      }
    }
  }
}