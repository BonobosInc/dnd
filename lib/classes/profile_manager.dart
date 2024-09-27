import 'dart:ffi';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:file_picker/file_picker.dart';
import '../configs/defines.dart';

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

  void initializeDatabase(Database db, String profileName) {
    var initialInfo = [
      {'info': Defines.infoName, 'text': profileName},
      {'info': Defines.infoRace, 'text': ""},
      {'info': Defines.infoClass, 'text': ""},
      {'info': Defines.infoOrigin, 'text': ""},
      {'info': Defines.infoBackground, 'text': ""},
    ];

    for (var info in initialInfo) {
      db.insert('info', info);
    }

    const initialSave = [
      {'save': Defines.saveStr, 'bonus': false},
      {'save': Defines.saveDex, 'bonus': false},
      {'save': Defines.saveCon, 'bonus': false},
      {'save': Defines.saveInt, 'bonus': false},
      {'save': Defines.saveWis, 'bonus': false},
      {'save': Defines.saveCha, 'bonus': false},
    ];

    for (var info in initialSave) {
      db.insert('savingthrow', info);
    }

    const initialSkills = [
      {
        'skill': Defines.skillAcrobatics,
        'proficiency': false,
        'expertise': false
      },
      {
        'skill': Defines.skillAnimalHandling,
        'proficiency': false,
        'expertise': false
      },
      {'skill': Defines.skillArcana, 'proficiency': false, 'expertise': false},
      {
        'skill': Defines.skillAthletics,
        'proficiency': false,
        'expertise': false
      },
      {
        'skill': Defines.skillDeception,
        'proficiency': false,
        'expertise': false
      },
      {'skill': Defines.skillHistory, 'proficiency': false, 'expertise': false},
      {'skill': Defines.skillInsight, 'proficiency': false, 'expertise': false},
      {
        'skill': Defines.skillIntimidation,
        'proficiency': false,
        'expertise': false
      },
      {
        'skill': Defines.skillInvestigation,
        'proficiency': false,
        'expertise': false
      },
      {
        'skill': Defines.skillMedicine,
        'proficiency': false,
        'expertise': false
      },
      {'skill': Defines.skillNature, 'proficiency': false, 'expertise': false},
      {
        'skill': Defines.skillPerception,
        'proficiency': false,
        'expertise': false
      },
      {
        'skill': Defines.skillPerformance,
        'proficiency': false,
        'expertise': false
      },
      {
        'skill': Defines.skillPersuasion,
        'proficiency': false,
        'expertise': false
      },
      {
        'skill': Defines.skillReligion,
        'proficiency': false,
        'expertise': false
      },
      {
        'skill': Defines.skillSleightOfHand,
        'proficiency': false,
        'expertise': false
      },
      {'skill': Defines.skillStealth, 'proficiency': false, 'expertise': false},
      {
        'skill': Defines.skillSurvival,
        'proficiency': false,
        'expertise': false
      },
    ];

    for (var info in initialSkills) {
      db.insert('skills', info);
    }

    const initialStats = [
      {'stat': Defines.statArmor, 'value': 10},
      {'stat': Defines.statLevel, 'value': 1},
      {'stat': Defines.statXP, 'value': 0},
      {'stat': Defines.statInspiration, 'value': 1},
      {'stat': Defines.statProficiencyBonus, 'value': 1},
      {'stat': Defines.statInitiative, 'value': 1},
      {'stat': Defines.statMovement, 'value': 1},
      {'stat': Defines.statMaxHP, 'value': 1},
      {'stat': Defines.statCurrentHP, 'value': 1},
      {'stat': Defines.statTempHP, 'value': 1},
      {'stat': Defines.statHitDice, 'value': 1},
      {'stat': Defines.statSTR, 'value': 0},
      {'stat': Defines.statDEX, 'value': 0},
      {'stat': Defines.statCON, 'value': 0},
      {'stat': Defines.statINT, 'value': 0},
      {'stat': Defines.statWIS, 'value': 0},
      {'stat': Defines.statCHA, 'value': 0},
    ];

    for (var stat in initialStats) {
      db.insert('stats', stat);
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
          'CREATE TABLE savingthrow (id INTEGER PRIMARY KEY, save TEXT, bonus BOOLEAN)');
      db.execute(
          'CREATE TABLE skills (id INTEGER PRIMARY KEY, skill TEXT, proficiency BOOLEAN, expertise BOOLEAN)');
      db.execute(
          'CREATE TABLE bag (id INTEGER PRIMARY KEY, item TEXT, amount INTEGER)');
      db.execute(
          'CREATE TABLE spells (id INTEGER PRIMARY KEY, spellname TEXT, status TEXT, level INTEGER, description TEXT)');

      initializeDatabase(db, profileName);
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
      if (row['info'] == Defines.infoRace) {
        race = row['text'];
      } else if (row['info'] == Defines.infoClass) {
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
    required String stat,
    int? value,
  }) async {
    if (currentDb == null || value == null) return;

    await currentDb!.update(
      'stats',
      {'value': value},
      where: 'stat = ?',
      whereArgs: [stat],
    );
  }

  Future<void> updateSavingThrows({
    required String savethrow,
    Bool? bonus,
  }) async {
    if (currentDb == null || bonus == null) return;

    await currentDb!.update(
      'savingthrow',
      {'bonus': bonus},
      where: 'save = ?',
      whereArgs: [savethrow],
    );
  }

  Future<void> updateSkills({
    required String skill,
    Bool? proficiency,
    Bool? expertise,
  }) async {
    if (currentDb == null || proficiency == null || expertise == null) return;

    await currentDb!.update(
      'skills',
      {'proficiency': proficiency, 'expertise': expertise},
      where: 'skill = ?',
      whereArgs: [skill],
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
    required String info,
    required String text,
  }) async {
    if (currentDb == null) return;

    await currentDb!.update(
      'info',
      {'text': text},
      where: 'info = ?',
      whereArgs: [info],
    );
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

  Future<int?> getStatValue(String statName) async {
    if (currentDb == null) return null;

    final List<Map<String, dynamic>> result = await currentDb!.query(
      'stats',
      where: 'stat = ?',
      whereArgs: [statName],
    );

    if (result.isNotEmpty) {
      return result.first['value'] as int?;
    }

    return null;
  }

  Future<Map<String, String>?> getProfileInfo(List<String> infoKeys) async {
    if (currentDb == null) return null;

    final List<Map<String, dynamic>> result = await currentDb!.query(
      'info',
      where: 'info IN (${infoKeys.map((_) => '?').join(',')})',
      whereArgs: infoKeys,
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
