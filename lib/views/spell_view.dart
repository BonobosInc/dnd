import 'package:dnd/classes/wiki_parser.dart';
import 'package:dnd/configs/defines.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:dnd/configs/colours.dart';
import 'package:dnd/classes/profile_manager.dart';
import 'spell_editing_view.dart';

class SpellManagementPage extends StatefulWidget {
  final ProfileManager profileManager;

  final WikiParser wikiParser;

  const SpellManagementPage({
    super.key,
    required this.profileManager,
    required this.wikiParser,
  });

  @override
  SpellManagementPageState createState() => SpellManagementPageState();
}

class SpellManagementPageState extends State<SpellManagementPage> {
  final TextEditingController _spellAttackController = TextEditingController();
  final TextEditingController _spellDcController = TextEditingController();
  final TextEditingController _spellcastingClassController =
      TextEditingController();
  final TextEditingController _spellcastingAbilityController =
      TextEditingController();

  List<List<Spell>> spellLevels = List.generate(10, (index) => []);

  @override
  void initState() {
    super.initState();
    _initializeFields();
    _fetchSpells();
  }

  Future<void> _initializeFields() async {
    var initialStats = await widget.profileManager.getStats();
    var initialInfo = await widget.profileManager.getProfileInfo();

    int spellAttackBonus = initialStats[0][Defines.statSpellAttackBonus] ?? 0;
    int spellSaveDC = initialStats[0][Defines.statSpellSaveDC] ?? 0;
    String spellcastingClass =
        initialInfo[0][Defines.infoSpellcastingClass] ?? "";
    String spellcastingAbility =
        initialInfo[0][Defines.infoSpellcastingAbility] ?? "";

    _spellAttackController.text = spellAttackBonus.toString();

    _spellDcController.text = spellSaveDC.toString();

    _spellcastingClassController.text = spellcastingClass;

    _spellcastingAbilityController.text = spellcastingAbility;
  }

