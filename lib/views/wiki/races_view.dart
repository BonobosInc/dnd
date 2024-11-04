import 'package:flutter/material.dart';
import 'package:dnd/classes/wiki_classes.dart';

class RaceDetailPage extends StatelessWidget {
  final RaceData raceData;

  const RaceDetailPage({super.key, required this.raceData});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(raceData.name),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              raceData.name,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text('Größe: ${raceData.size}'),
            Text('Bewegung: ${raceData.speed} ft'),
            Text('Fähigkeitspunkte-Verbesserung: ${raceData.ability}'),
            Text('Proficiencies: ${raceData.proficiency}'),
            Text('Zauberfähigkeit: ${raceData.spellAbility}'),
            const SizedBox(height: 10),
            const Text('Merkmale:',
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 5),
            ...raceData.traits.map((trait) {
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
