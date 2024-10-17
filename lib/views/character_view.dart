import 'package:dnd/classes/profile_manager.dart';
import 'package:flutter/material.dart';
import '../configs/defines.dart';
import '../configs/colours.dart';
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
          actions: [
            Builder(
              builder: (BuildContext context) {
                return IconButton(
                  icon: const Icon(Icons.menu),
                  onPressed: () {
                    Scaffold.of(context).openEndDrawer();
                  },
                );
              },
            ),
          ],
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
                              profileManager: profileManager)),
                    );
                  },
                ),
                ListTile(
                  title: const Text(
                    'Item 2',
                    style: TextStyle(color: AppColors.textColorLight),
                  ),
                  onTap: () {
                    Navigator.pop(context);
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
