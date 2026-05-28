import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart'; // Pastikan ada package intl untuk format tarikh
import 'package:myfuture_application/src/utils/theme/colors.dart'; // Import theme color awak

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  List<Map<String, String>> _notifications = [];
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
    
    // Auto-refresh setiap 2 saat supaya kalau user tunggu dalam page ni,
    // list akan muncul sendiri lepas 10 saat!
    _refreshTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      _loadNotifications();
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> rawList = prefs.getStringList('notification_history') ?? [];
    DateTime now = DateTime.now();

    List<Map<String, String>> tempList = [];

    for (String item in rawList) {
      // Pecahkan string guna pemisah '|||' tadi
      List<String> parts = item.split('|||');
      
      if (parts.length == 3) {
        String title = parts[0];
        String body = parts[1];
        String timeStr = parts[2];
        DateTime triggerTime = DateTime.parse(timeStr);

        // HANYA TUNJUK JIKA MASA DAH LEPAS (Logic 10 saat)
        // Kalau awak nak tunjuk semua (termasuk future), buang if ni.
        if (triggerTime.isBefore(now)) {
           tempList.add({
            'title': title,
            'body': body,
            'time': timeStr,
          });
        }
      }
    }

    // Susun ikut masa (Paling baru kat atas)
    tempList.sort((a, b) => b['time']!.compareTo(a['time']!));

    if (mounted) {
      setState(() {
        _notifications = tempList;
      });
    }
  }

  // Function Clear All
  Future<void> _clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('notification_history', []);
    _loadNotifications();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text("Notifications",
         style: TextStyle(
          fontWeight: FontWeight.bold, 
          color: primaryColor)),
        backgroundColor: backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: primaryColor),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            onPressed: _clearAll, 
            icon: const Icon(Icons.delete_outline, color: Colors.red)
          )
        ],
      ),
      body: _notifications.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.notifications_off_outlined, size: 80, color: Colors.grey[300]),
                  const SizedBox(height: 10),
                  Text("No notifications yet", style: TextStyle(color: Colors.grey[500])),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: _notifications.length,
              itemBuilder: (context, index) {
                final notif = _notifications[index];
                final DateTime date = DateTime.parse(notif['time']!);
                final String formattedTime = DateFormat('dd MMM, hh:mm a').format(date);

                return Container(
                  margin: const EdgeInsets.only(bottom: 15),
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4))
                    ],
                    border: Border.all(color: Colors.grey.shade100)
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Icon Bulat
                      Container(
                        height: 50, width: 50,
                        decoration: BoxDecoration(
                          color: primaryColor.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.notifications_active, color: primaryColor),
                      ),
                      const SizedBox(width: 15),
                      // Teks
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              notif['title']!,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              notif['body']!,
                              style: TextStyle(color: Colors.grey[600], fontSize: 13),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              formattedTime,
                              style: TextStyle(color: Colors.grey[400], fontSize: 11),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}