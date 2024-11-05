class ClassData implements Nameable {
  @override
  final String name;
  final String hd;
  final String proficiency;
  final String numSkills;
  final List<Autolevel> autolevels;

  ClassData({
    required this.name,
    required this.hd,
    required this.proficiency,
    required this.numSkills,
    required this.autolevels,
  });
}

class Autolevel {
  final String level;
  final List<FeatureData> features;
  final Slots? slots;

  Autolevel({required this.level, required this.features, this.slots});
}

class Slots {
  final List<int> slots;

  Slots({required this.slots});
}

class FeatureData {
  final String name;
  final String description;
  String? type;

  FeatureData({
    required this.name,
    required this.description,
    this.type,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is FeatureData &&
        name == other.name &&
        description == other.description;
  }

  @override
  int get hashCode => name.hashCode ^ description.hashCode;
}

class RaceData implements Nameable {
  @override
  final String name;
  final String size;
  final int speed;
  final String ability;
  final String proficiency;
  final String spellAbility;
  final List<FeatureData> traits;

  RaceData({
    required this.name,
    required this.size,
    required this.speed,
    required this.ability,
    required this.proficiency,
    required this.spellAbility,
    required this.traits,
  });
}

class BackgroundData implements Nameable {
  @override
  final String name;
  final String proficiency;
  final List<FeatureData> traits;

  BackgroundData({
    required this.name,
    required this.proficiency,
    required this.traits,
  });
}

class Trait {
  final String name;
  final String description;

  Trait({required this.name, required this.description});
}

class FeatData implements Nameable {
  @override
  final String name;
  final String? prerequisite;
  final String text;
  final String? modifier;

  FeatData({
    required this.name,
    this.prerequisite,
    required this.text,
    this.modifier,
  });
}

class SpellData implements Nameable {
  @override
  final String name;
  final List<String> classes;
  final String level;
  final String school;
  final String ritual;
  final String time;
  final String range;
  final String components;
  final String duration;
  final String text;

  SpellData({
    required this.name,
    required this.classes,
    required this.level,
    required this.school,
    required this.ritual,
    required this.time,
    required this.range,
    required this.components,
    required this.duration,
    required this.text,
  });
}

abstract class Nameable {
  String get name;
}
