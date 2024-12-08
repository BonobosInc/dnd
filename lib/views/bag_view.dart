import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:dnd/classes/profile_manager.dart';
import 'package:dnd/configs/defines.dart';
import 'package:dnd/configs/colours.dart';
import 'dart:math';

class BagPage extends StatefulWidget {
  final ProfileManager profileManager;

  const BagPage({
    super.key,
    required this.profileManager,
  });

  @override
  BagPageState createState() => BagPageState();
}

class BagPageState extends State<BagPage> {
  final TextEditingController platinController = TextEditingController();
  final TextEditingController goldController = TextEditingController();
  final TextEditingController electrumController = TextEditingController();
  final TextEditingController silverController = TextEditingController();
  final TextEditingController copperController = TextEditingController();

  final ScrollController _scrollController = ScrollController();

  final List<Item> items = [];

  @override
  void initState() {
    super.initState();
    _loadCharacterData();
    _fetchItems();
  }

  Future<void> _loadCharacterData() async {
    List<Map<String, dynamic>> result =
        await widget.profileManager.getBagItems();

    if (result.isNotEmpty) {
      Map<String, dynamic> characterData = result.first;
      setState(() {
        platinController.text =
            (characterData[Defines.bagPlatin] ?? 0).toString();
        goldController.text = (characterData[Defines.bagGold] ?? 0).toString();
        electrumController.text =
            (characterData[Defines.bagElectrum] ?? 0).toString();
        silverController.text =
            (characterData[Defines.bagSilver] ?? 0).toString();
        copperController.text =
            (characterData[Defines.bagCopper] ?? 0).toString();
      });
    }
  }

  void _onFieldChanged(String field, String value) {
    final int? intValue = int.tryParse(value);
    if (intValue != null) {
      widget.profileManager.updateBag(field: field, value: intValue);
    }
  }

  @override
  void dispose() {
    platinController.dispose();
    goldController.dispose();
    electrumController.dispose();
    silverController.dispose();
    copperController.dispose();
    super.dispose();
  }

