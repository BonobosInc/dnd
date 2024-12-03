import 'package:dnd/configs/colours.dart';
import 'package:dnd/configs/defines.dart';
import 'package:dnd/views/spell_editing_view.dart';
import 'package:flutter/material.dart';
import 'package:dnd/classes/wiki_classes.dart';

class SpellDetailPage extends StatelessWidget {
  final SpellData spellData;
  final bool importspell;

  const SpellDetailPage({
    super.key,
    required this.spellData,
    this.importspell = false,
  });

  String getSchoolFullName(String abbreviation) {
    switch (abbreviation) {
      case 'T':
        return 'Verwandlungszauber';
      case 'D':
        return 'Weissagung';
      case 'EV':
        return 'Hervorrufungszauber';
      case 'EN':
        return 'Verzauberungen';
      case 'C':
        return 'Beschwörung';
      case 'A':
        return 'Bannmagie';
      case 'I':
        return 'Illusion';
      case 'N':
        return 'Nekromantiezauber';
      default:
        return 'Keine Schule';
    }
  }

  @override
  Widget build(BuildContext context) {
    final uniqueClasses = spellData.classes.toSet().toList();
    final classesString = uniqueClasses.join(', ');

    return Scaffold(
      appBar: AppBar(
        title: Text(spellData.name),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              spellData.name,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text('Level: ${spellData.level}'),
            Text('Schule: ${getSchoolFullName(spellData.school)}'),
            Text('Zauberzeit: ${spellData.time}'),
            Text('Reichweite: ${spellData.range}'),
            Text('Dauer: ${spellData.duration}'),
            Text('Ritual: ${spellData.ritual}'),
            Text('Komponenten: ${spellData.components}'),
            const SizedBox(height: 10),
            Text(
              'Klassen: $classesString',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text(
              'Beschreibung:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 5),
            Text(spellData.text),
          ],
        ),
      ),
      floatingActionButton: importspell
          ? FloatingActionButton(
              onPressed: () async {
                final newSpell = await _showAddSpellDialog(context, spellData);
                if (newSpell != null && context.mounted) {
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                  Navigator.of(context).pop(newSpell);
                }
              },
              child: const Icon(Icons.add),
            )
          : null,
    );
  }
}

class ClassSpellsPage extends StatefulWidget {
  final String className;
  final List<SpellData> spells;
  final bool importspell;

  const ClassSpellsPage({
    super.key,
    required this.className,
    required this.spells,
    this.importspell = false,
  });

  @override
  ClassSpellsPageState createState() => ClassSpellsPageState();
}

class ClassSpellsPageState extends State<ClassSpellsPage> {
  final Set<SpellData> _selectedSpells = {};
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  bool isSearchVisible = false; // Tracks the visibility of the search bar
  String _searchText = ''; // Tracks the current search query

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchText = _searchController.text.toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _onSpellSelected(SpellData spell, bool isSelected) {
    setState(() {
      if (isSelected) {
        _selectedSpells.add(spell);
      } else {
        _selectedSpells.remove(spell);
      }
    });
  }

  List<SpellData> _filterSpells(List<SpellData> spells) {
    if (_searchText.isEmpty) {
      return spells;
    }
    return spells
        .where((spell) => spell.name.toLowerCase().contains(_searchText))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: isSearchVisible
            ? TextField(
                controller: _searchController,
                focusNode: _searchFocusNode,
                decoration: const InputDecoration(
                  hintText: 'Zauber durchsuchen...',
                  border: InputBorder.none,
                  hintStyle: TextStyle(color: Colors.white54),
                ),
                style: const TextStyle(color: Colors.white),
              )
            : Text('${widget.className} Zauber'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              setState(() {
                isSearchVisible = !isSearchVisible;
                if (isSearchVisible) {
                  _searchFocusNode.requestFocus();
                } else {
                  _searchText = '';
                  _searchController.clear();
                  _searchFocusNode.unfocus();
                }
              });
            },
          ),
          if (widget.importspell)
            IconButton(
              icon: const Icon(Icons.check),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop(_selectedSpells.toList());
              },
            ),
        ],
      ),
      body: buildSpellCollapsibleSections(
        _filterSpells(widget.spells),
        context,
        widget.importspell,
        _selectedSpells,
        _onSpellSelected,
      ),
    );
  }
}

class AllSpellsPage extends StatefulWidget {
  final List<SpellData> spells;
  final bool importspell;

