import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:xml/xml.dart' as xml;
import 'package:dnd/views/wiki/background_view.dart';
import 'package:dnd/views/wiki/classes_view.dart';
import 'package:dnd/views/wiki/creatures_view.dart';
import 'package:dnd/views/wiki/feat_view.dart';
import 'package:dnd/views/wiki/races_view.dart';
import 'package:dnd/views/wiki/spellwiki_view.dart';
import 'package:dnd/classes/wiki_parser.dart';
import 'package:dnd/views/wiki/wiki_editor/class_editor_view.dart';
import 'package:flutter/material.dart';
import 'package:dnd/classes/wiki_classes.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';

class WikiPage extends StatefulWidget {
  final WikiParser wikiParser;
  final bool importFeat;

  const WikiPage(
      {super.key, required this.wikiParser, this.importFeat = false});

  @override
  WikiPageState createState() => WikiPageState();
}

class WikiPageState extends State<WikiPage> {
  List<ClassData> classes = [];
  List<RaceData> races = [];
  List<BackgroundData> backgrounds = [];
  List<FeatData> feats = [];
  List<SpellData> spells = [];
  List<Creature> creatures = [];

  String searchQuery = '';
  bool isSearchVisible = false;
  final TextEditingController searchController = TextEditingController();
  final FocusNode searchFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    loadDataFromParser();
  }

  @override
  void dispose() {
    searchController.dispose();
    searchFocusNode.dispose();
    super.dispose();
  }

  Future<String> getDir() async {
    String savedFilePath;
    if (Platform.isWindows) {
      bool isDebugMode = bool.fromEnvironment('dart.vm.product') == false;

      if (isDebugMode) {
        savedFilePath = './temp/wiki.xml';
      } else {
        Directory appSupportDir = await getApplicationSupportDirectory();
        savedFilePath = '${appSupportDir.path}/wiki.xml';
      }
    } else {
      Directory appSupportDir = await getApplicationSupportDirectory();
      savedFilePath = '${appSupportDir.path}/wiki.xml';
    }
    return savedFilePath;
  }

  void loadDataFromParser() {
    setState(() {
      classes = widget.wikiParser.classes;
      races = widget.wikiParser.races;
      backgrounds = widget.wikiParser.backgrounds;
      feats = widget.wikiParser.feats;
      spells = widget.wikiParser.spells;
      creatures = widget.wikiParser.creatures;
    });
  }

  Future<void> _deleteXml() async {
    widget.wikiParser.deleteXml();
    widget.wikiParser.classes.clear();
    widget.wikiParser.races.clear();
    widget.wikiParser.backgrounds.clear();
    widget.wikiParser.feats.clear();
    widget.wikiParser.spells.clear();
    widget.wikiParser.creatures.clear();
  }

  Future<void> importXml() async {
    String? filePath = await FilePicker.platform
        .pickFiles(
          type: FileType.any,
        )
        .then((result) => result?.files.single.path);

    if (filePath != null) {
      if (!filePath.endsWith('.xml')) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Nur XML-Dateien sind erlaubt.')),
          );
        }
        return;
      }

      try {
        await widget.wikiParser.importXml(filePath);
        loadDataFromParser();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Import erfolgreich')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Import fehlgeschlagen: $e')),
          );
        }
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Import abgebrochen oder fehlgeschlagen.')),
        );
      }
    }
  }

  Future<void> exportXml() async {
    if (widget.wikiParser.savedXmlFilePath == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('No XML file has been loaded to export.')));
      return;
    }

    try {
      await widget.wikiParser.exportXml();

      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Export erfolgreich!')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Export fehlgeschlagen: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    List<dynamic> filteredItems = [];
    if (searchQuery.isNotEmpty) {
      filteredItems.addAll(classes.where((item) =>
          item.name.toLowerCase().contains(searchQuery.toLowerCase())));
      filteredItems.addAll(races.where((item) =>
          item.name.toLowerCase().contains(searchQuery.toLowerCase())));
      filteredItems.addAll(backgrounds.where((item) =>
          item.name.toLowerCase().contains(searchQuery.toLowerCase())));
      filteredItems.addAll(feats.where((item) =>
          item.name.toLowerCase().contains(searchQuery.toLowerCase())));
      filteredItems.addAll(spells.where((item) =>
          item.name.toLowerCase().contains(searchQuery.toLowerCase())));
    }

    return Scaffold(
      appBar: AppBar(
        title: isSearchVisible
            ? TextField(
                controller: searchController,
                focusNode: searchFocusNode,
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
            : const Text('D&D Wiki'),
        actions: widget.importFeat == false
            ? [
                IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () {
                    setState(() {
                      isSearchVisible = !isSearchVisible;
                      if (isSearchVisible) {
                        searchFocusNode.requestFocus();
                      } else {
                        searchQuery = '';
                        searchController.clear();
                        searchFocusNode.unfocus();
                      }
                    });
                  },
                ),
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert),
                  onSelected: (value) {
                    if (value == 'import') {
                      importXml();
                    } else if (value == 'export') {
                      exportXml();
                    } else if (value == 'delete') {
                      _deleteXml();
                      loadDataFromParser();
                    } else if (value == 'class') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AddClassPage(
                            onSave: (newClass) async {
                              final xmlFilePath = await getDir();
                              final xmlFile = File(xmlFilePath);
                              if (!xmlFile.existsSync()) {
                                throw Exception(
                                    "XML file not found at $xmlFilePath");
                              }
                              final document = xml.XmlDocument.parse(
                                  await xmlFile.readAsString());

                              widget.wikiParser
                                  .addClassToXml(document, newClass);

                              await xmlFile.writeAsString(
                                  document.toXmlString(pretty: true));
                              if (kDebugMode) {
                                print("Class added successfully to XML.");
                              }
                            },
                          ),
                        ),
                      );
                    }
                  },
                  itemBuilder: (BuildContext context) {
                    return [
                      const PopupMenuItem<String>(
                        value: 'import',
                        child: Text('Wiki importieren'),
                      ),
                      const PopupMenuItem<String>(
                        value: 'export',
                        child: Text('Wiki exportieren'),
                      ),
                      const PopupMenuItem<String>(
                        value: 'delete',
                        child: Text('Wiki löschen'),
                      ),
                      // const PopupMenuItem<String>(
                      //   value: 'class',
                      //   child: Text('Klasse hinzufügen'),
                      // ),
                    ];
                  },
                ),
              ]
            : [],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: searchQuery.isNotEmpty
            ? (filteredItems.isEmpty
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
                                    return ClassDetailPage(
                                        classData: item,
                                        importFeat: widget.importFeat);
                                  } else if (item is RaceData) {
                                    return RaceDetailPage(
                                        raceData: item,
                                        importFeat: widget.importFeat);
                                  } else if (item is BackgroundData) {
                                    return BackgroundDetailPage(
                                        backgroundData: item,
                                        importFeat: widget.importFeat);
                                  } else if (item is FeatData) {
                                    return FeatDetailPage(
                                        featData: item,
                                        importFeat: widget.importFeat);
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
                  }).toList())
            : [
                buildCollapsibleSection('Rassen', races),
                buildCollapsibleSection('Klassen', classes),
                buildCollapsibleSection('Hintergründe', backgrounds),
                buildCollapsibleSection('Talente', feats),
                buildCreatureCollapsibleSection('Monster', creatures),
                if (widget.importFeat == false)
                  buildSpellCollapsibleSection('Zauber', spells),
              ],
      ),
    );
  }

  Widget buildCollapsibleSection<T extends Nameable>(
      String title, List<T> items) {
    List<T> filteredItems = items.where((item) {
      return item.name.toLowerCase().contains(searchQuery.toLowerCase());
    }).toList();

    filteredItems
        .sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ExpansionTile(
          shape: const Border(),
          title: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Text(
              title,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          children: filteredItems.isEmpty
              ? [const ListTile(title: Text('Keine Ergebnisse gefunden'))]
              : filteredItems.asMap().entries.map((entry) {
                  int index = entry.key;
                  T item = entry.value;

                  return Column(
                    children: [
                      if (index == 0) const Divider(),
                      ListTile(
                        title: Text(item.name),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) {
                                if (item is ClassData) {
                                  return ClassDetailPage(
                                      classData: item,
                                      importFeat: widget.importFeat);
                                } else if (item is RaceData) {
                                  return RaceDetailPage(
                                      raceData: item,
                                      importFeat: widget.importFeat);
                                } else if (item is BackgroundData) {
                                  return BackgroundDetailPage(
                                      backgroundData: item,
                                      importFeat: widget.importFeat);
                                } else if (item is FeatData) {
                                  return FeatDetailPage(
                                      featData: item,
                                      importFeat: widget.importFeat);
                                } else if (item is SpellData) {
                                  return SpellDetailPage(spellData: item);
                                }
                                return const SizedBox.shrink();
                              },
                            ),
                          );
                        },
                      ),
                      if (index < filteredItems.length - 1) const Divider(),
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
      shape: const Border(),
      title: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Text(
          title,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
      children: [
        const Divider(),
        ListTile(
          title: const Text('Alle Zauber'),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AllSpellsPage(spells: spells),
              ),
            );
          },
        ),
        ...sortedClassNames.asMap().entries.map((entry) {
          int index = entry.key;
          String className = entry.value;

          return Column(
            children: [
              if (index == 0) const Divider(),
              ListTile(
                title: Text(className),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ClassSpellsPage(
                          className: className,
                          spells: groupedSpells[className]!),
                    ),
                  );
                },
              ),
              if (index < sortedClassNames.length - 1) const Divider(),
            ],
          );
        }),
        const Divider(),
      ],
    );
  }

  Widget buildCreatureCollapsibleSection(
      String title, List<Creature> creatures) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ExpansionTile(
          shape: const Border(),
          title: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Text(
              title,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          children: [
            const Divider(),
            ListTile(
              title: const Text('Alle Monster'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        AllCreaturesPage(creatures: creatures),
                  ),
                );
              },
            ),
          ],
        ),
        const Divider(),
      ],
    );
  }
}
