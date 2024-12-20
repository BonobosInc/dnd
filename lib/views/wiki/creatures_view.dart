import 'package:flutter/material.dart';
import 'package:dnd/classes/wiki_classes.dart';

class AllCreaturesPage extends StatefulWidget {
  final List<Creature> creatures;
  final bool importCreature;

  const AllCreaturesPage({
    super.key,
    required this.creatures,
    this.importCreature = false,
  });

  @override
  AllCreaturesPageState createState() => AllCreaturesPageState();
}

class AllCreaturesPageState extends State<AllCreaturesPage> {
  final Set<Creature> _selectedCreatures = {};
  String _searchText = '';
  bool _sortByCr = true;
  String? _selectedCr;
  late List<Creature> _filteredCreaturesCache;
  late List<String> _uniqueCRs;

  bool isSearchVisible = false;
  String _activeFilter = 'Sortieren nach CR';
  FocusNode searchFocusNode = FocusNode();
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _filteredCreaturesCache = _computeFilteredCreatures();
    _uniqueCRs = _getUniqueCRs();
  }

  @override
  void dispose() {
    searchFocusNode.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant AllCreaturesPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.creatures != widget.creatures ||
        _searchText != _searchText ||
        _sortByCr != _sortByCr ||
        _selectedCr != _selectedCr) {
      _filteredCreaturesCache = _computeFilteredCreatures();
    }
  }

  List<String> _getUniqueCRs() {
    Set<String> crSet = {};
    for (var creature in widget.creatures) {
      crSet.add(creature.cr);
    }

    List<String> crList = crSet.toList();
    crList.sort((a, b) {
      return parseCr(a).compareTo(parseCr(b));
    });

    return crList;
  }

  double parseCr(String cr) {
    try {
      if (cr.contains('/')) {
        var parts = cr.split('/');
        return double.parse(parts[0]) / double.parse(parts[1]);
      } else {
        return double.parse(cr);
      }
    } catch (e) {
      return double.infinity;
    }
  }

  List<Creature> _computeFilteredCreatures() {
    List<Creature> filteredList = widget.creatures
        .where((creature) =>
            creature.name.toLowerCase().contains(_searchText.toLowerCase()) &&
            (_selectedCr == null || creature.cr == _selectedCr))
        .toList();

    if (_sortByCr) {
      filteredList.sort((a, b) {
        return parseCr(a.cr).compareTo(parseCr(b.cr));
      });
    } else {
      filteredList.sort((a, b) => a.name.compareTo(b.name));
    }

    return filteredList;
  }

  void _onCreatureSelected(Creature creature, bool isSelected) {
    setState(() {
      if (isSelected) {
        _selectedCreatures.add(creature);
      } else {
        _selectedCreatures.remove(creature);
      }
    });
  }

  void _navigateToCreatureDetail(Creature creature) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => CreatureDetailPage(
          creature: creature,
          importCreature: widget.importCreature,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: isSearchVisible
            ? TextField(
                controller: searchController,
                focusNode: searchFocusNode,
                decoration: const InputDecoration(
                  hintText: 'Suchen...',
                  border: InputBorder.none,
                  hintStyle: TextStyle(color: Colors.white54),
                ),
                style: const TextStyle(color: Colors.white),
                onChanged: (value) {
                  setState(() {
                    _searchText = value;
                    _filteredCreaturesCache = _computeFilteredCreatures();
                  });
                },
              )
            : const Text('Alle Monster'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              setState(() {
                isSearchVisible = !isSearchVisible;
                if (isSearchVisible) {
                  searchFocusNode.requestFocus();
                } else {
                  _searchText = '';
                  searchController.clear();
                  searchFocusNode.unfocus();
                  _filteredCreaturesCache = _computeFilteredCreatures();
                }
              });
            },
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.filter_list),
            tooltip: 'Filter und Sortieren',
            onSelected: (value) {
              setState(() {
                _activeFilter = value;
                if (_activeFilter == 'Sortieren nach CR') {
                  _sortByCr = true;
                  _selectedCr = null;
                } else if (_activeFilter == 'Sortieren nach Name') {
                  _sortByCr = false;
                  _selectedCr = null;
                } else {
                  _sortByCr = true;
                  _selectedCr = _activeFilter;
                }
                _filteredCreaturesCache = _computeFilteredCreatures();
              });
            },
            itemBuilder: (BuildContext context) => [
              PopupMenuItem(
                value: 'Sortieren nach CR',
                child: Row(
                  children: [
                    if (_activeFilter == 'Sortieren nach CR')
                      const Icon(Icons.check, size: 18, color: Colors.blue),
                    const Text('Sortieren nach CR'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'Sortieren nach Name',
                child: Row(
                  children: [
                    if (_activeFilter == 'Sortieren nach Name')
                      const Icon(Icons.check, size: 18, color: Colors.blue),
                    const Text('Sortieren nach Name'),
                  ],
                ),
              ),
              ..._uniqueCRs.map(
                (cr) => PopupMenuItem(
                  value: cr,
                  child: Row(
                    children: [
                      if (_activeFilter == cr)
                        const Icon(Icons.check, size: 18, color: Colors.blue),
                      Text('CR: $cr'),
                    ],
                  ),
                ),
              ),
            ],
          ),
          if (widget.importCreature)
            IconButton(
              tooltip: "Ausgewählte Begleiter importieren",
              icon: const Icon(Icons.check),
              onPressed: () {
                Navigator.of(context).pop(_selectedCreatures.toList());
              },
            )
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _filteredCreaturesCache.length,
              itemBuilder: (context, index) {
                final creature = _filteredCreaturesCache[index];
                return ListTile(
                  title: Text(creature.name),
                  subtitle: Text('CR: ${creature.cr}'),
                  trailing: widget.importCreature
                      ? GestureDetector(
                          onTap: () {
                            _navigateToCreatureDetail(creature);
                          },
                          child: Checkbox(
                            value: _selectedCreatures.contains(creature),
                            onChanged: (isSelected) {
                              _onCreatureSelected(creature, isSelected!);
                            },
                          ),
                        )
                      : null,
                  onTap: () {
                    _navigateToCreatureDetail(creature);
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: widget.importCreature
          ? FloatingActionButton(
              tooltip: 'Neuen Begleiter erstellen',
              onPressed: () async {
                final newCreature = await _showAddCreatureDialog(context);
                if (newCreature != null && context.mounted) {
                  Navigator.of(context).pop(newCreature);
                }
              },
              child: const Icon(Icons.add),
            )
          : null,
    );
  }

  Future<Creature?> _showAddCreatureDialog(BuildContext context) async {
    return await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const CreateCreaturePage(),
      ),
    );
  }
}

