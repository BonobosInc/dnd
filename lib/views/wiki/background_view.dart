import 'package:flutter/material.dart';
import 'package:dnd/classes/wiki_classes.dart';

class BackgroundDetailPage extends StatelessWidget {
  final BackgroundData backgroundData;

  const BackgroundDetailPage({super.key, required this.backgroundData});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(backgroundData.name),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              backgroundData.name,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text('Fähigkeiten: ${backgroundData.proficiency}'),
            const SizedBox(height: 10),
            const Text('Merkmale:',
                style: TextStyle(fontWeight: FontWeight.bold)),
            ...backgroundData.traits.map((trait) {
              return ListTile(
                title: Text(trait.name,
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(trait.description),
              );
            }),
          ],
        ),
      ),
    );
  }
}