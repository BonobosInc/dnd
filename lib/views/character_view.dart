import 'package:dnd/views/character/mainstats_view.dart';
import 'package:dnd/views/character/stats_view.dart';
import 'package:flutter/material.dart';
import 'package:dnd/classes/profile_manager.dart';
import 'package:dnd/classes/wiki_parser.dart';
import 'package:dnd/views/bag_view.dart';
import 'package:dnd/views/notes_view.dart';
import 'package:dnd/views/weapon_view.dart';
import 'package:dnd/views/wiki_view.dart';
import 'package:dnd/configs/defines.dart';
import 'package:dnd/configs/colours.dart';
import 'spell_view.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class CharacterView extends StatefulWidget {
  final ProfileManager profileManager;
  final WikiParser wikiParser;

  const CharacterView({
    super.key,
    required this.profileManager,
    required this.wikiParser,
  });

  @override
  CharacterViewState createState() => CharacterViewState();
}

class CharacterViewState extends State<CharacterView> {
  String name = "Charakter";
  int level = 0;
  int xp = 0;

  @override
  void initState() {
    super.initState();
    _loadCharacterData();
  }

  Future<void> _loadCharacterData() async {
    List<Map<String, dynamic>> result =
        await widget.profileManager.getProfileInfo();
    List<Map<String, dynamic>> stats = await widget.profileManager.getStats();

    if (result.isNotEmpty) {
      Map<String, dynamic> characterData = result.first;
      setState(() {
        name = characterData[Defines.infoName] ?? "Unbekannter Charakter";
      });
    }
    if (stats.isNotEmpty) {
      Map<String, dynamic> characterData = stats.first;
      setState(() {
        level = characterData[Defines.statLevel]!;
        xp = characterData[Defines.statXP]!;
      });
    }
  }

  void _showLevelDialog() {
    showDialog<int>(
      context: context,
      builder: (BuildContext context) {
        int tempLevel = level;

        return StatefulBuilder(
          builder: (BuildContext context, setStateDialog) {
            return AlertDialog(
              title: const Text("Level"),
              content: SizedBox(
                width: 150,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove, size: 24),
                      onPressed: () {
                        if (tempLevel > 0) {
                          setStateDialog(() {
                            tempLevel--;
                          });
                        }
                      },
                    ),
                    Text(
                      tempLevel.toString(),
                      style: const TextStyle(fontSize: 20),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add, size: 24),
                      onPressed: () {
                        if (tempLevel < 20) {
                          setStateDialog(() {
                            tempLevel++;
                          });
                        }
                      },
                    ),
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: const Text("Abbrechen"),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                TextButton(
                  child: const Text("Speichern"),
                  onPressed: () async {
                    setState(() {
                      level = tempLevel;
                    });
                    await widget.profileManager.updateStats(
                      field: Defines.statLevel,
                      value: level,
                    );
                    if (context.mounted) Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showXPDialog() {
    showDialog<int>(
      context: context,
      builder: (BuildContext context) {
        int tempXP = xp;
        TextEditingController controller =
            TextEditingController(text: tempXP.toString());

        return AlertDialog(
          title: const Text("XP"),
          content: _buildTextField(
            label: 'Gib die Anzahl deiner XP ein',
            controller: controller,
            onChanged: (value) {
              tempXP = int.tryParse(value) ?? 0;
            },
          ),
          actions: <Widget>[
            TextButton(
              child: const Text("Abbrechen"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text("Speichern"),
              onPressed: () async {
                setState(() {
                  xp = tempXP;
                });
                await widget.profileManager.updateStats(
                  field: Defines.statXP,
                  value: xp,
                );
                if (context.mounted) Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required ValueChanged<String> onChanged,
  }) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      onChanged: onChanged,
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvokedWithResult: (bool didPop, Object? result) {
        if (didPop) {
          widget.profileManager.closeDB();
          return;
        }
      },
      child: DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            title: Text(name),
            backgroundColor: AppColors.appBarColor,
            bottom: TabBar(
              tabs: [
                Tab(icon: Icon(MdiIcons.swordCross)),
                const Tab(icon: Icon(Icons.list)),
              ],
            ),
          ),
          body: TabBarView(
            children: [
              MainStatsPage(
                  profileManager: widget.profileManager,
                  wikiParser: widget.wikiParser),
              StatsPage(profileManager: widget.profileManager),
            ],
          ),
          endDrawer: SizedBox(
            width: 250,
            child: Drawer(
              backgroundColor: AppColors.primaryColor,
              child: ListView(
                padding: EdgeInsets.zero,
                children: <Widget>[
                  SizedBox(
                    height: 120,
                    child: DrawerHeader(
                      decoration: const BoxDecoration(
                        color: AppColors.appBarColor,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          GestureDetector(
                            onTap: _showLevelDialog,
                            child: Text(
                              'Level: $level',
                              style: const TextStyle(
                                color: AppColors.textColorLight,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: _showXPDialog,
                            child: Text(
                              'XP: $xp',
                              style: const TextStyle(
                                color: AppColors.textColorLight,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  ListTile(
                    title: const Text(
                      'Zauber',
                      style: TextStyle(color: AppColors.textColorLight),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SpellManagementPage(
                            profileManager: widget.profileManager,
                            wikiParser: widget.wikiParser,
                          ),
                        ),
                      );
                    },
                  ),
                  ListTile(
                    title: const Text(
                      'Waffen',
                      style: TextStyle(color: AppColors.textColorLight),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => WeaponPage(
                            profileManager: widget.profileManager,
                          ),
                        ),
                      );
                    },
                  ),
                  ListTile(
                    title: const Text(
                      'Notizen',
                      style: TextStyle(color: AppColors.textColorLight),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => NotesPage(
                            profileManager: widget.profileManager,
                            wikiParser: widget.wikiParser,
                          ),
                        ),
                      );
                    },
                  ),
                  ListTile(
                    title: const Text(
                      'Ausrüstung',
                      style: TextStyle(color: AppColors.textColorLight),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => BagPage(
                            profileManager: widget.profileManager,
                          ),
                        ),
                      );
                    },
                  ),
                  ListTile(
                    title: const Text(
                      'Wiki',
                      style: TextStyle(color: AppColors.textColorLight),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => WikiPage(
                            wikiParser: widget.wikiParser,
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
