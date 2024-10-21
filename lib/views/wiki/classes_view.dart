import 'package:flutter/material.dart';
import 'package:dnd/classes/wiki_classes.dart';

class ClassDetailPage extends StatelessWidget {
  final ClassData classData;

  const ClassDetailPage({super.key, required this.classData});

  @override
  Widget build(BuildContext context) {
    Map<String, List<FeatureData>> featuresByLevel = {};
    
    for (var autolevel in classData.autolevels) {
      if (featuresByLevel.containsKey(autolevel.level)) {
        featuresByLevel[autolevel.level]!.addAll(autolevel.features);
      } else {
        featuresByLevel[autolevel.level] = autolevel.features;
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(classData.name),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              classData.name,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text('Hit Dice: ${classData.hd}'),
            Text('Proficiencies: ${classData.proficiency}'),
            Text('Number of Skills: ${classData.numSkills}'),
            const SizedBox(height: 10),
            const Text('Features by Level:',
                style: TextStyle(fontWeight: FontWeight.bold)),
            ...featuresByLevel.entries.map((entry) {
              String level = entry.key;
              List<FeatureData> features = entry.value;

              return ExpansionTile(
                title: Text('Level $level'),
                children: features.map((feature) {
                  return ListTile(
                    title: Text(
                      feature.name,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(feature.description),
                  );
                }).toList(),
              );
            }),
          ],
        ),
      ),
    );
  }
}
