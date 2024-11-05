import 'package:dnd/classes/wiki_classes.dart';
import 'package:dnd/classes/wiki_parser.dart';
import 'package:dnd/views/wiki_view.dart';
import 'package:flutter/material.dart';
import 'package:dnd/classes/profile_manager.dart';
import 'package:dnd/configs/defines.dart';
import 'package:dnd/configs/colours.dart';

class Feat {
  String name;
  String description;
  int? uuid;
  String? type;

  Feat({
    required this.name,
    required this.description,
    this.uuid,
    required this.type,
  });
}

class NotesPage extends StatefulWidget {
  final ProfileManager profileManager;
  final WikiParser wikiParser;

  const NotesPage({
    super.key,
    required this.profileManager,
    required this.wikiParser,
  });

  @override
  NotesPageState createState() => NotesPageState();
}

class NotesPageState extends State<NotesPage> {
  final TextEditingController raceController = TextEditingController();
  final TextEditingController classController = TextEditingController();
  final TextEditingController originController = TextEditingController();
  final TextEditingController backgroundController = TextEditingController();
  final TextEditingController personalityTraitsController =
      TextEditingController();
  final TextEditingController idealsController = TextEditingController();
  final TextEditingController bondsController = TextEditingController();
  final TextEditingController flawsController = TextEditingController();
  final TextEditingController ageController = TextEditingController();
  final TextEditingController godController = TextEditingController();
  final TextEditingController heightController = TextEditingController();
  final TextEditingController weightController = TextEditingController();
  final TextEditingController sexController = TextEditingController();
  final TextEditingController alignmentController = TextEditingController();
  final TextEditingController sizeController = TextEditingController();
  final TextEditingController eyeColourController = TextEditingController();
  final TextEditingController hairColourController = TextEditingController();
  final TextEditingController skinColourController = TextEditingController();
  final TextEditingController appearanceController = TextEditingController();
  final TextEditingController backStoryController = TextEditingController();
  final TextEditingController otherNotesController = TextEditingController();

  String? selectedSize;

  List<FeatData> featsData = [];

  final List<String> sizeOptions = [
    '',
    'Winzig',
    'Klein',
    'Mittelgroß',
    'Groß',
    'Riesig',
    'Gigantisch'
  ];

  final ScrollController _scrollController = ScrollController();

  final List<Feat> feats = [];

  @override
  void initState() {
    super.initState();
    _loadCharacterData();
    _fetchFeats();
    featsData = widget.wikiParser.feats;
  }

  Future<void> _fetchFeats() async {
    List<Map<String, dynamic>> fetchedFeats =
        await widget.profileManager.getFeats();

    setState(() {
      feats.clear();
      for (var feat in fetchedFeats) {
        feats.add(Feat(
          name: feat['featname'],
          description: feat['description'] ?? '',
          uuid: feat['ID'],
          type: feat['type'],
        ));
      }
      feats.sort((a, b) => a.uuid!.compareTo(b.uuid as num));
    });
  }

  Future<void> _loadCharacterData() async {
    List<Map<String, dynamic>> result =
        await widget.profileManager.getProfileInfo();

    if (result.isNotEmpty) {
      Map<String, dynamic> characterData = result.first;
      setState(() {
        raceController.text = characterData[Defines.infoRace] ?? '';
        classController.text = characterData[Defines.infoClass] ?? '';
        originController.text = characterData[Defines.infoOrigin] ?? '';
        backgroundController.text = characterData[Defines.infoBackground] ?? '';
        personalityTraitsController.text =
            characterData[Defines.infoPersonalityTraits] ?? '';
        idealsController.text = characterData[Defines.infoIdeals] ?? '';
        bondsController.text = characterData[Defines.infoBonds] ?? '';
        flawsController.text = characterData[Defines.infoFlaws] ?? '';
        ageController.text = characterData[Defines.infoAge] ?? '';
        godController.text = characterData[Defines.infoGod] ?? '';

        selectedSize = sizeOptions.contains(characterData[Defines.infoSize])
            ? characterData[Defines.infoSize]
            : sizeOptions[0];

        heightController.text = characterData[Defines.infoHeight] ?? '';
        weightController.text = characterData[Defines.infoWeight] ?? '';
        sexController.text = characterData[Defines.infoSex] ?? '';
        alignmentController.text = characterData[Defines.infoAlignment] ?? '';
        eyeColourController.text = characterData[Defines.infoEyeColour] ?? '';
        hairColourController.text = characterData[Defines.infoHairColour] ?? '';
        skinColourController.text = characterData[Defines.infoSkinColour] ?? '';
        appearanceController.text = characterData[Defines.infoAppearance] ?? '';
      });
    } else {
      selectedSize = sizeOptions[0];
    }
  }

