import 'package:flutter/material.dart';
import '../classes/profile_manager.dart';
import '../configs/colours.dart';
import 'character_view.dart';

class ProfileHomeScreen extends StatefulWidget {
  const ProfileHomeScreen({super.key});

  @override
  ProfileHomeScreenState createState() => ProfileHomeScreenState();
}

class ProfileHomeScreenState extends State<ProfileHomeScreen> {
  ProfileManager profileManager = ProfileManager();

  @override
  void initState() {
    super.initState();
    _initializeProfiles();
  }

  Future<void> _initializeProfiles() async {
    await profileManager.initialize();
    setState(() {});
  }

  Future<void> _addNewProfile() async {
    TextEditingController controller = TextEditingController();

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        bool _isCreatingProfile = false;

        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: const Text('Neuer Charakter'),
              content: TextField(
                controller: controller,
                decoration: const InputDecoration(hintText: 'Charakternamen eingeben'),
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Abbrechen'),
                ),
                TextButton(
                  onPressed: _isCreatingProfile
                      ? null
                      : () async {
                          String profileName = controller.text;
                          if (profileName.isNotEmpty) {
                            String lowerCaseProfileName = profileName.toLowerCase();

                            bool profileExists = profileManager.profiles
                                .map((profile) => profile.name.toLowerCase())
                                .contains(lowerCaseProfileName);

                            if (profileExists) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Der Charakter "$profileName" existiert bereits. Bitte wähle einen anderen Namen.',
                                    style: const TextStyle(color: AppColors.textColorLight),
                                  ),
                                  backgroundColor: AppColors.warningColor,
                                ),
                              );
                            } else {
                              setState(() {
                                _isCreatingProfile = true;
                              });

                              await profileManager.createProfile(profileName);

                              setState(() {
                                _isCreatingProfile = false;
                              });
                              await _initializeProfiles();
                              Navigator.of(context).pop();
                            }
                          }
                        },
                  child: const Text('Erstellen'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _dumpDatabase(String profileName) async {
    await profileManager.dumpDatabase(profileName);
  }

  Future<void> _renameProfile(Character oldProfile) async {
    TextEditingController controller = TextEditingController();
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Charakter umbenennen'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(hintText: 'Neuen Charakternamen eingeben'),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Abbrechen'),
            ),
            TextButton(
              onPressed: () async {
                String newName = controller.text;

                if (newName.isNotEmpty) {
                  try {
                    await profileManager.renameProfile(oldProfile.name, newName);
                    setState(() {
                      _initializeProfiles();
                    });
                    Navigator.of(context).pop();
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Der Charakter "$newName" existiert bereits. Bitte wähle einen anderen Namen.',
                          style: const TextStyle(color: AppColors.textColorLight),
                        ),
                        backgroundColor: AppColors.warningColor,
                      ),
                    );
                  }
                }
              },
              child: const Text('Umbenennen'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _addNewProfile,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: profileManager.hasProfiles()
                ? ListView.builder(
                    itemCount: profileManager.getProfiles().length,
                    itemBuilder: (context, index) {
                      final Character profile = profileManager.getProfiles()[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6.0),
                        child: Material(
                          elevation: 4,
                          borderRadius: BorderRadius.circular(12),
                          shadowColor: Colors.black.withOpacity(0.5),
                          child: Container(
                            padding: const EdgeInsets.all(8.0),
                            decoration: BoxDecoration(
                              color: AppColors.cardColor,
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                            child: ListTile(
                              title: Text(
                                profile.name,
                                style: const TextStyle(color: AppColors.textColorLight),
                              ),
                              onTap: () async {
                                await profileManager.selectProfile(profile);

                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => CharacterView(
                                        currentDb: profileManager.currentDb,
                                        profileManager: profileManager),
                                  ),
                                );
                              },
                              trailing: PopupMenuButton<String>(
                                onSelected: (value) async {
                                  if (value == 'delete') {
                                    bool confirmDelete = await showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          title: const Text('Charakter löschen'),
                                          content: Text('Willst du wirklich den Charakter ${profile.name} löschen?'),
                                          actions: <Widget>[
                                            TextButton(
                                              child: const Text('Nein'),
                                              onPressed: () {
                                                Navigator.of(context).pop(false);
                                              },
                                            ),
                                            TextButton(
                                              child: const Text('Ja'),
                                              onPressed: () {
                                                Navigator.of(context).pop(true);
                                              },
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                    if (confirmDelete == true) {
                                      await profileManager.deleteProfile(profile);
                                      setState(() {});
                                    }
                                  } else if (value == 'dump') {
                                    await _dumpDatabase(profile.name);
                                  } else if (value == 'rename') {
                                    await _renameProfile(profile);
                                  }
                                },
                                itemBuilder: (BuildContext context) {
                                  return [
                                    const PopupMenuItem<String>(
                                      value: 'dump',
                                      child: Text('Exportieren'),
                                    ),
                                    const PopupMenuItem<String>(
                                      value: 'delete',
                                      child: Text('Charakter löschen'),
                                    ),
                                    const PopupMenuItem<String>(
                                      value: 'rename',
                                      child: Text('Charakter umbenennen'),
                                    ),
                                  ];
                                },
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  )
                : const Center(
                    child: Text(
                      'Keine Charaktere vorhanden',
                      style: TextStyle(fontSize: 20, color: AppColors.textColorLight),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
