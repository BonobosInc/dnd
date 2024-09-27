import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:file_picker/file_picker.dart';

class ProfileManager {
  List<String> profiles = [];
  String? selectedProfile;
  Database? currentDb;

  Future<void> initialize() async {
    await loadProfiles();
  }

  Future<void> loadProfiles() async {
    final databasesPath = await getDatabasesPath();
    final profilesDir = Directory(databasesPath);

    if (await profilesDir.exists()) {
      final dbFiles = profilesDir
          .listSync()
          .where((file) => file.path.endsWith('.db'))
          .toList();
      profiles =
          dbFiles.map((file) => basenameWithoutExtension(file.path)).toList();
    }
  }

  Future<void> createProfile(String profileName) async {
    final databasesPath = await getDatabasesPath();
    final profileDbPath = join(databasesPath, '$profileName.db');

    if (kDebugMode) {
      print('Creating profile database at: $profileDbPath');
    }

    currentDb =
        await openDatabase(profileDbPath, version: 1, onCreate: (db, version) {
      db.execute(
          'CREATE TABLE info (id INTEGER PRIMARY KEY, info TEXT, text TEXT)');
      db.execute(
          'CREATE TABLE stats (id INTEGER PRIMARY KEY, stat TEXT, value INTEGER)');
      db.execute(
          'CREATE TABLE bag (id INTEGER PRIMARY KEY, item TEXT, amount INTEGER)');
      db.execute(
          'CREATE TABLE spells (id INTEGER PRIMARY KEY, spellname TEXT, status TEXT, level INTEGER, description TEXT)');

      var initialInfo = [
        {'info': 'name', 'text': profileName},
        {'info': 'race', 'text': "Human"},
        {'info': 'class', 'text': "Barbarian"},
      ];
      for (var info in initialInfo) {
        db.insert('info', info);
      }

      const initialStats = [
        {'stat': 'Level', 'value': 1},
        {'stat': 'STR', 'value': 0},
        {'stat': 'DEX', 'value': 0},
        {'stat': 'CON', 'value': 0},
        {'stat': 'INT', 'value': 0},
        {'stat': 'WIS', 'value': 0},
        {'stat': 'CHA', 'value': 0},
      ];
      for (var stat in initialStats) {
        db.insert('stats', stat);
      }
    });

    profiles.add(profileName);
  }

  Future<void> selectProfile(String profileName) async {
    final databasesPath = await getDatabasesPath();
    final profileDbPath = join(databasesPath, '$profileName.db');

    if (kDebugMode) {
      print('Selecting profile database at: $profileDbPath');
    }

    currentDb = await openDatabase(profileDbPath);
    selectedProfile = profileName;
  }

  Future<void> deleteProfile(String profileName) async {
    await closeProfile();

    final databasesPath = await getDatabasesPath();
    final profileDbPath = join(databasesPath, '$profileName.db');
    final File profileFile = File(profileDbPath);
    if (await profileFile.exists()) {
      await profileFile.delete();
    }

    await loadProfiles();
  }

  Future<void> dumpDatabase(String profileName) async {
    final databasesPath = await getDatabasesPath();
    final profileDbPath = join(databasesPath, '$profileName.db');

    Database profileDb = await openDatabase(profileDbPath);

    String? selectedPath = await FilePicker.platform.getDirectoryPath();
    if (selectedPath != null) {
      String profileData = await getProfileData(profileDb, profileName);
      final filePath = join(selectedPath, '$profileName.txt');
      final File file = File(filePath);
      await file.writeAsString(profileData);
    }

    await profileDb.close();
  }

  Future<String> getProfileData(Database profileDb, String profileName) async {
    List<Map<String, dynamic>> infoData = await profileDb.query('info');

    String race = 'Unknown Race';
    String classType = 'Unknown Class';

    for (var row in infoData) {
      if (row['info'] == 'race') {
        race = row['text'];
      } else if (row['info'] == 'class') {
        classType = row['text'];
      }
    }

    List<Map<String, dynamic>> statsData = await profileDb.query('stats');
    String profileStats = statsData.isNotEmpty
        ? statsData
            .map((row) => '${row['stat']}:\n └── ${row['value']}')
            .join('\n')
        : 'No stats available';

    List<Map<String, dynamic>> bagData = await profileDb.query('bag');
    String bagItems = bagData.isNotEmpty
        ? bagData
            .map((row) => ' └── ${row['item']}\n     └── ${row['amount']}')
            .join('\n')
        : 'No items in the bag';

    List<Map<String, dynamic>> spellsData = await profileDb.query('spells');
    String spellString = '';
    for (var spell in spellsData) {
      String spellName = spell['spellname'];
      String status = spell['status'];
      String level = spell['level'].toString();
      String description = spell['description'];

      spellString +=
          ' └── $spellName\n     └── Status: $status\n     └── Level: $level\n     └── Description: $description\n';
    }

    return 'Charakter Name: $profileName\nInfo:\n └── Rasse: $race\n └── Klasse: $classType\nStats:\n$profileStats\nBag:\n$bagItems\nSpells:\n$spellString';
  }



