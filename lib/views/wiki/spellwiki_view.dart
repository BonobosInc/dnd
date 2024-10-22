import 'package:flutter/material.dart';
import 'package:dnd/classes/wiki_classes.dart';

class SpellDetailPage extends StatelessWidget {
  final SpellData spellData;

  const SpellDetailPage({super.key, required this.spellData});

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
            Text('Schule: ${spellData.school}'),
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
    );
  }
}

class ClassSpellsPage extends StatelessWidget {
  final String className;
  final List<SpellData> spells;

  const ClassSpellsPage(
      {super.key, required this.className, required this.spells});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('$className Zauber'),
      ),
      body: buildSpellCollapsibleSections(spells, context),
    );
  }
}

class AllSpellsPage extends StatelessWidget {
  final List<SpellData> spells;

  const AllSpellsPage({super.key, required this.spells});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Alle Zauber'),
      ),
      body: buildSpellCollapsibleSections(spells, context),
    );
  }
}

Widget buildSpellCollapsibleSections(
    List<SpellData> spells, BuildContext context) {
  final groupedSpells = <String, List<SpellData>>{};

  for (var spell in spells) {
    if (!groupedSpells.containsKey(spell.level)) {
      groupedSpells[spell.level] = [];
    }
    groupedSpells[spell.level]!.add(spell);
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
          level, groupedSpells[level]!, context);
    }).toList(),
  );
}

Widget buildCollapsibleSectionForSpells(
    String level, List<SpellData> spells, BuildContext context) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      ExpansionTile(
        title: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Text(
            level == "Zaubertrick" ? "Zaubertrick" : 'Level $level',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
        children: spells.map((spell) {
          return Column(
            children: [
              ListTile(
                title: Text(spell.name),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SpellDetailPage(spellData: spell),
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