  Future<void> _fetchSpells() async {
    spellLevels = List.generate(10, (index) => []);

    List<Map<String, dynamic>> spellsWithLevels =
        await widget.profileManager.getAllSpells();

    for (var spell in spellsWithLevels) {
      if (spell['status'] == Defines.spellPrep && spell['level'] != null) {
        int level;

        if (spell['level'] is String) {
          level = int.tryParse(spell['level']) ?? 0;
        } else if (spell['level'] is int) {
          level = spell['level'];
        } else {
          continue;
        }

        Spell spellObj = Spell(
          name: spell['spellname'] ?? '',
          description: spell['description'] ?? '',
          status: spell['status'] ?? '',
          level: level,
          reach: spell['reach'] ?? '',
          duration: spell['duration'] ?? '',
          uuid: spell['ID'],
        );

        if (level >= 0 && level < spellLevels.length) {
          spellLevels[level].add(spellObj);
        }
      }
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Zauber'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => SpellEditingPage(
                          profileManager: widget.profileManager,
                          wikiParser: widget.wikiParser,
                        )),
              );
              await _fetchSpells();
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildSpellcastingFields(),
            Expanded(child: _buildSpellLevelFields()),
          ],
        ),
      ),
    );
  }

  Widget _buildSpellcastingFields() {
    return SizedBox(
      width: 300,
      height: 200,
      child: GridView.count(
        crossAxisCount: 2,
        childAspectRatio: 1.5,
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        children: [
          _buildTextField(
            controller: _spellAttackController,
            label: 'Zauber Angriff',
            hint: '',
            onChanged: (value) =>
                _updateField(Defines.statSpellAttackBonus, value),
            isIntegerField: true,
          ),
          _buildTextField(
            controller: _spellDcController,
            label: 'Zauberrettungswurf-SG',
            hint: '',
            onChanged: (value) => _updateField(Defines.statSpellSaveDC, value),
            isIntegerField: true,
          ),
          _buildTextField(
            controller: _spellcastingClassController,
            label: 'Zauberwirkende Klasse',
            hint: '',
            onChanged: (value) =>
                _updateField(Defines.infoSpellcastingClass, value),
          ),
          _buildTextField(
            controller: _spellcastingAbilityController,
            label: 'Zauberattribut',
            hint: '',
            onChanged: (value) =>
                _updateField(Defines.infoSpellcastingAbility, value),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required Function(String) onChanged,
    bool isIntegerField = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: 150,
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              label,
              style: TextStyle(
                color: AppColors.textColorLight,
                fontSize: 16,
              ),
            ),
          ),
        ),
        SizedBox(
          width: 100,
          height: 60,
          child: TextField(
            controller: controller,
            textAlign: TextAlign.center,
            keyboardType:
                isIntegerField ? TextInputType.number : TextInputType.text,
            inputFormatters: isIntegerField
                ? <TextInputFormatter>[FilteringTextInputFormatter.digitsOnly]
                : [],
            decoration: InputDecoration(
              filled: true,
              fillColor: AppColors.cardColor,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
                borderSide: BorderSide(color: AppColors.borderColor),
              ),
              hintText: hint,
              hintStyle: TextStyle(color: AppColors.textColorDark),
            ),
            onChanged: (value) {
              if (isIntegerField) {
                if (value.isEmpty || int.tryParse(value) != null) {
                  onChanged(value);
                } else {
                  controller.clear();
                }
              } else {
                onChanged(value);
              }
            },
          ),
        ),
      ],
    );
  }

  Future<void> _updateField(String field, String value) async {
    if (field == Defines.statSpellAttackBonus ||
        field == Defines.statSpellSaveDC) {
      await widget.profileManager.updateStats(field: field, value: value);
    } else {
      await widget.profileManager.updateProfileInfo(field: field, value: value);
    }
  }

  Widget _buildSpellLevelFields() {
    return SingleChildScrollView(
      child: Column(
        children: [
          for (int levelIndex = 0;
              levelIndex < spellLevels.length;
              levelIndex++)
            Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: () {
                      if (levelIndex > 0) {
                        _editSpellSlots(levelIndex);
                      }
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (levelIndex > 0) ...[
                          _buildDecrementButton(levelIndex),
                        ],
                        Text(
                          levelIndex == 0
                              ? 'Zaubertrick'
                              : 'Level $levelIndex ',
                          style: TextStyle(
                            color: AppColors.textColorLight,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (levelIndex > 0) ...[
                          _buildSpellSlotControls(levelIndex),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  ..._buildSpellNames(levelIndex),
                  const SizedBox(height: 8),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDecrementButton(int levelIndex) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: widget.profileManager.getSpellSlots(),
      builder: (context, snapshot) {
        int totalSlots = 0;
        int currentSlots = 0;
        if (snapshot.hasData) {
          String spellSlotKey = _getSpellSlotKey(levelIndex);

          for (var slot in snapshot.data!) {
            if (slot['spellslot'] == spellSlotKey) {
              totalSlots = slot['total'] ?? 0;
              currentSlots = slot['spent'] ?? 0;
            }
          }
        }

        return IconButton(
          icon: const Icon(Icons.remove),
          onPressed: () {
            if (currentSlots > 0) {
              setState(() {
                currentSlots--;
              });
              _updateCurrentSlots(levelIndex, currentSlots, totalSlots);
            }
          },
        );
      },
    );
  }

  Widget _buildSpellSlotControls(int levelIndex) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: widget.profileManager.getSpellSlots(),
      builder: (context, snapshot) {
        int totalSlots = 0;
        int currentSlots = 0;

        if (snapshot.hasData) {
          String spellSlotKey = _getSpellSlotKey(levelIndex);

          for (var slot in snapshot.data!) {
            if (slot['spellslot'] == spellSlotKey) {
              totalSlots = slot['total'] ?? 0;
              currentSlots = slot['spent'] ?? 0;
            }
          }
        }

        return Row(
          children: [
            Text(
              '($currentSlots/$totalSlots)',
              style: TextStyle(
                color: AppColors.textColorLight,
                fontSize: 16,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () {
                if (currentSlots < totalSlots) {
                  setState(() {
                    currentSlots++;
                  });
                  _updateCurrentSlots(levelIndex, currentSlots, totalSlots);
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _updateCurrentSlots(
      int levelIndex, int currentSlots, int totalSlots) async {
    String spellSlotKey = _getSpellSlotKey(levelIndex);

    await widget.profileManager.updateSpellSlots(
      spellslot: spellSlotKey,
      total: totalSlots,
      spent: currentSlots,
    );

    if (mounted) {
      setState(() {
        _fetchAndUpdateSlots();
      });
    }
  }

  List<Widget> _buildSpellNames(int levelIndex) {
    List<Widget> fields = [];
    for (var spell in spellLevels[levelIndex]) {
      fields.add(
        GestureDetector(
          onTap: () async {
            Map<String, dynamic> spelldata =
                await widget.profileManager.getSpell(spell.uuid!);
            _showSpellDescription(spell.name, spelldata);
          },
          child: SizedBox(
            width: 150,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              margin: const EdgeInsets.only(bottom: 8.0, right: 8.0),
              decoration: BoxDecoration(
                color: AppColors.cardColor,
                borderRadius: BorderRadius.circular(10.0),
                border: Border.all(color: AppColors.borderColor, width: 1.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    offset: const Offset(2, 2),
                    blurRadius: 4.0,
                    spreadRadius: 1.0,
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  spell.name.isNotEmpty ? spell.name : '',
                  style: TextStyle(
                    color: AppColors.textColorDark,
                    fontSize: 14.0,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 4,
                  overflow: TextOverflow.visible,
                ),
              ),
            ),
          ),
        ),
      );
    }

    return [
      Center(
        child: SizedBox(
          width: MediaQuery.of(context).size.width * 0.7,
          child: Wrap(
            alignment: WrapAlignment.center,
            spacing: 8.0,
            runSpacing: 8.0,
            children: fields,
          ),
        ),
      ),
    ];
  }

  void _showSpellDescription(String spellName, Map<String, dynamic> spellData) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(spellName),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Reichweite: ",
                    style: TextStyle(fontWeight: FontWeight.bold)),
                Text(spellData['reach'] ?? 'Nicht angegeben'),
                SizedBox(height: 8.0),
                Text("Dauer: ", style: TextStyle(fontWeight: FontWeight.bold)),
                Text(spellData['duration'] ?? 'Nicht angegeben'),
                SizedBox(height: 8.0),
                Text("Beschreibung: ",
                    style: TextStyle(fontWeight: FontWeight.bold)),
                Text(
                    spellData['description'] ?? 'Keine Beschreibung gefunden.'),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Schließen'),
            ),
          ],
        );
      },
    );
  }

  void _editSpellSlots(int levelIndex) async {
    int totalSlots = 0;
    int currentSlots = 0;

    String spellSlotKey = _getSpellSlotKey(levelIndex);

    var slots = await widget.profileManager.getSpellSlots();

    for (var slot in slots) {
      if (slot['spellslot'] == spellSlotKey) {
        totalSlots = slot['total'] ?? 0;
        currentSlots = slot['spent'] ?? 0;
      }
    }

    if (!mounted) return;

    showDialog(
      context: context,
      builder: (context) {
        int newTotal = totalSlots;
        int newCurrent = currentSlots;

        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(
                'Zauberplätze für Level ${levelIndex == 0 ? "Zaubertricks" : levelIndex}',
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Gesamt:'),
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove),
                            onPressed: () {
                              setState(() {
                                if (newTotal > 0) newTotal--;
                              });
                            },
                          ),
                          Text('$newTotal'),
                          IconButton(
                            icon: const Icon(Icons.add),
                            onPressed: () {
                              setState(() {
                                newTotal++;
                              });
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Aktuell:'),
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove),
                            onPressed: () {
                              setState(() {
                                if (newCurrent > 0) newCurrent--;
                              });
                            },
                          ),
                          Text('$newCurrent'),
                          IconButton(
                            icon: const Icon(Icons.add),
                            onPressed: () {
                              setState(() {
                                if (newCurrent < newTotal) newCurrent++;
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
                    await widget.profileManager.updateSpellSlots(
                      spellslot: spellSlotKey,
                      total: newTotal,
                      spent: newCurrent,
                    );

                    if (mounted) {
                      setState(() {
                        _fetchAndUpdateSlots();
                      });
                    }
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

  void _fetchAndUpdateSlots() {
    widget.profileManager.getSpellSlots().then((slots) {
      setState(() {});
    });
  }

  String _getSpellSlotKey(int levelIndex) {
    switch (levelIndex) {
      case 0:
        return Defines.slotZero;
      case 1:
        return Defines.slotOne;
      case 2:
        return Defines.slotTwo;
      case 3:
        return Defines.slotThree;
      case 4:
        return Defines.slotFour;
      case 5:
        return Defines.slotFive;
      case 6:
        return Defines.slotSix;
      case 7:
        return Defines.slotSeven;
      case 8:
        return Defines.slotEight;
      case 9:
        return Defines.slotNine;
      default:
        return Defines.slotZero;
    }
  }
}
