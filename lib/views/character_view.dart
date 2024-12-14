import 'dart:io';

import 'package:dnd/main.dart';
import 'package:dnd/views/character/mainstats_view.dart';
import 'package:dnd/views/character/stats_view.dart';
import 'package:file_picker/file_picker.dart';
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
import 'package:path_provider/path_provider.dart';

class CharacterView extends StatefulWidget {
  final ProfileManager profileManager;
  final WikiParser wikiParser;
  final Character profile;

  const CharacterView({
    super.key,
    required this.profileManager,
    required this.wikiParser,
    required this.profile,
  });

  @override
  CharacterViewState createState() => CharacterViewState();
}

class CharacterViewState extends State<CharacterView> {
  String name = "Charakter";
  int level = 0;
  int xp = 0;

  dynamic _profileImagePath = AssetImage('assets/images/default.png');

  GlobalKey<MainStatsPageState> mainStatsPageKey =
      GlobalKey<MainStatsPageState>();

  @override
  void initState() {
    super.initState();
    name = widget.profile.name;
    _loadCharacterData();
    _getProfileImagePath();
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

  Future<List<Map<String, dynamic>>> _getSpellSlots() async {
    final spellSlots = await widget.profileManager.getSpellSlots();

    final List<Map<String, dynamic>> updatedSlots = [];
    for (var slot in spellSlots) {
      final spellSlot = {
        'spellslot': slot['spellslot'],
        'total': slot['total'] ?? 0,
      };
      updatedSlots.add(spellSlot);
    }
    return updatedSlots;
  }

  Future<List<Map<String, dynamic>>> _getTrackers() async {
    final trackers = await widget.profileManager.getTracker();

    return trackers;
  }

  Future<void> _longRest() async {
    final shouldProceed = await _showConfirmationDialog(
        'Lange Rast', 'Möchtest du wirklich eine lange Rast machen?');

    if (!shouldProceed) return;

    final stats = await widget.profileManager.getStats();

    final currentHD = stats.first[Defines.statCurrentHitDice];
    final maxHD = stats.first[Defines.statMaxHitDice];

    var hitDiceToAdd = (maxHD / 2).floor();

    if (hitDiceToAdd == 0) {
      hitDiceToAdd = 1;
    }

    final updatedHitDice = (currentHD + hitDiceToAdd).clamp(0, maxHD);

    widget.profileManager.updateStats(
        field: Defines.statCurrentHP, value: stats.first[Defines.statMaxHP]);
    widget.profileManager.updateStats(field: Defines.statTempHP, value: 0);

    widget.profileManager
        .updateStats(field: Defines.statCurrentHitDice, value: updatedHitDice);

    final spellSlots = await _getSpellSlots();
    for (var spellSlot in spellSlots) {
      await widget.profileManager.updateSpellSlots(
        spellslot: spellSlot['spellslot'],
        spent: spellSlot['total'],
      );
    }

    final trackers = await _getTrackers();
    for (var tracker in trackers) {
      if (tracker['type'] == 'long' || tracker['type'] == 'short') {
        await widget.profileManager.updateTracker(
          uuid: tracker['ID'],
          value: tracker['max'],
        );
      }
    }

    if (mainStatsPageKey.currentState != null) {
      mainStatsPageKey.currentState!.refreshContent();
    }
  }

  Future<void> _shortRest() async {
    final shouldProceed = await _showConfirmationDialog(
        'Kurze Rast', 'Möchtest du wirklich eine kurze Rast machen?');

    if (!shouldProceed) return;

    final trackers = await _getTrackers();

    for (var tracker in trackers) {
      if (tracker['type'] == 'short') {
        await widget.profileManager.updateTracker(
          uuid: tracker['ID'],
          value: tracker['max'],
        );
      }
    }

    if (mainStatsPageKey.currentState != null) {
      mainStatsPageKey.currentState!.refreshContent();
    }
  }

  Future<void> _colorMode() async {
    isDarkMode.value = !isDarkMode.value;
  }

  Future<bool> _showConfirmationDialog(String title, String message) async {
    return await showDialog<bool>(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text(title),
              content: Text(message),
              actions: <Widget>[
                TextButton(
                  child: Text('Nein'),
                  onPressed: () {
                    Navigator.of(context).pop(false);
                  },
                ),
                TextButton(
                  child: Text('Ja'),
                  onPressed: () {
                    Navigator.of(context).pop(true);
                  },
                ),
              ],
            );
          },
        ) ??
        false;
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

