import 'package:dnd/classes/wiki_classes.dart';
import 'package:dnd/configs/colours.dart';
import 'package:flutter/material.dart';

class AddClassPage extends StatefulWidget {
  final void Function(ClassData) onSave;

  const AddClassPage({super.key, required this.onSave});

  @override
  AddClassPageState createState() => AddClassPageState();
}

class AddClassPageState extends State<AddClassPage> {
  final _nameController = TextEditingController();
  final _hdController = TextEditingController();
  final _proficiencyController = TextEditingController();
  final _numSkillsController = TextEditingController();
  final List<Autolevel> _autolevels = [];

  void _addAutolevel() async {
    final autolevel = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => AddAutolevelPage()),
    );
    if (autolevel != null) {
      setState(() {
        _autolevels.add(autolevel);
      });
    }
  }

  void _deleteAutolevel(Autolevel autolevel) {
    setState(() {
      _autolevels.remove(autolevel);
    });
  }

  void _saveClass() {
    final classData = ClassData(
      name: _nameController.text,
      hd: _hdController.text,
      proficiency: _proficiencyController.text,
      numSkills: _numSkillsController.text,
      autolevels: _autolevels,
    );
    widget.onSave(classData);
    Navigator.pop(context);
  }

  Widget _buildAutolevelSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'Autolevels',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const Spacer(),
            IconButton(
              onPressed: _addAutolevel,
              icon: const Icon(Icons.add),
              tooltip: 'Add Autolevel',
            ),
          ],
        ),
        const SizedBox(height: 10),
        for (var autolevel in _autolevels) ...[
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Card(
              color: AppColors.cardColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
              ),
              elevation: 3,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Level: ${autolevel.level}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (autolevel.slots != null)
                            Text('Slots: ${autolevel.slots!.slots.join(', ')}'),
                          for (var feature in autolevel.features)
                            Text('- ${feature.name}'),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => _deleteAutolevel(autolevel),
                      icon: const Icon(Icons.delete),
                      tooltip: 'Delete Autolevel',
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Add Class')),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: 'Name'),
            ),
            TextField(
              controller: _hdController,
              decoration: InputDecoration(labelText: 'HD'),
            ),
            TextField(
              controller: _proficiencyController,
              decoration: InputDecoration(labelText: 'Proficiency'),
            ),
            TextField(
              controller: _numSkillsController,
              decoration: InputDecoration(labelText: 'Number of Skills'),
            ),
            const SizedBox(height: 20),
            _buildAutolevelSection(),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveClass,
              child: Text('Save Class'),
            ),
          ],
        ),
      ),
    );
  }
}

class AddAutolevelPage extends StatefulWidget {
  const AddAutolevelPage({super.key});

  @override
  AddAutolevelPageState createState() => AddAutolevelPageState();
}

class AddAutolevelPageState extends State<AddAutolevelPage> {
  final _levelController = TextEditingController();
  final List<FeatureData> _features = [];
  final _slotsController = TextEditingController();

  void _addFeature() {
    final featureName = _levelController.text; // Feature name input
    final featureDescription =
        _slotsController.text; // Feature description input
    setState(() {
      _features
          .add(FeatureData(name: featureName, description: featureDescription));
    });
  }

  void _saveAutolevel() {
    final slots = _slotsController.text.isNotEmpty
        ? Slots(
            slots: _slotsController.text
                .split(',')
                .map((e) => int.parse(e.trim()))
                .toList())
        : null;

    final autolevel = Autolevel(
      level: _levelController.text,
      features: _features,
      slots: slots,
    );

    Navigator.pop(context, autolevel);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Add Autolevel')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _levelController,
              decoration: InputDecoration(labelText: 'Level'),
            ),
            TextField(
              controller: _slotsController,
              decoration: InputDecoration(labelText: 'Slots (comma-separated)'),
            ),
            ElevatedButton(
              onPressed: _addFeature,
              child: Text('Add Feature'),
            ),
            ElevatedButton(
              onPressed: _saveAutolevel,
              child: Text('Save Autolevel'),
            ),
          ],
        ),
      ),
    );
  }
}
