import 'package:flutter/material.dart';
import 'package:dnd/classes/wiki_classes.dart';

class ClassDetailPage extends StatefulWidget {
  final ClassData classData;

  const ClassDetailPage({super.key, required this.classData});

  @override
  ClassDetailPageState createState() => ClassDetailPageState();
}

class ClassDetailPageState extends State<ClassDetailPage>
    with SingleTickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  final Map<String, bool> _expandedLevels = {};
  final Map<String, GlobalKey> _tileKeys = {};
  final GlobalKey _firstExpansionTileKey = GlobalKey();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Map<String, List<FeatureData>> featuresByLevel = {};

    for (var autolevel in widget.classData.autolevels) {
      if (featuresByLevel.containsKey(autolevel.level)) {
        featuresByLevel[autolevel.level]!.addAll(autolevel.features);
      } else {
        featuresByLevel[autolevel.level] = autolevel.features;
        _tileKeys[autolevel.level] = GlobalKey();
        _expandedLevels[autolevel.level] = false;
      }
    }

    bool hasNonZeroSlots = widget.classData.autolevels
        .any((autolevel) => autolevel.slots!.slots.any((slot) => slot > 0));

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.classData.name),
      ),
      body: SingleChildScrollView(
        controller: _scrollController,
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.classData.name,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text('Trefferwürfel: ${widget.classData.hd}'),
            Text('Fähigkeiten: ${widget.classData.proficiency}'),
            Text('Anzahl Skills: ${widget.classData.numSkills}'),
            const SizedBox(height: 10),

            // Conditional rendering of the ExpansionTile for Spell Slots
            if (hasNonZeroSlots)
              ExpansionTile(
                key: _firstExpansionTileKey,
                title: const Text('Zauberplätze'),
                children: [
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Table(
                      defaultColumnWidth: const IntrinsicColumnWidth(),
                      border: TableBorder.all(color: Colors.grey),
                      children: [
                        TableRow(
                          children: [
                            const TableCell(
                              child: Padding(
                                padding: EdgeInsets.all(4.0),
                                child: Text('Lvl',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold)),
                              ),
                            ),
                            ...List.generate(10, (index) {
                              return TableCell(
                                child: Padding(
                                  padding: const EdgeInsets.all(4.0),
                                  child: Text(
                                    '${index.toString()}  ',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              );
                            }),
                          ],
                        ),
                        ...List.generate(20, (level) {
                          String levelString = (level + 1).toString();
                          Autolevel? autolevel = widget.classData.autolevels
                              .firstWhere((auto) => auto.level == levelString,
                                  orElse: () => Autolevel(
                                        level: levelString,
                                        features: [],
                                        slots: Slots(slots: List.filled(10, 0)),
                                      ));

                          List<String> slots = autolevel.slots?.slots
                                  .map((slot) => slot.toString())
                                  .toList() ??
                              List.filled(10, '-');

                          while (slots.length < 10) {
                            slots.add('-');
                          }

                          return TableRow(
                            children: [
                              TableCell(
                                child: Padding(
                                  padding: const EdgeInsets.all(4.0),
                                  child: Text(
                                    'Lvl ${level + 1}',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                              ...List.generate(10, (slotIndex) {
                                return TableCell(
                                  child: Padding(
                                    padding: const EdgeInsets.all(4.0),
                                    child: Text(
                                      slots[slotIndex],
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                );
                              }),
                            ],
                          );
                        }),
                      ],
                    ),
                  ),
                ],
              ),

            // The rest of your features
            ...featuresByLevel.entries.map((entry) {
              String level = entry.key;
              List<FeatureData> features = entry.value;

              return StatefulBuilder(
                builder: (context, setState) {
                  return ExpansionTile(
                    key: _tileKeys[level],
                    title: Text('Level $level'),
                    initiallyExpanded: _expandedLevels[level] ?? false,
                    onExpansionChanged: (expanded) {
                      setState(() {
                        _expandedLevels[level] =
                            expanded; // Update the individual level's expanded state
                      });

                      // Scroll to the tile if expanded
                      if (expanded) {
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          Scrollable.ensureVisible(
                            _tileKeys[level]!.currentContext!,
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        });
                      }
                    },
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
                },
              );
            }),
          ],
        ),
      ),
    );
  }
}
