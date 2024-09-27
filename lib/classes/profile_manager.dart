import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:file_picker/file_picker.dart';

class ProfileManager {
  String? folderPath;
  List<String> profiles = [];

  Future<void> loadFolderPath() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    folderPath = prefs.getString('profile_folder_path');
    if (folderPath != null) {
      await loadProfiles();
    }
  }

  Future<void> promptFolderSelection() async {
    String? selectedFolder = await FilePicker.platform.getDirectoryPath();
    if (selectedFolder != null) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('profile_folder_path', selectedFolder);
      folderPath = selectedFolder;
      await loadProfiles();
    }
  }

  Future<void> loadProfiles() async {
    if (folderPath == null) return;

    final directory = Directory(folderPath!);
    final jsonFiles = directory
        .listSync()
        .where((file) => file is File && file.path.endsWith('.json'))
        .toList();

    profiles = jsonFiles.map((file) => file.path.split('/').last).toList();
  }

  bool hasFolderPath() {
    return folderPath != null;
  }

  List<String> getProfiles() {
    return profiles;
  }
}
