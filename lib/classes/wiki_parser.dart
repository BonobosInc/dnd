import 'dart:isolate';
import 'package:xml/xml.dart' as xml;
import 'package:dnd/classes/wiki_classes.dart';

class WikiParser {
  static void parseXml(SendPort sendPort) {
    final port = ReceivePort();
    sendPort.send(port.sendPort);

    port.listen((message) {
      final xmlData = message[0] as String;
      final replyPort = message[1] as SendPort;

      final result = parseXmlData(xmlData);
      replyPort.send(result);
    });
  }

  static Map<String, List<dynamic>> parseXmlData(String xmlData) {
    final document = xml.XmlDocument.parse(xmlData);

    List<ClassData> classes = parseClasses(document);
    List<RaceData> races = parseRaces(document);
    List<BackgroundData> backgrounds = parseBackgrounds(document);
    List<FeatData> feats = parseFeats(document);
    List<SpellData> spells = parseSpells(document);

    return {
      'classes': classes,
      'races': races,
      'backgrounds': backgrounds,
      'feats': feats,
      'spells': spells,
    };
  }

  static List<ClassData> parseClasses(xml.XmlDocument document) {
    final classElements = document.findAllElements('class');

    return classElements.map((classElement) {
      final name = classElement.findElements('name').isNotEmpty
          ? classElement.findElements('name').first.innerText
          : 'Unknown';
      final hd = classElement.findElements('hd').isNotEmpty
          ? classElement.findElements('hd').first.innerText
          : 'Unknown';
      final proficiency = classElement.findElements('proficiency').isNotEmpty
          ? classElement.findElements('proficiency').first.innerText
          : 'Unknown';
      final numSkills = classElement.findElements('numSkills').isNotEmpty
          ? classElement.findElements('numSkills').first.innerText
          : 'Unknown';

      final autolevels =
          classElement.findAllElements('autolevel').map((levelElement) {
        final level = levelElement.getAttribute('level') ?? 'Unknown';

        final features =
            levelElement.findAllElements('feature').map((featureElement) {
          final featureName = featureElement.findElements('name').isNotEmpty
              ? featureElement.findElements('name').first.innerText
              : 'Unnamed Feature';
          final featureText = featureElement
              .findAllElements('text')
              .map((textElement) => textElement.innerText)
              .join('\n');
          return FeatureData(name: featureName, description: featureText);
        }).toList();

        return Autolevel(level: level, features: features);
      }).toList();

      return ClassData(
        name: name,
        hd: hd,
        proficiency: proficiency,
        numSkills: numSkills,
        autolevels: autolevels,
      );
    }).toList();
  }

  static List<RaceData> parseRaces(xml.XmlDocument document) {
    final raceElements = document.findAllElements('race');

    return raceElements.map((raceElement) {
      final name = raceElement.findElements('name').isNotEmpty
          ? raceElement.findElements('name').first.innerText
          : 'Unknown';

      final size = raceElement.findElements('size').isNotEmpty
          ? raceElement.findElements('size').first.innerText
          : 'Unknown';

      final speed = raceElement.findElements('speed').isNotEmpty
          ? int.tryParse(raceElement.findElements('speed').first.innerText) ?? 0
          : 0;

      final ability = raceElement.findElements('ability').isNotEmpty
          ? raceElement.findElements('ability').first.innerText
          : 'Unknown';

      final proficiency = raceElement.findElements('proficiency').isNotEmpty
          ? raceElement.findElements('proficiency').first.innerText
          : 'None';

      final spellAbility = raceElement.findElements('spellAbility').isNotEmpty
          ? raceElement.findElements('spellAbility').first.innerText
          : 'None';

      final traits = raceElement.findAllElements('trait').map((traitElement) {
        final traitName = traitElement.findElements('name').isNotEmpty
            ? traitElement.findElements('name').first.innerText
            : 'Unnamed Trait';
        final traitDescription = traitElement.findElements('text').isNotEmpty
            ? traitElement.findElements('text').first.innerText
            : 'No description available.';
        return Trait(name: traitName, description: traitDescription);
      }).toList();

      return RaceData(
        name: name,
        size: size,
        speed: speed,
        ability: ability,
        proficiency: proficiency,
        spellAbility: spellAbility,
        traits: traits,
      );
    }).toList();
  }

