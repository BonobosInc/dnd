import 'dart:isolate';
import 'package:dnd/views/wiki/background_view.dart';
import 'package:dnd/views/wiki/classes_view.dart';
import 'package:dnd/views/wiki/feat_view.dart';
import 'package:dnd/views/wiki/races_view.dart';
import 'package:dnd/views/wiki/spellwiki_view.dart';
import 'package:dnd/classes/wiki_parser.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:dnd/classes/wiki_classes.dart';
import 'dart:io';
import 'dart:async';

class WikiPage extends StatefulWidget {
  const WikiPage({super.key});

  @override
  WikiPageState createState() => WikiPageState();
}

class WikiPageState extends State<WikiPage> {
  List<ClassData> classes = [];
  List<RaceData> races = [];
  List<BackgroundData> backgrounds = [];
  List<FeatData> feats = [];
  List<SpellData> spells = [];
  String? savedXmlFilePath;
  bool isLoading = true;

  String searchQuery = '';
  bool isSearchVisible = false;
  final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadSavedXml();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Future<void> importXmlFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xml'],
    );

    if (result != null && result.files.single.path != null) {
      File selectedFile = File(result.files.single.path!);
      String newFilePath;

      if (Platform.isWindows) {
        newFilePath = './temp/wiki.xml';
        Directory('./temp').createSync(recursive: true);
      } else {
        Directory appSupportDir = await getApplicationSupportDirectory();
        newFilePath = '${appSupportDir.path}/wiki.xml';
      }

      await selectedFile.copy(newFilePath);

      setState(() {
        savedXmlFilePath = newFilePath;
        isLoading = true;
      });

      await parseXmlInIsolate(await File(newFilePath).readAsString());
    }
  }

  Future<void> exportXmlFile() async {
    if (savedXmlFilePath == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Kein Wiki zum exportieren.')),
      );
      return;
    }

    String? exportPath = await FilePicker.platform.saveFile(
      dialogTitle: 'Exportiere Wiki',
      fileName: 'wiki.xml',
    );

    if (exportPath != null) {
      try {
        File originalFile = File(savedXmlFilePath!);
        await originalFile.copy(exportPath);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Exportiert nach $exportPath')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Exportieren fehlgeschlagen.')),
          );
        }
      }
    }
  }

  Future<void> loadSavedXml() async {
    String savedFilePath;

    if (Platform.isWindows) {
      savedFilePath = './temp/wiki.xml';
    } else {
      Directory appSupportDir = await getApplicationSupportDirectory();
      savedFilePath = '${appSupportDir.path}/wiki.xml';
    }

    File file = File(savedFilePath);

    if (await file.exists()) {
      setState(() {
        savedXmlFilePath = savedFilePath;
        isLoading = true;
      });

      await parseXmlInIsolate(await file.readAsString());
    } else {
      setState(() {
        savedXmlFilePath = null;
        isLoading = false;
      });
    }
  }

  Future<void> parseXmlInIsolate(String xmlData) async {
    final response = ReceivePort();
    await Isolate.spawn(_parseXml, response.sendPort);

    final sendPort = await response.first as SendPort;
    final result = ReceivePort();
    sendPort.send([xmlData, result.sendPort]);

    final parsedData = await result.first as Map<String, List<dynamic>>;

    setState(() {
      classes = (parsedData['classes'] as List<ClassData>? ?? []);
      races = (parsedData['races'] as List<RaceData>? ?? []);
      backgrounds = (parsedData['backgrounds'] as List<BackgroundData>? ?? []);
      feats = (parsedData['feats'] as List<FeatData>? ?? []);
      spells = (parsedData['spells'] as List<SpellData>? ?? []);
      isLoading = false;
    });
  }

  static void _parseXml(SendPort sendPort) {
    final port = ReceivePort();
    sendPort.send(port.sendPort);

    port.listen((message) {
      final xmlData = message[0] as String;
      final replyPort = message[1] as SendPort;

      final result = WikiParser.parseXmlData(xmlData);
      replyPort.send(result);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: isSearchVisible
            ? TextField(
                controller: searchController,
                decoration: const InputDecoration(
                  hintText: 'Search...',
                  border: InputBorder.none,
                  hintStyle: TextStyle(color: Colors.white54),
                ),
                style: const TextStyle(color: Colors.white),
                onChanged: (value) {
                  setState(() {
                    searchQuery = value.toLowerCase();
                  });
                },
              )
            : const Text('D&D Wiki Table of Contents'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              setState(() {
                isSearchVisible = !isSearchVisible;
                if (!isSearchVisible) {
                  searchQuery = '';
                  searchController.clear();
                }
              });
            },
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) async {
              if (value == 'import') {
                importXmlFile();
              } else if (value == 'export') {
                exportXmlFile();
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem<String>(
                value: 'import',
                child: Text('Importiere Wiki'),
              ),
              const PopupMenuItem<String>(
                value: 'export',
                child: Text('Exportiere Wiki'),
              ),
            ],
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : savedXmlFilePath == null
              ? const Center(
                  child: Text('Kein Wiki gefunden. Bitte importiere ein Wiki'),
                )
              : ListView(
                  padding: const EdgeInsets.all(16.0),
                  children: [
                    buildCollapsibleSection('Races', races),
                    buildCollapsibleSection('Classes', classes),
                    buildCollapsibleSection('Backgrounds', backgrounds),
                    buildCollapsibleSection('Feats', feats),
                    buildSpellCollapsibleSection('Spells', spells),
                  ],
                ),
    );
  }

  Widget buildCollapsibleSection<T extends Nameable>(
      String title, List<T> items) {
    List<T> filteredItems = items.where((item) {
      return item.name.toLowerCase().contains(searchQuery);
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ExpansionTile(
          title: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Text(
              title,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          children: filteredItems.isEmpty
              ? [const ListTile(title: Text('Keine Ergebnisse gefunden'))]
              : filteredItems.map((item) {
                  return Column(
                    children: [
                      ListTile(
                        title: Text(item.name),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) {
                                if (item is ClassData) {
                                  return ClassDetailPage(classData: item);
                                } else if (item is RaceData) {
                                  return RaceDetailPage(raceData: item);
                                } else if (item is BackgroundData) {
                                  return BackgroundDetailPage(
                                      backgroundData: item);
                                } else if (item is FeatData) {
                                  return FeatDetailPage(featData: item);
                                } else if (item is SpellData) {
                                  return SpellDetailPage(spellData: item);
                                }
                                return const SizedBox.shrink();
                              },
                            ),
                          );
                        },
                      ),
                      const Divider(),
                    ],
                  );
                }).toList(),
        ),
        const Divider(),
      ],
    );
  }

  Widget buildSpellCollapsibleSection(String title, List<SpellData> spells) {
    final groupedSpells = <String, List<SpellData>>{};

    for (var spell in spells) {
      for (var className in spell.classes) {
        if (className.isNotEmpty) {
          if (!groupedSpells.containsKey(className)) {
            groupedSpells[className] = [];
          }
          groupedSpells[className]!.add(spell);
        }
      }
    }

    final sortedClassNames =
        groupedSpells.keys.where((name) => name.isNotEmpty).toList()..sort();

    return ExpansionTile(
      title: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Text(
          title,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
      children: [
        ListTile(
          title: const Text('All Spells'),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AllSpellsPage(spells: spells),
              ),
            );
          },
        ),
        ...sortedClassNames.map((className) {
          return ListTile(
            title: Text(className),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ClassSpellsPage(
                      className: className, spells: groupedSpells[className]!),
                ),
              );
            },
          );
        }),
      ],
    );
  }
}
