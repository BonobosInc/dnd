import 'package:flutter/material.dart';
import 'package:dnd/classes/profile_manager.dart';
import 'package:dnd/configs/defines.dart';

class StatsPage extends StatefulWidget {
  final ProfileManager profileManager;

  const StatsPage({super.key, required this.profileManager});

  @override
  StatsPageState createState() => StatsPageState();
}

class StatsPageState extends State<StatsPage> {

  int strength = 10;
  int dexterity = 10;
  int constitution = 10;
  int intelligence = 10;
  int wisdom = 10;
  int charisma = 10;

  int proficiencyBonus = 0;

  int saveStrProficiency = 0;
  int saveDexProficiency = 0;
  int saveConProficiency = 0;
  int saveIntProficiency = 0;
  int saveWisProficiency = 0;
  int saveChaProficiency = 0;

  int skillProfAcro = 0;
  int skillProfAnim = 0;
  int skillProfArca = 0;
  int skillProfAthl = 0;
  int skillProfDece = 0;
  int skillProfHist = 0;
  int skillProfInsi = 0;
  int skillProfInti = 0;
  int skillProfInve = 0;
  int skillProfMedi = 0;
  int skillProfNatu = 0;
  int skillProfPerc = 0;
  int skillProfPerf = 0;
  int skillProfPers = 0;
  int skillProfReli = 0;
  int skillProfSlei = 0;
  int skillProfStea = 0;
  int skillJack = 0;

  int skillExAcro = 0;
  int skillExAnim = 0;
  int skillExArca = 0;
  int skillExAthl = 0;
  int skillExDece = 0;
  int skillExHist = 0;
  int skillExInsi = 0;
  int skillExInti = 0;
  int skillExInve = 0;
  int skillExMedi = 0;
  int skillExNatu = 0;
  int skillExPerc = 0;
  int skillExPerf = 0;
  int skillExPers = 0;
  int skillExReli = 0;
  int skillExSlei = 0;
  int skillExStea = 0;

  @override
  void initState() {
    super.initState();
    _loadCharacterData();
  }

  Future<void> updateStats(String field, dynamic newScore) async {
    await widget.profileManager.updateStats(field: field, value: newScore);
    setState(() {
      _loadCharacterData();
    });
  }

  Future<void> updateSaves(String field, dynamic newScore) async {
    await widget.profileManager
        .updateSavingThrows(field: field, value: newScore);
    setState(() {
      _loadCharacterData();
    });
  }

  Future<void> updateSkills(
      String field, int proficiency, int? expertise) async {
    await widget.profileManager.updateSkills(
        skill: field, proficiency: proficiency, expertise: expertise);
    setState(() {
      _loadCharacterData();
    });
  }

