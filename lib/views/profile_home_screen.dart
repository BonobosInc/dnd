import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:dnd/classes/wiki_parser.dart';
import 'package:dnd/views/appstatus.dart';
import 'package:dnd/views/settings_view.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:dnd/classes/profile_manager.dart';
import 'package:dnd/configs/colours.dart';
import 'character_view.dart';

class ProfileHomeScreen extends StatefulWidget {
  final WikiParser wikiParser;

  const ProfileHomeScreen({
    super.key,
    required this.wikiParser,
  });

  @override
  ProfileHomeScreenState createState() => ProfileHomeScreenState();
}

class ProfileHomeScreenState extends State<ProfileHomeScreen> {
  ProfileManager profileManager = ProfileManager();
  bool _isImporting = false;

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
        bool isCreatingProfile = false;

        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: const Text('Neuer Charakter'),
              content: TextField(
                controller: controller,
                decoration:
                    const InputDecoration(hintText: 'Charakternamen eingeben'),
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Abbrechen'),
                ),
                TextButton(
                  onPressed: isCreatingProfile
                      ? null
                      : () async {
                          String profileName = controller.text;
                          if (profileName.isNotEmpty) {
                            String lowerCaseProfileName =
                                profileName.toLowerCase();

                            bool profileExists = profileManager.profiles
                                .map((profile) => profile.name.toLowerCase())
                                .contains(lowerCaseProfileName);

                            if (profileExists) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Der Charakter "$profileName" existiert bereits. Bitte wähle einen anderen Namen.',
                                    style: TextStyle(
                                        color: AppColors.textColorLight),
                                  ),
                                  backgroundColor: AppColors.warningColor,
                                ),
                              );
                            } else {
                              setState(() {
                                isCreatingProfile = true;
                              });

                              await profileManager.createProfile(profileName);

                              setState(() {
                                isCreatingProfile = false;
                              });
                              await _initializeProfiles();
                              if (context.mounted) {
                                Navigator.of(context).pop();
                                if (profileName.contains("69")) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Nice!')),
                                  );
                                }
                              }
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

  Future<void> _clearDatabase() async {
    bool confirmDelete = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Datenbank leeren'),
          content:
              const Text('Möchtest du wirklich die gesamte Datenbank leeren?'),
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
      await profileManager.clearDatabase();
      profileManager.profiles.clear();
      await _initializeProfiles();
    }
  }

  void showTestBar(BuildContext context) {
    const snackBar = SnackBar(
      content: Text('Diese Funktion existiert aktuell noch nicht'),
      duration: Duration(seconds: 2),
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
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
            decoration: const InputDecoration(
                hintText: 'Neuen Charakternamen eingeben'),
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
                    await profileManager.renameProfile(
                        oldProfile.name, newName);
                    setState(() {
                      _initializeProfiles();
                    });
                    if (context.mounted) {
                      Navigator.of(context).pop();
                      if (newName.contains("69")) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Nice!')),
                        );
                      }
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Der Charakter "$newName" existiert bereits. Bitte wähle einen anderen Namen.',
                            style: TextStyle(color: AppColors.textColorLight),
                          ),
                          backgroundColor: AppColors.warningColor,
                        ),
                      );
                    }
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

  Future<void> _exportFeatsToXml(Character profile) async {
    try {
      String xmlString = await profileManager.exportFeatsToXml(profile);

      if (kIsWeb || Platform.isWindows) {
        String? filePath = await FilePicker.platform.saveFile(
          dialogTitle: 'Speichern unter',
          fileName: '${profile.name}.xml',
          type: FileType.custom,
          allowedExtensions: ['xml'],
          bytes: utf8.encode(xmlString),
        );

        if (filePath != null) {
          File file = File(filePath);
          await file.writeAsString(xmlString);

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Export erfolgreich')),
            );
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Kein Speicherort ausgewählt')),
            );
          }
        }
      } else if (Platform.isAndroid) {
        final directory = await getExternalStorageDirectory();
        final file = File('${directory!.path}/${profile.name}.xml');
        await file.writeAsString(xmlString);

        final shareFile = XFile(file.path);

        await Share.shareXFiles([shareFile],
            text: 'Feats exportiert: ${profile.name}.xml');

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Export erfolgreich')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Export fehlschlagen: $e')),
        );
      }
    } finally {
      await profileManager.closeDB();
    }
  }

  Future<void> showExportDialog(BuildContext context, Character profile) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        bool isLoading = false;

        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: Text('Export Format'),
              content: isLoading
                  ? SizedBox(
                      width: 24.0,
                      height: 24.0,
                      child: Center(
                        child: CircularProgressIndicator(strokeWidth: 2.0),
                      ),
                    )
                  : null,
              actions: <Widget>[
                TextButton(
                  onPressed: () async {
                    Navigator.of(context).pop();
                    await _exportFeatsToXml(profile);
                  },
                  child: Text('XML'),
                ),
                TextButton(
                  onPressed: isLoading
                      ? null
                      : () async {
                          setState(() {
                            isLoading = true;
                          });
                          bool success =
                              await profileManager.exportToPDF(profile);
                          setState(() {
                            isLoading = false;
                          });
                          if (context.mounted) {
                            if (success) {
                              Navigator.of(context).pop();
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    content: Text('PDF export erfolgreich!')),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    content:
                                        Text('PDF export fehlgeschlagen!')),
                              );
                            }
                          }
                        },
                  child: Text('PDF'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _importProfileFromXmlFile() async {
    setState(() {
      _isImporting = true;
    });

    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.any,
      );

      if (result != null && result.files.isNotEmpty) {
        String filePath = result.files.single.path!;

        if (!filePath.endsWith('.xml')) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Nur XML-Dateien sind erlaubt.')),
            );
          }
          return;
        }

        File file = File(filePath);
        await profileManager.createProfileFromXmlFile(file);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Import erfolgreich')),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Keine Datei zum importieren ausgewählt.')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Import fehlschlagen: $e')),
        );
      }
    } finally {
      setState(() {
        _isImporting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) async {
              if (value == 'create') {
                await _addNewProfile();
              } else if (value == 'clear') {
                await _clearDatabase();
              } else if (value == 'import') {
                await _importProfileFromXmlFile();
              } else if (value == 'settings') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SettingsPage(),
                  ),
                );
              } else if (value == 'info') {
                showAppStatusDialog(context);
              }
            },
            itemBuilder: (BuildContext context) {
              return [
                const PopupMenuItem<String>(
                  value: 'create',
                  child: Text('Neuen Charakter erstellen'),
                ),
                const PopupMenuItem<String>(
                  value: 'import',
                  child: Text('Charakter aus Datei importieren'),
                ),
                const PopupMenuItem<String>(
                  value: 'clear',
                  child: Text('Datenbank leeren'),
                ),
                const PopupMenuItem<String>(
                  value: 'settings',
                  child: Text('Einstellungen'),
                ),
                const PopupMenuItem<String>(
                  value: 'info',
                  child: Text('BonoDND'),
                ),
              ];
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: _isImporting
                ? const Center(child: CircularProgressIndicator())
                : profileManager.hasProfiles()
                    ? ListView.builder(
                        physics: const ClampingScrollPhysics(),
                        itemCount: profileManager.getProfiles().length,
                        itemBuilder: (context, index) {
                          final Character profile =
                              profileManager.getProfiles()[index];
                          return Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8.0, vertical: 6.0),
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
                                    style: TextStyle(
                                        color: AppColors.textColorLight),
                                  ),
                                  onTap: () async {
                                    await profileManager.selectProfile(profile);
                                    if (context.mounted) {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => CharacterView(
                                            profileManager: profileManager,
                                            wikiParser: widget.wikiParser,
                                            profile: profile,
                                          ),
                                        ),
                                      );
                                    }
                                  },
                                  trailing: PopupMenuButton<String>(
                                    onSelected: (value) async {
                                      if (value == 'delete') {
                                        bool confirmDelete = await showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return AlertDialog(
                                              title: const Text(
                                                  'Charakter löschen'),
                                              content: Text(
                                                  'Willst du wirklich den Charakter ${profile.name} löschen?'),
                                              actions: <Widget>[
                                                TextButton(
                                                  child: const Text('Nein'),
                                                  onPressed: () {
                                                    Navigator.of(context)
                                                        .pop(false);
                                                  },
                                                ),
                                                TextButton(
                                                  child: const Text('Ja'),
                                                  onPressed: () {
                                                    Navigator.of(context)
                                                        .pop(true);
                                                  },
                                                ),
                                              ],
                                            );
                                          },
                                        );
                                        if (confirmDelete == true) {
                                          await profileManager
                                              .deleteProfile(profile);
                                          setState(() {});
                                        }
                                      } else if (value == 'dump') {
                                        showExportDialog(context, profile);
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
                    : Center(
                        child: Text(
                          'Keine Charaktere vorhanden',
                          style: TextStyle(
                              fontSize: 20, color: AppColors.textColorLight),
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}
