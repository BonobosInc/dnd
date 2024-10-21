import 'package:flutter/material.dart';
import 'package:dnd/classes/wiki_classes.dart';

class FeatDetailPage extends StatelessWidget {
  final FeatData featData;

  const FeatDetailPage({super.key, required this.featData});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(featData.name),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              featData.name,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            if (featData.prerequisite != null && featData.prerequisite!.isNotEmpty)
              Text('Prerequisite: ${featData.prerequisite}'),
            const SizedBox(height: 10),
            const Text('Description:',
                style: TextStyle(fontWeight: FontWeight.bold)),
            Text(featData.text),
            const SizedBox(height: 10),
            if (featData.modifier != null && featData.modifier!.isNotEmpty)
              Text('Modifier: ${featData.modifier}'),
          ],
        ),
      ),
    );
  }
}