  void _showProfileImageDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          insetPadding: EdgeInsets.zero,
          backgroundColor: Colors.transparent,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ClipOval(
                child: _profileImagePath is AssetImage
                    ? Image(
                        image: _profileImagePath,
                        width: 300,
                        height: 300,
                        fit: BoxFit.cover,
                      )
                    : Image.file(
                        _profileImagePath as File,
                        width: 300,
                        height: 300,
                        fit: BoxFit.cover,
                      ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  final pickedFile = await FilePicker.platform.pickFiles(
                    type: FileType.image,
                  );

                  if (pickedFile != null) {
                    File file = File(pickedFile.files.single.path!);
                    File savedFilePath = await _uploadImage(file);
                    if (context.mounted) Navigator.of(context).pop();
                    setState(() {
                      _profileImagePath = savedFilePath;
                    });

                    if (context.mounted) {
                      _showProfileImageDialog(context);
                    }
                  }
                },
                child: Text("Bild hinzufügen"),
              ),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  _showDeleteConfirmationDialog(context);
                },
                child: Text("Bild entfernen"),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showDeleteConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Bild entfernen'),
          content:
              const Text('Bist du sicher, dass du das Bild entfernen willst?'),
          actions: [
            TextButton(
              child: const Text('Abbrechen'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Entfernen'),
              onPressed: () async {
                if (_profileImagePath is File) {
                  File profileImageFile = _profileImagePath as File;

                  if (await profileImageFile.exists()) {
                    await profileImageFile.delete();
                  }
                }

                setState(() {
                  _profileImagePath = AssetImage('assets/images/default.png');
                });
                if (context.mounted) {
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                  _showProfileImageDialog(context);
                }
              },
            ),
          ],
        );
      },
    );
  }

  Future<File> _uploadImage(File pickedFile) async {
    String savedFilePath = '';

    if (Platform.isWindows) {
      bool isDebugMode = bool.fromEnvironment('dart.vm.product') == false;
      Directory directory = isDebugMode
          ? Directory('./temp')
          : await getApplicationSupportDirectory();

      savedFilePath = '${directory.path}/$name.png';

      await pickedFile.copy(savedFilePath);
    } else {
      Directory appSupportDir = await getApplicationSupportDirectory();
      savedFilePath = '${appSupportDir.path}/$name.png';

      await pickedFile.copy(savedFilePath);
    }

    return File(savedFilePath);
  }

  Future<void> _getProfileImagePath() async {
    String imagePath = '';

    if (Platform.isWindows) {
      bool isDebugMode = bool.fromEnvironment('dart.vm.product') == false;
      Directory directory = isDebugMode
          ? Directory('./temp')
          : await getApplicationSupportDirectory();

      imagePath = '${directory.path}/$name.png';
    } else {
      Directory appSupportDir = await getApplicationSupportDirectory();
      imagePath = '${appSupportDir.path}/$name.png';
    }

    File profileImageFile = File(imagePath);

    if (profileImageFile.existsSync()) {
      setState(() {
        _profileImagePath = profileImageFile;
      });
    } else {
      setState(() {
        _profileImagePath = AssetImage('assets/images/default.png');
      });
    }
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
            title: Row(
              children: [
                GestureDetector(
                  onTap: () {
                    _showProfileImageDialog(context);
                  },
                  child: ClipOval(
                    child: _profileImagePath is AssetImage
                        ? Image(
                            image: _profileImagePath as AssetImage,
                            width: 30,
                            height: 30,
                            fit: BoxFit.cover,
                          )
                        : Image.file(
                            _profileImagePath as File,
                            width: 30,
                            height: 30,
                            fit: BoxFit.cover,
                          ),
                  ),
                ),
                SizedBox(width: 10),
                Text(name),
              ],
            ),
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
                  key: mainStatsPageKey,
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
                    height: 140,
                    child: DrawerHeader(
                      decoration: BoxDecoration(
                        color: AppColors.appBarColor,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              GestureDetector(
                                onTap: _showLevelDialog,
                                child: Text(
                                  'Level: $level',
                                  style: TextStyle(
                                    color: AppColors.textColorLight,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              PopupMenuButton<int>(
                                tooltip: "",
                                icon: const Icon(Icons.settings),
                                color: AppColors.primaryColor,
                                iconSize: 28.0,
                                onSelected: (value) async {
                                  if (value == 1) {
                                    await _longRest();
                                  } else if (value == 2) {
                                    await _shortRest();
                                  } else if (value == 3) {
                                    await _colorMode();
                                  }
                                },
                                itemBuilder: (BuildContext context) {
                                  return [
                                    const PopupMenuItem<int>(
                                      value: 1,
                                      child: Text('Lange Rast'),
                                    ),
                                    const PopupMenuItem<int>(
                                      value: 2,
                                      child: Text('Kurze Rast'),
                                    ),
                                    PopupMenuItem<int>(
                                      value: 3,
                                      child: Center(
                                        child: Icon(
                                          isDarkMode.value
                                              ? Icons.dark_mode
                                              : Icons.light_mode,
                                        ),
                                      ),
                                    )
                                  ];
                                },
                              ),
                            ],
                          ),
                          GestureDetector(
                            onTap: _showXPDialog,
                            child: Text(
                              'XP: $xp',
                              style: TextStyle(
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
                    title: Text(
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
                    title: Text(
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
                    title: Text(
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
                    title: Text(
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
                    title: Text(
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