  Future<void> updateStats({
    String? stat,
    int? value,
  }) async {
    if (currentDb == null || stat == null || value == null) return;

    await currentDb!.update(
      'stats',
      {'value': value},
      where: 'stat = ?',
      whereArgs: [stat],
    );
  }

  Future<void> updateBagItem({
    required String itemName,
    int? amount,
  }) async {
    if (currentDb == null) return;

    final Map<String, dynamic> updates = {};

    if (amount != null) updates['amount'] = amount;

    if (updates.isNotEmpty) {
      await currentDb!.update(
        'bag',
        updates,
        where: 'item = ?',
        whereArgs: [itemName],
      );
    }
  }

  Future<void> updateProfileInfo({
  String? race,
  String? classType,
}) async {
  if (currentDb == null) return;

  final Map<String, dynamic> updates = {};

  if (race != null) updates['text'] = race;

  if (classType != null) {
    if (updates.isNotEmpty) {
      await currentDb!.update(
        'info',
        updates,
        where: 'info = ?',
        whereArgs: ['race'],
      );
    }

    updates['text'] = classType;
  }

  if (classType != null) {
    await currentDb!.update(
      'info',
      updates,
      where: 'info = ?',
      whereArgs: ['class'],
    );
  }
}


  Future<void> updateSpell({
    required String spellName,
    String? status,
    int? level,
    String? description,
  }) async {
    if (currentDb == null) return;

    final Map<String, dynamic> updates = {};

    if (status != null) updates['status'] = status;
    if (level != null) updates['level'] = level;
    if (description != null) updates['description'] = description;

    if (updates.isNotEmpty) {
      await currentDb!.update(
        'spells',
        updates,
        where: 'spellname = ?',
        whereArgs: [spellName],
      );
    }
  }

  Future<Map<int, Map<String, dynamic>>?> getStats() async {
    if (currentDb == null) return null;

    final List<Map<String, dynamic>> result = await currentDb!.query(
      'stats',
      where: 'stat IN (?, ?, ?, ?, ?, ?, ?)',
      whereArgs: ['Level', 'STR', 'DEX', 'CON', 'INT', 'WIS', 'CHA'],
    );

    return result.isNotEmpty ? result.asMap() : null;
  }

  Future<Map<String, String>?> getProfileInfo() async {
  if (currentDb == null) return null;

  final List<Map<String, dynamic>> result = await currentDb!.query(
    'info',
    where: 'info IN (?, ?)',
    whereArgs: ['race', 'class'],
  );
  final Map<String, String> profileInfo = {};

  for (var row in result) {
    profileInfo[row['info']] = row['text'];
  }

  return profileInfo.isNotEmpty ? profileInfo : null;
}

  Future<List<Map<String, dynamic>>> getAllBagItems() async {
    if (currentDb == null) return [];

    final List<Map<String, dynamic>> result = await currentDb!.query('bag');

    return result;
  }

  Future<List<Map<String, dynamic>>> getAllSpellsWithLevels() async {
    if (currentDb == null) return [];

    final List<Map<String, dynamic>> result = await currentDb!.query(
      'spells',
      columns: ['spellname', 'level'],
    );

    return result;
  }

  Future<String?> getSpellDescription(String spellName) async {
    if (currentDb == null) return null;

    final List<Map<String, dynamic>> result = await currentDb!.query(
      'spells',
      columns: ['description'],
      where: 'spellname = ?',
      whereArgs: [spellName],
    );

    return result.isNotEmpty ? result.first['description'] as String : null;
  }

  bool hasProfiles() {
    return profiles.isNotEmpty;
  }

  List<String> getProfiles() {
    return profiles;
  }

  Future<void> closeProfile() async {
    if (currentDb != null) {
      await currentDb!.close();
      if (kDebugMode) {
      print('Closing profile database');
    }
    }
  }
}
