import 'package:flutter/material.dart';
import 'package:dnd/main.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Einstellungen"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Dark Mode",
                  style: TextStyle(fontSize: 18.0),
                ),
                ValueListenableBuilder<bool>(
                  valueListenable: isDarkMode,
                  builder: (context, value, child) {
                    return Switch(
                      value: value,
                      onChanged: (bool newValue) {
                        isDarkMode.value = newValue;
                      },
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
