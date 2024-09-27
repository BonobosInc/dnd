import 'package:flutter/material.dart';
import '../classes/profile_manager.dart';

class ProfileHomeScreen extends StatefulWidget {
  const ProfileHomeScreen({super.key});

  @override
  ProfileHomeScreenState createState() => ProfileHomeScreenState();
}

class ProfileHomeScreenState extends State<ProfileHomeScreen> {
  ProfileManager profileManager = ProfileManager();

  @override
  void initState() {
    super.initState();
    _initializeProfiles();
  }

  Future<void> _initializeProfiles() async {
    await profileManager.loadFolderPath();
    setState(() {});
  }

  Future<void> _promptFolderSelection() async {
    await profileManager.promptFolderSelection();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: profileManager.hasFolderPath()
            ? [
                IconButton(
                  icon: const Icon(Icons.folder_open),
                  onPressed: _promptFolderSelection,
                ),
              ]
            : null,
      ),
      body: Column(
        children: [
          if (!profileManager.hasFolderPath())
            Center(
              child: ElevatedButton(
                onPressed: _promptFolderSelection,
                child: const Text('Profilordner auswählen'),
              ),
            )
          else
            Expanded(
              child: profileManager.getProfiles().isEmpty
                  ? const Center(child: Text('No profiles found in the folder'))
                  : ListView.builder(
                      itemCount: profileManager.getProfiles().length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          title: Text(profileManager.getProfiles()[index]),
                          onTap: () {
                          },
                        );
                      },
                    ),
            ),
        ],
      ),
    );
  }
}
