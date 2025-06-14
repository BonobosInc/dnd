import 'dart:math';

import 'package:dnd/configs/defines.dart';
import 'package:flutter/material.dart';
import 'package:dnd/classes/profile_manager.dart';
import 'package:dnd/configs/colours.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class WeaponPage extends StatefulWidget {
  final ProfileManager profileManager;

  const WeaponPage({super.key, required this.profileManager});

  @override
  WeaponPageState createState() => WeaponPageState();
}

class WeaponPageState extends State<WeaponPage> {
  final List<Weapon> weapons = [];

  @override
  void initState() {
    super.initState();
    _fetchWeapons();
  }

  Future<void> _fetchWeapons() async {
    List<Map<String, dynamic>> fetchedWeapons =
        await widget.profileManager.getWeapons();

    setState(() {
      weapons.clear();
      for (var weapon in fetchedWeapons) {
        weapons.add(Weapon(
          name: weapon[Defines.weaponName],
          attribute: weapon[Defines.weaponAttr],
          reach: weapon[Defines.weaponReach],
          bonus: weapon[Defines.weaponBonus],
          damage: weapon[Defines.weaponDamage],
          damageType: weapon[Defines.weaponDamageType],
          description: weapon[Defines.weaponDescription],
          uuid: weapon['ID'],
        ));
      }
    });
  }

  void _addWeapon(Weapon weapon, String description) {
    final loc = AppLocalizations.of(context)!;
    final finalDescription =
        description.isEmpty ? loc.nodescription : description;

    widget.profileManager
        .addWeapon(
      weapon: weapon.name,
      attribute: weapon.attribute,
      reach: weapon.reach,
      bonus: weapon.bonus,
      damage: weapon.damage,
      damagetype: weapon.damageType,
      description: finalDescription,
    )
        .then((_) {
      _fetchWeapons();
    });
  }

  void _updateWeapon(Weapon weapon, String description) {
    final loc = AppLocalizations.of(context)!;
    final finalDescription =
        description.isEmpty ? loc.nodescription : description;

    widget.profileManager
        .updateWeapons(
      weapon: weapon.name,
      attribute: weapon.attribute,
      reach: weapon.reach,
      bonus: weapon.bonus,
      damage: weapon.damage,
      damagetype: weapon.damageType,
      description: finalDescription,
      uuid: weapon.uuid!,
    )
        .then((_) {
      _fetchWeapons();
    });
  }

  void _deleteWeapon(int uuid) async {
    await widget.profileManager.removeweapon(uuid);
    _fetchWeapons();
  }

