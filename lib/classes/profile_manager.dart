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


  void initializeDatabase(Database db, String profileName) async {

  var initialInfo = {
    Defines.infoName: profileName,
    Defines.infoRace: '',
    Defines.infoClass: '',
    Defines.infoOrigin: '',
    Defines.infoBackground: '',
    Defines.infoPersonalityTraits: '',
    Defines.infoIdeals: '',
    Defines.infoBonds: '',
    Defines.infoFlaws: '',
    Defines.infoAge: '',
    Defines.infoGod: '',
    Defines.infoSize: '',
    Defines.infoHeight: '',
    Defines.infoWeight: '',
    Defines.infoSex: '',
    Defines.infoAlignment: '',
    Defines.infoEyeColour: '',
    Defines.infoHairColour: '',
    Defines.infoSkinColour: '',
    Defines.infoAppearance: '',
    Defines.infoTraits: '',
    Defines.infoSpellcastingClass: '',
    Defines.infoSpellcastingAbility: '',
  };

  int insertedCharId  = await db.insert('info', initialInfo);
    
    var initialSave = {
      'charId': insertedCharId,
      Defines.saveStr: 0,
      Defines.saveDex: 0,
      Defines.saveCon: 0,
      Defines.saveInt: 0,
      Defines.saveWis: 0,
      Defines.saveCha: 0,
    };

    db.insert('savingthrow', initialSave);

    var initialSkills = [
      {'charId': insertedCharId, 'skill': Defines.skillAcrobatics, 'proficiency': 0, 'expertise': 0},
      {'charId': insertedCharId, 'skill': Defines.skillAnimalHandling, 'proficiency': 0, 'expertise': 0},
      {'charId': insertedCharId, 'skill': Defines.skillArcana, 'proficiency': 0, 'expertise': 0},
      {'charId': insertedCharId, 'skill': Defines.skillAthletics, 'proficiency': 0, 'expertise': 0},
      {'charId': insertedCharId, 'skill': Defines.skillDeception, 'proficiency': 0, 'expertise': 0},
      {'charId': insertedCharId, 'skill': Defines.skillHistory, 'proficiency': 0, 'expertise': 0},
      {'charId': insertedCharId, 'skill': Defines.skillInsight, 'proficiency': 0, 'expertise': 0},
      {'charId': insertedCharId, 'skill': Defines.skillIntimidation, 'proficiency': 0, 'expertise': 0},
      {'charId': insertedCharId, 'skill': Defines.skillInvestigation, 'proficiency': 0, 'expertise': 0},
      {'charId': insertedCharId, 'skill': Defines.skillMedicine, 'proficiency': 0, 'expertise': 0},
      {'charId': insertedCharId, 'skill': Defines.skillNature, 'proficiency': 0, 'expertise': 0},
      {'charId': insertedCharId, 'skill': Defines.skillPerception, 'proficiency': 0, 'expertise': 0},
      {'charId': insertedCharId, 'skill': Defines.skillPerformance, 'proficiency': 0, 'expertise': 0},
      {'charId': insertedCharId, 'skill': Defines.skillPersuasion, 'proficiency': 0, 'expertise': 0},
      {'charId': insertedCharId, 'skill': Defines.skillReligion, 'proficiency': 0, 'expertise': 0},
      {'charId': insertedCharId, 'skill': Defines.skillSleightOfHand, 'proficiency': 0, 'expertise': 0},
      {'charId': insertedCharId, 'skill': Defines.skillStealth, 'proficiency': 0, 'expertise': 0},
      {'charId': insertedCharId, 'skill': Defines.skillSurvival, 'proficiency': 0, 'expertise': 0},
      {'charId': insertedCharId, 'skill': Defines.skillJackofAllTrades, 'proficiency': 0},
    ];

    for (var info in initialSkills) {
      db.insert('skills', info);
    }

    var initialStats = {
      'charId': insertedCharId, // Assuming you have the inserted character ID here
      Defines.statArmor: 10,
      Defines.statLevel: 1,
      Defines.statXP: 0,
      Defines.statInspiration: 1,
      Defines.statProficiencyBonus: 1,
      Defines.statInitiative: 1,
      Defines.statMovement: 1,
      Defines.statMaxHP: 1,
      Defines.statCurrentHP: 1,
      Defines.statTempHP: 1,
      Defines.statHitDice: 1,
      Defines.statSTR: 0,
      Defines.statDEX: 0,
      Defines.statCON: 0,
      Defines.statINT: 0,
      Defines.statWIS: 0,
      Defines.statCHA: 0,
      Defines.statSpellSaveDC: 0,
      Defines.statSpellAttackBonus: 0,
    };

    db.insert('stats', initialStats);
    
    var initialProfs = {
      'charId': insertedCharId,
      Defines.profLightArmor: '',
      Defines.profMediumArmor: '',
      Defines.profHeavyArmor: '',
      Defines.profShield: '',
      Defines.profSimpleWeapon: '',
      Defines.profMartialWeapon: '',
      Defines.profOtherWeapon: '',
      Defines.profWeaponList: '',
      Defines.profLanguages: '',
      Defines.profTools: '',
    };

    db.insert('proficiencies', initialProfs);

    var initialSpellSlots = [
      {'charId': insertedCharId, 'spellslot': Defines.slotOne, 'total': 0, 'spent': 0},
      {'charId': insertedCharId, 'spellslot': Defines.slotTwo, 'total': 0, 'spent': 0},
      {'charId': insertedCharId, 'spellslot': Defines.slotThree, 'total': 0, 'spent': 0},
      {'charId': insertedCharId, 'spellslot': Defines.slotFour, 'total': 0, 'spent': 0},
      {'charId': insertedCharId, 'spellslot': Defines.slotFive, 'total': 0, 'spent': 0},
      {'charId': insertedCharId, 'spellslot': Defines.slotSix, 'total': 0, 'spent': 0},
      {'charId': insertedCharId, 'spellslot': Defines.slotSeven, 'total': 0, 'spent': 0},
      {'charId': insertedCharId, 'spellslot': Defines.slotEight, 'total': 0, 'spent': 0},
      {'charId': insertedCharId, 'spellslot': Defines.slotNine, 'total': 0, 'spent': 0},
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
      //db.execute('CREATE TABLE info (info TEXT PRIMARY KEY, text TEXT)');
    db.execute(
      'CREATE TABLE info (charId INTEGER PRIMARY KEY AUTOINCREMENT, '
      '${Defines.infoName} TEXT, '
      '${Defines.infoRace} TEXT, '
      '${Defines.infoClass} TEXT, '
      '${Defines.infoOrigin} TEXT, '
      '${Defines.infoBackground} TEXT, '
      '${Defines.infoPersonalityTraits} TEXT, '
      '${Defines.infoIdeals} TEXT, '
      '${Defines.infoBonds} TEXT, '
      '${Defines.infoFlaws} TEXT, '
      '${Defines.infoAge} TEXT, '
      '${Defines.infoGod} TEXT, '
      '${Defines.infoSize} TEXT, '
      '${Defines.infoHeight} TEXT, '
      '${Defines.infoWeight} TEXT, '
      '${Defines.infoSex} TEXT, '
      '${Defines.infoAlignment} TEXT, '
      '${Defines.infoEyeColour} TEXT, '
      '${Defines.infoHairColour} TEXT, '
      '${Defines.infoSkinColour} TEXT, '
      '${Defines.infoAppearance} TEXT, '
      '${Defines.infoTraits} TEXT, '
      '${Defines.infoSpellcastingClass} TEXT, '
      '${Defines.infoSpellcastingAbility} TEXT'
      ')');
    db.execute(
      'CREATE TABLE Stats (id INTEGER PRIMARY KEY AUTOINCREMENT, '
      'charId INTEGER, '
      '${Defines.statArmor} INTEGER, '
      '${Defines.statLevel} INTEGER, '
      '${Defines.statXP} INTEGER, '
      '${Defines.statInspiration} INTEGER, '
      '${Defines.statProficiencyBonus} INTEGER, '
      '${Defines.statInitiative} INTEGER, '
      '${Defines.statMovement} INTEGER, '
      '${Defines.statMaxHP} INTEGER, '
      '${Defines.statCurrentHP} INTEGER, '
      '${Defines.statTempHP} INTEGER, '
      '${Defines.statHitDice} INTEGER, '
      '${Defines.statSTR} INTEGER, '
      '${Defines.statDEX} INTEGER, '
      '${Defines.statCON} INTEGER, '
      '${Defines.statINT} INTEGER, '
      '${Defines.statWIS} INTEGER, '
      '${Defines.statCHA} INTEGER, '
      '${Defines.statSpellSaveDC} INTEGER, '
      '${Defines.statSpellAttackBonus} INTEGER, '
      'FOREIGN KEY (charId) REFERENCES info(charId) ON DELETE CASCADE'
      ')');
    db.execute(
      'CREATE TABLE savingthrow (id INTEGER PRIMARY KEY AUTOINCREMENT, '
      'charId INTEGER, '
      '${Defines.saveStr} INTEGER, '
      '${Defines.saveDex} INTEGER, '
      '${Defines.saveCon} INTEGER, '
      '${Defines.saveInt} INTEGER, '
      '${Defines.saveWis} INTEGER, '
      '${Defines.saveCha} INTEGER, '
      'FOREIGN KEY (charId) REFERENCES info(charId) ON DELETE CASCADE'
      ')');
    db.execute(
      'CREATE TABLE proficiencies (id INTEGER PRIMARY KEY AUTOINCREMENT, '
      'charId INTEGER, '
      '${Defines.profLightArmor} TEXT, '
      '${Defines.profMediumArmor} TEXT, '
      '${Defines.profHeavyArmor} TEXT, '
      '${Defines.profShield} TEXT, '
      '${Defines.profSimpleWeapon} TEXT, '
      '${Defines.profMartialWeapon} TEXT, '
      '${Defines.profOtherWeapon} TEXT, '
      '${Defines.profWeaponList} TEXT, '
      '${Defines.profLanguages} TEXT, '
      '${Defines.profTools} TEXT, '
      'FOREIGN KEY (charId) REFERENCES info(charId) ON DELETE CASCADE'
      ')');
    db.execute(
      'CREATE TABLE skills (skill TEXT PRIMARY KEY, charId INTEGER, proficiency INTEGER, expertise INTEGER, FOREIGN KEY (charId) REFERENCES info(charId) ON DELETE CASCADE)'
      );
      
    db.execute(
      'CREATE TABLE spellslots (ID INTEGER PRIMARY KEY AUTOINCREMENT, charId INTEGER, spellslot TEXT, total INTEGER, spent INTEGER, FOREIGN KEY (charId) REFERENCES info(charId) ON DELETE CASCADE)'
      );
    db.execute(
      'CREATE TABLE bag (ID INTEGER PRIMARY KEY, item TEXT, charId INTEGER, amount INTEGER, FOREIGN KEY (charId) REFERENCES info(charId) ON DELETE CASCADE)'
      );
    
    db.execute(
      'CREATE TABLE spells (spellname TEXT PRIMARY KEY, charId INTEGER, status TEXT, level INTEGER, description TEXT, FOREIGN KEY (charId) REFERENCES info(charId) ON DELETE CASCADE)');
      
    db.execute(
      'CREATE TABLE weapons (weapon TEXT PRIMARY KEY, charId INTEGER, attribute TEXT, reach TEXT, bonus TEXT, damage TEXT, damagetype TEXT, description TEXT, FOREIGN KEY (charId) REFERENCES info(charId) ON DELETE CASCADE)');
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
