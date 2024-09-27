import 'package:dnd/classes/profile_manager.dart';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';

class CharacterView extends StatelessWidget {
  final Database? currentDb;
  final ProfileManager profileManager;

  const CharacterView({
    super.key,
    required this.currentDb,
    required this.profileManager,
  });

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvokedWithResult: (bool didPop, Object? result) {
              if (didPop) {
                profileManager.closeProfile();
                return;
              }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Character View'),
        ),
        body: const Center(
          child: Text('Using database for profile.'),
        ),
      ),
    );
  }
}