  void _showWeaponDialog(Weapon weapon, bool isNewWeapon) {
    final loc = AppLocalizations.of(context)!;
    final TextEditingController nameController =
        TextEditingController(text: weapon.name);
    final TextEditingController attributeController =
        TextEditingController(text: weapon.attribute);
    final TextEditingController reachController =
        TextEditingController(text: weapon.reach);
    final TextEditingController bonusController =
        TextEditingController(text: weapon.bonus);
    final TextEditingController damageController =
        TextEditingController(text: weapon.damage);
    final TextEditingController damageTypeController =
        TextEditingController(text: weapon.damageType);
    final TextEditingController descriptionController =
        TextEditingController(text: weapon.description);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(isNewWeapon ? loc.addweapon : loc.editweapon),
          content: SingleChildScrollView(
            child: _buildWeaponDetailForm(
              nameController,
              attributeController,
              reachController,
              bonusController,
              damageController,
              damageTypeController,
              descriptionController,
              weapon,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(loc.abort),
            ),
            TextButton(
              onPressed: () {
                if (isNewWeapon) {
                  _addWeapon(
                    Weapon(
                      name: nameController.text,
                      attribute: attributeController.text,
                      reach: reachController.text,
                      bonus: bonusController.text,
                      damage: damageController.text,
                      damageType: damageTypeController.text,
                      description: descriptionController.text,
                    ),
                    descriptionController.text,
                  );
                } else {
                  _updateWeapon(
                    Weapon(
                      name: nameController.text,
                      attribute: attributeController.text,
                      reach: reachController.text,
                      bonus: bonusController.text,
                      damage: damageController.text,
                      damageType: damageTypeController.text,
                      description: descriptionController.text,
                      uuid: weapon.uuid,
                    ),
                    descriptionController.text,
                  );
                }
                Navigator.of(context).pop();
              },
              child: Text(loc.save),
            ),
          ],
        );
      },
    );
  }

  Widget _buildWeaponDetailForm(
    TextEditingController nameController,
    TextEditingController attributeController,
    TextEditingController reachController,
    TextEditingController bonusController,
    TextEditingController damageController,
    TextEditingController damageTypeController,
    TextEditingController descriptionController,
    Weapon weapon,
  ) {
    final loc = AppLocalizations.of(context)!;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildTextField(loc.weapon, nameController),
        _buildTextField(loc.reach, reachController),
        _buildTextField(loc.damagetype, damageTypeController),
        _buildTextField(loc.bonus, bonusController),
        _buildTextField(loc.damage, damageController),
        _buildTextField(loc.attribute, attributeController),
        _buildDescriptionTextField(descriptionController),
      ],
    );
  }

  void _showAddWeaponDialog() {
    _showWeaponDialog(
      Weapon(
        name: '',
        attribute: '',
        reach: '',
        bonus: '',
        damage: '',
        damageType: '',
        description: '',
      ),
      true,
    );
  }

  void _showDeleteConfirmationDialog(Weapon weapon) {
    final loc = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(loc.confirmdelete),
          content: Text(
            loc.confirmItemDelete(weapon.name),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(loc.abort),
            ),
            TextButton(
              onPressed: () {
                _deleteWeapon(weapon.uuid!);
                Navigator.of(context).pop(true);
              },
              child: Text(loc.delete),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final constraints = BoxConstraints(
      maxWidth: MediaQuery.of(context).size.width,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.weapons,
            style: TextStyle(color: AppColors.textColorLight)),
        backgroundColor: AppColors.appBarColor,
        actions: [
          IconButton(
            icon: Icon(Icons.add, color: AppColors.textColorLight),
            onPressed: _showAddWeaponDialog,
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: weapons.length,
        itemBuilder: (context, index) {
          final weapon = weapons[index];
          return _buildWeaponTile(weapon, constraints);
        },
      ),
    );
  }

  Widget _buildWeaponTile(Weapon weapon, BoxConstraints constraints) {
    final loc = AppLocalizations.of(context)!;
    double scaledfontSize = min(constraints.maxWidth * 0.04, 600 * 0.04);
    double scaledfontDamageType = min(constraints.maxWidth * 0.035, 600 * 0.035);
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () {
              _showWeaponDialog(weapon, false);
            },
            child: Card(
              elevation: 8.0,
              color: AppColors.cardColor,
              margin:
                  const EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                weapon.name,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textColorLight,
                                  fontSize: scaledfontSize,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                weapon.reach ?? "",
                                style: TextStyle(
                                  color: AppColors.textColorLight,
                                  fontSize: scaledfontSize,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                weapon.damageType ?? "",
                                style: TextStyle(
                                  color: AppColors.textColorLight,
                                  fontSize: scaledfontDamageType,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                weapon.bonus ?? "",
                                style: TextStyle(
                                  color: AppColors.textColorLight,
                                  fontSize: scaledfontSize,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                weapon.damage ?? "",
                                style: TextStyle(
                                  color: AppColors.textColorLight,
                                  fontSize: scaledfontSize,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                weapon.attribute ?? "",
                                style: TextStyle(
                                  color: AppColors.textColorLight,
                                  fontSize: scaledfontSize,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    Divider(color: AppColors.dividerColor),
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                weapon.description ??
                                    loc.nodescription,
                                textAlign: TextAlign.left,
                                style: TextStyle(
                                  color: AppColors.textColorLight,
                                  fontSize: scaledfontSize,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),
          ),
        ),
        IconButton(
          icon: Icon(Icons.close, color: AppColors.textColorDark),
          onPressed: () {
            _showDeleteConfirmationDialog(weapon);
          },
        ),
      ],
    );
  }

  Widget _buildTextField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }

  Widget _buildDescriptionTextField(TextEditingController controller) {
    final loc = AppLocalizations.of(context)!;
    return TextField(
      controller: controller,
      maxLines: 4,
      decoration: InputDecoration(
        labelText: loc.description,
        border: const OutlineInputBorder(),
      ),
    );
  }
}

class Weapon {
  String name;
  String? attribute;
  String? reach;
  String? bonus;
  String? damage;
  String? damageType;
  String? description;
  int? uuid;

  Weapon({
    required this.name,
    this.attribute,
    this.reach,
    this.bonus,
    this.damage,
    this.damageType,
    this.description,
    this.uuid,
  });
}
