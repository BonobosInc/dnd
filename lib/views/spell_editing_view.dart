import 'package:dnd/classes/profile_manager.dart';
import 'package:flutter/material.dart';
import 'package:dnd/configs/defines.dart';
import 'package:dnd/configs/colours.dart';

class SpellEditingPage extends StatefulWidget {
  final ProfileManager profileManager;

  const SpellEditingPage({
    super.key,
    required this.profileManager,
  });

  @override
  SpellEditingPageState createState() => SpellEditingPageState();
}

class SpellEditingPageState extends State<SpellEditingPage> {
  final List<Spell> spells = [];

  static const Map<String, String> statusMapping = {
    Defines.spellPrep: 'vorbereiteter Zauber',
    Defines.spellKnown: 'bekannter Zauber',
  };

  @override
  void initState() {
    super.initState();
    _fetchSpells();
  }

  Future<void> _fetchSpells() async {
    List<Map<String, dynamic>> fetchedSpells =
        await widget.profileManager.getAllSpells();

    setState(() {
      spells.clear();
      for (var spell in fetchedSpells) {
        spells.add(Spell(
          name: spell['spellname'],
          description: spell['description'] ?? '',
          status: spell['status'] ?? 'nicht bekannt',
          level: spell['level'] is int ? spell['level'] : 0,
        ));
      }
      spells.sort((a, b) => a.level.compareTo(b.level));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bearbeite Zauber'),
        backgroundColor: AppColors.appBarColor,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _showAddSpellDialog,
          ),
        ],
      ),
      body: _buildSpellList(),
    );
  }

  Widget _buildSpellList() {
    Map<int, List<Spell>> groupedSpells = {};
    for (var spell in spells) {
      groupedSpells.putIfAbsent(spell.level, () => []).add(spell);
    }

    List<int> sortedLevels = groupedSpells.keys.toList()..sort();

    return ListView(
      children: sortedLevels.map((level) {
        return ExpansionTile(
          title:
              Text('Level $level', style: const TextStyle(color: Colors.white)),
          children: groupedSpells[level]!.map((spell) {
            return _buildSpellTile(spell);
          }).toList(),
        );
      }).toList(),
    );
  }

  Widget _buildSpellTile(Spell spell) {
    return Card(
      color: AppColors.cardColor,
      elevation: 4.0,
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: ListTile(
        title: Text(
          spell.name,
          style: const TextStyle(color: AppColors.textColorLight),
        ),
        subtitle: Text(
          _getStatus(spell.status),
          style: const TextStyle(color: AppColors.textColorDark),
        ),
        onTap: () => _showSpellDetails(spell),
      ),
    );
  }

  void _showAddSpellDialog() {
    _showSpellDialog(Spell(
      name: '',
      description: '',
      status: Defines.spellKnown,
      level: Defines.spellZero,
    ));
  }

  void _showSpellDetails(Spell spell) {
    _showSpellDialog(spell);
  }

  void _showSpellDialog(Spell spell) {
    TextEditingController descriptionController =
        TextEditingController(text: spell.description);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Spell'),
          content: _buildSpellDetailForm(spell, descriptionController),
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
            if (spell.name.isNotEmpty)
              SizedBox(
                height: 36,
                child: TextButton(
                  onPressed: () {
                    _showDeleteConfirmationDialog(spell);
                  },
                  child: const Text('Löschen'),
                ),
              ),
            SizedBox(
              height: 36,
              child: TextButton(
                onPressed: () {
                  _updateSpell(spell, descriptionController.text);
                  Navigator.of(context).pop(true);
                },
                child: const Text('Speichern'),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteConfirmationDialog(Spell spell) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Bestätigen Sie die Löschung'),
          content: Text(
              'Sind Sie sicher, dass Sie "${spell.name}" löschen möchten?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Abbrechen'),
            ),
            TextButton(
              onPressed: () {
                _deleteSpell(spell.name);
                Navigator.of(context).pop();
                Navigator.of(context).pop(true);
              },
              child: const Text('Löschen'),
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
          child: Text('Level $level'),
        );
      }).toList(),
      onChanged: (value) {
        if (value != null) {
          setState(() {
            spell.level = value;
          });
        }
      },
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
          setState(() {
            spell.status = value;
          });
        }
      },
    );
  }

  void _updateSpell(Spell spell, String description) {

  widget.profileManager
      .updateSpell(
    spellName: spell.name,
    status: spell.status,
    level: spell.level,
    description: description,
  )
      .then((_) {
    _fetchSpells();
  });
}


  void _deleteSpell(String spellName) async {
    await widget.profileManager.removeSpell(spellName);
    _fetchSpells();
  }

  String _getStatus(String status) {
    return statusMapping[status] ?? status;
  }
}

class Spell {
  String name;
  String description;
  String status;
  int level;

  Spell({
    required this.name,
    required this.description,
    required this.status,
    required this.level,
  });
}
