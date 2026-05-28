import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:timezone/data/latest.dart' as tzData;
import 'package:myfuture_application/src/features/controllers/notifications.dart';
import 'package:myfuture_application/src/features/screens/intro_screens/onboarding_screen.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  tzData.initializeTimeZones();

  

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform
  );
  
  //init notifications
await NotificationService.init();  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: OnBoardingScreen()
    );
  }
}
