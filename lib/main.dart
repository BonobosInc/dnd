import 'dart:io';
import 'package:dnd/classes/wiki_parser.dart';
import 'package:dnd/configs/auto_updater.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'views/profile_home_screen.dart';
import 'configs/colours.dart';
import 'package:flutter/services.dart';
import 'package:window_size/window_size.dart';

ValueNotifier<bool> isDarkMode = ValueNotifier(true);
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await cleanupPendingApk();

  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    setWindowTitle('BonoDND');
    setWindowMinSize(const Size(400, 700));
  }

  await AppColors.loadThemePreference();

  isDarkMode.value = AppColors.isDarkMode;

  if (!kIsWeb && (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  WikiParser wikiParser = WikiParser();
  await wikiParser.loadXml();

  runApp(DNDApp(wikiParser: wikiParser));

  WidgetsBinding.instance.addPostFrameCallback((_) {
    final context = navigatorKey.currentContext!;
    final deviceType = getDeviceType(context);
    if (deviceType == 'phone') {
      SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    }
    checkForUpdate(context);
  });
}

String getDeviceType(BuildContext context) {
  final data = MediaQuery.of(context);
  return data.size.shortestSide < 600 ? 'phone' : 'tablet';
}

class DNDApp extends StatelessWidget {
  final WikiParser wikiParser;

  const DNDApp({super.key, required this.wikiParser});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: isDarkMode,
      builder: (context, isDark, child) {
        AppColors.toggleTheme(isDark);

        return MaterialApp(
          navigatorKey: navigatorKey,
          title: 'DND App',
          theme: ThemeData(
            brightness: isDark ? Brightness.dark : Brightness.light,
            primaryColor: AppColors.primaryColor,
            scaffoldBackgroundColor: AppColors.primaryColor,
            appBarTheme: AppBarTheme(
              color: AppColors.appBarColor,
            ),
            splashColor: Colors.transparent,
            cardColor: AppColors.cardColor,
            dividerColor: AppColors.dividerColor,
            textTheme: TextTheme(
              bodyLarge: TextStyle(color: AppColors.textColorLight),
              bodyMedium: TextStyle(color: AppColors.textColorDark),
              displayLarge:
                  TextStyle(color: AppColors.textColorLight, fontSize: 20),
            ),
          ),
          home: ProfileHomeScreen(wikiParser: wikiParser),
          debugShowCheckedModeBanner: false,
        );
      },
    );
  }
}