  const AllSpellsPage({
    super.key,
    required this.spells,
    this.importspell = false,
  });

  @override
  AllSpellsPageState createState() => AllSpellsPageState();
}

class AllSpellsPageState extends State<AllSpellsPage> {
  final Set<SpellData> _selectedSpells = {};
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  bool isSearchVisible = false; // Tracks the visibility of the search bar
  String _searchText = ''; // Tracks the current search query

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchText = _searchController.text.toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _onSpellSelected(SpellData spell, bool isSelected) {
    setState(() {
      if (isSelected) {
        _selectedSpells.add(spell);
      } else {
        _selectedSpells.remove(spell);
      }
    });
  }

  List<SpellData> _filterSpells(List<SpellData> spells) {
    if (_searchText.isEmpty) {
      return spells;
    }
    return spells
        .where((spell) => spell.name.toLowerCase().contains(_searchText))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: isSearchVisible
            ? TextField(
                controller: _searchController,
                focusNode: _searchFocusNode,
                decoration: const InputDecoration(
                  hintText: 'Zauber durchsuchen...',
                  border: InputBorder.none,
                  hintStyle: TextStyle(color: Colors.white54),
                ),
                style: const TextStyle(color: Colors.white),
              )
            : const Text('Alle Zauber'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              setState(() {
                isSearchVisible = !isSearchVisible;
                if (isSearchVisible) {
                  _searchFocusNode.requestFocus();
                } else {
                  _searchText = '';
                  _searchController.clear();
                  _searchFocusNode.unfocus();
                }
              });
            },
          ),
          if (widget.importspell)
            IconButton(
              icon: const Icon(Icons.check),
              onPressed: () {
                Navigator.of(context).pop(_selectedSpells.toList());
              },
            ),
        ],
      ),
      body: buildSpellCollapsibleSections(
        _filterSpells(widget.spells),
        context,
        widget.importspell,
        _selectedSpells,
        _onSpellSelected,
      ),
    );
  }
}

Widget buildSpellCollapsibleSections(
  List<SpellData> spells,
  BuildContext context,
  bool importSpell,
  Set<SpellData> selectedSpells,
  void Function(SpellData spell, bool isSelected) onSpellSelected,
) {
  final groupedSpells = <String, List<SpellData>>{};

  for (var spell in spells) {
    final levelKey = spell.level == "0" ? "Zaubertrick" : spell.level;

    if (!groupedSpells.containsKey(levelKey)) {
      groupedSpells[levelKey] = [];
    }
    groupedSpells[levelKey]!.add(spell);
  }

  final sortedLevels = <String>[];
  if (groupedSpells.containsKey("Zaubertrick")) {
    sortedLevels.add("Zaubertrick");
  }

  final otherLevels = groupedSpells.keys
      .where((level) => level != "Zaubertrick")
      .toList()
    ..sort();
  sortedLevels.addAll(otherLevels);

  return ListView(
    padding: const EdgeInsets.all(16.0),
    children: sortedLevels.map((level) {
      return buildCollapsibleSectionForSpells(
        level,
        groupedSpells[level]!,
        context,
        importSpell,
        selectedSpells,
        onSpellSelected,
      );
    }).toList(),
  );
}

Widget buildCollapsibleSectionForSpells(
  String level,
  List<SpellData> spells,
  BuildContext context,
  bool importSpell,
  Set<SpellData> selectedSpells,
  void Function(SpellData spell, bool isSelected) onSpellSelected,
) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      ExpansionTile(
        shape: const Border(),
        title: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Text(
            level == "Zaubertrick" ? "Zaubertrick" : 'Level $level',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
        children: spells.asMap().entries.map((entry) {
          int index = entry.key;
          SpellData spell = entry.value;

          return Column(
            children: [
              if (index == 0) const Divider(),
              ListTile(
                title: Text(spell.name),
                leading: importSpell
                    ? Checkbox(
                        value: selectedSpells.contains(spell),
                        onChanged: (isSelected) {
                          onSpellSelected(spell, isSelected ?? false);
                        },
                      )
                    : null,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SpellDetailPage(
                        spellData: spell,
                        importspell: importSpell,
                      ),
                    ),
                  );
                },
              ),
              if (index < spells.length - 1) const Divider(),
            ],
          );
        }).toList(),
      ),
      const Divider(),
    ],
  );
}

class ClassSelectionPage extends StatelessWidget {
  final List<SpellData> spells;

  const ClassSelectionPage({super.key, required this.spells});

