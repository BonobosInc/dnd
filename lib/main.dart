import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'views/profile_home_screen.dart';
import 'package:flutter/foundation.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (kDebugMode) {
    await clearSharedPreferences();
  }

  runApp(const DNDApp());
}

class DNDApp extends StatelessWidget {
  const DNDApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Profilauswahl',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const ProfileHomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

Future<void> clearSharedPreferences() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.clear();
}
