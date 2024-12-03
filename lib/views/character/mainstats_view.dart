import 'package:dnd/classes/wiki_classes.dart';
import 'package:dnd/classes/wiki_parser.dart';
import 'package:dnd/configs/colours.dart';
import 'package:dnd/views/wiki/creatures_view.dart';
import 'package:flutter/material.dart';
import 'package:dnd/classes/profile_manager.dart';
import 'package:dnd/configs/defines.dart';

class MainStatsPage extends StatefulWidget {
  final ProfileManager profileManager;
  final WikiParser wikiParser;

  const MainStatsPage(
      {super.key, required this.profileManager, required this.wikiParser});

  @override
  MainStatsPageState createState() => MainStatsPageState();
}

class MainStatsPageState extends State<MainStatsPage> {
  int currentHP = 0;
  int maxHP = 0;
  int tempHP = 0;

  int currentHitDice = 0;
  int maxHitDice = 0;
  String healFactor = '';

  int armor = 0;
  int inspiration = 0;
  int proficiencyBonus = 0;
  int initiative = 0;
  String movement = '0m';

  List<Tracker> trackers = [];

  List<Creature> creatures = [];

  @override
  void initState() {
    super.initState();
    _loadCharacterData();
    _loadTrackers();
    _fetchCreatures();
  }

  Future<void> _loadCharacterData() async {
    List<Map<String, dynamic>> result = await widget.profileManager.getStats();

    if (result.isNotEmpty) {
      Map<String, dynamic> characterData = result.first;
      setState(() {
        currentHP = characterData[Defines.statCurrentHP];
        maxHP = characterData[Defines.statMaxHP];
        tempHP = characterData[Defines.statTempHP];
        armor = characterData[Defines.statArmor];
        inspiration = characterData[Defines.statInspiration];
        proficiencyBonus = characterData[Defines.statProficiencyBonus];
        initiative = characterData[Defines.statInitiative];
        movement = characterData[Defines.statMovement].toString();
        currentHitDice = characterData[Defines.statCurrentHitDice];
        maxHitDice = characterData[Defines.statMaxHitDice];
        healFactor = characterData[Defines.statHitDiceFactor];
      });
    }
  }

