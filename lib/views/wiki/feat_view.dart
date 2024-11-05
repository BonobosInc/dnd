import 'package:flutter/material.dart';
import 'package:dnd/classes/wiki_classes.dart';

class FeatDetailPage extends StatelessWidget {
  final FeatData featData;
  final bool importFeat;

  const FeatDetailPage({super.key, required this.featData, this.importFeat = false});

  FeatureData _convertToFeatureData(FeatData feat) {
    return FeatureData(
      name: feat.name,
      description: feat.text,
      type: "Fähigkeiten",
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(featData.name),
        actions: importFeat
            ? [
                IconButton(
                  icon: const Icon(Icons.check),
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).pop(_convertToFeatureData(featData));
                  },
                ),
              ]
            : null,
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
              Text('Voraussetzung: ${featData.prerequisite}'),
            const SizedBox(height: 10),
            const Text(
              'Beschreibung:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(featData.text),
            const SizedBox(height: 10),
            if (featData.modifier != null && featData.modifier!.isNotEmpty)
              Text('Modifikator: ${featData.modifier}'),
          ],
        ),
      ),
    );
  }
}
