import 'package:dnd/configs/colours.dart';
import 'package:flutter/material.dart';
import 'package:dnd/classes/profile_manager.dart';
import 'package:dnd/configs/defines.dart';

class MainStatsPage extends StatefulWidget {
  final ProfileManager profileManager;

  const MainStatsPage({
    super.key,
    required this.profileManager,
  });

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

  @override
  void initState() {
    super.initState();
    _loadCharacterData();
    _loadTrackers();
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
        movement = characterData[Defines.statMovement];
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

  void _incrementHitDice() {
    setState(() {
      if (currentHitDice < maxHitDice) {
        currentHitDice++;
        _updateStat(Defines.statCurrentHitDice, currentHitDice);
      }
    });
  }

  void _decrementHitDice() {
    setState(() {
      if (currentHitDice > 0) {
        currentHitDice--;
        _updateStat(Defines.statCurrentHitDice, currentHitDice);
      }
    });
  }

  Future<void> _updateStat(String field, dynamic value) async {
    await widget.profileManager.updateStats(field: field, value: value);
  }

  Future<void> _showEditStatDialog(
      String statName, String field, dynamic currentValue) async {
    dynamic newValue = currentValue;

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Bearbeite $statName"),
          content: TextField(
            decoration: const InputDecoration(labelText: "Neuer Wert"),
            keyboardType: field == Defines.statMovement
                ? TextInputType.text
                : TextInputType.number,
            onChanged: (value) {
              newValue = value;
            },
            controller: TextEditingController(text: currentValue.toString()),
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
                    armor = int.tryParse(newValue)!;
                  }
                  if (field == Defines.statInspiration) {
                    int.tryParse(newValue)!;
                  }
                  if (field == Defines.statProficiencyBonus) {
                    proficiencyBonus = int.tryParse(newValue)!;
                  }
                  if (field == Defines.statInitiative) {
                    initiative = int.tryParse(newValue)!;
                  }
                  if (field == Defines.statMovement) {
                    movement =
                        newValue;
                  }
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

  Future<void> _showEditHpDialog() async {
    int newCurrentHP = currentHP;
    int newMaxHP = maxHP;
    int newTempHP = tempHP;

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Bearbeite HP"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: const InputDecoration(labelText: "Aktuelle HP"),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  newCurrentHP = int.tryParse(value) ?? currentHP;
                },
                controller: TextEditingController(text: currentHP.toString()),
              ),
              TextField(
                decoration: const InputDecoration(labelText: "Max HP"),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  newMaxHP = int.tryParse(value) ?? maxHP;
                },
                controller: TextEditingController(text: maxHP.toString()),
              ),
              TextField(
                decoration: const InputDecoration(labelText: "Temp HP"),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  newTempHP = int.tryParse(value) ?? tempHP;
                },
                controller: TextEditingController(text: tempHP.toString()),
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
    int newTrackerValue = 0; // Change to an integer
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
                  TextField(
                    decoration: const InputDecoration(labelText: "Tracker"),
                    onChanged: (value) {
                      newTrackerName = value;
                    },
                  ),
                  const SizedBox(height: 16),
                  // Row for Value with Increment and Decrement
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
              title: Text("Bearbeite ${tracker.tracker}"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: TextEditingController(text: editedTrackerName),
                    decoration:
                        const InputDecoration(labelText: "Tracker Name"),
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

  Future<void> _showEditHitDiceDialog() async {
    int newCurrentHitDice = currentHitDice;
    int newMaxHitDice = maxHitDice;
    String newHealFactor = healFactor;

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Bearbeite Hit Dice"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: const InputDecoration(labelText: "Heilungsfaktor"),
                keyboardType: TextInputType.text,
                onChanged: (value) {
                  newHealFactor = value;
                },
                controller: TextEditingController(text: healFactor),
              ),
              TextField(
                decoration:
                    const InputDecoration(labelText: "Aktuelle Hit Dice"),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  newCurrentHitDice = int.tryParse(value) ?? currentHitDice;
                },
                controller:
                    TextEditingController(text: currentHitDice.toString()),
              ),
              TextField(
                decoration: const InputDecoration(labelText: "Max Hit Dice"),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  newMaxHitDice = int.tryParse(value) ?? maxHitDice;
                },
                controller: TextEditingController(text: maxHitDice.toString()),
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
                newCurrentHitDice = newCurrentHitDice.clamp(0, newMaxHitDice);

                await _updateStat(
                    Defines.statCurrentHitDice, newCurrentHitDice);
                await _updateStat(Defines.statMaxHitDice, newMaxHitDice);
                await _updateStat(Defines.statHitDiceFactor, newHealFactor);

                setState(() {
                  currentHitDice = newCurrentHitDice;
                  maxHitDice = newMaxHitDice;
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
  }

  Future<void> _removeTracker(int? trackerID) async {
    await widget.profileManager.removeTracker(trackerID!);
    _loadTrackers();
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

    double hitDiceWidth =
        maxHitDice > 0 ? (currentHitDice / maxHitDice) * healthBarWidth : 0;

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
            'Health',
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
                    color: const Color(0xFFB71C1C),
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
                Positioned(
                  left: 0,
                  child: Container(
                    height: 20,
                    width: currentHPWidth,
                    decoration: BoxDecoration(
                      color: const Color(0xFF388E3C),
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
          // Hit Dice Section
          Row(
            children: [
              Text(
                '$currentHitDice$healFactor HD',
                style: const TextStyle(fontSize: 18),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.remove),
                onPressed: _decrementHitDice,
              ),
              IconButton(
                icon: const Icon(Icons.add),
                onPressed: _incrementHitDice,
              ),
            ],
          ),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: () {
              _showEditHitDiceDialog();
            },
            child: Stack(
              children: [
                Container(
                  height: 20,
                  decoration: BoxDecoration(
                    color: Colors.grey,
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
                Positioned(
                  left: 0,
                  child: Container(
                    height: 20,
                    width: hitDiceWidth,
                    decoration: BoxDecoration(
                      color: const Color(0xFF1976D2),
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(5),
                        bottomLeft: const Radius.circular(5),
                        topRight: currentHitDice == maxHitDice
                            ? const Radius.circular(5)
                            : Radius.zero,
                        bottomRight: currentHitDice == maxHitDice
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
            'Stats',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const Divider(color: AppColors.textColorLight, thickness: 1.5),
          const SizedBox(height: 8),
          Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildStatCard('Rüstungsklasse', armor, Defines.statArmor),
                  _buildStatCard(
                      'Inspiration', inspiration, Defines.statInspiration),
                  _buildStatCard('Übungsbonus', proficiencyBonus,
                      Defines.statProficiencyBonus),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildStatCard(
                      'Initiative', initiative, Defines.statInitiative),
                  _buildStatCard(
                      'Bewegungsrate', movement, Defines.statMovement),
                ],
              ),
            ],
          ),
          const SizedBox(height: 25),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Trackers',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              IconButton(
                icon: const Icon(Icons.add),
                onPressed: _addNewTracker,
              ),
            ],
          ),

          // Trackers Section
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
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildStatCard(String name, dynamic value, dynamic statType) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          _showEditStatDialog(name, statType, value);
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
