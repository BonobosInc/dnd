import 'dart:io';
import 'package:dnd/classes/wiki_parser.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'views/profile_home_screen.dart';
import 'configs/colours.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (!kIsWeb && (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  WikiParser wikiParser = WikiParser();
  await wikiParser.loadXml();

  runApp(DNDApp(wikiParser: wikiParser));
}

class DNDApp extends StatelessWidget {
  final WikiParser wikiParser;

  const DNDApp({super.key, required this.wikiParser});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DND App',
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: AppColors.primaryColor,
        scaffoldBackgroundColor: AppColors.primaryColor,
        appBarTheme: const AppBarTheme(
          color: AppColors.appBarColor,
        ),
        splashColor: Colors.transparent,
        cardColor: AppColors.cardColor,
        dividerColor: AppColors.dividerColor,
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: AppColors.textColorLight),
          bodyMedium: TextStyle(color: AppColors.textColorDark),
          displayLarge: TextStyle(color: AppColors.textColorLight, fontSize: 20),
        ),
      ),
      home: ProfileHomeScreen(wikiParser: wikiParser),
      debugShowCheckedModeBanner: false,
    );
  }
}
