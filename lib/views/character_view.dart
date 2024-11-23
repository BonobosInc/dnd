import 'package:dnd/views/character/mainstats_view.dart';
import 'package:flutter/material.dart';
import 'package:dnd/classes/profile_manager.dart';
import 'package:dnd/classes/wiki_parser.dart';
import 'package:dnd/views/bag_view.dart';
import 'package:dnd/views/notes_view.dart';
import 'package:dnd/views/weapon_view.dart';
import 'package:dnd/views/wiki_view.dart';
import 'package:dnd/configs/defines.dart';
import 'package:dnd/configs/colours.dart';
import 'spell_view.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class CharacterView extends StatefulWidget {
  final ProfileManager profileManager;
  final WikiParser wikiParser;

  const CharacterView({
    super.key,
    required this.profileManager,
    required this.wikiParser,
  });

  @override
  CharacterViewState createState() => CharacterViewState();
}

class CharacterViewState extends State<CharacterView> {
  String name = "Charakter";

  @override
  void initState() {
    super.initState();
    _loadCharacterData();
  }

  Future<void> _loadCharacterData() async {
    List<Map<String, dynamic>> result = await widget.profileManager.getProfileInfo();

    if (result.isNotEmpty) {
      Map<String, dynamic> characterData = result.first;
      setState(() {
        name = characterData[Defines.infoName] ?? "Unbekannter Charakter";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvokedWithResult: (bool didPop, Object? result) {
        if (didPop) {
          widget.profileManager.closeDB();
          return;
        }
      },
      child: DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            title: Text(name),
            backgroundColor: AppColors.appBarColor,
            bottom: TabBar(
              tabs: [
                Tab(icon: Icon(MdiIcons.swordCross)),
                const Tab(icon: Icon(Icons.list)),
              ],
            ),
          ),
          body: TabBarView(
            children: [
              MainStatsPage(profileManager: widget.profileManager),
              const Page2(),
            ],
          ),
          endDrawer: SizedBox(
            width: 250,
            child: Drawer(
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
                      child: Text(
                        'Menü',
                        style: TextStyle(
                          color: AppColors.textColorLight,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  ListTile(
                    title: const Text(
                      'Spells',
                      style: TextStyle(color: AppColors.textColorLight),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SpellManagementPage(
                            profileManager: widget.profileManager,
                            wikiParser: widget.wikiParser,
                          ),
                        ),
                      );
                    },
                  ),
                  ListTile(
                    title: const Text(
                      'Weapons',
                      style: TextStyle(color: AppColors.textColorLight),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => WeaponPage(
                            profileManager: widget.profileManager,
                          ),
                        ),
                      );
                    },
                  ),
                  ListTile(
                    title: const Text(
                      'Notes',
                      style: TextStyle(color: AppColors.textColorLight),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => NotesPage(
                            profileManager: widget.profileManager,
                            wikiParser: widget.wikiParser,
                          ),
                        ),
                      );
                    },
                  ),
                  ListTile(
                    title: const Text(
                      'Bag',
                      style: TextStyle(color: AppColors.textColorLight),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => BagPage(
                            profileManager: widget.profileManager,
                          ),
                        ),
                      );
                    },
                  ),
                  ListTile(
                    title: const Text(
                      'Wiki',
                      style: TextStyle(color: AppColors.textColorLight),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => WikiPage(
                            wikiParser: widget.wikiParser,
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class Page2 extends StatelessWidget {
  const Page2({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Page 2 Content'));
  }
}
