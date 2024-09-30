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
      {'info': Defines.infoPersonalityTraits, 'text': ""},
      {'info': Defines.infoIdeals, 'text': ""},
      {'info': Defines.infoBonds, 'text': ""},
      {'info': Defines.infoFlaws, 'text': ""},
      {'info': Defines.infoAge, 'text': ""},
      {'info': Defines.infoGod, 'text': ""},
      {'info': Defines.infoSize, 'text': ""},
      {'info': Defines.infoHeight, 'text': ""},
      {'info': Defines.infoWeight, 'text': ""},
      {'info': Defines.infoSex, 'text': ""},
      {'info': Defines.infoAlignment, 'text': ""},
      {'info': Defines.infoEyeColour, 'text': ""},
      {'info': Defines.infoHairColour, 'text': ""},
      {'info': Defines.infoSkinColour, 'text': ""},
      {'info': Defines.infoAppearance, 'text': ""},
      {'info': Defines.infoTraits, 'text': ""},
      {'info': Defines.infoSpellcastingClass, 'text': ""},
      {'info': Defines.infoSpellcastingAbility, 'text': ""},
    ];

    for (var info in initialInfo) {
      db.insert('info', info);
    }

    const initialSave = [
      {'save': Defines.saveStr, 'bonus': 0},
      {'save': Defines.saveDex, 'bonus': 0},
      {'save': Defines.saveCon, 'bonus': 0},
      {'save': Defines.saveInt, 'bonus': 0},
      {'save': Defines.saveWis, 'bonus': 0},
      {'save': Defines.saveCha, 'bonus': 0},
    ];

    for (var info in initialSave) {
      db.insert('savingthrow', info);
    }

    const initialSkills = [
      {'skill': Defines.skillAcrobatics, 'proficiency': 0, 'expertise': 0},
      {'skill': Defines.skillAnimalHandling, 'proficiency': 0, 'expertise': 0},
      {'skill': Defines.skillArcana, 'proficiency': 0, 'expertise': 0},
      {'skill': Defines.skillAthletics, 'proficiency': 0, 'expertise': 0},
      {'skill': Defines.skillDeception, 'proficiency': 0, 'expertise': 0},
      {'skill': Defines.skillHistory, 'proficiency': 0, 'expertise': 0},
      {'skill': Defines.skillInsight, 'proficiency': 0, 'expertise': 0},
      {'skill': Defines.skillIntimidation, 'proficiency': 0, 'expertise': 0},
      {'skill': Defines.skillInvestigation, 'proficiency': 0, 'expertise': 0},
      {'skill': Defines.skillMedicine, 'proficiency': 0, 'expertise': 0},
      {'skill': Defines.skillNature, 'proficiency': 0, 'expertise': 0},
      {'skill': Defines.skillPerception, 'proficiency': 0, 'expertise': 0},
      {'skill': Defines.skillPerformance, 'proficiency': 0, 'expertise': 0},
      {'skill': Defines.skillPersuasion, 'proficiency': 0, 'expertise': 0},
      {'skill': Defines.skillReligion, 'proficiency': 0, 'expertise': 0},
      {'skill': Defines.skillSleightOfHand, 'proficiency': 0, 'expertise': 0},
      {'skill': Defines.skillStealth, 'proficiency': 0, 'expertise': 0},
      {'skill': Defines.skillSurvival, 'proficiency': 0, 'expertise': 0},
      {'skill': Defines.skillJackofAllTrades, 'proficiency': 0},
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
      {'stat': Defines.statSpellSaveDC, 'value': 0},
      {'stat': Defines.statSpellAttackBonus, 'value': 0},
    ];

    for (var stat in initialStats) {
      db.insert('stats', stat);
    }

    const initialProfs = [
      {'proficiency': Defines.profLightArmor, 'prof': ""},
      {'proficiency': Defines.profMediumArmor, 'prof': ""},
      {'proficiency': Defines.profHeavyArmor, 'prof': ""},
      {'proficiency': Defines.profShield, 'prof': ""},
      {'proficiency': Defines.profSimpleWeapon, 'prof': ""},
      {'proficiency': Defines.profMartialWeapon, 'prof': ""},
      {'proficiency': Defines.profOtherWeapon, 'prof': ""},
      {'proficiency': Defines.profWeaponList, 'prof': ""},
      {'proficiency': Defines.profLanguages, 'prof': ""},
      {'proficiency': Defines.profTools, 'prof': ""},
    ];

    for (var prof in initialProfs) {
      db.insert('proficiencies', prof);
    }

    const initialSpellSlots = [
      {'spellslot': Defines.slotOne, 'total': 0, 'spent': 0},
      {'spellslot': Defines.slotTwo, 'total': 0, 'spent': 0},
      {'spellslot': Defines.slotThree, 'total': 0, 'spent': 0},
      {'spellslot': Defines.slotFour, 'total': 0, 'spent': 0},
      {'spellslot': Defines.slotFive, 'total': 0, 'spent': 0},
      {'spellslot': Defines.slotSix, 'total': 0, 'spent': 0},
      {'spellslot': Defines.slotSeven, 'total': 0, 'spent': 0},
      {'spellslot': Defines.slotEight, 'total': 0, 'spent': 0},
      {'spellslot': Defines.slotNine, 'total': 0, 'spent': 0},
    ];

    for (var slot in initialSpellSlots) {
      db.insert('spellslots', slot);
    }
  }

  Future<void> createProfile(String profileName) async {
    final databasesPath = await getDatabasesPath();
    final profileDbPath = join(databasesPath, '$profileName.db');

    if (kDebugMode) {
      print('Creating profile database at: $profileDbPath');
    }

    // the Integer for savingthrow and skills are used as substitutes for booleans as sqlite doesnt have booleans
    currentDb =
        await openDatabase(profileDbPath, version: 1, onCreate: (db, version) {
      db.execute('CREATE TABLE info (info TEXT PRIMARY KEY, text TEXT)');
      db.execute('CREATE TABLE stats (stat TEXT PRIMARY KEY, value INTEGER)');
      db.execute(
          'CREATE TABLE savingthrow (save TEXT PRIMARY KEY, bonus INTEGER)');
      db.execute(
          'CREATE TABLE skills (skill TEXT PRIMARY KEY, proficiency INTEGER, expertise INTEGER)');
      db.execute('CREATE TABLE bag (item TEXT PRIMARY KEY, amount INTEGER)');
      db.execute(
          'CREATE TABLE spells (spellname TEXT PRIMARY KEY, status TEXT, level INTEGER, description TEXT)');
      db.execute(
          'CREATE TABLE weapons (weapon TEXT PRIMARY KEY, attribute TEXT, reach TEXT, bonus TEXT, damage TEXT, damagetype TEXT, description TEXT)');
      db.execute(
          'CREATE TABLE proficiencies (proficiency TEXT PRIMARY KEY, prof TEXT)');
      db.execute(
          'CREATE TABLE spellslots (spellslot TEXT PRIMARY KEY, total INTEGER, spent INTEGER)');
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

  Future<void> renameProfile(String oldName, String newName) async {
    final databasesPath = await getDatabasesPath();
    final oldPath = join(databasesPath, '$oldName.db');
    final newPath = join(databasesPath, '$newName.db');

    if (profiles.contains(newName)) {
      throw Exception(
          'Ein Charakter mit dem Namen "$newName" existiert bereits.');
    }

    final File oldFile = File(oldPath);

    if (await oldFile.exists()) {
      await oldFile.rename(newPath);
    }

    profiles[profiles.indexOf(oldName)] = newName;

    if (selectedProfile == oldName) {
      selectedProfile = newName;
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
    String spellString = spellsData.isNotEmpty
        ? spellsData.map((spell) {
            String spellName = spell['spellname'];
            String status = spell['status'];
            String level = spell['level'].toString();
            String description = spell['description'];
            return ' └── $spellName\n     └── Status: $status\n     └── Level: $level\n     └── Description: $description';
          }).join('\n')
        : 'No spells available';

    List<Map<String, dynamic>> weaponsData = await profileDb.query('weapons');
    String weaponsString = weaponsData.isNotEmpty
        ? weaponsData.map((weapon) {
            String weaponName = weapon['weapon'];
            String attribute = weapon['attribute'];
            String reach = weapon['reach'];
            String bonus = weapon['bonus'];
            String damage = weapon['damage'];
            String damageType = weapon['damagetype'];
            String description = weapon['description'];
            return ' └── $weaponName\n     └── Attribute: $attribute\n     └── Reach: $reach\n     └── Bonus: $bonus\n     └── Damage: $damage\n     └── Damage Type: $damageType\n     └── Description: $description';
          }).join('\n')
        : 'No weapons available';

    List<Map<String, dynamic>> skillsData = await profileDb.query('skills');
    String skillsString = skillsData.isNotEmpty
        ? skillsData.map((skill) {
            String skillName = skill['skill'];
            String proficiency = skill['proficiency'].toString();
            String expertise = skill['expertise'].toString();
            return ' └── $skillName\n     └── Proficiency: $proficiency\n     └── Expertise: $expertise';
          }).join('\n')
        : 'No skills available';

    List<Map<String, dynamic>> savingThrowsData =
        await profileDb.query('savingthrow');
    String savingThrowsString = savingThrowsData.isNotEmpty
        ? savingThrowsData.map((savingThrow) {
            String saveName = savingThrow['save'];
            String bonus = savingThrow['bonus'].toString();
            return ' └── $saveName\n     └── Bonus: $bonus';
          }).join('\n')
        : 'No saving throws available';

    List<Map<String, dynamic>> proficienciesData =
        await profileDb.query('proficiencies');
    String proficienciesString = proficienciesData.isNotEmpty
        ? proficienciesData.map((proficiency) {
            String profName = proficiency['proficiency'];
            String profValue = proficiency['prof'];
            return ' └── $profName\n     └── Value: $profValue';
          }).join('\n')
        : 'No proficiencies available';

    List<Map<String, dynamic>> spellSlotsData =
        await profileDb.query('spellslots');
    String spellSlotsString = spellSlotsData.isNotEmpty
        ? spellSlotsData.map((slot) {
            String slotName = slot['spellslot'];
            String total = slot['total'].toString();
            String spent = slot['spent'].toString();
            return ' └── $slotName\n     └── Total: $total\n     └── Spent: $spent';
          }).join('\n')
        : 'No spell slots available';

    return '''
          Character Name: $profileName
          Info:
          └── Race: $race
          └── Class: $classType

          Stats:
          $profileStats

          Bag:
          $bagItems

          Spells:
          $spellString

          Weapons:
          $weaponsString

          Skills:
          $skillsString

          Saving Throws:
          $savingThrowsString

          Proficiencies:
          $proficienciesString

          Spell Slots:
          $spellSlotsString
          ''';
  }

  Future<void> updateStats({
    required String stat,
    int? value,
  }) async {
    if (currentDb == null || value == null) return;

    final List<Map<String, dynamic>> existingStatList = await currentDb!.query(
      'stats',
      where: 'stat = ?',
      whereArgs: [stat],
    );

    Map<String, dynamic>? existingStat;
    if (existingStatList.isNotEmpty) {
      existingStat = existingStatList.first;
    }

    if (existingStat?['value'] != value) {
      await currentDb!.update(
        'stats',
        {'value': value},
        where: 'stat = ?',
        whereArgs: [stat],
      );
    }
  }

  Future<void> updateSavingThrows({
    required String savethrow,
    int? bonus,
  }) async {
    if (currentDb == null || bonus == null) return;

    final List<Map<String, dynamic>> existingSaveList = await currentDb!.query(
      'savingthrow',
      where: 'save = ?',
      whereArgs: [savethrow],
    );

    Map<String, dynamic>? existingSave;
    if (existingSaveList.isNotEmpty) {
      existingSave = existingSaveList.first;
    }

    if (existingSave?['bonus'] != bonus) {
      await currentDb!.update(
        'savingthrow',
        {'bonus': bonus},
        where: 'save = ?',
        whereArgs: [savethrow],
      );
    }
  }

  Future<void> updateSkills({
    required String skill,
    int? proficiency,
    int? expertise,
  }) async {
    if (currentDb == null) return;

    // Query the existing skill
    final List<Map<String, dynamic>> existingSkillList = await currentDb!.query(
      'skills',
      where: 'skill = ?',
      whereArgs: [skill],
    );

    Map<String, dynamic>? existingSkill;
    if (existingSkillList.isNotEmpty) {
      existingSkill = existingSkillList.first;
    }

    final Map<String, dynamic> updates = {
      'proficiency': proficiency ?? existingSkill?['proficiency'],
      'expertise': expertise ?? existingSkill?['expertise'],
    };

    await currentDb!.update(
      'skills',
      updates,
      where: 'skill = ?',
      whereArgs: [skill],
    );
  }

  Future<void> updateBagItem({
    required String itemName,
    int? amount,
  }) async {
    if (currentDb == null) return;

    final List<Map<String, dynamic>> existingItemList = await currentDb!.query(
      'bag',
      where: 'item = ?',
      whereArgs: [itemName],
    );

    Map<String, dynamic>? existingItem;
    if (existingItemList.isNotEmpty) {
      existingItem = existingItemList.first;
    }

    final Map<String, dynamic> updates = {
      'amount': amount ?? existingItem?['amount'],
    };

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
    String? text,
  }) async {
    if (currentDb == null) return;

    final List<Map<String, dynamic>> existingInfoList = await currentDb!.query(
      'info',
      where: 'info = ?',
      whereArgs: [info],
    );

    Map<String, dynamic>? existingInfo;
    if (existingInfoList.isNotEmpty) {
      existingInfo = existingInfoList.first;
    }

    final Map<String, dynamic> updates = {
      'text': text ?? existingInfo?['text'],
    };

    await currentDb!.update(
      'info',
      updates,
      where: 'info = ?',
      whereArgs: [info],
    );
  }

  Future<void> updateProficiencies({
    required String proficiency,
    String? text,
  }) async {
    if (currentDb == null) return;

    final List<Map<String, dynamic>> existingInfoList = await currentDb!.query(
      'proficiencies',
      where: 'proficiency = ?',
      whereArgs: [proficiency],
    );

    Map<String, dynamic>? existingInfo;
    if (existingInfoList.isNotEmpty) {
      existingInfo = existingInfoList.first;
    }

    final Map<String, dynamic> updates = {
      'text': text ?? existingInfo?['text'],
    };

    await currentDb!.update(
      'proficiencies',
      updates,
      where: 'proficiency = ?',
      whereArgs: [proficiency],
    );
  }

  Future<void> updateSpellSlots({
    required String spellslot,
    int? total,
    int? spent,
  }) async {
    if (currentDb == null) return;

    // Query the existing skill
    final List<Map<String, dynamic>> existingSkillList = await currentDb!.query(
      'spellslots',
      where: 'spellslot = ?',
      whereArgs: [spellslot],
    );

    Map<String, dynamic>? existingSkill;
    if (existingSkillList.isNotEmpty) {
      existingSkill = existingSkillList.first;
    }

    final Map<String, dynamic> updates = {
      'total': total ?? existingSkill?['total'],
      'spent': spent ?? existingSkill?['spent'],
    };

    await currentDb!.update(
      'spellslots',
      updates,
      where: 'spellslot = ?',
      whereArgs: [spellslot],
    );
  }

  Future<void> updateWeapons({
    required String weapon,
    String? attribute,
    String? reach,
    String? bonus,
    String? damage,
    String? damagetype,
    String? description,
  }) async {
    if (currentDb == null) return;

    final List<Map<String, dynamic>> existingWeaponList =
        await currentDb!.query(
      'weapons',
      where: 'weapon = ?',
      whereArgs: [weapon],
    );

    Map<String, dynamic>? existingWeapon;
    if (existingWeaponList.isNotEmpty) {
      existingWeapon = existingWeaponList.first;
    }

    final Map<String, dynamic> updates = {
      'weapon': weapon,
      'attribute': attribute ?? existingWeapon?['attribute'],
      'reach': reach ?? existingWeapon?['reach'],
      'bonus': bonus ?? existingWeapon?['bonus'],
      'damage': damage ?? existingWeapon?['damage'],
      'damagetype': damagetype ?? existingWeapon?['damagetype'],
      'description': description ?? existingWeapon?['description'],
    };

    await currentDb!.insert(
      'weapons',
      updates,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    if (kDebugMode) {
      print("Upserted: $updates");
    }
  }

  Future<void> updateSpell({
    required String spellName,
    String? status,
    int? level,
    String? description,
  }) async {
    if (currentDb == null) return;

    final List<Map<String, dynamic>> existingSpellList = await currentDb!.query(
      'spells',
      where: 'spellname = ?',
      whereArgs: [spellName],
    );

    Map<String, dynamic>? existingSpell;
    if (existingSpellList.isNotEmpty) {
      existingSpell = existingSpellList.first;
    }

    final Map<String, dynamic> updates = {
      'status': status ?? existingSpell?['status'],
      'level': level ?? existingSpell?['level'],
      'description': description ?? existingSpell?['description'],
    };

    await currentDb!.update(
      'spells',
      updates,
      where: 'spellname = ?',
      whereArgs: [spellName],
    );
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

  Future<List<Map<String, dynamic>>> getWeapons() async {
    if (currentDb == null) return [];

    final List<Map<String, dynamic>> result = await currentDb!.query('weapons');

    return result;
  }

  Future<List<Map<String, dynamic>>> getProficiencies() async {
    if (currentDb == null) return [];

    final List<Map<String, dynamic>> result =
        await currentDb!.query('proficiencies');

    return result;
  }

  Future<List<Map<String, dynamic>>> getSkills() async {
    if (currentDb == null) return [];

    final List<Map<String, dynamic>> result = await currentDb!.query('skills');

    return result;
  }

  Future<List<Map<String, dynamic>>> getSpellSlots() async {
    if (currentDb == null) return [];

    final List<Map<String, dynamic>> result =
        await currentDb!.query('spellslots');

    return result;
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
