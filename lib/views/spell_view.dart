import 'package:flutter/material.dart';
import '../configs/colours.dart';
import '../classes/profile_manager.dart';

class SpellManagementPage extends StatefulWidget {
  final ProfileManager profileManager;

  const SpellManagementPage({
    super.key,
    required this.profileManager,
  });

  @override
  SpellManagementPageState createState() => SpellManagementPageState();
}

class SpellManagementPageState extends State<SpellManagementPage> {
  final TextEditingController _spellAttackController = TextEditingController();
  final TextEditingController _spellDcController = TextEditingController();
  final TextEditingController _spellcastingClassController = TextEditingController();
  final TextEditingController _spellcastingAbilityController = TextEditingController();

  List<List<TextEditingController>> spellLevels =
      List.generate(10, (index) => [TextEditingController(), TextEditingController(), TextEditingController()]);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Spell Manager'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildSpellcastingFields(),
            Expanded(child: _buildSpellLevelFields()),
          ],
        ),
      ),
    );
  }

  Widget _buildSpellcastingFields() {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      // Row for Spell Attack and Spell DC
      Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text('Spell Attack', style: TextStyle(color: AppColors.textColorLight, fontSize: 16)),
                ),
                TextField(
                  controller: _spellAttackController,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: AppColors.cardColor,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide: const BorderSide(color: AppColors.dividerColor),
                    ),
                    hintText: 'Enter Spell Attack',
                    hintStyle: const TextStyle(color: AppColors.textColorDark),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8), // Space between fields
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text('Spell DC', style: TextStyle(color: AppColors.textColorLight, fontSize: 16)),
                ),
                TextField(
                  controller: _spellDcController,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: AppColors.cardColor,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide: const BorderSide(color: AppColors.dividerColor),
                    ),
                    hintText: 'Enter Spell DC',
                    hintStyle: const TextStyle(color: AppColors.textColorDark),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      const SizedBox(height: 16), // Space between rows
      // Row for Spellcasting Class and Spellcasting Ability
      Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text('Spellcasting Class', style: TextStyle(color: AppColors.textColorLight, fontSize: 16)),
                ),
                TextField(
                  controller: _spellcastingClassController,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: AppColors.cardColor,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide: const BorderSide(color: AppColors.dividerColor),
                    ),
                    hintText: 'Enter Spellcasting Class',
                    hintStyle: const TextStyle(color: AppColors.textColorDark),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8), // Space between fields
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text('Spellcasting Ability', style: TextStyle(color: AppColors.textColorLight, fontSize: 16)),
                ),
                TextField(
                  controller: _spellcastingAbilityController,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: AppColors.cardColor,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide: const BorderSide(color: AppColors.dividerColor),
                    ),
                    hintText: 'Enter Spellcasting Ability',
                    hintStyle: const TextStyle(color: AppColors.textColorDark),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      const SizedBox(height: 16),
    ],
  );
}


  Widget _buildSpellLevelFields() {
    return ListView.builder(
      itemCount: spellLevels.length,
      itemBuilder: (context, levelIndex) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Spell Level ${levelIndex == 0 ? "Cantrip" : levelIndex}',
              style: const TextStyle(color: AppColors.textColorLight, fontSize: 18, fontWeight: FontWeight.bold),
            ),
            ..._buildSpellFields(levelIndex),
            const SizedBox(height: 16),
          ],
        );
      },
    );
  }

  List<Widget> _buildSpellFields(int levelIndex) {
    List<Widget> fields = [];
    for (var controller in spellLevels[levelIndex]) {
      fields.add(
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                onChanged: (value) {
                  if (value.isNotEmpty && fields.length <= 4) {
                    setState(() {
                      spellLevels[levelIndex].add(TextEditingController());
                    });
                  }
                },
                decoration: InputDecoration(
                  filled: true,
                  fillColor: AppColors.cardColor,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: const BorderSide(color: AppColors.dividerColor),
                  ),
                  hintText: 'Spell Name',
                  hintStyle: const TextStyle(color: AppColors.textColorDark),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                controller: TextEditingController(),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: AppColors.cardColor,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: const BorderSide(color: AppColors.dividerColor),
                  ),
                  hintText: 'Status',
                  hintStyle: const TextStyle(color: AppColors.textColorDark),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                controller: TextEditingController(),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: AppColors.cardColor,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: const BorderSide(color: AppColors.dividerColor),
                  ),
                  hintText: 'Description',
                  hintStyle: const TextStyle(color: AppColors.textColorDark),
                ),
              ),
            ),
          ],
        ),
      );
    }
    return fields;
  }
}