class CreateCreaturePage extends StatefulWidget {
  final Creature? creature;
  final bool statsMenu;

  const CreateCreaturePage({super.key, this.creature, this.statsMenu = false});

  @override
  CreateCreaturePageState createState() => CreateCreaturePageState();
}

class CreateCreaturePageState extends State<CreateCreaturePage> {
  late final TextEditingController _nameController =
      TextEditingController(text: widget.creature?.name ?? '');
  late final TextEditingController _sizeController =
      TextEditingController(text: widget.creature?.size ?? '');
  late final TextEditingController _typeController =
      TextEditingController(text: widget.creature?.type ?? '');
  late final TextEditingController _alignmentController =
      TextEditingController(text: widget.creature?.alignment ?? '');
  late final TextEditingController _acController =
      TextEditingController(text: widget.creature?.ac.toString() ?? '');
  late final TextEditingController _hpController =
      TextEditingController(text: widget.creature?.maxHP.toString() ?? '');
  late final TextEditingController _speedController =
      TextEditingController(text: widget.creature?.speed ?? '');
  late final TextEditingController _crController =
      TextEditingController(text: widget.creature?.cr ?? '');
  late final TextEditingController _strController =
      TextEditingController(text: widget.creature?.str.toString() ?? '');
  late final TextEditingController _dexController =
      TextEditingController(text: widget.creature?.dex.toString() ?? '');
  late final TextEditingController _conController =
      TextEditingController(text: widget.creature?.con.toString() ?? '');
  late final TextEditingController _intController =
      TextEditingController(text: widget.creature?.intScore.toString() ?? '');
  late final TextEditingController _wisController =
      TextEditingController(text: widget.creature?.wis.toString() ?? '');
  late final TextEditingController _chaController =
      TextEditingController(text: widget.creature?.cha.toString() ?? '');
  late final TextEditingController _savesController =
      TextEditingController(text: widget.creature?.saves ?? '');
  late final TextEditingController _skillsController =
      TextEditingController(text: widget.creature?.skills ?? '');
  late final TextEditingController _resistancesController =
      TextEditingController(text: widget.creature?.resistances ?? '');
  late final TextEditingController _vulnerabilitiesController =
      TextEditingController(text: widget.creature?.vulnerabilities ?? '');
  late final TextEditingController _immunitiesController =
      TextEditingController(text: widget.creature?.immunities ?? '');
  late final TextEditingController _conditionImmunitiesController =
      TextEditingController(text: widget.creature?.conditionImmunities ?? '');
  late final TextEditingController _sensesController =
      TextEditingController(text: widget.creature?.senses ?? '');
  late final TextEditingController _passivePerceptionController =
      TextEditingController(
          text: widget.creature?.passivePerception.toString() ?? '');
  late final TextEditingController _languagesController =
      TextEditingController(text: widget.creature?.languages ?? '');

