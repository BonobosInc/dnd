import 'dart:io';
import 'package:dnd/classes/wiki_classes.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:xml/xml.dart';
import 'package:dnd/configs/defines.dart';

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
      if (kDebugMode) {
        print("Error querying the database: $e");
      }
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
        Defines.statInspiration: 0,
        Defines.statProficiencyBonus: 0,
        Defines.statInitiative: 0,
        Defines.statMovement: "0m",
        Defines.statMaxHP: 0,
        Defines.statCurrentHP: 0,
        Defines.statTempHP: 0,
        Defines.statCurrentHitDice: 0,
        Defines.statMaxHitDice: 0,
        Defines.statHitDiceFactor: "",
        Defines.statSTR: 10,
        Defines.statDEX: 10,
        Defines.statCON: 10,
        Defines.statINT: 10,
        Defines.statWIS: 10,
        Defines.statCHA: 10,
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

      var initialBag = {
        'charId': insertedCharId,
        Defines.bagPlatin: 0,
        Defines.bagGold: 0,
        Defines.bagElectrum: 0,
        Defines.bagSilver: 0,
        Defines.bagCopper: 0,
      };
      await txn.insert('bag', initialBag);

      var initialSpellSlots = [
        {
          'charId': insertedCharId,
          'spellslot': Defines.slotZero,
          'total': 0,
          'spent': 0
        },
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
        '${Defines.infoBackstory} TEXT, '
        '${Defines.infoNotes} TEXT, '
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
        '${Defines.statMovement} TEXT, '
        '${Defines.statMaxHP} INTEGER, '
        '${Defines.statCurrentHP} INTEGER, '
        '${Defines.statTempHP} INTEGER, '
        '${Defines.statCurrentHitDice} INTEGER, '
        '${Defines.statMaxHitDice} INTEGER, '
        '${Defines.statHitDiceFactor} TEXT, '
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
        '${Defines.profArmor} TEXT, '
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
    currentDb!.execute('CREATE TABLE IF NOT EXISTS bag (ID INTEGER PRIMARY KEY,'
        'charId INTEGER, '
        '${Defines.bagPlatin} INTEGER, '
        '${Defines.bagGold} INTEGER, '
        '${Defines.bagElectrum} INTEGER, '
        '${Defines.bagSilver} INTEGER, '
        '${Defines.bagCopper} INTEGER, '
        'FOREIGN KEY (charId) REFERENCES info(charId) ON DELETE CASCADE)');
    currentDb!.execute(
        'CREATE TABLE IF NOT EXISTS skills (ID INTEGER PRIMARY KEY AUTOINCREMENT, skill TEXT , charId INTEGER, proficiency INTEGER, expertise INTEGER, FOREIGN KEY (charId) REFERENCES info(charId) ON DELETE CASCADE)');
    currentDb!.execute(
        'CREATE TABLE IF NOT EXISTS spellslots (ID INTEGER PRIMARY KEY AUTOINCREMENT, charId INTEGER, spellslot TEXT, total INTEGER, spent INTEGER, FOREIGN KEY (charId) REFERENCES info(charId) ON DELETE CASCADE)');
    currentDb!.execute(
        'CREATE TABLE IF NOT EXISTS spells (ID INTEGER PRIMARY KEY AUTOINCREMENT, spellname TEXT, charId INTEGER, status TEXT, level INTEGER, description TEXT, FOREIGN KEY (charId) REFERENCES info(charId) ON DELETE CASCADE)');
    currentDb!.execute(
        'CREATE TABLE IF NOT EXISTS weapons (ID INTEGER PRIMARY KEY AUTOINCREMENT, weapon TEXT, charId INTEGER, attribute TEXT, reach TEXT, bonus TEXT, damage TEXT, damagetype TEXT, description TEXT, FOREIGN KEY (charId) REFERENCES info(charId) ON DELETE CASCADE)');
    currentDb!.execute(
        'CREATE TABLE IF NOT EXISTS feats (ID INTEGER PRIMARY KEY AUTOINCREMENT, featname TEXT, charId INTEGER, description TEXT, type TEXT, FOREIGN KEY (charId) REFERENCES info(charId) ON DELETE CASCADE)');
    currentDb!.execute(
        'CREATE TABLE IF NOT EXISTS items (ID INTEGER PRIMARY KEY AUTOINCREMENT, itemname TEXT, charId INTEGER, description TEXT, type TEXT, FOREIGN KEY (charId) REFERENCES info(charId) ON DELETE CASCADE)');
    currentDb!.execute(
        'CREATE TABLE IF NOT EXISTS tracker (ID INTEGER PRIMARY KEY AUTOINCREMENT, trackername TEXT, charId INTEGER, value INTEGER, max INTEGER, FOREIGN KEY (charId) REFERENCES info(charId) ON DELETE CASCADE)');
    currentDb!.execute('''
  CREATE TABLE IF NOT EXISTS creatures (
    ID INTEGER PRIMARY KEY AUTOINCREMENT,
    charId INTEGER,
    name TEXT,
    size TEXT,
    type TEXT,
    alignment TEXT,
    ac INTEGER,
    hp TEXT,
    currentHP INTEGER,
    maxHP INTEGER,
    speed TEXT,
    str INTEGER,
    dex INTEGER,
    con INTEGER,
    intScore INTEGER,
    wis INTEGER,
    cha INTEGER,
    saves TEXT,
    skills TEXT,
    resistances TEXT,
    vulnerabilities TEXT,
    immunities TEXT,
    conditionImmunities TEXT,
    senses TEXT,
    passivePerception INTEGER,
    languages TEXT,
    cr TEXT,
    FOREIGN KEY (charId) REFERENCES info(charId) ON DELETE CASCADE
  )
''');
    currentDb!.execute('''
  CREATE TABLE IF NOT EXISTS creature_traits (
    ID INTEGER PRIMARY KEY AUTOINCREMENT,
    charId INTEGER,
    creature_id INTEGER,
    trait_name TEXT,
    trait_description TEXT,
    FOREIGN KEY (creature_id) REFERENCES creatures(ID) ON DELETE CASCADE,
    FOREIGN KEY (charId) REFERENCES info(charId) ON DELETE CASCADE
  )
''');
    currentDb!.execute('''
  CREATE TABLE IF NOT EXISTS creature_actions (
    ID INTEGER PRIMARY KEY AUTOINCREMENT,
    charId INTEGER,
    creature_id INTEGER,
    action_name TEXT,
    action_description TEXT,
    action TEXT,
    FOREIGN KEY (creature_id) REFERENCES creatures(ID) ON DELETE CASCADE,
    FOREIGN KEY (charId) REFERENCES info(charId) ON DELETE CASCADE
  )
''');
    currentDb!.execute('''
  CREATE TABLE IF NOT EXISTS creature_legendary_actions (
    ID INTEGER PRIMARY KEY AUTOINCREMENT,
    charId INTEGER,
    creature_id INTEGER,
    legendary_action_name TEXT,
    legendary_action_description TEXT,
    FOREIGN KEY (creature_id) REFERENCES creatures(ID) ON DELETE CASCADE,
    FOREIGN KEY (charId) REFERENCES info(charId) ON DELETE CASCADE
  )
''');

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
    await currentDb!.delete('feats', where: 'charId = ?', whereArgs: [charId]);

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

  Future<void> clearDatabase() async {
    final databasesPath = await getDatabasesPath();
    final profileDbPath = join(databasesPath, 'characters.db');

    if (currentDb != null) {
      await currentDb!.close();
      currentDb = null;
    }

    try {
      await deleteDatabase(profileDbPath);
      if (kDebugMode) {
        print('Database deleted successfully.');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error deleting database: $e');
      }
    }
  }

  Future<void> updateStats({
    required String field,
    required dynamic value,
  }) async {
    if (currentDb == null) return;

    final Map<String, dynamic> updates = {
      field: value,
    };

    await currentDb!.update(
      'stats',
      updates,
      where: 'charId = ?',
      whereArgs: [selectedID],
    );
  }

  Future<void> updateSavingThrows({
    required String field,
    required dynamic value,
  }) async {
    if (currentDb == null) return;

    final Map<String, dynamic> updates = {
      field: value,
    };

    await currentDb!.update(
      'savingthrow',
      updates,
      where: 'charId = ?',
      whereArgs: [selectedID],
    );
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

  Future<void> updateBag({
    required String field,
    required dynamic value,
  }) async {
    if (currentDb == null) return;

    final Map<String, dynamic> updates = {
      field: value,
    };

    await currentDb!.update(
      'bag',
      updates,
      where: 'charId = ?',
      whereArgs: [selectedID],
    );
  }

  Future<void> updateProfileInfo({
    required String field,
    required dynamic value,
  }) async {
    if (currentDb == null) return;

    final Map<String, dynamic> updates = {
      field: value,
    };

    await currentDb!.update(
      'info',
      updates,
      where: 'charId = ?',
      whereArgs: [selectedID],
    );
  }

  Future<void> updateProficiencies({
    required String field,
    required dynamic value,
  }) async {
    if (currentDb == null) return;

    final Map<String, dynamic> updates = {
      field: value,
    };

    await currentDb!.update(
      'proficiencies',
      updates,
      where: 'charId = ?',
      whereArgs: [selectedID],
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
    required uuid,
    String? weapon,
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
      where: 'charId = ? AND ID = ?',
      whereArgs: [selectedID, uuid],
    );

    final Map<String, dynamic> updates = {
      'weapon': weapon,
      'attribute': attribute,
      'reach': reach,
      'bonus': bonus,
      'damage': damage,
      'damagetype': damagetype,
      'description': description,
    };

    if (existingWeaponList.isNotEmpty) {
      final Map<String, dynamic> existingWeapon = existingWeaponList.first;
      updates.forEach((key, value) {
        if (value == null) {
          updates[key] = existingWeapon[key];
        }
      });
      await currentDb!.update(
        'weapons',
        updates,
        where: 'charId = ? AND ID = ?',
        whereArgs: [selectedID, uuid],
      );
    } else {
      await currentDb!.insert(
        'weapons',
        updates,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
  }

  Future<void> addWeapon({
    required String weapon,
    String? attribute,
    String? reach,
    String? bonus,
    String? damage,
    String? damagetype,
    String? description,
  }) async {
    if (currentDb == null) return;

    final Map<String, dynamic> weapondata = {
      'weapon': weapon,
      'charId': selectedID,
      'attribute': attribute,
      'reach': reach,
      'bonus': bonus,
      'damage': damage,
      'damagetype': damagetype,
      'description': description,
    };

    try {
      await currentDb!.insert(
        'weapons',
        weapondata,
        conflictAlgorithm: ConflictAlgorithm.abort,
      );
    } catch (e) {
      if (kDebugMode) {
        print('Error adding weapon: $e');
      }
    }
  }

  Future<void> removeweapon(int uuid) async {
    if (currentDb == null) return;

    await currentDb!.delete(
      'weapons',
      where: 'charId = ? AND ID = ?',
      whereArgs: [selectedID, uuid],
    );
  }

  Future<void> updateSpell({
    required uuid,
    String? spellName,
    String? status,
    int? level,
    String? description,
  }) async {
    if (currentDb == null) return;

    final List<Map<String, dynamic>> existingSpellList = await currentDb!.query(
      'spells',
      where: 'charId = ? AND ID = ?',
      whereArgs: [selectedID, uuid],
    );

    final Map<String, dynamic> updates = {
      'spellname': spellName,
      'status': status,
      'level': level,
      'description': description,
    };

    if (existingSpellList.isNotEmpty) {
      final Map<String, dynamic> existingSpell = existingSpellList.first;
      updates.forEach((key, value) {
        if (value == null) {
          updates[key] = existingSpell[key];
        }
      });
      await currentDb!.update(
        'spells',
        updates,
        where: 'charId = ? AND ID = ?',
        whereArgs: [selectedID, uuid],
      );
    } else {
      await currentDb!.insert(
        'spells',
        updates,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
  }

  Future<void> addSpell({
    required String spellName,
    String? status,
    int? level,
    String? description,
  }) async {
    if (currentDb == null) return;

    final Map<String, dynamic> spellData = {
      'charId': selectedID,
      'spellname': spellName,
      'status': status,
      'level': level,
      'description': description,
    };

    try {
      await currentDb!.insert(
        'spells',
        spellData,
        conflictAlgorithm: ConflictAlgorithm.abort,
      );
    } catch (e) {
      if (kDebugMode) {
        print('Error adding spell: $e');
      }
    }
  }

  Future<void> removeSpell(int uuid) async {
    if (currentDb == null) return;

    await currentDb!.delete(
      'spells',
      where: 'charId = ? AND ID = ?',
      whereArgs: [selectedID, uuid],
    );
  }

  Future<void> updateFeat({
    required uuid,
    String? featName,
    String? description,
    String? type,
  }) async {
    if (currentDb == null) return;

    final List<Map<String, dynamic>> existingFeatList = await currentDb!.query(
      'feats',
      where: 'charId = ? AND ID = ?',
      whereArgs: [selectedID, uuid],
    );

    final Map<String, dynamic> updates = {
      'featname': featName,
      'description': description,
      'type': type,
    };

    if (existingFeatList.isNotEmpty) {
      final Map<String, dynamic> existingFeat = existingFeatList.first;
      updates.forEach((key, value) {
        if (value == null) {
          updates[key] = existingFeat[key];
        }
      });
      await currentDb!.update(
        'feats',
        updates,
        where: 'charId = ? AND ID = ?',
        whereArgs: [selectedID, uuid],
      );
    } else {
      await currentDb!.insert(
        'feats',
        updates,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
  }

  Future<void> addFeat({
    required String featName,
    String? description,
    String? type,
  }) async {
    if (currentDb == null) return;

    final Map<String, dynamic> spellData = {
      'charId': selectedID,
      'featname': featName,
      'description': description,
      'type': type,
    };

    try {
      await currentDb!.insert(
        'feats',
        spellData,
        conflictAlgorithm: ConflictAlgorithm.abort,
      );
    } catch (e) {
      if (kDebugMode) {
        print('Error adding feat: $e');
      }
    }
  }

  Future<void> removeFeat(int uuid) async {
    if (currentDb == null) return;

    await currentDb!.delete(
      'feats',
      where: 'charId = ? AND ID = ?',
      whereArgs: [selectedID, uuid],
    );
  }

  Future<void> updateItem({
    required uuid,
    String? itemname,
    String? description,
    String? type,
  }) async {
    if (currentDb == null) return;

    final List<Map<String, dynamic>> existingItemList = await currentDb!.query(
      'items',
      where: 'charId = ? AND ID = ?',
      whereArgs: [selectedID, uuid],
    );

    final Map<String, dynamic> updates = {
      'itemname': itemname,
      'description': description,
      'type': type,
    };

    if (existingItemList.isNotEmpty) {
      final Map<String, dynamic> existingItem = existingItemList.first;
      updates.forEach((key, value) {
        if (value == null) {
          updates[key] = existingItem[key];
        }
      });
      await currentDb!.update(
        'items',
        updates,
        where: 'charId = ? AND ID = ?',
        whereArgs: [selectedID, uuid],
      );
    } else {
      await currentDb!.insert(
        'items',
        updates,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
  }

  Future<void> addItem({
    required String itemname,
    String? description,
    String? type,
  }) async {
    if (currentDb == null) return;

    final Map<String, dynamic> itemData = {
      'charId': selectedID,
      'itemname': itemname,
      'description': description,
      'type': type,
    };

    try {
      await currentDb!.insert(
        'items',
        itemData,
        conflictAlgorithm: ConflictAlgorithm.abort,
      );
    } catch (e) {
      if (kDebugMode) {
        print('Error adding item: $e');
      }
    }
  }

  Future<void> removeItem(int uuid) async {
    if (currentDb == null) return;

    await currentDb!.delete(
      'items',
      where: 'charId = ? AND ID = ?',
      whereArgs: [selectedID, uuid],
    );
  }

  Future<void> updateTracker({
    required uuid,
    String? tracker,
    int? value,
    int? max,
  }) async {
    if (currentDb == null) return;

    final List<Map<String, dynamic>> existingTrackerList =
        await currentDb!.query(
      'tracker',
      where: 'charId = ? AND ID = ?',
      whereArgs: [selectedID, uuid],
    );

    final Map<String, dynamic> updates = {
      'trackername': tracker,
      'value': value,
      'max': max,
    };

    if (existingTrackerList.isNotEmpty) {
      final Map<String, dynamic> existingTracker = existingTrackerList.first;
      updates.forEach((key, value) {
        if (value == null) {
          updates[key] = existingTracker[key];
        }
      });
      await currentDb!.update(
        'tracker',
        updates,
        where: 'charId = ? AND ID = ?',
        whereArgs: [selectedID, uuid],
      );
    } else {
      await currentDb!.insert(
        'tracker',
        updates,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
  }

  Future<void> addTracker({
    required String tracker,
    int? value,
    int? max,
  }) async {
    if (currentDb == null) return;

    final Map<String, dynamic> trackerData = {
      'charId': selectedID,
      'trackername': tracker,
      'value': value,
      'max': max
    };

    try {
      await currentDb!.insert(
        'tracker',
        trackerData,
        conflictAlgorithm: ConflictAlgorithm.abort,
      );
    } catch (e) {
      if (kDebugMode) {
        print('Error adding item: $e');
      }
    }
  }

  Future<void> removeTracker(int uuid) async {
    if (currentDb == null) return;

    await currentDb!.delete(
      'tracker',
      where: 'charId = ? AND ID = ?',
      whereArgs: [selectedID, uuid],
    );
  }

  Future<void> addCreature(Creature creature) async {
    if (currentDb == null) return;

    final Map<String, dynamic> creatureData = {
      'charId': selectedID,
      'name': creature.name,
      'size': creature.size,
      'type': creature.type,
      'alignment': creature.alignment,
      'ac': creature.ac,
      'hp': creature.hp,
      'currentHP': creature.currentHP,
      'maxHP': creature.maxHP,
      'speed': creature.speed,
      'str': creature.str,
      'dex': creature.dex,
      'con': creature.con,
      'intScore': creature.intScore,
      'wis': creature.wis,
      'cha': creature.cha,
      'saves': creature.saves,
      'skills': creature.skills,
      'resistances': creature.resistances,
      'vulnerabilities': creature.vulnerabilities,
      'immunities': creature.immunities,
      'conditionImmunities': creature.conditionImmunities,
      'senses': creature.senses,
      'passivePerception': creature.passivePerception,
      'languages': creature.languages,
      'cr': creature.cr,
    };

    try {
      final int creatureId = await currentDb!.insert(
        'creatures',
        creatureData,
        conflictAlgorithm: ConflictAlgorithm.abort,
      );

      for (var trait in creature.traits) {
        await currentDb!.insert(
          'creature_traits',
          {
            'charId': selectedID,
            'creature_id': creatureId,
            'trait_name': trait.name,
            'trait_description': trait.description,
          },
        );
      }

      for (var action in creature.actions) {
        await currentDb!.insert(
          'creature_actions',
          {
            'charId': selectedID,
            'creature_id': creatureId,
            'action_name': action.name,
            'action': action.attack,
            'action_description': action.description,
          },
        );
      }

      for (var legendary in creature.legendaryActions) {
        await currentDb!.insert(
          'creature_legendary_actions',
          {
            'charId': selectedID,
            'creature_id': creatureId,
            'legendary_action_name': legendary.name,
            'legendary_action_description': legendary.description,
          },
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error adding creature: $e');
      }
    }
  }

  Future<void> updateCreature(
    Creature creature,
  ) async {
    if (currentDb == null) return;

    final List<Map<String, dynamic>> existingCreatureList =
        await currentDb!.query(
      'creatures',
      where: 'charId = ? AND ID = ?',
      whereArgs: [selectedID, creature.uuid],
    );

    final Map<String, dynamic> updates = {
      'name': creature.name,
      'size': creature.size,
      'type': creature.type,
      'alignment': creature.alignment,
      'ac': creature.ac,
      'hp': creature.hp,
      'speed': creature.speed,
      'str': creature.str,
      'dex': creature.dex,
      'con': creature.con,
      'intScore': creature.intScore,
      'wis': creature.wis,
      'cha': creature.cha,
      'saves': creature.saves,
      'skills': creature.skills,
      'resistances': creature.resistances,
      'vulnerabilities': creature.vulnerabilities,
      'immunities': creature.immunities,
      'conditionImmunities': creature.conditionImmunities,
      'senses': creature.senses,
      'passivePerception': creature.passivePerception,
      'languages': creature.languages,
      'cr': creature.cr,
    };

    if (existingCreatureList.isNotEmpty) {
      await currentDb!.update(
        'creatures',
        updates,
        where: 'charId = ? AND ID = ?',
        whereArgs: [selectedID, creature.uuid],
      );

      await currentDb!.delete('creature_traits',
          where: 'charId = ? AND creature_id = ?',
          whereArgs: [selectedID, creature.uuid]);
      await currentDb!.delete('creature_actions',
          where: 'charId = ? AND creature_id = ?',
          whereArgs: [selectedID, creature.uuid]);
      await currentDb!.delete('creature_legendary_actions',
          where: 'charId = ? AND creature_id = ?',
          whereArgs: [selectedID, creature.uuid]);

      for (var trait in creature.traits) {
        await currentDb!.insert(
          'creature_traits',
          {
            'charId': selectedID,
            'creature_id': creature.uuid,
            'trait_name': trait.name,
            'trait_description': trait.description,
          },
        );
      }

      for (var action in creature.actions) {
        await currentDb!.insert(
          'creature_actions',
          {
            'charId': selectedID,
            'creature_id': creature.uuid,
            'action_name': action.name,
            'action': action.attack,
            'action_description': action.description,
          },
        );
      }

      for (var legendary in creature.legendaryActions) {
        await currentDb!.insert(
          'creature_legendary_actions',
          {
            'charId': selectedID,
            'creature_id': creature.uuid,
            'legendary_action_name': legendary.name,
            'legendary_action_description': legendary.description,
          },
        );
      }
    } else {
      await addCreature(creature);
    }
  }

  Future<void> removeCreature(int uuid) async {
    if (currentDb == null) return;

    try {
      await currentDb!.delete(
        'creature_traits',
        where: 'charId = ? AND creature_id = ?',
        whereArgs: [selectedID, uuid],
      );
      await currentDb!.delete(
        'creature_actions',
        where: 'charId = ? AND creature_id = ?',
        whereArgs: [selectedID, uuid],
      );
      await currentDb!.delete(
        'creature_legendary_actions',
        where: 'charId = ? AND creature_id = ?',
        whereArgs: [selectedID, uuid],
      );
      await currentDb!.delete(
        'creatures',
        where: 'charId = ? AND ID = ?',
        whereArgs: [selectedID, uuid],
      );
    } catch (e) {
      if (kDebugMode) {
        print('Error removing creature: $e');
      }
    }
  }

  Future<List<Creature>> getCreatures() async {
    if (currentDb == null) return [];

    final List<Map<String, dynamic>> result = await currentDb!.query(
      'creatures',
      where: 'charId = ?',
      whereArgs: [selectedID],
    );

    List<Creature> creatures = [];

    for (var creatureData in result) {
      final int creatureId = creatureData['ID'];

      final List<Map<String, dynamic>> traitsData = await currentDb!.query(
        'creature_traits',
        where: 'charId = ? AND creature_id = ?',
        whereArgs: [selectedID, creatureId],
      );
      List<Trait> traits = traitsData
          .map((trait) => Trait(
                name: trait['trait_name'],
                description: trait['trait_description'],
              ))
          .toList();

      final List<Map<String, dynamic>> actionsData = await currentDb!.query(
        'creature_actions',
        where: 'charId = ? AND creature_id = ?',
        whereArgs: [selectedID, creatureId],
      );
      List<CAction> actions = actionsData
          .map((action) => CAction(
                name: action['action_name'],
                description: action['action_description'],
                attack: action['action'],
              ))
          .toList();

      final List<Map<String, dynamic>> legendaryActionsData =
          await currentDb!.query(
        'creature_legendary_actions',
        where: 'charId = ? AND creature_id = ?',
        whereArgs: [selectedID, creatureId],
      );
      List<Legendary> legendaryActions = legendaryActionsData
          .map((legendary) => Legendary(
                name: legendary['legendary_action_name'],
                description: legendary['legendary_action_description'],
              ))
          .toList();

      creatures.add(Creature(
        uuid: creatureId,
        name: creatureData['name'],
        size: creatureData['size'],
        type: creatureData['type'],
        alignment: creatureData['alignment'],
        ac: creatureData['ac'],
        hp: creatureData['hp'],
        currentHP: creatureData['currentHP'],
        maxHP: creatureData['maxHP'],
        speed: creatureData['speed'],
        str: creatureData['str'],
        dex: creatureData['dex'],
        con: creatureData['con'],
        intScore: creatureData['intScore'],
        wis: creatureData['wis'],
        cha: creatureData['cha'],
        saves: creatureData['saves'],
        skills: creatureData['skills'],
        resistances: creatureData['resistances'],
        vulnerabilities: creatureData['vulnerabilities'],
        immunities: creatureData['immunities'],
        conditionImmunities: creatureData['conditionImmunities'],
        senses: creatureData['senses'],
        passivePerception: creatureData['passivePerception'],
        languages: creatureData['languages'],
        cr: creatureData['cr'],
        traits: traits,
        actions: actions,
        legendaryActions: legendaryActions,
      ));
    }

    return creatures;
  }

  Future<List<Map<String, dynamic>>> getTracker() async {
    if (currentDb == null) return [];

    final List<Map<String, dynamic>> result = await currentDb!.query(
      'tracker',
      where: 'charId = ?',
      whereArgs: [selectedID],
    );

    return result;
  }

  Future<List<Map<String, dynamic>>> getStats() async {
    if (currentDb == null) return [];

    final List<Map<String, dynamic>> result = await currentDb!.query(
      'stats',
      where: 'charId = ?',
      whereArgs: [selectedID],
    );

    return result;
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

  Future<List<Map<String, dynamic>>> getBagItems() async {
    if (currentDb == null) return [];

    final List<Map<String, dynamic>> result = await currentDb!.query(
      'bag',
      where: 'charId = ?',
      whereArgs: [selectedID],
    );

    return result;
  }

  Future<List<Map<String, dynamic>>> getItems() async {
    if (currentDb == null) return [];

    final List<Map<String, dynamic>> result = await currentDb!.query(
      'items',
      where: 'charId = ?',
      whereArgs: [selectedID],
    );

    return result;
  }

  Future<List<Map<String, dynamic>>> getFeats() async {
    if (currentDb == null) return [];

    final List<Map<String, dynamic>> result = await currentDb!.query(
      'feats',
      where: 'charId = ?',
      whereArgs: [selectedID],
    );

    return result;
  }

  Future<List<Map<String, dynamic>>> getSavingThrows() async {
    if (currentDb == null) return [];

    final List<Map<String, dynamic>> result = await currentDb!.query(
      'savingthrow',
      where: 'charId = ?',
      whereArgs: [selectedID],
    );

    return result;
  }

  Future<List<Map<String, dynamic>>> getAllSpells() async {
    if (currentDb == null) return [];

    final List<Map<String, dynamic>> result = await currentDb!.query(
      'spells',
      columns: ['spellname', 'level', 'status', 'description', 'ID'],
      where: 'charId = ?',
      whereArgs: [selectedID],
    );

    return result;
  }

  Future<String> getSpellDescription(String spellName) async {
    if (currentDb == null) return "keine Beschreibung";

    final List<Map<String, dynamic>> result = await currentDb!.query(
      'spells',
      columns: ['description'],
      where: 'charId = ? AND spellname = ?',
      whereArgs: [selectedID, spellName],
    );

    return result.isNotEmpty && result.first['description'] != null
        ? result.first['description'] as String
        : "keine Beschreibung";
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

  List<FeatureData> parseFeatureData(String xmlString, int characterLevel) {
    final document = XmlDocument.parse(xmlString);
    List<FeatureData> features = [];

    void parseFeats(Iterable<XmlElement> featElements, String type) {
      for (final feat in featElements) {
        final name = feat.findElements('name').first.innerText;
        final description = feat.findElements('text').isNotEmpty
            ? feat.findElements('text').first.innerText
            : feat.findElements('description').first.innerText;

        features.add(FeatureData(
          name: name,
          description: description,
          type: type,
        ));
      }
    }

    final characterFeats = document
        .findAllElements('character')
        .expand((e) => e.findAllElements('feat'));
    parseFeats(characterFeats, 'Charakter');

    parseFeats(
      document.findAllElements('race').expand((e) => e.findAllElements('feat')),
      'Rasse',
    );

    parseFeats(
      document
          .findAllElements('background')
          .expand((e) => e.findAllElements('feat')),
      'Hintergrund',
    );

    final classElements = document.findAllElements('class');
    for (final classElement in classElements) {
      final autolevels = classElement.findAllElements('autolevel');
      for (final autolevel in autolevels) {
        final levelElements = autolevel.findElements('level');
        final level = levelElements.isNotEmpty
            ? int.parse(levelElements.first.innerText)
            : null;

        if (level == null || level <= characterLevel) {
          parseFeats(autolevel.findAllElements('feat'), 'Klasse');
        }
      }
    }

    final allFeatElements = document.findAllElements('feat');
    final knownFeatElements = {
      ...document
          .findAllElements('race')
          .expand((e) => e.findAllElements('feat')),
      ...document
          .findAllElements('background')
          .expand((e) => e.findAllElements('feat')),
      ...document
          .findAllElements('character')
          .expand((e) => e.findAllElements('feat')),
      ...classElements.expand((e) => e.findAllElements('feat')),
    };

    for (final feat in allFeatElements) {
      if (!knownFeatElements.contains(feat)) {
        final name = feat.findElements('name').first.innerText;
        final description = feat.findElements('description').first.innerText;
        final type = feat.findElements('type').isNotEmpty
            ? feat.findElements('type').first.innerText
            : 'Sonstige';

        features.add(FeatureData(
          name: name,
          description: description,
          type: type,
        ));
      }
    }

    return features;
  }

  dynamic parseStatsData(String xmlString) {
    final document = XmlDocument.parse(xmlString);

    final abilitiesString =
        document.findAllElements('abilities').first.innerText;
    final abilitiesList = abilitiesString
        .split(',')
        .where((value) => value.trim().isNotEmpty)
        .map((value) => int.parse(value.trim()))
        .toList();

    final abilities = {
      Defines.statSTR: abilitiesList[0],
      Defines.statDEX: abilitiesList[1],
      Defines.statCON: abilitiesList[2],
      Defines.statINT: abilitiesList[3],
      Defines.statWIS: abilitiesList[4],
      Defines.statCHA: abilitiesList[5],
    };

    int? parseIntStat(String tagName) {
      final elements = document.findAllElements(tagName);
      return elements.isNotEmpty ? int.parse(elements.first.innerText) : 0;
    }

    final additionalStats = {
      Defines.statMaxHP: parseIntStat('hpMax'),
      Defines.statCurrentHP: parseIntStat('hpCurrent'),
      Defines.statTempHP: parseIntStat('hpTemp'),
      Defines.statXP: parseIntStat('xp'),
      Defines.statArmor: parseIntStat('armorclass'),
      Defines.statInspiration: parseIntStat('inspiration'),
      Defines.statProficiencyBonus: parseIntStat('proficiencyBonus'),
      Defines.statInitiative: parseIntStat('initiative'),
      Defines.statSpellSaveDC: parseIntStat('spellSaveDC'),
      Defines.statSpellAttackBonus: parseIntStat('spellAttackBonus'),
    };

    final classElement = document.findAllElements('class').isNotEmpty
        ? document.findAllElements('class').first
        : null;

    final level = classElement != null
        ? int.parse(classElement.findElements('level').isNotEmpty
            ? classElement.findElements('level').first.innerText
            : '0')
        : parseIntStat('level');

    final hdCurrent = classElement != null
        ? parseIntStat('hdCurrent')
        : parseIntStat('hdCurrent');

    final hd = classElement != null ? parseIntStat('hd') : parseIntStat('hd');

    return {
      ...abilities,
      ...additionalStats,
      Defines.statLevel: level,
      Defines.statMaxHitDice: hd,
      Defines.statCurrentHitDice: hdCurrent,
    };
  }

  dynamic parseToolProficiencies(String xmlString) {
    final document = XmlDocument.parse(xmlString);

    final classElement = document.findAllElements('class').first;
    final armor = classElement.findElements('armor').first.innerText;
    final weapons = classElement.findElements('weapons').first.innerText;
    final tools = classElement.findElements('tools').first.innerText;

    return {
      Defines.profArmor: armor,
      Defines.profWeaponList: weapons,
      Defines.profTools: tools,
    };
  }

  dynamic parseInfos(String xmlString) {
    final document = XmlDocument.parse(xmlString);

    String getText(String parentTag, String childTag) {
      final parent = document.findAllElements(parentTag);
      if (parent.isNotEmpty) {
        final child = parent.first.findElements(childTag);
        return child.isNotEmpty ? child.first.innerText.trim() : "";
      }
      return "";
    }

    String getTextFromInfoOrFallback(String tagName) {
      String infoText = getText('info', tagName);
      if (infoText.isNotEmpty) {
        return infoText;
      } else {
        switch (tagName) {
          case 'name':
            return getText('character', 'name');
          case 'race':
            return getText('race', 'name');
          case 'background':
            return getText('background', 'name');
          case 'class':
            return getText('class', 'name');
          default:
            return "";
        }
      }
    }

    return {
      Defines.infoName: getTextFromInfoOrFallback('name'),
      Defines.infoRace: getTextFromInfoOrFallback('race'),
      Defines.infoClass: getTextFromInfoOrFallback('class'),
      Defines.infoBackground: getTextFromInfoOrFallback('background'),
      Defines.infoOrigin: getText('info', Defines.infoOrigin),
      Defines.infoPersonalityTraits:
          getText('info', Defines.infoPersonalityTraits),
      Defines.infoIdeals: getText('info', Defines.infoIdeals),
      Defines.infoBonds: getText('info', Defines.infoBonds),
      Defines.infoFlaws: getText('info', Defines.infoFlaws),
      Defines.infoAge: getText('info', Defines.infoAge),
      Defines.infoGod: getText('info', Defines.infoGod),
      Defines.infoSize: getText('info', Defines.infoSize),
      Defines.infoHeight: getText('info', Defines.infoHeight),
      Defines.infoWeight: getText('info', Defines.infoWeight),
      Defines.infoSex: getText('info', Defines.infoSex),
      Defines.infoAlignment: getText('info', Defines.infoAlignment),
      Defines.infoEyeColour: getText('info', Defines.infoEyeColour),
      Defines.infoHairColour: getText('info', Defines.infoHairColour),
      Defines.infoSkinColour: getText('info', Defines.infoSkinColour),
      Defines.infoAppearance: getText('info', Defines.infoAppearance),
      Defines.infoBackstory: getText('info', Defines.infoBackstory),
      Defines.infoNotes: getText('info', Defines.infoNotes),
      Defines.infoSpellcastingClass:
          getText('info', Defines.infoSpellcastingClass),
      Defines.infoSpellcastingAbility:
          getText('info', Defines.infoSpellcastingAbility),
    };
  }

  List<Map<String, dynamic>> parseSpells(String xmlString) {
    final document = XmlDocument.parse(xmlString);
    List<Map<String, dynamic>> spells = [];

    final spellElements = document.findAllElements('spell');
    for (final spellElement in spellElements) {
      final name = spellElement.findElements('name').first.innerText;

      final description = spellElement.findElements('text').isNotEmpty
          ? spellElement.findElements('text').first.innerText
          : spellElement.findElements('description').isNotEmpty
              ? spellElement.findElements('description').first.innerText
              : "";

      final levelElement = spellElement.findElements('level').isNotEmpty
          ? int.parse(spellElement.findElements('level').first.innerText)
          : 0;

      final status = spellElement.findElements('status').isNotEmpty
          ? spellElement.findElements('status').first.innerText
          : Defines.spellKnown;

      spells.add({
        'name': name,
        'description': description,
        'status': status,
        'level': levelElement,
      });
    }

    return spells;
  }

  List<Map<String, dynamic>> parseTrackers(String xmlString) {
    final document = XmlDocument.parse(xmlString);
    List<Map<String, dynamic>> trackers = [];

    final trackerElements = document.findAllElements('tracker');
    for (final trackerElement in trackerElements) {
      final name = trackerElement.findElements('label').isNotEmpty
          ? trackerElement.findElements('label').first.innerText
          : 'Kein Name';

      final value = trackerElement.findElements('value').isNotEmpty
          ? int.parse(trackerElement.findElements('value').first.innerText)
          : 0;

      final maxElement = trackerElement.findElements('formula').isNotEmpty
          ? trackerElement.findElements('formula').first
          : trackerElement.findElements('max').isNotEmpty
              ? trackerElement.findElements('max').first
              : null;

      final max = maxElement != null ? int.parse(maxElement.innerText) : 0;

      trackers.add({
        'name': name,
        'value': value,
        'max': max,
      });
    }

    return trackers;
  }

  Map<String, Map<String, int>> parseSpellSlots(String xmlString) {
    final document = XmlDocument.parse(xmlString);

    final spellSlotsElements = document.findAllElements('spellSlots').toList();

    String slotsString = '';
    String slotsCurrentString = '';

    if (spellSlotsElements.isNotEmpty) {
      final spellSlotsElement = spellSlotsElements.first;
      slotsString = spellSlotsElement.findElements('slots').isNotEmpty
          ? spellSlotsElement.findElements('slots').first.innerText
          : '';
      slotsCurrentString =
          spellSlotsElement.findElements('slotsCurrent').isNotEmpty
              ? spellSlotsElement.findElements('slotsCurrent').first.innerText
              : '';
    } else {
      slotsString = document.findElements('slots').isNotEmpty
          ? document.findElements('slots').first.innerText
          : '';
      slotsCurrentString = document.findElements('slotsCurrent').isNotEmpty
          ? document.findElements('slotsCurrent').first.innerText
          : '';
    }

    final slotsList = slotsString.isNotEmpty
        ? slotsString
            .split(',')
            .where((value) => value.trim().isNotEmpty)
            .map((value) => int.parse(value.trim()))
            .toList()
        : List.generate(10, (index) => 0);

    final slotsCurrentList = slotsCurrentString.isNotEmpty
        ? slotsCurrentString
            .split(',')
            .where((value) => value.trim().isNotEmpty)
            .map((value) => int.parse(value.trim()))
            .toList()
        : List.generate(10, (index) => 0);

    if (slotsList.length != slotsCurrentList.length) {
      throw Exception(
          'Mismatch between total spell slots and current spell slots.');
    }

    Map<String, Map<String, int>> spellSlotsMap = {};

    for (int i = 0; i < slotsList.length; i++) {
      String slotName;
      switch (i) {
        case 0:
          slotName = Defines.slotZero;
          break;
        case 1:
          slotName = Defines.slotOne;
          break;
        case 2:
          slotName = Defines.slotTwo;
          break;
        case 3:
          slotName = Defines.slotThree;
          break;
        case 4:
          slotName = Defines.slotFour;
          break;
        case 5:
          slotName = Defines.slotFive;
          break;
        case 6:
          slotName = Defines.slotSix;
          break;
        case 7:
          slotName = Defines.slotSeven;
          break;
        case 8:
          slotName = Defines.slotEight;
          break;
        case 9:
          slotName = Defines.slotNine;
          break;
        default:
          continue;
      }

      spellSlotsMap[slotName] = {
        'total': slotsList[i],
        'spent': slotsCurrentList[i],
      };
    }

    return spellSlotsMap;
  }

  List<Map<String, String>> parseWeapons(String xmlString) {
    final document = XmlDocument.parse(xmlString);
    List<Map<String, String>> attacks = [];

    final weaponsElements = document.findAllElements('weapons');

    for (final weaponsElement in weaponsElements) {
      bool isInsideClassTag = false;

      var parent = weaponsElement.parent;
      while (parent != null) {
        if (parent is XmlElement && parent.name.local == 'class') {
          isInsideClassTag = true;
          break;
        }
        parent = parent.parent;
      }

      if (!isInsideClassTag) {
        final weaponElements = weaponsElement.findAllElements('weapon');
        for (final weaponElement in weaponElements) {
          final name = weaponElement.findElements('name').isNotEmpty
              ? weaponElement.findElements('name').first.innerText
              : '';
          final attackBonus =
              weaponElement.findElements('attackBonus').isNotEmpty
                  ? weaponElement.findElements('attackBonus').first.innerText
                  : '';
          final damage = weaponElement.findElements('damage').isNotEmpty
              ? weaponElement.findElements('damage').first.innerText
              : '';

          attacks.add({
            'name': name,
            'attackBonus': attackBonus,
            'damage': damage,
          });
        }
      }
    }

    final attackElements = document.findAllElements('attack');
    for (final attackElement in attackElements) {
      final name = attackElement.findElements('name').isNotEmpty
          ? attackElement.findElements('name').first.innerText
          : '';
      final attackBonus = attackElement.findElements('attackBonus').isNotEmpty
          ? attackElement.findElements('attackBonus').first.innerText
          : '';
      final damage = attackElement.findElements('damage').isNotEmpty
          ? attackElement.findElements('damage').first.innerText
          : '';
      final damageType = attackElement.findElements('damageType').isNotEmpty
          ? attackElement.findElements('damageType').first.innerText
          : '';

      attacks.add({
        'name': name,
        'attackBonus': attackBonus,
        'damage': damage,
        'damageType': damageType,
      });
    }

    return attacks;
  }

  List<Map<String, String>> parseItems(String xmlString) {
    final document = XmlDocument.parse(xmlString);

    final itemElements = document.findAllElements('item');

    List<Map<String, String>> items = [];

    for (final itemElement in itemElements) {
      final name = itemElement.findElements('name').first.innerText;
      final detailElement = itemElement.findElements('detail').isNotEmpty
          ? itemElement.findElements('detail').first.innerText
          : null;
      final typeElement = itemElement.findElements('type').isNotEmpty
          ? itemElement.findElements('type').first.innerText
          : "Sonstige";

      items.add({
        'name': name,
        if (detailElement != null) 'detail': detailElement,
        'type': typeElement,
      });
    }

    return items;
  }

  Map<String, int> parseSavingThrows(String xmlString) {
    final document = XmlDocument.parse(xmlString);

    final Map<String, int> savingThrows = {};

    final savingthrowsElement = document.findElements('savingthrows').isNotEmpty
        ? document.findElements('savingthrows').first
        : null;

    if (savingthrowsElement == null) {
      savingThrows[Defines.saveStr] = 0;
      savingThrows[Defines.saveDex] = 0;
      savingThrows[Defines.saveCon] = 0;
      savingThrows[Defines.saveInt] = 0;
      savingThrows[Defines.saveWis] = 0;
      savingThrows[Defines.saveCha] = 0;
    } else {
      final saveStr = savingthrowsElement
              .findElements(Defines.saveStr)
              .isNotEmpty
          ? int.parse(
              savingthrowsElement.findElements(Defines.saveStr).first.innerText)
          : 0;
      final saveDex = savingthrowsElement
              .findElements(Defines.saveDex)
              .isNotEmpty
          ? int.parse(
              savingthrowsElement.findElements(Defines.saveDex).first.innerText)
          : 0;
      final saveCon = savingthrowsElement
              .findElements(Defines.saveCon)
              .isNotEmpty
          ? int.parse(
              savingthrowsElement.findElements(Defines.saveCon).first.innerText)
          : 0;
      final saveInt = savingthrowsElement
              .findElements(Defines.saveInt)
              .isNotEmpty
          ? int.parse(
              savingthrowsElement.findElements(Defines.saveInt).first.innerText)
          : 0;
      final saveWis = savingthrowsElement
              .findElements(Defines.saveWis)
              .isNotEmpty
          ? int.parse(
              savingthrowsElement.findElements(Defines.saveWis).first.innerText)
          : 0;
      final saveCha = savingthrowsElement
              .findElements(Defines.saveCha)
              .isNotEmpty
          ? int.parse(
              savingthrowsElement.findElements(Defines.saveCha).first.innerText)
          : 0;

      savingThrows[Defines.saveStr] = saveStr;
      savingThrows[Defines.saveDex] = saveDex;
      savingThrows[Defines.saveCon] = saveCon;
      savingThrows[Defines.saveInt] = saveInt;
      savingThrows[Defines.saveWis] = saveWis;
      savingThrows[Defines.saveCha] = saveCha;
    }

    return savingThrows;
  }

  List<Map<String, dynamic>> parseBagItems(String xmlString) {
    final document = XmlDocument.parse(xmlString);
    List<Map<String, dynamic>> bagItems = [];

    final bagElement = document.findAllElements('bag').isNotEmpty
        ? document.findAllElements('bag').first
        : null;

    if (bagElement == null) {
      bagItems.add({
        'platin': 0,
        'gold': 0,
        'electrum': 0,
        'silver': 0,
        'copper': 0,
      });
    } else {
      final platin = bagElement.findAllElements(Defines.bagPlatin).isNotEmpty
          ? int.parse(
              bagElement.findAllElements(Defines.bagPlatin).first.innerText)
          : 0;
      final gold = bagElement.findAllElements(Defines.bagGold).isNotEmpty
          ? int.parse(
              bagElement.findAllElements(Defines.bagGold).first.innerText)
          : 0;
      final electrum = bagElement
              .findAllElements(Defines.bagElectrum)
              .isNotEmpty
          ? int.parse(
              bagElement.findAllElements(Defines.bagElectrum).first.innerText)
          : 0;
      final silver = bagElement.findAllElements(Defines.bagSilver).isNotEmpty
          ? int.parse(
              bagElement.findAllElements(Defines.bagSilver).first.innerText)
          : 0;
      final copper = bagElement.findAllElements(Defines.bagCopper).isNotEmpty
          ? int.parse(
              bagElement.findAllElements(Defines.bagCopper).first.innerText)
          : 0;

      bagItems.add({
        'platin': platin,
        'gold': gold,
        'electrum': electrum,
        'silver': silver,
        'copper': copper,
      });
    }

    return bagItems;
  }

  List<Map<String, dynamic>> parseSkills(String xmlString) {
    final document = XmlDocument.parse(xmlString);
    List<Map<String, dynamic>> skills = [];

    int safeParseInt(String text) {
      try {
        return int.parse(text);
      } catch (e) {
        return 0;
      }
    }

    final skillsElement = document.findAllElements('skills').isNotEmpty
        ? document.findAllElements('skills').first
        : null;

    if (skillsElement == null) {
      return skills;
    }

    for (final skillElement in skillsElement.findAllElements('skill')) {
      final skillName = skillElement.findAllElements('name').isNotEmpty
          ? skillElement.findAllElements('name').first.innerText
          : 'Kein Name';

      final proficiency = skillElement.findAllElements('proficiency').isNotEmpty
          ? int.parse(
              skillElement.findAllElements('proficiency').first.innerText)
          : 0;

      final expertise = skillElement.findAllElements('expertise').isNotEmpty
          ? safeParseInt(
              skillElement.findAllElements('expertise').first.innerText)
          : 0;

      skills.add({
        'skill': skillName,
        'proficiency': proficiency,
        'expertise': expertise,
      });
    }

    return skills;
  }

  List<Creature> parseCreatures(String xmlString) {
    final document = XmlDocument.parse(xmlString);
    List<Creature> creatures = [];

    int safeParseInt(String text) {
      try {
        return int.parse(text);
      } catch (e) {
        return 0;
      }
    }

    String extractTextFromElement(XmlElement element, String tag) {
      return element.findElements(tag).isNotEmpty
          ? element.findElements(tag).first.innerText
          : '';
    }

    final creaturesElement = document.findAllElements('creature');

    for (final creatureElement in creaturesElement) {
      String extractText(String tag) =>
          creatureElement.findElements(tag).isNotEmpty
              ? creatureElement.findElements(tag).first.innerText
              : '';

      int extractInt(String tag) => safeParseInt(extractText(tag));

      List<Trait> parseTraits(XmlElement traitsElement) {
        return traitsElement.findAllElements('trait').map((traitElement) {
          return Trait(
            name: extractTextFromElement(traitElement, 'name'),
            description: extractTextFromElement(traitElement, 'description'),
          );
        }).toList();
      }

      List<CAction> parseActions(XmlElement actionsElement) {
        return actionsElement.findAllElements('action').map((actionElement) {
          return CAction(
            name: extractTextFromElement(actionElement, 'name'),
            description: extractTextFromElement(actionElement, 'description'),
            attack: extractTextFromElement(actionElement, 'actionDetails'),
          );
        }).toList();
      }

      List<Legendary> parseLegendaryActions(
          XmlElement legendaryActionsElement) {
        return legendaryActionsElement
            .findAllElements('legendaryAction')
            .map((legendaryElement) {
          return Legendary(
            name: extractTextFromElement(legendaryElement, 'name'),
            description:
                extractTextFromElement(legendaryElement, 'description'),
          );
        }).toList();
      }

      Creature creature = Creature(
        name: extractText('name'),
        size: extractText('size'),
        type: extractText('type'),
        alignment: extractText('alignment'),
        ac: extractInt('ac'),
        hp: extractText('hp'),
        currentHP: extractInt('currentHP'),
        maxHP: extractInt('maxHP'),
        speed: extractText('speed'),
        str: extractInt('str'),
        dex: extractInt('dex'),
        con: extractInt('con'),
        intScore: extractInt('intScore'),
        wis: extractInt('wis'),
        cha: extractInt('cha'),
        saves: extractText('saves'),
        skills: extractText('skills'),
        resistances: extractText('resistances'),
        vulnerabilities: extractText('vulnerabilities'),
        immunities: extractText('immunities'),
        conditionImmunities: extractText('conditionImmunities'),
        senses: extractText('senses'),
        passivePerception: extractInt('passivePerception'),
        languages: extractText('languages'),
        cr: extractText('cr'),
        traits: creatureElement.findElements('traits').isNotEmpty
            ? parseTraits(creatureElement.findElements('traits').first)
            : [],
        actions: creatureElement.findElements('actions').isNotEmpty
            ? parseActions(creatureElement.findElements('actions').first)
            : [],
        legendaryActions:
            creatureElement.findElements('legendaryActions').isNotEmpty
                ? parseLegendaryActions(
                    creatureElement.findElements('legendaryActions').first)
                : [],
      );

      creatures.add(creature);
    }

    return creatures;
  }

  Future<void> createProfileFromXmlFile(File file) async {
    String xmlString = await file.readAsString();

    final parsedStats = parseStatsData(xmlString);
    final parsedInfos = parseInfos(xmlString);
    final parsedFeats =
        parseFeatureData(xmlString, parsedStats[Defines.statLevel]);
    final parsedSpells = parseSpells(xmlString);
    final parsedSlots = parseSpellSlots(xmlString);
    final parsedWeapons = parseWeapons(xmlString);
    final parsedTrackers = parseTrackers(xmlString);
    final parsedItems = parseItems(xmlString);
    final parsedSavingThrows = parseSavingThrows(xmlString);
    final parsedBagItems = parseBagItems(xmlString);
    final parsedSkills = parseSkills(xmlString);
    final parsedCreatures = parseCreatures(xmlString);

    String characterName = parsedInfos[Defines.infoName];
    String uniqueName = await _getUniqueName(characterName);

    await createProfile(uniqueName);
    Character profile = profiles.firstWhere((p) => p.name == uniqueName);
    await selectProfile(profile);

    await _importStats(parsedStats);
    await _importProfileInfo(parsedInfos);
    await _importSpells(parsedSpells);
    await _importFeats(parsedFeats);
    await _importWeapons(parsedWeapons);
    await _importTrackers(parsedTrackers);
    await _importItems(parsedItems);
    await _importSavingThrows(parsedSavingThrows);
    await _importBagItems(parsedBagItems);
    await _importSkills(parsedSkills);
    await _importSpellSlots(parsedSlots);
    await _importCreatures(parsedCreatures);

    await closeDB();

    if (kDebugMode) {
      print('Profile created and selected successfully from XML file!');
    }
  }

  Future<String> _getUniqueName(String characterName) async {
    String uniqueName = characterName;
    int counter = 1;
    while (profiles.any((p) => p.name == uniqueName)) {
      uniqueName = '$characterName ($counter)';
      counter++;
    }
    return uniqueName;
  }

  Future<void> _importStats(Map<String, dynamic> parsedStats) async {
    await updateStats(
        field: Defines.statSTR, value: parsedStats[Defines.statSTR]);
    await updateStats(
        field: Defines.statDEX, value: parsedStats[Defines.statDEX]);
    await updateStats(
        field: Defines.statCON, value: parsedStats[Defines.statCON]);
    await updateStats(
        field: Defines.statINT, value: parsedStats[Defines.statINT]);
    await updateStats(
        field: Defines.statWIS, value: parsedStats[Defines.statWIS]);
    await updateStats(
        field: Defines.statCHA, value: parsedStats[Defines.statCHA]);

    await updateStats(
        field: Defines.statMaxHP, value: parsedStats[Defines.statMaxHP]);
    await updateStats(
        field: Defines.statCurrentHP,
        value: parsedStats[Defines.statCurrentHP]);
    await updateStats(
        field: Defines.statTempHP, value: parsedStats[Defines.statTempHP]);
    await updateStats(
        field: Defines.statXP, value: parsedStats[Defines.statXP]);
    await updateStats(
        field: Defines.statArmor, value: parsedStats[Defines.statArmor]);
    await updateStats(
        field: Defines.statInspiration,
        value: parsedStats[Defines.statInspiration]);
    await updateStats(
        field: Defines.statProficiencyBonus,
        value: parsedStats[Defines.statProficiencyBonus]);
    await updateStats(
        field: Defines.statInitiative,
        value: parsedStats[Defines.statInitiative]);
    await updateStats(
        field: Defines.statSpellSaveDC,
        value: parsedStats[Defines.statSpellSaveDC]);
    await updateStats(
        field: Defines.statSpellAttackBonus,
        value: parsedStats[Defines.statSpellAttackBonus]);

    await updateStats(
        field: Defines.statLevel, value: parsedStats[Defines.statLevel]);
    await updateStats(
        field: Defines.statMaxHitDice,
        value: parsedStats[Defines.statMaxHitDice]);
    await updateStats(
        field: Defines.statCurrentHitDice,
        value: parsedStats[Defines.statCurrentHitDice]);
  }

  Future<void> _importProfileInfo(Map<String, dynamic> parsedInfos) async {
    await updateProfileInfo(
        field: Defines.infoRace, value: parsedInfos[Defines.infoRace]);
    await updateProfileInfo(
        field: Defines.infoClass, value: parsedInfos[Defines.infoClass]);
    await updateProfileInfo(
        field: Defines.infoBackground,
        value: parsedInfos[Defines.infoBackground]);
    await updateProfileInfo(
        field: Defines.infoOrigin, value: parsedInfos[Defines.infoOrigin]);
    await updateProfileInfo(
        field: Defines.infoPersonalityTraits,
        value: parsedInfos[Defines.infoPersonalityTraits]);
    await updateProfileInfo(
        field: Defines.infoIdeals, value: parsedInfos[Defines.infoIdeals]);
    await updateProfileInfo(
        field: Defines.infoBonds, value: parsedInfos[Defines.infoBonds]);
    await updateProfileInfo(
        field: Defines.infoFlaws, value: parsedInfos[Defines.infoFlaws]);
    await updateProfileInfo(
        field: Defines.infoAge, value: parsedInfos[Defines.infoAge]);
    await updateProfileInfo(
        field: Defines.infoGod, value: parsedInfos[Defines.infoGod]);
    await updateProfileInfo(
        field: Defines.infoSize, value: parsedInfos[Defines.infoSize]);
    await updateProfileInfo(
        field: Defines.infoHeight, value: parsedInfos[Defines.infoHeight]);
    await updateProfileInfo(
        field: Defines.infoWeight, value: parsedInfos[Defines.infoWeight]);
    await updateProfileInfo(
        field: Defines.infoSex, value: parsedInfos[Defines.infoSex]);
    await updateProfileInfo(
        field: Defines.infoAlignment,
        value: parsedInfos[Defines.infoAlignment]);
    await updateProfileInfo(
        field: Defines.infoEyeColour,
        value: parsedInfos[Defines.infoEyeColour]);
    await updateProfileInfo(
        field: Defines.infoHairColour,
        value: parsedInfos[Defines.infoHairColour]);
    await updateProfileInfo(
        field: Defines.infoSkinColour,
        value: parsedInfos[Defines.infoSkinColour]);
    await updateProfileInfo(
        field: Defines.infoAppearance,
        value: parsedInfos[Defines.infoAppearance]);
    await updateProfileInfo(
        field: Defines.infoBackstory,
        value: parsedInfos[Defines.infoBackstory]);
    await updateProfileInfo(
        field: Defines.infoNotes, value: parsedInfos[Defines.infoNotes]);
    await updateProfileInfo(
        field: Defines.infoSpellcastingClass,
        value: parsedInfos[Defines.infoSpellcastingClass]);
    await updateProfileInfo(
        field: Defines.infoSpellcastingAbility,
        value: parsedInfos[Defines.infoSpellcastingAbility]);
  }

  Future<void> _importSpells(List<Map<String, dynamic>> parsedSpells) async {
    for (final spell in parsedSpells) {
      await addSpell(
        spellName: spell['name'],
        status: spell['status'],
        level: spell['level'],
        description: spell['description'],
      );
    }
  }

  Future<void> _importFeats(List<FeatureData> parsedFeats) async {
    for (final feat in parsedFeats) {
      await addFeat(
        featName: feat.name,
        description: feat.description,
        type: feat.type,
      );
    }
  }

  Future<void> _importWeapons(List<Map<String, dynamic>> parsedWeapons) async {
    for (final weapon in parsedWeapons) {
      await addWeapon(
        weapon: weapon['name']!,
        bonus: weapon['attackBonus'],
        damage: weapon['damage'],
        reach: weapon['reach'],
        attribute: weapon['attribute'],
        damagetype: weapon['damageType'],
        description: weapon['description'],
      );
    }
  }

  Future<void> _importTrackers(
      List<Map<String, dynamic>> parsedTrackers) async {
    for (final tracker in parsedTrackers) {
      await addTracker(
        tracker: tracker['name']!,
        value: tracker['value'],
        max: tracker['max'],
      );
    }
  }

  Future<void> _importItems(List<Map<String, dynamic>> parsedItems) async {
    for (final item in parsedItems) {
      await addItem(
        itemname: item['name']!,
        description: item['detail'],
        type: item['type'],
      );
    }
  }

  Future<void> _importSavingThrows(
      Map<String, dynamic> parsedSavingThrows) async {
    await updateSavingThrows(
        field: Defines.saveStr, value: parsedSavingThrows[Defines.saveStr]);
    await updateSavingThrows(
        field: Defines.saveDex, value: parsedSavingThrows[Defines.saveDex]);
    await updateSavingThrows(
        field: Defines.saveCon, value: parsedSavingThrows[Defines.saveCon]);
    await updateSavingThrows(
        field: Defines.saveInt, value: parsedSavingThrows[Defines.saveInt]);
    await updateSavingThrows(
        field: Defines.saveWis, value: parsedSavingThrows[Defines.saveWis]);
    await updateSavingThrows(
        field: Defines.saveCha, value: parsedSavingThrows[Defines.saveCha]);
  }

  Future<void> _importBagItems(
      List<Map<String, dynamic>> parsedBagItems) async {
    await updateBag(
        field: Defines.bagPlatin, value: parsedBagItems[0]['platin']);
    await updateBag(field: Defines.bagGold, value: parsedBagItems[0]['gold']);
    await updateBag(
        field: Defines.bagElectrum, value: parsedBagItems[0]['electrum']);
    await updateBag(
        field: Defines.bagSilver, value: parsedBagItems[0]['silver']);
    await updateBag(
        field: Defines.bagCopper, value: parsedBagItems[0]['copper']);
  }

  Future<void> _importSkills(List<Map<String, dynamic>> parsedSkills) async {
    for (final skill in parsedSkills) {
      int? expertise = skill['expertise'];

      if (skill['skill'] == Defines.skillJackofAllTrades) {
        expertise = null;
      }

      await updateSkills(
        skill: skill['skill'],
        proficiency: skill['proficiency'],
        expertise: expertise,
      );
    }
  }

  Future<void> _importSpellSlots(
      Map<String, Map<String, int>> parsedSpellSlots) async {
    for (final entry in parsedSpellSlots.entries) {
      final spellslot = entry.key;
      final total = entry.value['total'];
      final spent = entry.value['spent'];

      await updateSpellSlots(
        spellslot: spellslot,
        total: total,
        spent: spent,
      );
    }
  }

  Future<void> _importCreatures(
      List<Creature> parsedCreatures) async {
    for (final entry in parsedCreatures) {

      await addCreature(entry);
    }
  }

  Future<String> exportFeatsToXml(Character profile) async {
    await selectProfile(profile);

    final feats = await getFeats();
    final statsList = await getStats();
    final proficienciesList = await getProficiencies();
    final profileInfoList = await getProfileInfo();
    final spells = await getAllSpells();
    final trackers = await getTracker();
    final spellSlots = await getSpellSlots();
    final weapons = await getWeapons();
    final items = await getItems();
    final savingThrows = await getSavingThrows();
    final bagItems = await getBagItems();
    final skills = await getSkills();
    final creatures = await getCreatures();

    final builder = XmlBuilder();
    builder.processing('xml', 'version="1.0" encoding="UTF-8"');

    builder.element('character', nest: () {
      builder.element('feats', nest: () {
        for (final feat in feats) {
          builder.element('feat', nest: () {
            builder.element('name', nest: feat['featname']);
            builder.element('description', nest: feat['description']);
            builder.element('type', nest: feat['type']);
          });
        }
      });

      builder.element('stats', nest: () {
        if (statsList.isNotEmpty) {
          final stats = statsList.first;
          void addStatElement(String tagName, dynamic value) {
            if (value != null) {
              builder.element(tagName, nest: value.toString());
            }
          }

          addStatElement(
              'abilities',
              [
                stats[Defines.statSTR],
                stats[Defines.statDEX],
                stats[Defines.statCON],
                stats[Defines.statINT],
                stats[Defines.statWIS],
                stats[Defines.statCHA]
              ].join(", "));

          addStatElement('hpMax', stats[Defines.statMaxHP]);
          addStatElement('hpCurrent', stats[Defines.statCurrentHP]);
          addStatElement('hpTemp', stats[Defines.statTempHP]);
          addStatElement('xp', stats[Defines.statXP]);
          addStatElement('armorclass', stats[Defines.statArmor]);
          addStatElement('inspiration', stats[Defines.statInspiration]);
          addStatElement(
              'proficiencyBonus', stats[Defines.statProficiencyBonus]);
          addStatElement('initiative', stats[Defines.statInitiative]);
          addStatElement('spellSaveDC', stats[Defines.statSpellSaveDC]);
          addStatElement(
              'spellAttackBonus', stats[Defines.statSpellAttackBonus]);
          addStatElement('level', stats[Defines.statLevel]);
          addStatElement('hdCurrent', stats[Defines.statCurrentHitDice]);
          addStatElement('hd', stats[Defines.statMaxHitDice]);
        }
      });

      builder.element('proficiencies', nest: () {
        if (proficienciesList.isNotEmpty) {
          final proficiencies = proficienciesList.first;

          void addProficiencyElement(String tagName, dynamic value) {
            if (value != null) {
              builder.element(tagName, nest: value.toString());
            }
          }

          addProficiencyElement('armor', proficiencies[Defines.profArmor]);
          addProficiencyElement(
              'weapons', proficiencies[Defines.profWeaponList]);
          addProficiencyElement('tools', proficiencies[Defines.profTools]);
        }
      });

      builder.element('info', nest: () {
        if (profileInfoList.isNotEmpty) {
          final profileInfo = profileInfoList.first;

          void addInfoElement(String tagName, dynamic value) {
            if (value != null && value.toString().isNotEmpty) {
              builder.element(tagName, nest: value.toString());
            }
          }

          addInfoElement('name', profileInfo[Defines.infoName]);
          addInfoElement('race', profileInfo[Defines.infoRace]);
          addInfoElement('class', profileInfo[Defines.infoClass]);
          addInfoElement('background', profileInfo[Defines.infoBackground]);
          addInfoElement('origin', profileInfo[Defines.infoOrigin]);
          addInfoElement(
              'personalityTraits', profileInfo[Defines.infoPersonalityTraits]);
          addInfoElement('ideals', profileInfo[Defines.infoIdeals]);
          addInfoElement('bonds', profileInfo[Defines.infoBonds]);
          addInfoElement('flaws', profileInfo[Defines.infoFlaws]);
          addInfoElement('age', profileInfo[Defines.infoAge]);
          addInfoElement('god', profileInfo[Defines.infoGod]);
          addInfoElement('size', profileInfo[Defines.infoSize]);
          addInfoElement('height', profileInfo[Defines.infoHeight]);
          addInfoElement('weight', profileInfo[Defines.infoWeight]);
          addInfoElement('sex', profileInfo[Defines.infoSex]);
          addInfoElement('alignment', profileInfo[Defines.infoAlignment]);
          addInfoElement('eyeColour', profileInfo[Defines.infoEyeColour]);
          addInfoElement('hairColour', profileInfo[Defines.infoHairColour]);
          addInfoElement('skinColour', profileInfo[Defines.infoSkinColour]);
          addInfoElement('appearance', profileInfo[Defines.infoAppearance]);
          addInfoElement('backstory', profileInfo[Defines.infoBackstory]);
          addInfoElement('notes', profileInfo[Defines.infoNotes]);
          addInfoElement(
              'spellcastingClass', profileInfo[Defines.infoSpellcastingClass]);
          addInfoElement('spellcastingAbility',
              profileInfo[Defines.infoSpellcastingAbility]);
        }
      });

      builder.element('spells', nest: () {
        for (final spell in spells) {
          builder.element('spell', nest: () {
            builder.element('name', nest: spell['spellname']);
            builder.element('description', nest: spell['description']);
            builder.element('level', nest: spell['level'].toString());
            builder.element('status', nest: spell['status']);
          });
        }
      });

      builder.element('trackers', nest: () {
        for (final tracker in trackers) {
          builder.element('tracker', nest: () {
            builder.element('label', nest: tracker['trackername']);
            builder.element('value', nest: tracker['value'].toString());
            builder.element('max', nest: tracker['max'].toString());
          });
        }
      });

      builder.element('spellSlots', nest: () {
        final slotsList = [];
        final slotsCurrentList = [];

        for (int i = 0; i < spellSlots.length; i++) {
          slotsList.add(spellSlots[i]['total'].toString());
          slotsCurrentList.add(spellSlots[i]['spent'].toString());
        }

        builder.element('slots', nest: '${slotsList.join(',')},');
        builder.element('slotsCurrent', nest: '${slotsCurrentList.join(',')},');
      });

      builder.element('weapons', nest: () {
        for (final weapon in weapons) {
          builder.element('weapon', nest: () {
            builder.element('name', nest: weapon['weapon']);
            if (weapon['attribute'] != null &&
                weapon['attribute']!.isNotEmpty) {
              builder.element('attribute', nest: weapon['attribute']);
            }
            if (weapon['reach'] != null && weapon['reach']!.isNotEmpty) {
              builder.element('reach', nest: weapon['reach']);
            }
            if (weapon['bonus'] != null && weapon['bonus']!.isNotEmpty) {
              builder.element('attackBonus', nest: weapon['bonus']);
            }
            if (weapon['damage'] != null && weapon['damage']!.isNotEmpty) {
              builder.element('damage', nest: weapon['damage']);
            }
            if (weapon['damageType'] != null &&
                weapon['damageType']!.isNotEmpty) {
              builder.element('damageType', nest: weapon['damageType']);
            }
            if (weapon['description'] != null &&
                weapon['description']!.isNotEmpty) {
              builder.element('description', nest: weapon['description']);
            }
          });
        }
      });

      builder.element('items', nest: () {
        for (final item in items) {
          builder.element('item', nest: () {
            builder.element('name', nest: item['itemname']);
            if (item['description'] != null &&
                item['description']!.isNotEmpty) {
              builder.element('detail', nest: item['description']);
            }
            if (item['type'] != null && item['type']!.isNotEmpty) {
              builder.element('type', nest: item['type']);
            }
          });
        }
      });

      builder.element('savingthrows', nest: () {
        final allowedKeys = ['STR', 'DEX', 'CON', 'INT', 'WIS', 'CHA'];

        for (final entry in savingThrows.first.entries) {
          final key = entry.key;
          final value = entry.value;

          if (allowedKeys.contains(key) && value != null) {
            builder.element(key, nest: value.toString());
          }
        }
      });

      builder.element('bag', nest: () {
        for (final item in bagItems) {
          if (item['platin'] != null) {
            builder.element(Defines.bagPlatin, nest: item['platin'].toString());
          }
          if (item['gold'] != null) {
            builder.element(Defines.bagGold, nest: item['gold'].toString());
          }
          if (item['electrum'] != null) {
            builder.element(Defines.bagElectrum,
                nest: item['electrum'].toString());
          }
          if (item['silver'] != null) {
            builder.element(Defines.bagSilver, nest: item['silver'].toString());
          }
          if (item['copper'] != null) {
            builder.element(Defines.bagCopper, nest: item['copper'].toString());
          }
        }
      });

      builder.element('skills', nest: () {
        for (final skill in skills) {
          builder.element('skill', nest: () {
            builder.element('name', nest: skill['skill']);
            builder.element('proficiency',
                nest: skill['proficiency'].toString());
            builder.element('expertise', nest: skill['expertise'].toString());
          });
        }
      });

      builder.element('creatures', nest: () {
        for (final creature in creatures) {
          builder.element('creature', nest: () {
            builder.element('name', nest: creature.name);
            builder.element('size', nest: creature.size);
            builder.element('type', nest: creature.type);
            builder.element('alignment', nest: creature.alignment);
            builder.element('ac', nest: creature.ac.toString());
            builder.element('hp', nest: creature.hp);
            builder.element('currentHP', nest: creature.currentHP.toString());
            builder.element('maxHP', nest: creature.maxHP.toString());
            builder.element('speed', nest: creature.speed);
            builder.element('str', nest: creature.str.toString());
            builder.element('dex', nest: creature.dex.toString());
            builder.element('con', nest: creature.con.toString());
            builder.element('intScore', nest: creature.intScore.toString());
            builder.element('wis', nest: creature.wis.toString());
            builder.element('cha', nest: creature.cha.toString());
            builder.element('saves', nest: creature.saves);
            builder.element('skills', nest: creature.skills);
            builder.element('resistances', nest: creature.resistances);
            builder.element('vulnerabilities', nest: creature.vulnerabilities);
            builder.element('immunities', nest: creature.immunities);
            builder.element('conditionImmunities',
                nest: creature.conditionImmunities);
            builder.element('senses', nest: creature.senses);
            builder.element('passivePerception',
                nest: creature.passivePerception.toString());
            builder.element('languages', nest: creature.languages);
            builder.element('cr', nest: creature.cr);

            builder.element('traits', nest: () {
              for (final trait in creature.traits) {
                builder.element('trait', nest: () {
                  builder.element('name', nest: trait.name);
                  builder.element('description', nest: trait.description);
                });
              }
            });

            builder.element('actions', nest: () {
              for (final action in creature.actions) {
                builder.element('action', nest: () {
                  builder.element('name', nest: action.name);
                  builder.element('description', nest: action.description);
                  builder.element('actionDetails', nest: action.attack);
                });
              }
            });

            builder.element('legendaryActions', nest: () {
              for (final legendary in creature.legendaryActions) {
                builder.element('legendaryAction', nest: () {
                  builder.element('name', nest: legendary.name);
                  builder.element('description', nest: legendary.description);
                });
              }
            });
          });
        }
      });
    });

    final document = builder.buildDocument();
    return document.toXmlString(pretty: true, indent: '  ');
  }
}
