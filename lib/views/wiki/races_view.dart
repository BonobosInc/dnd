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
      body: Center(
        child: Text('Details about ${raceData.name} coming soon!'),
      ),
    );
  }
}
