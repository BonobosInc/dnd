import 'package:flutter/material.dart';
import 'package:dnd/classes/profile_manager.dart';

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
          name: weapon['weapon'],
          attribute: weapon['attribute'],
          reach: weapon['reach'],
          bonus: weapon['bonus'],
          damage: weapon['damage'],
          damageType: weapon['damagetype'],
          description: weapon['description'],
          uuid: weapon['ID'],
        ));
      }
    });
  }

  void _addWeapon(Weapon weapon, String description) {
    final finalDescription =
        description.isEmpty ? "Keine Beschreibung verfügbar" : description;

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
    final finalDescription =
        description.isEmpty ? "Keine Beschreibung verfügbar" : description;

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
          title: Text(isNewWeapon ? 'Waffe hinzufügen' : 'Waffe bearbeiten'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                _buildTextField('Waffe', nameController),
                _buildTextField('Attribut', attributeController),
                _buildTextField('Reichweite', reachController),
                _buildTextField('Bonus', bonusController),
                _buildTextField('Schaden', damageController),
                _buildTextField('Schadenstyp', damageTypeController),
                _buildDescriptionTextField(descriptionController),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("Abbrechen"),
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
                  _updateWeapon(weapon, descriptionController.text);
                }
                Navigator.of(context).pop();
                _fetchWeapons();
              },
              child: const Text("Speichern"),
            ),
          ],
        );
      },
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Waffen"),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _showAddWeaponDialog,
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: weapons.length,
        itemBuilder: (context, index) {
          final weapon = weapons[index];
          return _buildWeaponTile(weapon);
        },
      ),
    );
  }

  Widget _buildWeaponTile(Weapon weapon) {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () {
              _showWeaponDialog(weapon, false);
            },
            child: Card(
              elevation: 4.0,
              margin:
                  const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
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
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(weapon.reach ?? "N/A"),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                  weapon.damageType ?? "N/A"),
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
                              Text(weapon.bonus ?? "N/A"),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(weapon.damage ?? "N/A"),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(weapon.attribute ?? "N/A"),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const Divider(),
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        weapon.description ?? "Keine Beschreibung verfügbar",
                        textAlign: TextAlign.left,
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
          icon: const Icon(Icons.close),
          onPressed: () {
            _deleteWeapon(weapon.uuid!);
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
    return TextField(
      controller: controller,
      maxLines: 4,
      decoration: const InputDecoration(
        labelText: 'Beschreibung',
        border: OutlineInputBorder(),
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