  late List<Trait> _traits;
  late List<CAction> _actions;
  late List<Legendary> _legendaryActions;

  @override
  void initState() {
    super.initState();

    _traits = widget.creature?.traits ?? [];
    _actions = widget.creature?.actions ?? [];
    _legendaryActions = widget.creature?.legendaryActions ?? [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Begleiter bearbeiten'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: () {
              final newCreature = Creature(
                name: _nameController.text,
                size: _sizeController.text,
                type: _typeController.text,
                alignment: _alignmentController.text,
                ac: int.tryParse(_acController.text) ?? 0,
                maxHP: int.tryParse(_hpController.text) ?? 0,
                currentHP: (widget.creature?.currentHP ?? 0) == 0
                    ? int.tryParse(_hpController.text) ?? 0
                    : widget.creature?.currentHP ?? 0,
                speed: _speedController.text,
                str: int.tryParse(_strController.text) ?? 0,
                dex: int.tryParse(_dexController.text) ?? 0,
                con: int.tryParse(_conController.text) ?? 0,
                intScore: int.tryParse(_intController.text) ?? 0,
                wis: int.tryParse(_wisController.text) ?? 0,
                cha: int.tryParse(_chaController.text) ?? 0,
                saves: _savesController.text,
                skills: _skillsController.text,
                resistances: _resistancesController.text,
                vulnerabilities: _vulnerabilitiesController.text,
                immunities: _immunitiesController.text,
                conditionImmunities: _conditionImmunitiesController.text,
                senses: _sensesController.text,
                passivePerception:
                    int.tryParse(_passivePerceptionController.text) ?? 0,
                languages: _languagesController.text,
                cr: _crController.text,
                traits: _traits,
                actions: _actions,
                legendaryActions: _legendaryActions,
                uuid: widget.statsMenu ? (widget.creature?.uuid ?? 0) : 0,
              );

              Navigator.of(context).pop(newCreature);
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _nameController,
                      decoration: const InputDecoration(labelText: 'Name'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextField(
                      controller: _sizeController,
                      decoration: const InputDecoration(labelText: 'Größe'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _typeController,
                      decoration: const InputDecoration(labelText: 'Typ'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextField(
                      controller: _alignmentController,
                      decoration: const InputDecoration(labelText: 'Gesinnung'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _acController,
                      decoration: const InputDecoration(
                          labelText: 'Rüstungsklasse (AC)'),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextField(
                      controller: _hpController,
                      decoration:
                          const InputDecoration(labelText: 'Lebenspunkte (HP)'),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _speedController,
                      decoration:
                          const InputDecoration(labelText: 'Bewegungsrate'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextField(
                      controller: _crController,
                      decoration: const InputDecoration(
                          labelText: 'Herausforderungsgrad'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _strController,
                      decoration: const InputDecoration(labelText: 'Stärke'),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextField(
                      controller: _dexController,
                      decoration:
                          const InputDecoration(labelText: 'Geschicklichkeit'),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _conController,
                      decoration:
                          const InputDecoration(labelText: 'Konstitution'),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextField(
                      controller: _intController,
                      decoration:
                          const InputDecoration(labelText: 'Intelligenz'),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _wisController,
                      decoration: const InputDecoration(labelText: 'Weisheit'),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextField(
                      controller: _chaController,
                      decoration: const InputDecoration(labelText: 'Charisma'),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _savesController,
                      decoration:
                          const InputDecoration(labelText: 'Rettungswürfe'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextField(
                      controller: _skillsController,
                      decoration:
                          const InputDecoration(labelText: 'Fertigkeiten'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _resistancesController,
                      decoration:
                          const InputDecoration(labelText: 'Resistenzen'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextField(
                      controller: _vulnerabilitiesController,
                      decoration:
                          const InputDecoration(labelText: 'Verwundbarkeiten'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _immunitiesController,
                      decoration:
                          const InputDecoration(labelText: 'Immunitäten'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextField(
                      controller: _conditionImmunitiesController,
                      decoration: const InputDecoration(
                          labelText: 'Zustandsimmunitäten'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _sensesController,
                      decoration: const InputDecoration(labelText: 'Sinne'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextField(
                      controller: _passivePerceptionController,
                      decoration: const InputDecoration(
                          labelText: 'Passive Wahrnehmung'),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _languagesController,
                      decoration: const InputDecoration(labelText: 'Sprachen'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _buildTraitSection(),
              const Divider(color: Colors.grey, thickness: 1.5),
              const SizedBox(height: 10),
              _buildCActionSection(),
              const Divider(color: Colors.grey, thickness: 1.5),
              const SizedBox(height: 10),
              _buildLegendaryActionSection(),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTraitSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'Merkmale',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const Spacer(),
            IconButton(
              onPressed: () {
                _showTraitDialog(context);
              },
              icon: const Icon(Icons.add),
              tooltip: 'Merkmal hinzufügen',
            ),
          ],
        ),
        const SizedBox(height: 10),
        for (var trait in _traits) ...[
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: GestureDetector(
              onTap: () {
                _showEditDialog(context, trait, 'trait');
              },
              child: Card(
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
                              trait.name,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          _showDeleteConfirmationDialog(trait, 'trait');
                        },
                        icon: const Icon(Icons.delete),
                        tooltip: 'Lösche ${trait.name}',
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildCActionSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'Aktion',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const Spacer(),
            IconButton(
              onPressed: () {
                _showCActionDialog(context);
              },
              icon: const Icon(Icons.add),
              tooltip: 'Aktion hinzufügen',
            ),
          ],
        ),
        const SizedBox(height: 10),
        for (var action in _actions) ...[
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: GestureDetector(
              onTap: () {
                _showEditDialog(context, action, 'action');
              },
              child: Card(
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
                              action.name,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          _showDeleteConfirmationDialog(action, 'action');
                        },
                        icon: const Icon(Icons.delete),
                        tooltip: 'Lösche ${action.name}',
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildLegendaryActionSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'Legendäre Aktionen',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const Spacer(),
            IconButton(
              onPressed: () {
                _showLegendaryActionDialog(context);
              },
              icon: const Icon(Icons.add),
              tooltip: 'Legendäre Aktion hinzufügen',
            ),
          ],
        ),
        const SizedBox(height: 10),
        for (var legendary in _legendaryActions) ...[
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: GestureDetector(
              onTap: () {
                _showEditDialog(context, legendary, 'legendary');
              },
              child: Card(
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
                              legendary.name,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          _showDeleteConfirmationDialog(legendary, 'legendary');
                        },
                        icon: const Icon(Icons.delete),
                        tooltip: 'Lösche ${legendary.name}',
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ],
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

  Widget _buildDescriptionTextField(TextEditingController controller) {
    return TextField(
      controller: controller,
      maxLines: 5,
      decoration: const InputDecoration(
        labelText: 'Beschreibung',
        border: OutlineInputBorder(),
      ),
    );
  }

  Future<void> _showTraitDialog(BuildContext context) async {
    final traitNameController = TextEditingController();
    final traitDescriptionController = TextEditingController();

    await showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Merkmale bearbeiten'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 16),
                _buildTextField(
                  label: 'Merkmal',
                  controller: traitNameController,
                  onChanged: (value) {},
                ),
                const SizedBox(height: 16),
                _buildDescriptionTextField(traitDescriptionController),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Abbrechen'),
            ),
            TextButton(
              onPressed: () {
                if (traitNameController.text.isNotEmpty &&
                    traitDescriptionController.text.isNotEmpty) {
                  setState(() {
                    _traits.add(Trait(
                      name: traitNameController.text,
                      description: traitDescriptionController.text,
                    ));
                  });
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Speichern'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showCActionDialog(BuildContext context) async {
    final cActionNameController = TextEditingController();
    final cActionDescriptionController = TextEditingController();
    final cActionAttackController = TextEditingController();

    await showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Angriff bearbeiten'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 16),
                _buildTextField(
                  label: 'Angriff',
                  controller: cActionNameController,
                  onChanged: (value) {},
                ),
                const SizedBox(height: 16),
                _buildDescriptionTextField(cActionDescriptionController),
                const SizedBox(height: 16),
                _buildTextField(
                  label: 'Angriffswert',
                  controller: cActionAttackController,
                  onChanged: (value) {},
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Abbrechen'),
            ),
            TextButton(
              onPressed: () {
                if (cActionNameController.text.isNotEmpty &&
                    cActionDescriptionController.text.isNotEmpty) {
                  setState(() {
                    _actions.add(CAction(
                      name: cActionNameController.text,
                      description: cActionDescriptionController.text,
                      attack: cActionAttackController.text.isNotEmpty
                          ? cActionAttackController.text
                          : null,
                    ));
                  });
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Speichern'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showLegendaryActionDialog(BuildContext context) async {
    final legendaryActionNameController = TextEditingController();
    final legendaryActionDescriptionController = TextEditingController();

    await showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Legendäre Aktion bearbeiten'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 16),
                _buildTextField(
                  label: 'Legendäre Aktion',
                  controller: legendaryActionNameController,
                  onChanged: (value) {},
                ),
                const SizedBox(height: 16),
                _buildDescriptionTextField(
                    legendaryActionDescriptionController),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Abbrechen'),
            ),
            TextButton(
              onPressed: () {
                if (legendaryActionNameController.text.isNotEmpty &&
                    legendaryActionDescriptionController.text.isNotEmpty) {
                  setState(() {
                    _legendaryActions.add(Legendary(
                      name: legendaryActionNameController.text,
                      description: legendaryActionDescriptionController.text,
                    ));
                  });
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Speichern'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showDeleteConfirmationDialog(dynamic item, String type) async {
    final String itemName = item is Trait
        ? item.name
        : item is CAction
            ? item.name
            : (item as Legendary).name;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Lösche $type'),
          content: Text('Bist du sicher, dass du $itemName löschen möchtest?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Abbrechen'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  if (type == 'trait') {
                    _traits.remove(item);
                  } else if (type == 'action') {
                    _actions.remove(item);
                  } else {
                    _legendaryActions.remove(item);
                  }
                });
                Navigator.of(context).pop();
              },
              child: const Text('Löschen'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showEditDialog(
      BuildContext context, dynamic item, String type) async {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController descriptionController = TextEditingController();
    String attackControllerText = '';

    // Initialize controllers with the current item's values
    if (item is Trait) {
      nameController.text = item.name;
      descriptionController.text = item.description;
    } else if (item is CAction) {
      nameController.text = item.name;
      descriptionController.text = item.description;
      attackControllerText = item.attack ?? '';
    } else if (item is Legendary) {
      nameController.text = item.name;
      descriptionController.text = item.description;
    }

    String dialogTitle = '';
    String nameLabel = '';
    String attackLabel = '';

    if (type == 'trait') {
      dialogTitle = 'Bearbeite Merkmal';
      nameLabel = 'Merkmal';
    } else if (type == 'action') {
      dialogTitle = 'Bearbeite Angriff';
      nameLabel = 'Angriff';
      attackLabel = 'Angriffswert';
    } else if (type == 'legendary') {
      dialogTitle = 'Bearbeite Legendäre Aktion';
      nameLabel = 'Legendäre Aktion';
    }

    await showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(dialogTitle),
          content: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 16),
                _buildTextField(
                  label: nameLabel,
                  controller: nameController,
                  onChanged: (value) {},
                ),
                const SizedBox(height: 16),
                _buildDescriptionTextField(descriptionController),
                const SizedBox(height: 16),
                if (type == 'action')
                  _buildTextField(
                    label: attackLabel,
                    controller:
                        TextEditingController(text: attackControllerText),
                    onChanged: (value) {
                      attackControllerText = value;
                    },
                  ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Abbrechen'),
            ),
            TextButton(
              onPressed: () {
                if (nameController.text.isNotEmpty &&
                    descriptionController.text.isNotEmpty) {
                  setState(() {
                    if (type == 'trait') {
                      item.name = nameController.text;
                      item.description = descriptionController.text;
                    } else if (type == 'action') {
                      item.name = nameController.text;
                      item.description = descriptionController.text;
                      item.attack = attackControllerText.isNotEmpty
                          ? attackControllerText
                          : null;
                    } else if (type == 'legendary') {
                      item.name = nameController.text;
                      item.description = descriptionController.text;
                    }
                  });
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Speichern'),
            ),
          ],
        );
      },
    );
  }
}

class CreatureDetailPage extends StatelessWidget {
  final Creature creature;
  final bool importCreature;
  final bool statsMenu;

  const CreatureDetailPage({
    super.key,
    required this.creature,
    this.importCreature = false,
    this.statsMenu = false,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(creature.name),
        actions: [
          if (statsMenu)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () async {
                final updatedCreature = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CreateCreaturePage(
                      creature: creature,
                      statsMenu: statsMenu,
                    ),
                  ),
                );

                if (updatedCreature != null && context.mounted) {
                  Navigator.of(context).pop(updatedCreature);
                }
              },
            ),
          if (importCreature)
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () async {
                final newCreature =
                    await _showAddCreatureDialog(context, creature);
                if (newCreature != null && context.mounted) {
                  Navigator.of(context).pop();
                  Navigator.of(context).pop(newCreature);
                }
              },
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSizeAlignmentSection(),
            const Divider(),
            _buildArmorHitpointsSpeedSection(),
            const Divider(),
            _buildStatsSection(),
            const Divider(),
            _buildSavingThrowsSection(),
            const Divider(),
            _buildSensesLanguagesCrSection(),
            const Divider(),
            _buildTraitsSection(),
            const Divider(),
            _buildActionsSection(),
            const Divider(),
            _buildLegendaryActionsSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildSizeAlignmentSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Größe: ${creature.size}'),
        Text('Typ: ${creature.type}'),
        Text('Gesinnung: ${creature.alignment}'),
      ],
    );
  }

  Widget _buildArmorHitpointsSpeedSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Rüstungsklasse: ${creature.ac}'),
        Text('Lebenspunkte: ${creature.maxHP}'),
        Text('Bewegungsrate: ${creature.speed}'),
      ],
    );
  }

  Widget _buildStatsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildStatRow('STR', creature.str),
        _buildStatRow('DEX', creature.dex),
        _buildStatRow('CON', creature.con),
        _buildStatRow('INT', creature.intScore),
        _buildStatRow('WIS', creature.wis),
        _buildStatRow('CHA', creature.cha),
      ],
    );
  }

  Widget _buildStatRow(String label, int value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Text('$label:', style: const TextStyle(fontWeight: FontWeight.bold)),
        Text(value.toString()),
      ],
    );
  }

  Widget _buildSavingThrowsSection() {
    return Text(
        'Rettungswürfe: ${creature.saves.isNotEmpty ? creature.saves : 'None'}');
  }

  Widget _buildSensesLanguagesCrSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Sinne: ${creature.senses.isNotEmpty ? creature.senses : 'None'}'),
        Text(
            'Sprachen: ${creature.languages.isNotEmpty ? creature.languages : 'None'}'),
        Text(
            'Herausforderungsgrad: ${creature.cr.isNotEmpty ? creature.cr : 'N/A'}'),
      ],
    );
  }

  Widget _buildTraitsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Merkmale',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        if (creature.traits.isEmpty) const Text('None'),
        ...creature.traits.map((trait) => _buildTrait(trait)),
      ],
    );
  }

  Widget _buildTrait(Trait trait) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(trait.name, style: const TextStyle(fontWeight: FontWeight.bold)),
          Text(trait.description),
        ],
      ),
    );
  }

  Widget _buildActionsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Aktionen',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        if (creature.actions.isEmpty) const Text('None'),
        ...creature.actions.map((action) => _buildAction(action)),
      ],
    );
  }

  Widget _buildAction(CAction action) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            action.name,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Text(action.description),
          if (action.attack != null && action.attack!.isNotEmpty)
            Text('Angriff: ${action.attack}'),
        ],
      ),
    );
  }

  Widget _buildLegendaryActionsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Legendäre Aktion',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        if (creature.legendaryActions.isEmpty) const Text('None'),
        ...creature.legendaryActions
            .map((legendary) => _buildLegendaryAction(legendary)),
      ],
    );
  }

  Widget _buildLegendaryAction(Legendary legendary) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(legendary.name,
              style: const TextStyle(fontWeight: FontWeight.bold)),
          Text(legendary.description),
        ],
      ),
    );
  }

  Future<Creature?> _showAddCreatureDialog(
      BuildContext context, Creature creature) async {
    return showDialog<Creature?>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Begeleiter hinzufügen'),
          content: Text('Möchtest du ${creature.name} hinzufügen?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Nein'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(creature);
              },
              child: const Text('Ja'),
            ),
          ],
        );
      },
    );
  }
}