  static List<FeatData> parseFeats(xml.XmlDocument document) {
    final featElements = document.findAllElements('feat');

    return featElements.map((featElement) {
      final name = featElement.findElements('name').isNotEmpty
          ? featElement.findElements('name').first.innerText
          : 'Unknown';
      final prerequisite = featElement.findElements('prerequisite').isNotEmpty
          ? featElement.findElements('prerequisite').first.innerText
          : null;
      final text = featElement.findElements('text').isNotEmpty
          ? featElement.findElements('text').first.innerText
          : 'No description available.';
      final modifier = featElement.findElements('modifier').isNotEmpty
          ? featElement.findElements('modifier').first.innerText
          : null;

      return FeatData(
        name: name,
        prerequisite: prerequisite,
        text: text,
        modifier: modifier,
      );
    }).toList();
  }

  static List<BackgroundData> parseBackgrounds(xml.XmlDocument document) {
    final backgroundElements = document.findAllElements('background');

    return backgroundElements.map((backgroundElement) {
      final name = backgroundElement.findElements('name').isNotEmpty
          ? backgroundElement.findElements('name').first.innerText
          : 'Unknown';
      final proficiency =
          backgroundElement.findElements('proficiency').isNotEmpty
              ? backgroundElement.findElements('proficiency').first.innerText
              : 'Unknown';

      final traits =
          backgroundElement.findAllElements('trait').map((traitElement) {
        final traitName = traitElement.findElements('name').isNotEmpty
            ? traitElement.findElements('name').first.innerText
            : 'Unnamed Trait';
        final traitDescription = traitElement.findElements('text').isNotEmpty
            ? traitElement.findElements('text').first.innerText
            : 'No description available.';
        return Trait(name: traitName, description: traitDescription);
      }).toList();

      return BackgroundData(
        name: name,
        proficiency: proficiency,
        traits: traits,
      );
    }).toList();
  }

  static List<SpellData> parseSpells(xml.XmlDocument document) {
    final spellElements = document.findAllElements('spell');

    return spellElements.map((spellElement) {
      final name = spellElement.findElements('name').isNotEmpty
          ? spellElement.findElements('name').first.innerText
          : 'Unknown';
      final spellclasses = spellElement.findElements('classes').isNotEmpty
          ? spellElement.findElements('classes').first.innerText.split(', ')
          : [];
      final level = spellElement.findElements('level').isNotEmpty
          ? spellElement.findElements('level').first.innerText
          : 'Unknown';
      final school = spellElement.findElements('school').isNotEmpty
          ? spellElement.findElements('school').first.innerText
          : 'Unknown';
      final ritual = spellElement.findElements('ritual').isNotEmpty
          ? spellElement.findElements('ritual').first.innerText
          : 'Unknown';
      final time = spellElement.findElements('time').isNotEmpty
          ? spellElement.findElements('time').first.innerText
          : 'Unknown';
      final range = spellElement.findElements('range').isNotEmpty
          ? spellElement.findElements('range').first.innerText
          : 'Unknown';
      final components = spellElement.findElements('components').isNotEmpty
          ? spellElement.findElements('components').first.innerText
          : 'Unknown';
      final duration = spellElement.findElements('duration').isNotEmpty
          ? spellElement.findElements('duration').first.innerText
          : 'Unknown';
      final text = spellElement.findElements('text').isNotEmpty
          ? spellElement.findElements('text').first.innerText
          : 'No description available.';

      return SpellData(
        name: name,
        classes: spellclasses as List<String>,
        level: level,
        school: school,
        ritual: ritual,
        time: time,
        range: range,
        components: components,
        duration: duration,
        text: text,
      );
    }).toList();
  }
}
