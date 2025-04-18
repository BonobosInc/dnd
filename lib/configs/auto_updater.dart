import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:flutter_app_installer/flutter_app_installer.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:dnd/configs/version.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String repoOwner = 'BonobosInc';
const String repoName = 'dnd';

Future<void> checkForUpdate(BuildContext context) async {
  if (!Platform.isAndroid) return;

  try {
    final response = await http.get(Uri.parse(
        'https://api.github.com/repos/$repoOwner/$repoName/releases/latest'));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final latestVersion = data['tag_name']?.replaceFirst('v', '');
      final apkAsset = (data['assets'] as List)
          .firstWhere((a) => a['name'].endsWith('.apk'), orElse: () => null);

      if (latestVersion != null &&
          isNewerVersion(latestVersion, appVersion) &&
          apkAsset != null) {
        final apkUrl = apkAsset['browser_download_url'];

        if (context.mounted) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (_) => AlertDialog(
              title: Text('Aktualisierung verfügbar'),
              content: Text(
                  'Eine neue Version ($latestVersion) ist erhältlich. Du verwendest Version $appVersion.'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('Überspringen'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    _downloadAndInstallApk(context, apkUrl);
                  },
                  child: Text('Aktualisieren'),
                ),
              ],
            ),
          );
        }
      }
    }
  } catch (e) {
    if (kDebugMode) {
      print('Update check failed: $e');
    }
  }
}

bool isNewerVersion(String latest, String current) {
  final latestParts = latest.split('.').map(int.parse).toList();
  final currentParts = current.split('.').map(int.parse).toList();

  for (int i = 0; i < latestParts.length; i++) {
    if (latestParts[i] > currentParts[i]) return true;
    if (latestParts[i] < currentParts[i]) return false;
  }

  return false;
}

Future<void> _downloadAndInstallApk(BuildContext context, String url) async {
  final dir = await getExternalStorageDirectory();
  final filePath = '${dir!.path}/update.apk';
  final file = File(filePath);

  try {
    final response = await http.get(Uri.parse(url));
    await file.writeAsBytes(response.bodyBytes);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('pending_apk_cleanup', filePath);

    final flutterAppInstaller = FlutterAppInstaller();
    await flutterAppInstaller.installApk(filePath: filePath);
  } catch (e) {
    if (e.toString().contains("INSTALL_FAILED_PERMISSION_DENIED")) {
      if (context.mounted) {
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: Text('Installation nicht erlaubt'),
            content: Text(
              'Bitte erlaube dieser App die Installation von unbekannten Quellen in den Systemeinstellungen.',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  openAppSettings();
                },
                child: Text('Einstellungen öffnen'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('Abbrechen'),
              ),
            ],
          ),
        );
      }
    } else {
      if (context.mounted) {
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: Text('Aktualisierung fehlgeschlagen'),
            content: Text(
              'Die Aktualisierung konnte nicht heruntergeladen oder installiert werden. Bitte versuche es später erneut.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('OK'),
              )
            ],
          ),
        );
      }
    }
  }
}

Future<void> cleanupPendingApk() async {
  final prefs = await SharedPreferences.getInstance();
  final apkPath = prefs.getString('pending_apk_cleanup');

  if (apkPath != null) {
    final file = File(apkPath);
    if (await file.exists()) {
      try {
        await file.delete();
        if (kDebugMode) print("Old APK file deleted.");
      } catch (e) {
        if (kDebugMode) print("Failed to delete old APK file: $e");
      }
    }
    await prefs.remove('pending_apk_cleanup');
  }
}