  Future<void> _loadTrackers() async {
    List<Map<String, dynamic>> result =
        await widget.profileManager.getTracker();
    setState(() {
      trackers.clear();
      for (var item in result) {
        trackers.add(Tracker(
          tracker: item['trackername'],
          uuid: item['ID'],
          value: item['value'],
        ));
      }
    });
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required ValueChanged<String> onChanged,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      onChanged: onChanged,
      keyboardType: keyboardType,
    );
  }

  void _incrementHP() {
    setState(() {
      if (tempHP > 0) {
        currentHP = (currentHP + 1).clamp(0, maxHP);
        _updateStat(Defines.statCurrentHP, currentHP);
      } else {
        if (currentHP < maxHP) {
          currentHP = (currentHP + 1).clamp(0, maxHP);
          _updateStat(Defines.statCurrentHP, currentHP);
        }
      }
    });
  }

  void _decrementHP() {
    setState(() {
      if (tempHP > 0) {
        tempHP = (tempHP - 1).clamp(0, maxHP);
        _updateStat(Defines.statTempHP, tempHP);
      } else {
        currentHP = (currentHP - 1).clamp(0, maxHP);
        _updateStat(Defines.statCurrentHP, currentHP);
      }
    });
  }

  void _incrementCreatureHP(int index) {
    setState(() {
      if (creatures[index].currentHP < creatures[index].maxHP) {
        creatures[index].currentHP =
            (creatures[index].currentHP + 1).clamp(0, creatures[index].maxHP);
        _updateCreatureHP(index);
      }
    });
  }

  void _decrementCreatureHP(int index) {
    setState(() {
      if (creatures[index].currentHP > 0) {
        creatures[index].currentHP =
            (creatures[index].currentHP - 1).clamp(0, creatures[index].maxHP);
        _updateCreatureHP(index);
      }
    });
  }

  Future<void> _updateCreatureHP(int index) async {
    await widget.profileManager.updateCreature(creatures[index]);
  }

  Future<void> _updateStat(String field, dynamic value) async {
    await widget.profileManager.updateStats(field: field, value: value);
  }

  Future<void> _showEditStatDialog(
      String statName, String field, dynamic currentValue,
      {bool isCount = false}) async {
    dynamic newValue = currentValue;

    TextEditingController controller =
        TextEditingController(text: currentValue.toString());

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(statName),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  isCount
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Wert:'),
                            Row(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.remove),
                                  onPressed: () {
                                    setState(() {
                                      newValue--;
                                    });
                                  },
                                ),
                                Text('$newValue'),
                                IconButton(
                                  icon: const Icon(Icons.add),
                                  onPressed: () {
                                    setState(() {
                                      newValue++;
                                    });
                                  },
                                ),
                              ],
                            ),
                          ],
                        )
                      : _buildTextField(
                          label: "",
                          controller: controller,
                          onChanged: (value) {
                            newValue = value;
                          },
                          keyboardType: field == Defines.statMovement
                              ? TextInputType.text
                              : TextInputType.number,
                        ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text("Abbrechen"),
                ),
                TextButton(
                  onPressed: () async {
                    await _updateStat(field, newValue);

                    setState(() {
                      if (field == Defines.statArmor) {
                        armor = int.tryParse(newValue.toString())!;
                      }
                      if (field == Defines.statInspiration) {
                        inspiration = int.tryParse(newValue.toString())!;
                      }
                      if (field == Defines.statProficiencyBonus) {
                        proficiencyBonus = int.tryParse(newValue.toString())!;
                      }
                      if (field == Defines.statInitiative) {
                        initiative = int.tryParse(newValue.toString())!;
                      }
                      if (field == Defines.statMovement) {
                        movement = newValue;
                      }
                    });

                    await _loadCharacterData();
                    if (context.mounted) Navigator.of(context).pop();
                  },
                  child: const Text("Speichern"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showEditCreatureHPDialog(int index) {
    TextEditingController hpController = TextEditingController(
      text: creatures[index].currentHP.toString(),
    );
    TextEditingController maxHpController = TextEditingController(
      text: creatures[index].maxHP.toString(),
    );

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("HP für ${creatures[index].name}"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildTextField(
                label: 'Aktuelle HP',
                controller: hpController,
                onChanged: (value) {},
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 10),
              _buildTextField(
                label: 'Maximale HP',
                controller: maxHpController,
                onChanged: (value) {},
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Abbrechen'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  int newHP = int.tryParse(hpController.text) ??
                      creatures[index].currentHP;
                  int newMaxHP = int.tryParse(maxHpController.text) ??
                      creatures[index].maxHP;

                  creatures[index].currentHP = newHP.clamp(0, newMaxHP);
                  creatures[index].maxHP = newMaxHP.clamp(0, 9999);

                  _updateCreatureHP(index);
                });
                Navigator.of(context).pop();
              },
              child: const Text('Speichern'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showEditHpDialog() async {
    int newCurrentHP = currentHP;
    int newMaxHP = maxHP;
    int newTempHP = tempHP;

    TextEditingController currentHpController =
        TextEditingController(text: currentHP.toString());
    TextEditingController maxHpController =
        TextEditingController(text: maxHP.toString());
    TextEditingController tempHpController =
        TextEditingController(text: tempHP.toString());

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("HP"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildTextField(
                  label: "Aktuelle HP",
                  controller: currentHpController,
                  onChanged: (value) {
                    newCurrentHP = int.tryParse(value) ?? currentHP;
                  },
                  keyboardType: TextInputType.number),
              const SizedBox(height: 8),
              _buildTextField(
                  label: "Max HP",
                  controller: maxHpController,
                  onChanged: (value) {
                    newMaxHP = int.tryParse(value) ?? maxHP;
                  },
                  keyboardType: TextInputType.number),
              const SizedBox(height: 8),
              _buildTextField(
                  label: "Temp HP",
                  controller: tempHpController,
                  onChanged: (value) {
                    newTempHP = int.tryParse(value) ?? tempHP;
                  },
                  keyboardType: TextInputType.number),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Abbrechen"),
            ),
            TextButton(
              onPressed: () async {
                newCurrentHP = newCurrentHP.clamp(0, newMaxHP);
                newTempHP = newTempHP.clamp(0, newMaxHP);

                await _updateStat(Defines.statCurrentHP, newCurrentHP);
                await _updateStat(Defines.statMaxHP, newMaxHP);
                await _updateStat(Defines.statTempHP, newTempHP);

                setState(() {
                  currentHP = newCurrentHP;
                  maxHP = newMaxHP;
                  tempHP = newTempHP;
                });

                if (context.mounted) Navigator.of(context).pop();
              },
              child: const Text("Speichern"),
            ),
          ],
        );
      },
    );
  }

  Future<void> _addNewTracker() async {
    String newTrackerName = '';
    int newTrackerValue = 0;
    String newTrackerType = '';

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text("Neuen Tracker erstellen"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildTextField(
                    label: "Tracker",
                    controller: TextEditingController(text: newTrackerName),
                    onChanged: (value) {
                      newTrackerName = value;
                    },
                  ),
                  const SizedBox(height: 16),
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
                                if (newTrackerValue > 0) {
                                  newTrackerValue--;
                                }
                              });
                            },
                          ),
                          Text('$newTrackerValue'),
                          IconButton(
                            icon: const Icon(Icons.add),
                            onPressed: () {
                              setState(() {
                                newTrackerValue++;
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
                  child: const Text("Abbrechen"),
                ),
                TextButton(
                  onPressed: () async {
                    if (newTrackerName.isNotEmpty) {
                      await widget.profileManager.addTracker(
                        tracker: newTrackerName,
                        value: newTrackerValue,
                        type: newTrackerType,
                      );
                      _loadTrackers();
                      if (context.mounted) Navigator.of(context).pop();
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content:
                                Text("Bitte einen Tracker-Namen eingeben.")),
                      );
                    }
                  },
                  child: const Text("Hinzufügen"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _editTracker(Tracker tracker) async {
    String editedTrackerName = tracker.tracker;
    int editedValue = tracker.value ?? 0;

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(tracker.tracker),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildTextField(
                    label: "Tracker Name",
                    controller: TextEditingController(text: editedTrackerName),
                    onChanged: (value) {
                      editedTrackerName = value;
                    },
                  ),
                  const SizedBox(height: 16),
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
                                if (editedValue > 0) editedValue--;
                              });
                            },
                          ),
                          Text('$editedValue'),
                          IconButton(
                            icon: const Icon(Icons.add),
                            onPressed: () {
                              setState(() {
                                editedValue++;
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
                    await widget.profileManager.updateTracker(
                      uuid: tracker.uuid,
                      tracker: editedTrackerName,
                      value: editedValue,
                    );
                    _loadTrackers();

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

  void _addCreature() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AllCreaturesPage(
          importCreature: true,
          creatures: widget.wikiParser.creatures,
        ),
      ),
    );

    if (result != null) {
      if (result is Creature) {
        _addCreatureToList(result);
      } else if (result is List<Creature>) {
        for (var creature in result) {
          _addCreatureToList(creature);
        }
      }
    }
  }

  void _editCreature(Creature creature) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreatureDetailPage(
          creature: creature,
          statsMenu: true,
        ),
      ),
    );

    if (result != null) {
      if (result is Creature) {
        _updateCreatureToList(result);
      } else if (result is List<Creature>) {
        for (var creature in result) {
          _updateCreatureToList(creature);
        }
      }
    }
  }

  void _updateCreatureToList(Creature creature) {
    widget.profileManager.updateCreature(creature).then((_) {
      _fetchCreatures();
    });
  }

  void _addCreatureToList(Creature creature) {
    widget.profileManager.addCreature(creature).then((_) {
      _fetchCreatures();
    });
  }

  Future<void> _fetchCreatures() async {
    List<Creature> fetchedCreatures =
        await widget.profileManager.getCreatures();

    setState(() {
      creatures.clear();
      for (var creature in fetchedCreatures) {
        creatures.add(creature);
      }

      creatures.sort((a, b) => a.name.compareTo(b.name));
    });
  }

  Future<void> _showEditHitDiceDialog() async {
    int newCurrentHitDice = currentHitDice;
    int newMaxHitDice = maxHitDice;
    String newHealFactor = healFactor;

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text("Hit Dice"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildTextField(
                    label: "Heilungsfaktor",
                    controller: TextEditingController(text: healFactor),
                    onChanged: (value) {
                      newHealFactor = value;
                    },
                    keyboardType: TextInputType.text,
                  ),
                  const SizedBox(height: 16),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Aktuelle Hit Dice:'),
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove),
                            onPressed: () {
                              setState(() {
                                if (newCurrentHitDice > 0) newCurrentHitDice--;
                              });
                            },
                          ),
                          Text('$newCurrentHitDice'),
                          IconButton(
                            icon: const Icon(Icons.add),
                            onPressed: () {
                              setState(() {
                                if (newCurrentHitDice < newMaxHitDice) {
                                  newCurrentHitDice++;
                                } else {
                                  newCurrentHitDice = newMaxHitDice;
                                }
                              });
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Max Hit Dice:'),
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove),
                            onPressed: () {
                              setState(() {
                                if (newMaxHitDice > 0) newMaxHitDice--;
                              });
                            },
                          ),
                          Text('$newMaxHitDice'),
                          IconButton(
                            icon: const Icon(Icons.add),
                            onPressed: () {
                              setState(() {
                                newMaxHitDice++;
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
                  child: const Text("Abbrechen"),
                ),
                TextButton(
                  onPressed: () async {
                    newCurrentHitDice =
                        newCurrentHitDice.clamp(0, newMaxHitDice);

                    await _updateStat(
                        Defines.statCurrentHitDice, newCurrentHitDice);
                    await _updateStat(Defines.statMaxHitDice, newMaxHitDice);
                    await _updateStat(Defines.statHitDiceFactor, newHealFactor);

                    setState(() {
                      currentHitDice = newCurrentHitDice;
                      maxHitDice = newMaxHitDice;
                      healFactor = newHealFactor;
                      _loadCharacterData();
                    });

                    if (context.mounted) Navigator.of(context).pop();
                  },
                  child: const Text("Speichern"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _removeTracker(int? trackerID) async {
    await widget.profileManager.removeTracker(trackerID!);
    _loadTrackers();
  }

  Future<void> _removeCreature(int? creatureID) async {
    await widget.profileManager.removeCreature(creatureID!);
    _fetchCreatures();
  }

  @override
  Widget build(BuildContext context) {
    double healthBarWidth = MediaQuery.of(context).size.width - 32;
    double currentHPWidth =
        maxHP > 0 ? (currentHP / maxHP) * healthBarWidth : 0;

    double remainingHPWidth = maxHP > 0 ? healthBarWidth - currentHPWidth : 0;
    double tempHPWidth = tempHP > 0 ? (tempHP / maxHP) * healthBarWidth : 0;

    tempHPWidth =
        tempHPWidth > remainingHPWidth ? remainingHPWidth : tempHPWidth;

    final screenWidth = MediaQuery.of(context).size.width;
    int itemsPerRow = 3;
    double itemWidth = 100.0;

    if (screenWidth >= 800) {
      itemsPerRow = 5;
      itemWidth = (screenWidth - 64) / itemsPerRow;
    } else if (screenWidth >= 600) {
      itemsPerRow = 4;
      itemWidth = (screenWidth - 64) / itemsPerRow;
    } else if (screenWidth >= 400) {
      itemsPerRow = 3;
      itemWidth = (screenWidth - 32) / itemsPerRow;
    } else {
      itemsPerRow = 2;
      itemWidth = (screenWidth - 32) / itemsPerRow;
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Lebenspunkte',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const Divider(color: AppColors.textColorLight, thickness: 1.5),
          Row(
            children: [
              Text(
                tempHP > 0
                    ? '$currentHP/$maxHP + $tempHP Temp'
                    : '$currentHP/$maxHP',
                style: const TextStyle(fontSize: 18),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.remove),
                onPressed: _decrementHP,
              ),
              IconButton(
                icon: const Icon(Icons.add),
                onPressed: _incrementHP,
              ),
            ],
          ),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: _showEditHpDialog,
            child: Stack(
              children: [
                Container(
                  height: 20,
                  decoration: BoxDecoration(
                    color: const Color(0xFF581B10),
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
                Positioned(
                  left: 0,
                  child: Container(
                    height: 20,
                    width: currentHPWidth,
                    decoration: BoxDecoration(
                      color: const Color(0xFF1B6533),
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(5),
                        bottomLeft: const Radius.circular(5),
                        topRight: (currentHP == maxHP)
                            ? const Radius.circular(5)
                            : Radius.zero,
                        bottomRight: (currentHP == maxHP)
                            ? const Radius.circular(5)
                            : Radius.zero,
                      ),
                    ),
                  ),
                ),
                if (tempHP > 0)
                  Positioned(
                    left: currentHPWidth,
                    child: Container(
                      height: 20,
                      width: tempHPWidth,
                      decoration: BoxDecoration(
                        color: const Color(0xFF1976D2),
                        borderRadius: BorderRadius.only(
                          topRight: tempHPWidth == remainingHPWidth
                              ? const Radius.circular(5)
                              : Radius.zero,
                          bottomRight: tempHPWidth == remainingHPWidth
                              ? const Radius.circular(5)
                              : Radius.zero,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 25),

          // Stats Section
          const Text(
            'Statistik',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const Divider(color: AppColors.textColorLight, thickness: 1.5),
          const SizedBox(height: 8),
          Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildStatCard('Rüstungsklasse', armor, Defines.statArmor,
                      isCount: true),
                  _buildStatCard(
                      'Inspiration', inspiration, Defines.statInspiration,
                      isCount: true),
                  _buildStatCard('Übungsbonus', proficiencyBonus,
                      Defines.statProficiencyBonus,
                      isCount: true),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildStatCard(
                      'Initiative', initiative, Defines.statInitiative,
                      isCount: true),
                  _buildStatCard(
                      'Bewegungsrate', movement, Defines.statMovement),
                  _buildEditHitDiceCard(),
                ],
              ),
            ],
          ),
          const SizedBox(height: 25),

          // Trackers Section
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Tracker',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              IconButton(
                icon: const Icon(Icons.add),
                onPressed: _addNewTracker,
              ),
            ],
          ),
          const Divider(color: AppColors.textColorLight, thickness: 1.5),
          Column(
            children: [
              for (int i = 0; i < trackers.length; i += itemsPerRow)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        for (int j = i;
                            j < i + itemsPerRow && j < trackers.length;
                            j++)
                          SizedBox(
                            width: itemWidth,
                            child: GestureDetector(
                              onTap: () {
                                _editTracker(trackers[j]);
                              },
                              onLongPress: () {
                                _showDeleteConfirmationDialog(trackers[j]);
                              },
                              child: Column(
                                children: [
                                  Text(
                                    trackers[j].tracker,
                                    style: const TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(
                                    width: itemWidth,
                                    child: Card(
                                      elevation: 3,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              trackers[j].value.toString(),
                                              style: const TextStyle(
                                                fontSize: 16,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
            ],
          ),

          // Creatures Section
          const SizedBox(height: 25),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Begleiter',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              IconButton(
                icon: const Icon(Icons.add),
                onPressed: _addCreature,
              ),
            ],
          ),
          const Divider(color: AppColors.textColorLight, thickness: 1.5),
          Column(
            children: [
              for (int i = 0; i < creatures.length; i++)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: GestureDetector(
                    onLongPress: () {
                      _showDeleteConfirmationDialogC(creatures[i]);
                    },
                    onTap: () {
                      _editCreature(creatures[i]);
                    },
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                      elevation: 3,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    '${creatures[i].name} ${creatures[i].currentHP} / ${creatures[i].maxHP}',
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                Row(
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.remove),
                                      onPressed: () {
                                        _decrementCreatureHP(i);
                                      },
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.add),
                                      onPressed: () {
                                        _incrementCreatureHP(i);
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            GestureDetector(
                              onTap: () {
                                _showEditCreatureHPDialog(i);
                              },
                              child: LayoutBuilder(
                                builder: (context, constraints) {
                                  double cardWidth = constraints.maxWidth;
                                  double greenBarWidth = 0;

                                  if (creatures[i].maxHP > 0) {
                                    greenBarWidth = (creatures[i].currentHP /
                                            creatures[i].maxHP) *
                                        cardWidth;
                                    greenBarWidth =
                                        greenBarWidth.clamp(0.0, cardWidth);
                                  }

                                  return Stack(
                                    children: [
                                      Container(
                                        height: 20,
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF581B10),
                                          borderRadius:
                                              BorderRadius.circular(5),
                                        ),
                                      ),
                                      Positioned(
                                        left: 0,
                                        child: Container(
                                          height: 20,
                                          width: greenBarWidth,
                                          decoration: BoxDecoration(
                                            color: const Color(0xFF1B6533),
                                            borderRadius:
                                                BorderRadius.circular(5),
                                          ),
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),

          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildStatCard(String name, dynamic value, dynamic statType,
      {bool isCount = false}) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          _showEditStatDialog(name, statType, value, isCount: isCount);
        },
        child: Column(
          children: [
            Text(
              name,
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(
              height: 50,
              child: Card(
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Center(
                    child: Text(
                      '$value',
                      style: const TextStyle(
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEditHitDiceCard() {
    return Expanded(
      child: GestureDetector(
        onTap: _showEditHitDiceDialog,
        child: Column(
          children: [
            Text(
              'Hit Dice $healFactor',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(
              height: 50,
              child: Card(
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '$currentHitDice / $maxHitDice',
                          style: const TextStyle(
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmationDialog(Tracker tracker) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Tracker löschen'),
          content: Text(
              'Bist du sicher, dass du "${tracker.tracker} löschen willst"?'),
          actions: [
            TextButton(
              child: const Text('Abbrechen'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Löschen'),
              onPressed: () {
                _removeTracker(tracker.uuid);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showDeleteConfirmationDialogC(Creature creature) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Begleiter löschen'),
          content: Text(
              'Bist du sicher, dass du "${creature.name} löschen willst"?'),
          actions: [
            TextButton(
              child: const Text('Abbrechen'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Löschen'),
              onPressed: () {
                _removeCreature(creature.uuid);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}

class Tracker {
  String tracker;
  int? uuid;
  int? value;

  Tracker({
    required this.tracker,
    this.uuid,
    required this.value,
  });
}
