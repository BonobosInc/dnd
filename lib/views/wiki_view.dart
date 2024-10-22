import 'package:dnd/views/wiki/background_view.dart';
import 'package:dnd/views/wiki/classes_view.dart';
import 'package:dnd/views/wiki/feat_view.dart';
import 'package:dnd/views/wiki/races_view.dart';
import 'package:dnd/views/wiki/spellwiki_view.dart';
import 'package:dnd/classes/wiki_parser.dart';
import 'package:flutter/material.dart';
import 'package:dnd/classes/wiki_classes.dart';
import 'package:file_picker/file_picker.dart';

class WikiPage extends StatefulWidget {
  final WikiParser wikiParser;

  const WikiPage({super.key, required this.wikiParser});

  @override
  WikiPageState createState() => WikiPageState();
}

class WikiPageState extends State<WikiPage> {
  List<ClassData> classes = [];
  List<RaceData> races = [];
  List<BackgroundData> backgrounds = [];
  List<FeatData> feats = [];
  List<SpellData> spells = [];

  String searchQuery = '';
  bool isSearchVisible = false;
  final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadDataFromParser();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  void loadDataFromParser() {
    setState(() {
      classes = widget.wikiParser.classes;
      races = widget.wikiParser.races;
      backgrounds = widget.wikiParser.backgrounds;
      feats = widget.wikiParser.feats;
      spells = widget.wikiParser.spells;
    });
  }

  Future<void> importXml() async {
    String? filePath = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xml'],
    ).then((result) => result?.files.single.path);

    if (filePath != null) {
      try {
        await widget.wikiParser.importXml(filePath);
        loadDataFromParser();
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Import erfolgreich')));
      } catch (e) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Import fehlgeschlagen: $e')));
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Import abgebrochen oder fehlgeschlagen.')));
    }
  }

  Future<void> exportXml() async {
    if (widget.wikiParser.savedXmlFilePath == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('No XML file has been loaded to export.')));
      return;
    }

    String? filePath = await FilePicker.platform.saveFile(
      dialogTitle: 'Wiki exportieren',
      fileName: 'exported_wiki.xml',
      type: FileType.custom,
      allowedExtensions: ['xml'],
    );

    if (filePath != null) {
      try {
        await widget.wikiParser.exportXml();
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Export erfolgreich!')));
      } catch (e) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Export fehlgeschlagen: $e')));
      }
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Export abgebrochen oder fehlgeschlagen.')));
    }
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
            : const Text('D&D Wiki'),
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
            onSelected: (value) {
              if (value == 'import') {
                importXml();
              } else if (value == 'export') {
                exportXml();
              }
            },
            itemBuilder: (BuildContext context) {
              return [
                const PopupMenuItem<String>(
                  value: 'import',
                  child: Text('Import XML'),
                ),
                const PopupMenuItem<String>(
                  value: 'export',
                  child: Text('Export XML'),
                ),
              ];
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          buildCollapsibleSection('Rassen', races),
          buildCollapsibleSection('Klassen', classes),
          buildCollapsibleSection('Hintergründe', backgrounds),
          buildCollapsibleSection('Talente', feats),
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