  Future<void> _loadCharacterData() async {
    // Load character stats
    List<Map<String, dynamic>> stats = await widget.profileManager.getStats();

    // Load saving throws
    List<Map<String, dynamic>> saves =
        await widget.profileManager.getSavingThrows();

    // Load skills
    List<Map<String, dynamic>> skills = await widget.profileManager.getSkills();

    // Loading stats
    if (stats.isNotEmpty) {
      Map<String, dynamic> characterStats = stats.first;
      setState(() {
        strength = characterStats[Defines.statSTR] ?? 10;
        dexterity = characterStats[Defines.statDEX] ?? 10;
        constitution = characterStats[Defines.statCON] ?? 10;
        intelligence = characterStats[Defines.statINT] ?? 10;
        wisdom = characterStats[Defines.statWIS] ?? 10;
        charisma = characterStats[Defines.statCHA] ?? 10;
        proficiencyBonus = characterStats[Defines.statProficiencyBonus] ?? 0;
      });
    }

    // Loading saving throws
    if (saves.isNotEmpty) {
      Map<String, dynamic> characterStats = saves.first;
      setState(() {
        saveStrProficiency = characterStats[Defines.saveStr] ?? 0;
        saveDexProficiency = characterStats[Defines.saveDex] ?? 0;
        saveConProficiency = characterStats[Defines.saveCon] ?? 0;
        saveIntProficiency = characterStats[Defines.saveInt] ?? 0;
        saveWisProficiency = characterStats[Defines.saveWis] ?? 0;
        saveChaProficiency = characterStats[Defines.saveCha] ?? 0;
      });
    }

    // Loading skills and expertise
    if (skills.isNotEmpty) {
      for (var skill in skills) {
        switch (skill['skill']) {
          case Defines.skillAcrobatics:
            setState(() {
              skillProfAcro = skill['proficiency'] ?? 0;
              skillExAcro = skill['expertise'] ?? 0;
            });
            break;
          case Defines.skillAnimalHandling:
            setState(() {
              skillProfAnim = skill['proficiency'] ?? 0;
              skillExAnim = skill['expertise'] ?? 0;
            });
            break;
          case Defines.skillArcana:
            setState(() {
              skillProfArca = skill['proficiency'] ?? 0;
              skillExArca = skill['expertise'] ?? 0;
            });
            break;
          case Defines.skillAthletics:
            setState(() {
              skillProfAthl = skill['proficiency'] ?? 0;
              skillExAthl = skill['expertise'] ?? 0;
            });
            break;
          case Defines.skillDeception:
            setState(() {
              skillProfDece = skill['proficiency'] ?? 0;
              skillExDece = skill['expertise'] ?? 0;
            });
            break;
          case Defines.skillHistory:
            setState(() {
              skillProfHist = skill['proficiency'] ?? 0;
              skillExHist = skill['expertise'] ?? 0;
            });
            break;
          case Defines.skillInsight:
            setState(() {
              skillProfInsi = skill['proficiency'] ?? 0;
              skillExInsi = skill['expertise'] ?? 0;
            });
            break;
          case Defines.skillIntimidation:
            setState(() {
              skillProfInti = skill['proficiency'] ?? 0;
              skillExInti = skill['expertise'] ?? 0;
            });
            break;
          case Defines.skillInvestigation:
            setState(() {
              skillProfInve = skill['proficiency'] ?? 0;
              skillExInve = skill['expertise'] ?? 0;
            });
            break;
          case Defines.skillMedicine:
            setState(() {
              skillProfMedi = skill['proficiency'] ?? 0;
              skillExMedi = skill['expertise'] ?? 0;
            });
            break;
          case Defines.skillNature:
            setState(() {
              skillProfNatu = skill['proficiency'] ?? 0;
              skillExNatu = skill['expertise'] ?? 0;
            });
            break;
          case Defines.skillPerception:
            setState(() {
              skillProfPerc = skill['proficiency'] ?? 0;
              skillExPerc = skill['expertise'] ?? 0;
            });
            break;
          case Defines.skillPerformance:
            setState(() {
              skillProfPerf = skill['proficiency'] ?? 0;
              skillExPerf = skill['expertise'] ?? 0;
            });
            break;
          case Defines.skillPersuasion:
            setState(() {
              skillProfPers = skill['proficiency'] ?? 0;
              skillExPers = skill['expertise'] ?? 0;
            });
            break;
          case Defines.skillReligion:
            setState(() {
              skillProfReli = skill['proficiency'] ?? 0;
              skillExReli = skill['expertise'] ?? 0;
            });
            break;
          case Defines.skillSleightOfHand:
            setState(() {
              skillProfSlei = skill['proficiency'] ?? 0;
              skillExSlei = skill['expertise'] ?? 0;
            });
            break;
          case Defines.skillStealth:
            setState(() {
              skillProfStea = skill['proficiency'] ?? 0;
              skillExStea = skill['expertise'] ?? 0;
            });
            break;
          case Defines.skillJackofAllTrades:
            setState(() {
              skillJack = skill['proficiency'] ?? 0;
            });
            break;
        }
      }
    }
  }

