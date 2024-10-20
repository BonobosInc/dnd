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

  Autolevel({required this.level, required this.features});
}

class FeatureData {
  final String name;
  final String description;

  FeatureData({required this.name, required this.description});
}

class RaceData implements Nameable {
  @override
  final String name;

  RaceData({required this.name});
}

class BackgroundData implements Nameable {
  @override
  final String name;
  final String proficiency;
  final List<Trait> traits;

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

abstract class Nameable {
  String get name;
}