import 'package:flutter/material.dart';
import 'package:dnd/classes/profile_manager.dart';
import 'package:dnd/configs/defines.dart';
import 'package:dnd/configs/colours.dart';

class NotesPage extends StatefulWidget {
  final ProfileManager profileManager;

  const NotesPage({
    super.key,
    required this.profileManager,
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
  final TextEditingController traitsController = TextEditingController();
  final TextEditingController otherNotesController = TextEditingController();

  String? selectedSize;

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

  @override
  void initState() {
    super.initState();
    _loadCharacterData();
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
        traitsController.text = characterData[Defines.infoTraits] ?? '';
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
    traitsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Character Notes'),
        backgroundColor: AppColors.appBarColor,
        actions: [
          Builder(
            builder: (context) {
              return IconButton(
                icon: const Icon(Icons.menu),
                onPressed: () => Scaffold.of(context).openEndDrawer(),
              );
            },
          ),
        ],
      ),
      endDrawer: _buildDrawer(),
      body: SingleChildScrollView(
        controller: _scrollController,
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                    child: _buildTextField(
                        'Volk', raceController, Defines.infoRace)),
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
                    child: _buildTextField('Hintergrund', backgroundController,
                        Defines.infoBackground)),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                    child: _buildTextField(
                        'Alter', ageController, Defines.infoAge)),
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
                    child: _buildTextField('Augenfarbe', eyeColourController,
                        Defines.infoEyeColour)),
                const SizedBox(width: 16),
                Expanded(
                    child: _buildTextField('Haarfarbe', hairColourController,
                        Defines.infoHairColour)),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                    child: _buildTextField('Hautfarbe', skinColourController,
                        Defines.infoSkinColour)),
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
                    child: _buildTextField('Gesinnung', alignmentController,
                        Defines.infoAlignment)),
              ],
            ),
            const SizedBox(height: 16),
            _buildLargeTextField(
                'Aussehen', appearanceController, Defines.infoAppearance, 3),
            const SizedBox(height: 16),
            _buildLargeTextField('Persönlichkeitsmerkmale',
                personalityTraitsController, Defines.infoPersonalityTraits, 3),
            const SizedBox(height: 16),
            _buildLargeTextField(
                'Ideale', idealsController, Defines.infoIdeals, 3),
            const SizedBox(height: 16),
            _buildLargeTextField(
                'Bindungen', bondsController, Defines.infoBonds, 3),
            const SizedBox(height: 16),
            _buildLargeTextField('Makel', flawsController, Defines.infoFlaws, 3),
            const SizedBox(height: 16),
            _buildLargeTextField(
                'Klassenmerkmale', traitsController, Defines.infoTraits, 15),
            const SizedBox(height: 16),
            _buildLargeTextField(
                'Sonstige Notizen', otherNotesController, Defines.infoNotes, 15),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
        backgroundColor: AppColors.primaryColor,
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            const SizedBox(
              height: 100,
              child: DrawerHeader(
                decoration: BoxDecoration(
                  color: AppColors.appBarColor,
                ),
                child:
                  Text(
                    'Schnellwahl',
                    style: TextStyle(
                      color: AppColors.textColorLight,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
              ),
            ),
            ListTile(
              title: const Text('Volk',
                  style: TextStyle(color: AppColors.textColorLight)),
              onTap: () {
                Navigator.pop(context);
                _scrollToSection(0);
              },
            ),
            ListTile(
              title: const Text('Herkunft',
                  style: TextStyle(color: AppColors.textColorLight)),
              onTap: () {
                Navigator.pop(context);
                _scrollToSection(0);
              },
            ),
            ListTile(
              title: const Text('Klasse',
                  style: TextStyle(color: AppColors.textColorLight)),
              onTap: () {
                Navigator.pop(context);
                _scrollToSection(0);
              },
            ),
            ListTile(
              title: const Text('Hintergrund',
                  style: TextStyle(color: AppColors.textColorLight)),
              onTap: () {
                Navigator.pop(context);
                _scrollToSection(0);
              },
            ),
            ListTile(
              title: const Text('Alter',
                  style: TextStyle(color: AppColors.textColorLight)),
              onTap: () {
                Navigator.pop(context);
                _scrollToSection(0);
              },
            ),
            ListTile(
              title: const Text('Geschlecht',
                  style: TextStyle(color: AppColors.textColorLight)),
              onTap: () {
                Navigator.pop(context);
                _scrollToSection(0);
              },
            ),
            ListTile(
              title: const Text('Größe',
                  style: TextStyle(color: AppColors.textColorLight)),
              onTap: () {
                Navigator.pop(context);
                _scrollToSection(0);
              },
            ),
            ListTile(
              title: const Text('Gewicht',
                  style: TextStyle(color: AppColors.textColorLight)),
              onTap: () {
                Navigator.pop(context);
                _scrollToSection(0);
              },
            ),
            ListTile(
              title: const Text('Augenfarbe',
                  style: TextStyle(color: AppColors.textColorLight)),
              onTap: () {
                Navigator.pop(context);
                _scrollToSection(0);
              },
            ),
            ListTile(
              title: const Text('Haarfarbe',
                  style: TextStyle(color: AppColors.textColorLight)),
              onTap: () {
                Navigator.pop(context);
                _scrollToSection(0);
              },
            ),
            ListTile(
              title: const Text('Hautfarbe',
                  style: TextStyle(color: AppColors.textColorLight)),
              onTap: () {
                Navigator.pop(context);
                _scrollToSection(0);
              },
            ),
            ListTile(
              title: const Text('Glaube/Gottheit',
                  style: TextStyle(color: AppColors.textColorLight)),
              onTap: () {
                Navigator.pop(context);
                _scrollToSection(0);
              },
            ),
            ListTile(
              title: const Text('Gesinnung',
                  style: TextStyle(color: AppColors.textColorLight)),
              onTap: () {
                Navigator.pop(context);
                _scrollToSection(0);
              },
            ),
            ListTile(
              title: const Text('Aussehen',
                  style: TextStyle(color: AppColors.textColorLight)),
              onTap: () {
                Navigator.pop(context);
                _scrollToSection(5);
              },
            ),
            ListTile(
              title: const Text('Persönlichkeitsmerkmale',
                  style: TextStyle(color: AppColors.textColorLight)),
              onTap: () {
                Navigator.pop(context);
                _scrollToSection(7);
              },
            ),
            ListTile(
              title: const Text('Ideale',
                  style: TextStyle(color: AppColors.textColorLight)),
              onTap: () {
                Navigator.pop(context);
                _scrollToSection(10);
              },
            ),
            ListTile(
              title: const Text('Bindungen',
                  style: TextStyle(color: AppColors.textColorLight)),
              onTap: () {
                Navigator.pop(context);
                _scrollToSection(13);
              },
            ),
            ListTile(
              title: const Text('Makel',
                  style: TextStyle(color: AppColors.textColorLight)),
              onTap: () {
                Navigator.pop(context);
                _scrollToSection(15);
              },
            ),
            ListTile(
              title: const Text('Klassenmerkmale',
                  style: TextStyle(color: AppColors.textColorLight)),
              onTap: () {
                Navigator.pop(context);
                _scrollToSection(18);
              },
            ),
            ListTile(
              title: const Text('Sonstige Notizen',
                  style: TextStyle(color: AppColors.textColorLight)),
              onTap: () {
                Navigator.pop(context);
                _scrollToSection(20);
              },
            ),
          ],
        ));
  }

  void _scrollToSection(int index) {
    double offset = index * 100.0;
    _scrollController.animateTo(
      offset,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
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

  Widget _buildLargeTextField(
      String label, TextEditingController controller, String field, int maxLines) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      onChanged: (value) => _onFieldChanged(field, value),
    );
  }

  Widget _buildDropdownField(
      String label, String? selectedValue, List<String> options, String field) {
    return DropdownButtonFormField<String>(
      value: selectedValue,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      items: options.map((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
      onChanged: (String? newValue) {
        setState(() {
          selectedSize = newValue;
        });
        _onFieldChanged(field, newValue!);
      },
    );
  }
}