  Widget _buildHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const Divider(color: Colors.grey, thickness: 1.5),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildStatRow(String statName, int abilityScore, String field) {
    int abilityModifier = ((abilityScore - 10) / 2).floor();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 0.0, horizontal: 12.0),
      child: Row(
        children: [
          Expanded(
            flex: 1,
            child: GestureDetector(
              onTap: () => _showEditDialog(statName, abilityScore, field),
              child: Column(
                children: [
                  SizedBox(
                    height: 45,
                    child: Card(
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Center(
                        child: Text(
                          abilityScore.toString(),
                          style: const TextStyle(fontSize: 16),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 3),
          Expanded(
            flex: 2,
            child: Column(
              children: [
                SizedBox(
                  height: 45,
                  child: Card(
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Center(
                      child: Text(
                        statName,
                        style: const TextStyle(fontSize: 16),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 5),
          Expanded(
            flex: 1,
            child: Column(
              children: [
                SizedBox(
                  height: 45,
                  child: Card(
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Center(
                      child: Text(
                        (abilityModifier >= 0
                            ? "+$abilityModifier"
                            : "$abilityModifier"),
                        style: const TextStyle(fontSize: 16),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showEditDialog(
      String statName, int currentScore, String field) async {
    int newScore = currentScore;

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Bearbeite $statName'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Wert:'),
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove),
                            onPressed: () {
                              setState(() {
                                if (newScore > 0) newScore--;
                              });
                            },
                          ),
                          Text('$newScore'),
                          IconButton(
                            icon: const Icon(Icons.add),
                            onPressed: () {
                              setState(() {
                                newScore++;
                              });
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Abbrechen'),
                ),
                TextButton(
                  onPressed: () async {
                    updateStats(field, newScore);

                    if (context.mounted) Navigator.of(context).pop();
                  },
                  child: const Text('Speichern'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _showSavingThrowDialog(
      String statName, int proficiency, String field) async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Rettungswurf für $statName'),
        content: StatefulBuilder(
          builder: (context, setState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CheckboxListTile(
                  title: const Text("Übungsbonus"),
                  value: proficiency == 1,
                  onChanged: (bool? value) {
                    setState(() {
                      proficiency = value == true ? 1 : 0;
                    });
                  },
                ),
              ],
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Abbrechen'),
          ),
          TextButton(
            onPressed: () async {
              updateSaves(field, proficiency);
              setState(() {
                _loadCharacterData();
              });
              Navigator.of(context).pop();
            },
            child: const Text('Speichern'),
          ),
        ],
      ),
    );
  }

  Widget _buildSavingThrowRow(
      String statName, int proficiency, String field, int abilityScore) {
    int abilityModifier = (abilityScore - 10) ~/ 2;
    int savingThrowBonus =
        proficiency == 1 ? abilityModifier + proficiencyBonus : abilityModifier;

    String bonusText =
        savingThrowBonus >= 0 ? "+$savingThrowBonus" : "$savingThrowBonus";

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 0.0, horizontal: 12.0),
      child: Row(
        children: [
          Expanded(
            flex: 1,
            child: GestureDetector(
              onTap: () => _showSavingThrowDialog(statName, proficiency, field),
              child: SizedBox(
                height: 45,
                child: Card(
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Center(
                    child: Text(
                      bonusText,
                      style: const TextStyle(fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 3),
          Expanded(
            flex: 3,
            child: SizedBox(
              height: 45,
              child: Card(
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Center(
                  child: Text(
                    statName,
                    style: const TextStyle(fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showSkillDialog(
      String skillName, int proficiency, int hasExpertise, String field) async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Bearbeite Fertigkeit für $skillName'),
        content: StatefulBuilder(
          builder: (context, setState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CheckboxListTile(
                  title: const Text("Übung"),
                  value: proficiency == 1,
                  onChanged: (bool? value) {
                    setState(() {
                      proficiency = value == true ? 1 : 0;
                      if (proficiency == 0) {
                        hasExpertise = 0;
                      }
                    });
                  },
                ),
                CheckboxListTile(
                  title: const Text("Expertise"),
                  value: hasExpertise == 1,
                  onChanged: (bool? value) {
                    if (proficiency == 1) {
                      setState(() {
                        hasExpertise = value == true ? 1 : 0;
                      });
                    }
                  },
                  enabled: proficiency == 1,
                  activeColor: proficiency == 1 ? null : Colors.grey,
                  checkColor: proficiency == 1 ? null : Colors.grey[700],
                ),
                CheckboxListTile(
                  title: const Text("Alleskönner"),
                  value: skillJack == 1,
                  onChanged: (bool? value) {
                    setState(() {
                      skillJack = value == true ? 1 : 0;
                    });
                  },
                ),
              ],
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Abbrechen'),
          ),
          TextButton(
            onPressed: () async {
              updateSkills(field, proficiency, hasExpertise);
              updateSkills(Defines.skillJackofAllTrades, skillJack, null);
              setState(() {
                _loadCharacterData();
              });
              Navigator.of(context).pop();
            },
            child: const Text('Speichern'),
          ),
        ],
      ),
    );
  }

  Widget _buildSkillRow(String skillName, int proficiency, int hasExpertise,
      String field, int abilityScore) {
    int abilityModifier = (abilityScore - 10) ~/ 2;

    int skillBonus = abilityModifier;

    if (skillJack == 1 && proficiency != 1 && hasExpertise != 1) {
      skillBonus += 1;
    } else {
      if (proficiency == 1) {
        skillBonus += proficiencyBonus;
        if (hasExpertise == 1) {
          skillBonus += proficiencyBonus;
        }
      }
    }

    String bonusText = skillBonus >= 0 ? "+$skillBonus" : "$skillBonus";

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 0.0, horizontal: 12.0),
      child: Row(
        children: [
          Expanded(
            flex: 1,
            child: GestureDetector(
              onTap: () =>
                  _showSkillDialog(skillName, proficiency, hasExpertise, field),
              child: SizedBox(
                height: 45,
                child: Card(
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Center(
                    child: Text(
                      bonusText,
                      style: const TextStyle(fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 3),
          Expanded(
            flex: 3,
            child: SizedBox(
              height: 45,
              child: Card(
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Center(
                  child: Text(
                    skillName,
                    style: const TextStyle(fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSkillsSection() {
    return Column(
      children: [
        _buildSkillsLabelRow(),
        _buildSkillRow("Akrobatik", skillProfAcro, skillExAcro,
            Defines.skillAcrobatics, dexterity),
        _buildSkillRow("Arkane Kenntnis", skillProfArca, skillExArca,
            Defines.skillArcana, intelligence),
        _buildSkillRow("Athletik", skillProfAthl, skillExAthl,
            Defines.skillAthletics, strength),
        _buildSkillRow("Auftreten", skillProfPerf, skillExPerf,
            Defines.skillPerformance, charisma),
        _buildSkillRow("Einschüchtern", skillProfInti, skillExInti,
            Defines.skillIntimidation, charisma),
        _buildSkillRow("Fingerfertigkeit", skillProfSlei, skillExSlei,
            Defines.skillSleightOfHand, dexterity),
        _buildSkillRow("Geschichte", skillProfHist, skillExHist,
            Defines.skillHistory, intelligence),
        _buildSkillRow("Heilkunde", skillProfMedi, skillExMedi,
            Defines.skillMedicine, wisdom),
        _buildSkillRow("Heimlichkeit", skillProfStea, skillExStea,
            Defines.skillStealth, dexterity),
        _buildSkillRow("Mit Tieren umgehen", skillProfAnim, skillExAnim,
            Defines.skillAnimalHandling, wisdom),
        _buildSkillRow("Motiv Erkennen", skillProfInsi, skillExInsi,
            Defines.skillInsight, wisdom),
        _buildSkillRow("Nachforschung", skillProfInve, skillExInve,
            Defines.skillInvestigation, intelligence),
        _buildSkillRow("Naturkunde", skillProfNatu, skillExNatu,
            Defines.skillNature, intelligence),
        _buildSkillRow("Religion", skillProfReli, skillExReli,
            Defines.skillReligion, intelligence),
        _buildSkillRow("Täuschen", skillProfDece, skillExDece,
            Defines.skillDeception, charisma),
        _buildSkillRow("Überlebenskunst", skillProfStea, skillExStea,
            Defines.skillSurvival, wisdom),
        _buildSkillRow("Überredung", skillProfPers, skillExPers,
            Defines.skillPersuasion, charisma),
        _buildSkillRow("Wahrnehmung", skillProfPerc, skillExPerc,
            Defines.skillPerception, wisdom),
      ],
    );
  }

  Widget _buildStatsLabelRow() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 0.0, horizontal: 12.0),
      child: Row(
        children: [
          Expanded(
            flex: 1,
            child: Center(
              child: Text(
                "Wert",
                style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          SizedBox(width: 5),
          Expanded(
            flex: 2,
            child: Center(
              child: Text(
                "Fähigkeit",
                style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          SizedBox(width: 5),
          Expanded(
            flex: 1,
            child: Center(
              child: Text(
                "Mod",
                style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSavingThrowLabelRow() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 0.0, horizontal: 12.0),
      child: Row(
        children: [
          Expanded(
            flex: 1,
            child: Center(
              child: Text(
                "Bonus",
                style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          SizedBox(width: 5),
          Expanded(
            flex: 3,
            child: Center(
              child: Text(
                "Fähigkeit",
                style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSkillsLabelRow() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 0.0, horizontal: 12.0),
      child: Row(
        children: [
          Expanded(
            flex: 1,
            child: Center(
              child: Text(
                "Bonus",
                style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          SizedBox(width: 5),
          Expanded(
            flex: 3,
            child: Center(
              child: Text(
                "Fertigkeit",
                style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader("Stats"),
          _buildStatsLabelRow(),
          _buildStatRow("Stärke", strength, Defines.statSTR),
          _buildStatRow("Geschicklichkeit", dexterity, Defines.statDEX),
          _buildStatRow("Konstitution", constitution, Defines.statCON),
          _buildStatRow("Intelligenz", intelligence, Defines.statINT),
          _buildStatRow("Weisheit", wisdom, Defines.statWIS),
          _buildStatRow("Charisma", charisma, Defines.statCHA),
          const SizedBox(height: 24),
          _buildHeader("Rettungswürfe"),
          _buildSavingThrowLabelRow(),
          _buildSavingThrowRow(
              "Stärke", saveStrProficiency, Defines.saveStr, strength),
          _buildSavingThrowRow("Geschicklichkeit", saveDexProficiency,
              Defines.saveDex, dexterity),
          _buildSavingThrowRow("Konstitution", saveConProficiency,
              Defines.saveCon, constitution),
          _buildSavingThrowRow(
              "Intelligenz", saveIntProficiency, Defines.saveInt, intelligence),
          _buildSavingThrowRow(
              "Weisheit", saveWisProficiency, Defines.saveWis, wisdom),
          _buildSavingThrowRow(
              "Charisma", saveChaProficiency, Defines.saveCha, charisma),
          const SizedBox(height: 24),
          _buildHeader("Fertigkeiten"),
          _buildSkillsSection(),
        ],
      ),
    );
  }
}
