import 'package:dnd/classes/profile_manager.dart';
import 'package:dnd/views/bag_view.dart';
import 'package:dnd/views/notes_view.dart';
import 'package:flutter/material.dart';
import 'package:dnd/configs/defines.dart';
import 'package:dnd/configs/colours.dart';
import 'spell_view.dart';

class CharacterView extends StatelessWidget {
  final ProfileManager profileManager;

  const CharacterView({
    super.key,
    required this.profileManager,
  });

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvokedWithResult: (bool didPop, Object? result) {
        if (didPop) {
          profileManager.closeDB();
          return;
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Character View'),
          backgroundColor: AppColors.appBarColor,
        ),
        body: const Center(
          child: Text('Using database for profile.'),
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
                          profileManager: profileManager,
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
                          profileManager: profileManager,
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
                          profileManager: profileManager,
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
    );
  }
}