  Future<void> _fetchItems() async {
    List<Map<String, dynamic>> fetchedItems =
        await widget.profileManager.getItems();

    setState(() {
      items.clear();
      for (var item in fetchedItems) {
        items.add(Item(
          name: item['itemname'],
          description: item['description'] ?? '',
          uuid: item['ID'],
          type: item['type'] ?? 'Sonstige',
          amount: item['amount'] ?? 1,
        ));
      }
      items.sort((a, b) => a.uuid!.compareTo(b.uuid as num));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gegenstände/Ausrüstung'),
        backgroundColor: AppColors.appBarColor,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _showAddItemDialog,
            tooltip: 'Gegenstand hinzufügen',
          ),
        ],
      ),
      body: SingleChildScrollView(
        controller: _scrollController,
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: _buildIntegerTextField(
                    'PM',
                    platinController,
                    Defines.bagPlatin,
                  ),
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: _buildIntegerTextField(
                    'GM',
                    goldController,
                    Defines.bagGold,
                  ),
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: _buildIntegerTextField(
                    'EM',
                    electrumController,
                    Defines.bagElectrum,
                  ),
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: _buildIntegerTextField(
                    'SM',
                    silverController,
                    Defines.bagSilver,
                  ),
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: _buildIntegerTextField(
                    'KM',
                    copperController,
                    Defines.bagCopper,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildItemsTiles(),
          ],
        ),
      ),
    );
  }

  Widget _buildIntegerTextField(
    String label,
    TextEditingController controller,
    String field,
  ) {
    return LayoutBuilder(
      builder: (context, constraints) {
        double fontSize = min(constraints.maxWidth * 0.18, 90 * 0.18);

        return TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
          ],
          decoration: InputDecoration(
            labelText: label,
            border: const OutlineInputBorder(),
          ),
          style: TextStyle(fontSize: fontSize),
          textAlign: TextAlign.center,
          onChanged: (value) => _onFieldChanged(field, value),
        );
      },
    );
  }

  void _showAddItemDialog() {
    var newItem = true;
    _showItemDialog(Item(name: '', description: '', type: 'Sonstige', amount: 1), newItem);
  }

  void _showItemDetails(Item item) {
    var newItem = false;
    _showItemDialog(item, newItem);
  }

  void _showItemDialog(Item item, bool newItem) {
    TextEditingController descriptionController =
        TextEditingController(text: item.description);

    String? selectedType = item.type;
    int editedAmount = item.amount ?? 1;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Gegenstand bearbeiten'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 16),
                _buildItemDetailForm(item, descriptionController),
                const SizedBox(height: 16),
                // Dropdown for type
                DropdownButtonFormField<String>(
                  value: selectedType,
                  items: const [
                    DropdownMenuItem(
                        value: 'Gegenstände', child: Text('Gegenstände')),
                    DropdownMenuItem(
                        value: 'Ausrüstung', child: Text('Ausrüstung')),
                    DropdownMenuItem(
                        value: 'Sonstige', child: Text('Sonstige')),
                  ],
                  decoration: const InputDecoration(
                    labelText: 'Typ',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                    selectedType = value;
                    item.type = selectedType;
                  },
                ),
                const SizedBox(height: 16),
                // Row for editing amount
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Menge:'),
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.remove),
                          onPressed: () {
                            setState(() {
                              if (editedAmount > 1) editedAmount--;
                            });
                          },
                        ),
                        Text('$editedAmount'),
                        IconButton(
                          icon: const Icon(Icons.add),
                          onPressed: () {
                            setState(() {
                              editedAmount++;
                            });
                          },
                        ),
                      ],
                    ),
                  ],
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
                  item.amount = editedAmount;
                  if (newItem) {
                    _addItem(item, descriptionController.text);
                  } else {
                    _updateItem(item, descriptionController.text);
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

  void _updateItem(Item item, String description) {
    final finalDescription =
        description.isEmpty ? "Keine Beschreibung vorhanden" : description;

    widget.profileManager
        .updateItem(
      itemname: item.name,
      description: finalDescription,
      type: item.type,
      uuid: item.uuid,
    )
        .then((_) {
      _fetchItems();
    });
  }

  void _addItem(Item item, String description) {
    final finalDescription =
        description.isEmpty ? "Keine Beschreibung vorhanden" : description;

    widget.profileManager
        .addItem(
            itemname: item.name, description: finalDescription, type: item.type)
        .then((_) {
      _fetchItems();
    });
  }

  void _deleteItem(int uuid) async {
    await widget.profileManager.removeItem(uuid);
    _fetchItems();
  }

  Widget _buildItemDetailForm(
      Item item, TextEditingController descriptionController) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildItemTextField(
          label: 'Name',
          controller: TextEditingController(text: item.name),
          onChanged: (value) => item.name = value,
        ),
        const SizedBox(height: 16),
        _buildDescriptionTextField(descriptionController),
      ],
    );
  }

  Widget _buildItemTextField({
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
      maxLines: 8,
      decoration: const InputDecoration(
        labelText: 'Beschreibung',
        border: OutlineInputBorder(),
      ),
    );
  }

  Widget _buildItemsTiles() {
    items.sort((a, b) => a.uuid!.compareTo(b.uuid!));

    Map<String, List<Item>> groupedItems = {
      'Gegenstände': [],
      'Ausrüstung': [],
      'Sonstige': [],
    };

    for (var item in items) {
      String groupKey;
      switch (item.type) {
        case 'Gegenstände':
          groupKey = 'Gegenstände';
          break;
        case 'Ausrüstung':
          groupKey = 'Ausrüstung';
          break;
        default:
          groupKey = 'Sonstige';
          break;
      }
      groupedItems[groupKey]!.add(item);
    }

    var nonEmptyCategories =
        groupedItems.entries.where((entry) => entry.value.isNotEmpty).toList();

    return Column(
      children: nonEmptyCategories.map((entry) {
        String category = entry.key;
        List<Item> itemsOfCategory = entry.value;

        List<Widget> categoryWidgets = [
          const Divider(),
          ExpansionTile(
            shape: const Border(),
            title: Text(
              category,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            children: itemsOfCategory.map((item) {
              return Card(
                color: AppColors.cardColor,
                elevation: 4.0,
                margin:
                    const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                child: ListTile(
                  title: Text(
                    item.name,
                    style: TextStyle(color: AppColors.textColorLight),
                  ),
                  onTap: () => _showItemDetails(item),
                  trailing: SizedBox(
                    width: 35,
                    height: 35,
                    child: IconButton(
                      icon: Icon(Icons.close,
                          color: AppColors.textColorDark),
                      iconSize: 20.0,
                      padding: EdgeInsets.zero,
                      onPressed: () {
                        _showDeleteConfirmationDialog(item);
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
          ),
        ];
        if (entry == nonEmptyCategories.last) {
          categoryWidgets.add(const Divider());
        }

        return Column(children: categoryWidgets);
      }).toList(),
    );
  }

  void _showDeleteConfirmationDialog(Item item) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Löschen bestätigen'),
          content:
              Text('Bist du sicher, dass du "${item.name}" löschen möchtest?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Abbrechen'),
            ),
            TextButton(
              onPressed: () {
                _deleteItem(item.uuid!);
                Navigator.of(context).pop(true);
              },
              child: const Text('Löschen'),
            ),
          ],
        );
      },
    );
  }
}

class Item {
  String name;
  String description;
  int? uuid;
  String? type;
  int? amount;

  Item({
    required this.name,
    required this.description,
    this.uuid,
    required this.type,
    required this.amount,
  });
}
