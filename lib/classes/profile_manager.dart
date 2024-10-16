import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:file_picker/file_picker.dart';
import '../configs/defines.dart';

class Character {
  final int id;
  final String name;

  Character({required this.id, required this.name});
}

class ProfileManager {
  List<Character> profiles = [];
  String? selectedProfile;
  int? selectedID;
  Database? currentDb;

  Future<void> initialize() async {
    await loadProfiles();
  }

  Future<void> loadProfiles() async {
    final databasesPath = await getDatabasesPath();
    final dbPath = join(databasesPath, 'characters.db');

    final dbFile = File(dbPath);
    if (!await dbFile.exists()) {
      if (kDebugMode) {
        print("Database doesn't exist yet.");
      }
      return;
    }

    final db = await openDatabase(dbPath);

    try {
      final List<Map<String, dynamic>> results = await db.query('info');

      profiles.clear();

      for (var result in results) {
        Character character = Character(
          id: result['charId'],
          name: result['name'],
        );

        profiles.add(character);
      }
    } catch (e) {
      print("Error querying the database: $e");
    } finally {
      await db.close();
    }
  }

  Future<void> initializeDatabase(Database db, String profileName) async {
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

    await db.transaction((txn) async {
      int insertedCharId = await txn.insert('info', initialInfo);

      var initialSave = {
        'charId': insertedCharId,
        Defines.saveStr: 0,
        Defines.saveDex: 0,
        Defines.saveCon: 0,
        Defines.saveInt: 0,
        Defines.saveWis: 0,
        Defines.saveCha: 0,
      };
      await txn.insert('savingthrow', initialSave);

      var initialSkills = [
        {
          'charId': insertedCharId,
          'skill': Defines.skillAcrobatics,
          'proficiency': 0,
          'expertise': 0
        },
        {
          'charId': insertedCharId,
          'skill': Defines.skillAnimalHandling,
          'proficiency': 0,
          'expertise': 0
        },
        {
          'charId': insertedCharId,
          'skill': Defines.skillArcana,
          'proficiency': 0,
          'expertise': 0
        },
        {
          'charId': insertedCharId,
          'skill': Defines.skillAthletics,
          'proficiency': 0,
          'expertise': 0
        },
        {
          'charId': insertedCharId,
          'skill': Defines.skillDeception,
          'proficiency': 0,
          'expertise': 0
        },
        {
          'charId': insertedCharId,
          'skill': Defines.skillHistory,
          'proficiency': 0,
          'expertise': 0
        },
        {
          'charId': insertedCharId,
          'skill': Defines.skillInsight,
          'proficiency': 0,
          'expertise': 0
        },
        {
          'charId': insertedCharId,
          'skill': Defines.skillIntimidation,
          'proficiency': 0,
          'expertise': 0
        },
        {
          'charId': insertedCharId,
          'skill': Defines.skillInvestigation,
          'proficiency': 0,
          'expertise': 0
        },
        {
          'charId': insertedCharId,
          'skill': Defines.skillMedicine,
          'proficiency': 0,
          'expertise': 0
        },
        {
          'charId': insertedCharId,
          'skill': Defines.skillNature,
          'proficiency': 0,
          'expertise': 0
        },
        {
          'charId': insertedCharId,
          'skill': Defines.skillPerception,
          'proficiency': 0,
          'expertise': 0
        },
        {
          'charId': insertedCharId,
          'skill': Defines.skillPerformance,
          'proficiency': 0,
          'expertise': 0
        },
        {
          'charId': insertedCharId,
          'skill': Defines.skillPersuasion,
          'proficiency': 0,
          'expertise': 0
        },
        {
          'charId': insertedCharId,
          'skill': Defines.skillReligion,
          'proficiency': 0,
          'expertise': 0
        },
        {
          'charId': insertedCharId,
          'skill': Defines.skillSleightOfHand,
          'proficiency': 0,
          'expertise': 0
        },
        {
          'charId': insertedCharId,
          'skill': Defines.skillStealth,
          'proficiency': 0,
          'expertise': 0
        },
        {
          'charId': insertedCharId,
          'skill': Defines.skillSurvival,
          'proficiency': 0,
          'expertise': 0
        },
        {
          'charId': insertedCharId,
          'skill': Defines.skillJackofAllTrades,
          'proficiency': 0
        },
      ];

      Batch batchSkills = txn.batch();
      for (var skill in initialSkills) {
        batchSkills.insert('skills', skill);
      }
      await batchSkills.commit(noResult: true);

      var initialStats = {
        'charId': insertedCharId,
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
      await txn.insert('stats', initialStats);

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
      await txn.insert('proficiencies', initialProfs);

      var initialSpellSlots = [
        {
          'charId': insertedCharId,
          'spellslot': Defines.slotOne,
          'total': 0,
          'spent': 0
        },
        {
          'charId': insertedCharId,
          'spellslot': Defines.slotTwo,
          'total': 0,
          'spent': 0
        },
        {
          'charId': insertedCharId,
          'spellslot': Defines.slotThree,
          'total': 0,
          'spent': 0
        },
        {
          'charId': insertedCharId,
          'spellslot': Defines.slotFour,
          'total': 0,
          'spent': 0
        },
        {
          'charId': insertedCharId,
          'spellslot': Defines.slotFive,
          'total': 0,
          'spent': 0
        },
        {
          'charId': insertedCharId,
          'spellslot': Defines.slotSix,
          'total': 0,
          'spent': 0
        },
        {
          'charId': insertedCharId,
          'spellslot': Defines.slotSeven,
          'total': 0,
          'spent': 0
        },
        {
          'charId': insertedCharId,
          'spellslot': Defines.slotEight,
          'total': 0,
          'spent': 0
        },
        {
          'charId': insertedCharId,
          'spellslot': Defines.slotNine,
          'total': 0,
          'spent': 0
        },
      ];

      Batch batchSpellSlots = txn.batch();
      for (var slot in initialSpellSlots) {
        batchSpellSlots.insert('spellslots', slot);
      }
      await batchSpellSlots.commit(noResult: true);
    });
  }

  Future<void> createProfile(String profileName) async {
    final databasesPath = await getDatabasesPath();
    final profileDbPath = join(databasesPath, 'characters.db');

    currentDb = await openDatabase(profileDbPath, version: 1);
    currentDb!.execute(
        'CREATE TABLE IF NOT EXISTS info (charId INTEGER PRIMARY KEY AUTOINCREMENT, '
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
    currentDb!.execute(
        'CREATE TABLE IF NOT EXISTS Stats (id INTEGER PRIMARY KEY AUTOINCREMENT, '
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
    currentDb!.execute(
        'CREATE TABLE IF NOT EXISTS savingthrow (id INTEGER PRIMARY KEY AUTOINCREMENT, '
        'charId INTEGER, '
        '${Defines.saveStr} INTEGER, '
        '${Defines.saveDex} INTEGER, '
        '${Defines.saveCon} INTEGER, '
        '${Defines.saveInt} INTEGER, '
        '${Defines.saveWis} INTEGER, '
        '${Defines.saveCha} INTEGER, '
        'FOREIGN KEY (charId) REFERENCES info(charId) ON DELETE CASCADE'
        ')');
    currentDb!.execute(
        'CREATE TABLE IF NOT EXISTS proficiencies (id INTEGER PRIMARY KEY AUTOINCREMENT, '
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
    currentDb!.execute(
        'CREATE TABLE IF NOT EXISTS skills (ID INTEGER PRIMARY KEY AUTOINCREMENT, skill TEXT , charId INTEGER, proficiency INTEGER, expertise INTEGER, FOREIGN KEY (charId) REFERENCES info(charId) ON DELETE CASCADE)');
    currentDb!.execute(
        'CREATE TABLE IF NOT EXISTS spellslots (ID INTEGER PRIMARY KEY AUTOINCREMENT, charId INTEGER, spellslot TEXT, total INTEGER, spent INTEGER, FOREIGN KEY (charId) REFERENCES info(charId) ON DELETE CASCADE)');
    currentDb!.execute(
        'CREATE TABLE IF NOT EXISTS bag (ID INTEGER PRIMARY KEY, item TEXT, charId INTEGER, amount INTEGER, FOREIGN KEY (charId) REFERENCES info(charId) ON DELETE CASCADE)');
    currentDb!.execute(
        'CREATE TABLE IF NOT EXISTS spells (spellname TEXT PRIMARY KEY, charId INTEGER, status TEXT, level INTEGER, description TEXT, FOREIGN KEY (charId) REFERENCES info(charId) ON DELETE CASCADE)');
    currentDb!.execute(
        'CREATE TABLE IF NOT EXISTS weapons (weapon TEXT PRIMARY KEY, charId INTEGER, attribute TEXT, reach TEXT, bonus TEXT, damage TEXT, damagetype TEXT, description TEXT, FOREIGN KEY (charId) REFERENCES info(charId) ON DELETE CASCADE)');
    await initializeDatabase(currentDb!, profileName);

    await loadProfiles();
  }

  Future<void> selectProfile(Character profile) async {
    final databasesPath = await getDatabasesPath();
    final profileDbPath = join(databasesPath, 'characters.db');

    if (kDebugMode) {
      print('Selecting profile: ${profile.name}');
    }

    currentDb = await openDatabase(profileDbPath);
    selectedProfile = profile.name;
    selectedID = profile.id;
  }

  Future<void> deleteProfile(Character profile) async {
    selectedID = null;
    selectedProfile = null;

    final databasesPath = await getDatabasesPath();
    final profileDbPath = join(databasesPath, 'characters.db');

    currentDb = await openDatabase(profileDbPath);

    int charId = profile.id;

    await currentDb!.delete('info', where: 'charId = ?', whereArgs: [charId]);
    await currentDb!.delete('Stats', where: 'charId = ?', whereArgs: [charId]);
    await currentDb!
        .delete('savingthrow', where: 'charId = ?', whereArgs: [charId]);
    await currentDb!
        .delete('proficiencies', where: 'charId = ?', whereArgs: [charId]);
    await currentDb!.delete('skills', where: 'charId = ?', whereArgs: [charId]);
    await currentDb!
        .delete('spellslots', where: 'charId = ?', whereArgs: [charId]);
    await currentDb!.delete('bag', where: 'charId = ?', whereArgs: [charId]);
    await currentDb!.delete('spells', where: 'charId = ?', whereArgs: [charId]);
    await currentDb!
        .delete('weapons', where: 'charId = ?', whereArgs: [charId]);

    await loadProfiles();
  }

  Future<void> renameProfile(String oldName, String newName) async {
    final databasesPath = await getDatabasesPath();
    final profileDbPath = join(databasesPath, 'characters.db');

    if (profiles.any((profile) => profile.name == newName)) {
      throw Exception(
          'Ein Charakter mit dem Namen "$newName" existiert bereits.');
    }

    currentDb = await openDatabase(profileDbPath);
    final index = profiles.indexWhere((profile) => profile.name == oldName);

    if (index != -1) {
      profiles[index] = Character(id: profiles[index].id, name: newName);
      if (selectedProfile == oldName) {
        selectedProfile = newName;
        selectedID = profiles[index].id;
      }

      await currentDb!.execute(
          'INSERT OR REPLACE INTO info (charId, ${Defines.infoName}) VALUES (?, ?)',
          [profiles[index].id, newName]);
    }

    await loadProfiles();

    if (kDebugMode) {
      print('Renamed profile from $oldName to $newName');
    }
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
    if (currentDb == null || value == null || selectedID == null) return;

    final List<Map<String, dynamic>> existingStatList = await currentDb!.query(
      'Stats',
      where: 'charId = ? AND stat = ?',
      whereArgs: [selectedID, stat],
    );

    Map<String, dynamic>? existingStat;
    if (existingStatList.isNotEmpty) {
      existingStat = existingStatList.first;
    }

    if (existingStat?['value'] != value) {
      await currentDb!.update(
        'Stats',
        {'value': value},
        where: 'charId = ? AND stat = ?',
        whereArgs: [selectedID, stat],
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
      where: 'charId = ? AND save = ?',
      whereArgs: [selectedID, savethrow],
    );

    Map<String, dynamic>? existingSave;
    if (existingSaveList.isNotEmpty) {
      existingSave = existingSaveList.first;
    }

    if (existingSave?['bonus'] != bonus) {
      await currentDb!.update(
        'savingthrow',
        {'bonus': bonus},
        where: 'charId = ? AND save = ?',
        whereArgs: [selectedID, savethrow],
      );
    }
  }

  Future<void> updateSkills({
    required String skill,
    int? proficiency,
    int? expertise,
  }) async {
    if (currentDb == null) return;

    final List<Map<String, dynamic>> existingSkillList = await currentDb!.query(
      'skills',
      where: 'charId = ? AND skill = ?',
      whereArgs: [selectedID, skill],
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
      where: 'charId = ? AND skill = ?',
      whereArgs: [selectedID, skill],
    );
  }

  Future<void> updateBagItem({
    required String itemName,
    int? amount,
  }) async {
    if (currentDb == null) return;

    final List<Map<String, dynamic>> existingItemList = await currentDb!.query(
      'bag',
      where: 'charId = ? AND item = ?',
      whereArgs: [selectedID, itemName],
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
        where: 'charId = ? AND item = ?',
        whereArgs: [selectedID, itemName],
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
      where: 'charId = ?',
      whereArgs: [selectedID],
    );

    Map<String, dynamic>? existingInfo;
    if (existingInfoList.isNotEmpty) {
      existingInfo = existingInfoList.first;
    }

    final Map<String, dynamic> updates = {
      info: text ?? existingInfo?['text'],
    };

    await currentDb!.update(
      'info',
      updates,
      where: 'charId = ? AND $info',
      whereArgs: [selectedID],
    );
  }

  Future<void> updateProficiencies({
    required String proficiency,
    String? text,
  }) async {
    if (currentDb == null) return;

    final List<Map<String, dynamic>> existingInfoList = await currentDb!.query(
      'proficiencies',
      where: 'charId = ? AND proficiency = ?',
      whereArgs: [selectedID, proficiency],
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
      where: 'charId = ? AND proficiency = ?',
      whereArgs: [selectedID, proficiency],
    );
  }

  Future<void> updateSpellSlots({
    required String spellslot,
    int? total,
    int? spent,
  }) async {
    if (currentDb == null) return;

    final List<Map<String, dynamic>> existingSkillList = await currentDb!.query(
      'spellslots',
      where: 'charId = ? AND spellslot = ?',
      whereArgs: [selectedID, spellslot],
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
      where: 'charId = ? AND spellslot = ?',
      whereArgs: [selectedID, spellslot],
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
      where: 'charId = ? AND weapon = ?',
      whereArgs: [selectedID, weapon],
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
      where: 'charId = ? AND spellname = ?',
      whereArgs: [selectedID, spellName],
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
      where: 'charId = ? AND spellname = ?',
      whereArgs: [selectedID, spellName],
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

  Future<List<Map<String, dynamic>>> getProfileInfo() async {
    if (currentDb == null) return [];

    final List<Map<String, dynamic>> result = await currentDb!.query(
      'info',
      where: 'charId = ?',
      whereArgs: [selectedID],
    );

    return result;
  }

  Future<List<Map<String, dynamic>>> getWeapons() async {
    if (currentDb == null) return [];

    final List<Map<String, dynamic>> result = await currentDb!.query(
      'weapons',
      where: 'charId = ?',
      whereArgs: [selectedID],
    );

    return result;
  }

  Future<List<Map<String, dynamic>>> getProficiencies() async {
    if (currentDb == null) return [];

    final List<Map<String, dynamic>> result = await currentDb!.query(
      'proficiencies',
      where: 'charId = ?',
      whereArgs: [selectedID],
    );

    return result;
  }

  Future<List<Map<String, dynamic>>> getSkills() async {
    if (currentDb == null) return [];

    final List<Map<String, dynamic>> result = await currentDb!.query(
      'skills',
      where: 'charId = ?',
      whereArgs: [selectedID],
    );

    return result;
  }

  Future<List<Map<String, dynamic>>> getSpellSlots() async {
    if (currentDb == null) return [];

    final List<Map<String, dynamic>> result = await currentDb!.query(
      'spellslots',
      where: 'charId = ?',
      whereArgs: [selectedID],
    );

    return result;
  }

  Future<List<Map<String, dynamic>>> getAllBagItems() async {
    if (currentDb == null) return [];

    final List<Map<String, dynamic>> result = await currentDb!.query(
      'bag',
      where: 'charId = ?',
      whereArgs: [selectedID],
    );

    return result;
  }

  Future<List<Map<String, dynamic>>> getAllSpellsWithLevels() async {
    if (currentDb == null) return [];

    final List<Map<String, dynamic>> result = await currentDb!.query(
      'spells',
      columns: ['spellname', 'level'],
      where: 'charId = ?',
      whereArgs: [selectedID],
    );

    return result;
  }

  Future<String?> getSpellDescription(String spellName) async {
    if (currentDb == null) return null;

    final List<Map<String, dynamic>> result = await currentDb!.query(
      'spells',
      columns: ['description'],
      where: 'charId = ? AND spellname = ?',
      whereArgs: [selectedID, spellName],
    );

    return result.isNotEmpty ? result.first['description'] as String : null;
  }

  bool hasProfiles() {
    return profiles.isNotEmpty;
  }

  List<Character> getProfiles() {
    return profiles;
  }

  Future<void> closeDB() async {
    if (currentDb != null) {
      await currentDb!.close();
      if (kDebugMode) {
        print('Closing profile database');
      }
    }
  }
}