  @override
  Widget build(BuildContext context) {
    final groupedSpells = <String, List<SpellData>>{};

    for (var spell in spells) {
      for (var className in spell.classes) {
        if (className.isNotEmpty) {
          groupedSpells.putIfAbsent(className, () => []).add(spell);
        }
      }
    }

    final sortedClassNames =
        groupedSpells.keys.where((name) => name.isNotEmpty).toList()..sort();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Wählen Sie eine Klasse'),
        backgroundColor: AppColors.appBarColor,
      ),
      body: ListView(
        children: [
          ListTile(
            title: const Text('Alle Zauber'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      AllSpellsPage(spells: spells, importspell: true),
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
                      className: className,
                      spells: groupedSpells[className]!,
                      importspell: true,
                    ),
                  ),
                );
              },
            );
          }),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final Spell? newSpell = await _showAddSpellDialog(context, null);
          if (newSpell != null && context.mounted) {
            Navigator.of(context).pop(newSpell);
          }
        },
        tooltip: 'Add Spell',
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}

Future<Spell?> _showAddSpellDialog(
    BuildContext context, SpellData? spellData) async {
  const bool isNewSpell = true;

  String name = spellData?.name ?? '';
  String description = spellData?.text ?? '';

  int level = Defines.spellZero;
  if (spellData?.level is String) {
    try {
      level = int.parse(spellData!.level);
    } catch (e) {
      level = Defines.spellZero;
    }
  } else if (spellData?.level is int) {
    level = spellData!.level as int;
  }

  return await _showSpellDialog(
    context,
    Spell(
      name: name,
      description: description,
      status: Defines.spellKnown,
      level: level,
    ),
    isNewSpell,
  );
}

Future<Spell?> _showSpellDialog(
    BuildContext context, Spell spell, bool isNewSpell) {
  final TextEditingController descriptionController =
      TextEditingController(text: spell.description);

  return showDialog<Spell>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('Zauber bearbeiten'),
        content: SingleChildScrollView(
          child: _buildSpellDetailForm(spell, descriptionController),
        ),
        actions: [
          SizedBox(
            height: 36,
            child: TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Abbrechen'),
            ),
          ),
          SizedBox(
            height: 36,
            child: TextButton(
              onPressed: () {
                spell.description = descriptionController.text;
                Navigator.of(context).pop(spell);
              },
              child: const Text('Speichern'),
            ),
          ),
        ],
      );
    },
  );
}

Widget _buildSpellDetailForm(
    Spell spell, TextEditingController descriptionController) {
  return Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      _buildTextField(
        label: 'Zaubername',
        controller: TextEditingController(text: spell.name),
        onChanged: (value) => spell.name = value,
      ),
      const SizedBox(height: 16),
      _buildDescriptionTextField(descriptionController),
      const SizedBox(height: 16),
      _buildLevelDropdown(spell),
      const SizedBox(height: 16),
      _buildStatusDropdown(spell),
    ],
  );
}

Widget _buildStatusDropdown(Spell spell) {
  const List<String> statuses = [Defines.spellPrep, Defines.spellKnown];

  return DropdownButtonFormField<String>(
    value: spell.status,
    decoration: const InputDecoration(
      labelText: 'Status',
      border: OutlineInputBorder(),
    ),
    items: statuses.map((String status) {
      return DropdownMenuItem<String>(
        value: status,
        child: Text(_getStatus(status)),
      );
    }).toList(),
    onChanged: (value) {
      if (value != null) {
        spell.status = value;
      }
    },
  );
}

Widget _buildLevelDropdown(Spell spell) {
  return DropdownButtonFormField<int>(
    value: spell.level,
    decoration: const InputDecoration(
      labelText: 'Level',
      border: OutlineInputBorder(),
    ),
    items: List.generate(10, (index) => index).map((int level) {
      return DropdownMenuItem<int>(
        value: level,
        child: Text(level == 0 ? 'Zaubertrick' : 'Level $level'),
      );
    }).toList(),
    onChanged: (value) {
      if (value != null) {
        spell.level = value;
      }
    },
  );
}

Widget _buildDescriptionTextField(TextEditingController controller) {
  return TextField(
    controller: controller,
    maxLines: 4,
    decoration: const InputDecoration(
      labelText: 'Beschreibung',
      border: OutlineInputBorder(),
    ),
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

String _getStatus(String status) {
  return status == Defines.spellPrep
      ? 'vorbereiteter Zauber'
      : 'bekannter Zauber';
}