  void _onFieldChanged(String field, String value) {
    widget.profileManager.updateProfileInfo(field: field, value: value);
  }

  @override
  void dispose() {
    raceController.dispose();
    classController.dispose();
    originController.dispose();
    backgroundController.dispose();
    personalityTraitsController.dispose();
    idealsController.dispose();
    bondsController.dispose();
    flawsController.dispose();
    ageController.dispose();
    godController.dispose();
    heightController.dispose();
    weightController.dispose();
    sexController.dispose();
    alignmentController.dispose();
    eyeColourController.dispose();
    hairColourController.dispose();
    skinColourController.dispose();
    appearanceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notizen'),
        backgroundColor: AppColors.appBarColor,
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.add),
            onSelected: (String value) {
              if (value == 'addFeat') {
                _showAddFeatDialog();
              } else if (value == 'navigateToWiki') {
                _navigateToWiki();
              }
            },
            itemBuilder: (BuildContext context) {
              return featsData.isEmpty
                  ? [
                      const PopupMenuItem<String>(
                        value: 'addFeat',
                        child: Text('Neues Feature'),
                      )
                    ]
                  : [
                      const PopupMenuItem<String>(
                        value: 'addFeat',
                        child: Text('Neues Feature'),
                      ),
                      const PopupMenuItem<String>(
                        value: 'navigateToWiki',
                        child: Text('Feature aus Wiki importieren'),
                      ),
                    ];
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        controller: _scrollController,
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Divider(),
            ExpansionTile(
              title: const Text(
                'Notizen',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              children: _buildNotesFields(),
            ),
            const Divider(),
            _buildFeatsExpansionTiles(),
            const Divider(),
          ],
        ),
      ),
    );
  }

  void _navigateToWiki() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            WikiPage(wikiParser: widget.wikiParser, importFeat: true),
      ),
    );

    if (result != null) {
      if (result is List<FeatureData>) {
        for (var featData in result) {
          final feat = _convertFeatDataToFeat(featData);
          _addFeat(feat, feat.description, feat.type);
        }
      } else if (result is FeatureData) {
        final feat = _convertFeatDataToFeat(result);
        _addFeat(feat, feat.description, feat.type);
      } else if (result is Feat) {
        _addFeat(result, result.description, result.type);
      }
    }
  }

  Feat _convertFeatDataToFeat(FeatureData featData) {
    String name = featData.name;
    String description = featData.description;

    return Feat(
      name: name,
      description: description,
      type: featData.type ?? "Sonstige",
    );
  }

  void _showAddFeatDialog() {
    var newFeat = true;
    _showFeatDialog(
        Feat(
          name: '',
          description: '',
          type: 'Sonstige',
        ),
        newFeat);
  }

  void _showFeatDetails(Feat feat) {
    var newFeat = false;
    _showFeatDialog(feat, newFeat);
  }

  void _showFeatDialog(Feat feat, bool newFeat) {
    TextEditingController descriptionController =
        TextEditingController(text: feat.description);

    String? selectedType = feat.type;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Feat bearbeiten'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 16),
                _buildFeatDetailForm(feat, descriptionController),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: selectedType,
                  items: const [
                    DropdownMenuItem(value: 'Klasse', child: Text('Klasse')),
                    DropdownMenuItem(value: 'Rasse', child: Text('Rasse')),
                    DropdownMenuItem(
                        value: 'Hintergrund', child: Text('Hintergrund')),
                    DropdownMenuItem(
                        value: 'Fähigkeiten', child: Text('Fähigkeiten')),
                    DropdownMenuItem(
                        value: 'Sonstige', child: Text('Sonstige')),
                  ],
                  decoration: const InputDecoration(
                    labelText: 'Typ',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                    selectedType = value;
                  },
                ),
              ],
            ),
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
                  if (newFeat) {
                    _addFeat(feat, descriptionController.text, selectedType!);
                  } else {
                    _updateFeat(
                        feat, descriptionController.text, selectedType!);
                  }
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

  void _updateFeat(Feat feat, String description, String? type) {
    final finalDescription =
        description.isEmpty ? "Keine Beschreibung vorhanden" : description;

    widget.profileManager
        .updateFeat(
      featName: feat.name,
      description: finalDescription,
      uuid: feat.uuid,
      type: feat.type,
    )
        .then((_) {
      _fetchFeats();
    });
  }

  void _addFeat(Feat feat, String description, String? type) {
    final finalDescription =
        description.isEmpty ? "Keine Beschreibung vorhanden" : description;

    widget.profileManager
        .addFeat(featName: feat.name, description: finalDescription, type: type)
        .then((_) {
      _fetchFeats();
    });
  }

  void _deleteFeat(int uuid) async {
    await widget.profileManager.removeFeat(uuid);
    _fetchFeats();
  }

  Widget _buildFeatDetailForm(
      Feat feat, TextEditingController descriptionController) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildFeatTextField(
          label: 'Name',
          controller: TextEditingController(text: feat.name),
          onChanged: (value) => feat.name = value,
        ),
        const SizedBox(height: 16),
        _buildDescriptionTextField(descriptionController),
      ],
    );
  }

  Widget _buildFeatTextField({
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

  Widget _buildDescriptionTextField(TextEditingController controller) {
    return TextField(
      controller: controller,
      maxLines: 15,
      decoration: const InputDecoration(
        labelText: 'Beschreibung',
        border: OutlineInputBorder(),
      ),
    );
  }

  List<Widget> _buildNotesFields() {
    return [
      Row(
        children: [
          Expanded(
              child: _buildTextField('Volk', raceController, Defines.infoRace)),
          const SizedBox(width: 16),
          Expanded(
              child: _buildTextField(
                  'Herkunft', originController, Defines.infoOrigin)),
        ],
      ),
      const SizedBox(height: 16),
      Row(
        children: [
          Expanded(
              child: _buildTextField(
                  'Klasse', classController, Defines.infoClass)),
          const SizedBox(width: 16),
          Expanded(
              child: _buildTextField(
                  'Hintergrund', backgroundController, Defines.infoBackground)),
        ],
      ),
      const SizedBox(height: 16),
      Row(
        children: [
          Expanded(
              child: _buildTextField('Alter', ageController, Defines.infoAge)),
          const SizedBox(width: 16),
          Expanded(
              child: _buildTextField(
                  'Geschlecht', sexController, Defines.infoSex)),
        ],
      ),
      const SizedBox(height: 16),
      Row(
        children: [
          Expanded(
              child: _buildTextField(
                  'Größe', heightController, Defines.infoHeight)),
          const SizedBox(width: 16),
          Expanded(
              child: _buildTextField(
                  'Gewicht', weightController, Defines.infoWeight)),
        ],
      ),
      const SizedBox(height: 16),
      Row(
        children: [
          Expanded(
              child: _buildTextField(
                  'Augenfarbe', eyeColourController, Defines.infoEyeColour)),
          const SizedBox(width: 16),
          Expanded(
              child: _buildTextField(
                  'Haarfarbe', hairColourController, Defines.infoHairColour)),
        ],
      ),
      const SizedBox(height: 16),
      Row(
        children: [
          Expanded(
              child: _buildTextField(
                  'Hautfarbe', skinColourController, Defines.infoSkinColour)),
          const SizedBox(width: 16),
          Expanded(
              child: _buildTextField(
                  'Glaube/Gottheit', godController, Defines.infoGod)),
        ],
      ),
      const SizedBox(height: 16),
      Row(
        children: [
          Expanded(
              child: _buildTextField('Größenkategorie', alignmentController,
                  Defines.infoAlignment)),
          const SizedBox(width: 16),
          Expanded(
              child: _buildTextField(
                  'Gesinnung', alignmentController, Defines.infoAlignment)),
        ],
      ),
      const SizedBox(height: 16),
      _buildLargeTextField(
          'Aussehen', appearanceController, Defines.infoAppearance, 3),
      const SizedBox(height: 16),
      _buildLargeTextField('Persönlichkeitsmerkmale',
          personalityTraitsController, Defines.infoPersonalityTraits, 3),
      const SizedBox(height: 16),
      _buildLargeTextField('Ideale', idealsController, Defines.infoIdeals, 3),
      const SizedBox(height: 16),
      _buildLargeTextField('Bindungen', bondsController, Defines.infoBonds, 3),
      const SizedBox(height: 16),
      _buildLargeTextField('Makel', flawsController, Defines.infoFlaws, 3),
      const SizedBox(height: 16),
      _buildLargeTextField('Hintergrundgeschichte', backStoryController,
          Defines.infoBackstory, 15),
      const SizedBox(height: 16),
      _buildLargeTextField(
          'Sonstige Notizen', otherNotesController, Defines.infoNotes, 15),
    ];
  }

  Widget _buildFeatsExpansionTiles() {
    feats.sort((a, b) => a.uuid!.compareTo(b.uuid!));

    // Determine the names from the controllers
    String className =
        classController.text.isEmpty ? "Klasse" : classController.text;
    String raceName =
        raceController.text.isEmpty ? "Rasse" : raceController.text;
    String backgroundName = backgroundController.text.isEmpty
        ? "Hintergrund"
        : backgroundController.text;

    // Initialize the grouped feats map
    Map<String, List<Feat>> groupedFeats = {
      className: [],
      raceName: [],
      backgroundName: [],
      'Fähigkeiten': [],
      'Sonstige': []
    };

    for (var feat in feats) {
      String groupKey;
      switch (feat.type) {
        case 'Klasse':
          groupKey = className;
          break;
        case 'Rasse':
          groupKey = raceName;
          break;
        case 'Hintergrund':
          groupKey = backgroundName;
          break;
        default:
          groupKey = 'Sonstige';
          break;
      }

      groupedFeats[groupKey]!.add(feat);
    }

    return ExpansionTile(
      title: const Text(
        'Feats',
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      ),
      children: groupedFeats.entries.map((entry) {
        String type = entry.key;
        List<Feat> featsOfType = entry.value;

        if (featsOfType.isEmpty) return const SizedBox.shrink();

        return ExpansionTile(
          title: Text(
            type,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          children: featsOfType.map((feat) {
            return Card(
              color: AppColors.cardColor,
              elevation: 4.0,
              margin:
                  const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
              child: ListTile(
                title: Text(
                  feat.name,
                  style: const TextStyle(color: AppColors.textColorLight),
                ),
                onTap: () => _showFeatDetails(feat),
                trailing: SizedBox(
                  width: 35,
                  height: 35,
                  child: IconButton(
                    icon:
                        const Icon(Icons.close, color: AppColors.textColorDark),
                    iconSize: 20.0,
                    padding: EdgeInsets.zero,
                    onPressed: () {
                      _showDeleteConfirmationDialog(feat);
                    },
                  ),
                ),
                tileColor: AppColors.cardColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
              ),
            );
          }).toList(),
        );
      }).toList(),
    );
  }

  void _showDeleteConfirmationDialog(Feat feat) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Löschen bestätigen'),
          content:
              Text('Bist du sicher, dass du "${feat.name}" löschen möchtest?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                _deleteFeat(feat.uuid!);
                Navigator.of(context).pop(true);
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTextField(
      String label, TextEditingController controller, String field) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      onChanged: (value) => _onFieldChanged(field, value),
    );
  }

  Widget _buildLargeTextField(String label, TextEditingController controller,
      String field, int maxLines) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      maxLines: maxLines,
      onChanged: (value) => _onFieldChanged(field, value),
    );
  }
}
