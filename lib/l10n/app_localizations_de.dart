// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get settings => 'Einstellungen';

  @override
  String get darkMode => 'Dunkelmodus';

  @override
  String get language => 'Sprache';

  @override
  String get close => 'Schließen';

  @override
  String get bonodnd => 'Für Bonobos, von Bonobos';

  @override
  String get equipments => 'Gegenstände/Ausrüstung';

  @override
  String get additem => 'Gegenstand hinzufügen';

  @override
  String get edititem => 'Gegenstand bearbeiten';

  @override
  String get item => 'Gegenstand';

  @override
  String get equipment => 'Ausrüstung';

  @override
  String get other => 'Sonstiges';

  @override
  String get gold => 'GM';

  @override
  String get silver => 'SM';

  @override
  String get copper => 'KM';

  @override
  String get platinum => 'PM';

  @override
  String get electrum => 'EM';

  @override
  String get amount => 'Menge';

  @override
  String get abort => 'Abbrechen';

  @override
  String get save => 'Speichern';

  @override
  String get nodescription => 'Keine Beschreibung vorhanden';

  @override
  String get description => 'Beschreibung';

  @override
  String get name => 'Name';

  @override
  String get confirmdelete => 'Löschen bestätigen';

  @override
  String get delete => 'Löschen';

  @override
  String confirmItemDelete(Object itemName) {
    return 'Bist du sicher, dass du \"$itemName\" löschen möchtest?';
  }

  @override
  String get type => 'Typ';

  @override
  String get unknownchar => 'Unbekannter Charakter';

  @override
  String get createnewchar => 'Neuen Charakter erstellen';

  @override
  String get importchar => 'Charakter aus Datei importieren';

  @override
  String get newchar => 'Neuer Charakter';

  @override
  String get entercharactername => 'Charakternamen eingeben';

  @override
  String get changeName => 'Charakter umbenennen';

  @override
  String get enternewname => 'Neuen Charakternamen eingeben';

  @override
  String get deletechar => 'Charakter löschen';

  @override
  String deletecharconfirm(Object profileName) {
    return 'Bist du sicher, dass du den Charakter \"$profileName\" löschen möchtest?';
  }

  @override
  String get rename => 'Umbenennen';

  @override
  String get saveto => 'Speichern unter';

  @override
  String characterExists(Object profileName) {
    return 'Der Charakter \"$profileName\" existiert bereits. Bitte wähle einen anderen Namen.';
  }

  @override
  String get create => 'Erstellen';

  @override
  String get level => 'Level';

  @override
  String get xp => 'XP';

  @override
  String get enterxpamount => 'Gib die Anzahl deiner XP ein';

  @override
  String get longrest => 'Lange Rast';

  @override
  String get shortrest => 'Kurze Rast';

  @override
  String get never => 'Niemals';

  @override
  String get longrestconfirm => 'Bist du sicher, dass du eine lange Rast machen möchtest?';

  @override
  String get shortrestconfirm => 'Bist du sicher, dass du eine kurze Rast machen möchtest?';

  @override
  String get yes => 'Ja';

  @override
  String get no => 'Nein';

  @override
  String get addimage => 'Bild hinzufügen';

  @override
  String get deleteimage => 'Bild entfernen';

  @override
  String get deleteimageconfirm => 'Bist du sicher, dass du das Bild entfernen möchtest?';

  @override
  String get spells => 'Zauber';

  @override
  String get weapons => 'Waffen';

  @override
  String get notes => 'Notizen';

  @override
  String get wiki => 'Wiki';

  @override
  String get newFeat => 'neues Merkmal';

  @override
  String get importfeatfromwiki => 'Merkmal aus Wiki importieren';

  @override
  String get editFeat => 'Merkmal bearbeiten';

  @override
  String get deleteFeat => 'Merkmal löschen';

  @override
  String get feats => 'Merkmale';

  @override
  String get feat => 'Merkmal';

  @override
  String get classKey => 'Klasse';

  @override
  String get classesKey => 'Klassen';

  @override
  String get race => 'Rasse';

  @override
  String get races => 'Rassen';

  @override
  String get background => 'Hintergrund';

  @override
  String get backgrounds => 'Hintergründe';

  @override
  String get abilities => 'Fähigkeiten';

  @override
  String get ability => 'Fähigkeit';

  @override
  String get talents => 'Talente';

  @override
  String get monster => 'Monster';

  @override
  String get folk => 'Volk';

  @override
  String get origin => 'Herkunft';

  @override
  String get age => 'Alter';

  @override
  String get sex => 'Geschlecht';

  @override
  String get height => 'Größe';

  @override
  String get weight => 'Gewicht';

  @override
  String get eyecolor => 'Augenfarbe';

  @override
  String get haircolor => 'Haarfarbe';

  @override
  String get skincolor => 'Hautfarbe';

  @override
  String get faith => 'Glaube/Gottheit';

  @override
  String get sizecat => 'Größenkategorie';

  @override
  String get size => 'Größe';

  @override
  String get alignment => 'Gesinnung';

  @override
  String get look => 'Aussehen';

  @override
  String get personalitytraits => 'Persönlichkeitsmerkmale';

  @override
  String get ideals => 'Ideale';

  @override
  String get bonds => 'Bindungen';

  @override
  String get flaws => 'Makel';

  @override
  String get backstory => 'Hintergrundgeschichte';

  @override
  String get otherNotes => 'Sonstige Notizen';

  @override
  String get armors => 'Rüstungen';

  @override
  String get tools => 'Werkzeuge';

  @override
  String get languages => 'Sprachen';

  @override
  String get cleardatabase => 'Datenbank leeren';

  @override
  String get cleardatabaseconfirm => 'Bist du sicher, dass du die Datenbank leeren möchtest? Alle Charaktere und Einstellungen gehen verloren.';

  @override
  String get exportgood => 'Export erfolgreich';

  @override
  String get exportbad => 'Export fehlgeschlagen';

  @override
  String get nosavelocation => 'Keine Speicherorte ausgewählt';

  @override
  String get exportedto => 'Exportiert nach';

  @override
  String get exportformat => 'Exportformat';

  @override
  String get noexportfilefound => 'Keine XML-Datei wurde zum Exportieren geladen.';

  @override
  String get onlyxmlallowed => 'Nur XML-Dateien sind erlaubt';

  @override
  String get importgood => 'Import erfolgreich';

  @override
  String get importbad => 'Import fehlgeschlagen';

  @override
  String get noimportfiles => 'Keine Datei zum importieren ausgewählt.';

  @override
  String get export => 'Exportieren';

  @override
  String get nocharfound => 'Kein Charakter vorhanden.';

  @override
  String get knownSpell => 'bekannter Zauber';

  @override
  String get preparedSpell => 'vorbereiteter Zauber';

  @override
  String get unknown => 'nicht bekannt';

  @override
  String get editspells => 'Zauber bearbeiten';

  @override
  String get editSpell => 'Zauber bearbeiten';

  @override
  String get deleteSpell => 'Zauber löschen';

  @override
  String get addSpell => 'Zauber hinzufügen';

  @override
  String get cantrip => 'Zaubertrick';

  @override
  String get reach => 'Reichweite';

  @override
  String get duration => 'Dauer';

  @override
  String get spellname => 'Zaubername';

  @override
  String get status => 'Status';

  @override
  String get spell => 'Zauber';

  @override
  String get spellattack => 'Zauberangriff';

  @override
  String get spelldc => 'Zauberrettungswurf-SG';

  @override
  String get spellclass => 'Zauberwirkende Klasse';

  @override
  String get spellcastingability => 'Zauberattrribut';

  @override
  String get spellslotsforlevel => 'Zauberplätze für Stufe';

  @override
  String get total => 'Gesamt';

  @override
  String get current => 'Aktuell';

  @override
  String get addweapon => 'Waffe hinzufügen';

  @override
  String get editweapon => 'Waffe bearbeiten';

  @override
  String get weapon => 'Waffe';

  @override
  String get damagetype => 'Schadenstyp';

  @override
  String get damage => 'Schaden';

  @override
  String get bonus => 'Bonus';

  @override
  String get attribute => 'Attribut';

  @override
  String get search => 'Suchen';

  @override
  String get importwiki => 'Wiki importieren';

  @override
  String get exportwiki => 'Wiki exportieren';

  @override
  String get deletewiki => 'Wiki löschen';

  @override
  String get noresultfound => 'Keine Ergebnisse gefunden';

  @override
  String get allspells => 'Alle Zauber';

  @override
  String get allmonster => 'Alle Monster';

  @override
  String get hitdice => 'Trefferwürfel';

  @override
  String get currenthitdice => 'Aktuelle Trefferwürfel';

  @override
  String get maxhitdice => 'Maximale Trefferwürfel';

  @override
  String get healfactor => 'Heilfaktor';

  @override
  String get numskills => 'Anzahl Skills';

  @override
  String get spellslots => 'Zauberplätze';

  @override
  String get sortbycr => 'Nach CR sortieren';

  @override
  String get sortbyname => 'Nach Name sortieren';

  @override
  String get filterandsort => 'Filtern und Sortieren';

  @override
  String get importselectedcompanion => 'Ausgewählten Begleiter importieren';

  @override
  String get createnewcompanion => 'Neuen Begleiter erstellen';

  @override
  String get editcompanion => 'Begleiter bearbeiten';

  @override
  String get addcompanion => 'Begleiter hinzufügen';

  @override
  String addcompanionConfirmation(Object creatureName) {
    return 'Möchtest du \"$creatureName\" hinzufügen?';
  }

  @override
  String get deletecompanion => 'Begleiter löschen';

  @override
  String get companion => 'Begleiter';

  @override
  String get ac => 'Rüstungsklasse';

  @override
  String get hp => 'Trefferpunkte';

  @override
  String get movement => 'Bewegungsrate';

  @override
  String get cr => 'Herausforderungsgrad';

  @override
  String get strength => 'Stärke';

  @override
  String get dexterity => 'Geschicklichkeit';

  @override
  String get constitution => 'Konstitution';

  @override
  String get intelligence => 'Intelligenz';

  @override
  String get wisdom => 'Weisheit';

  @override
  String get charisma => 'Charisma';

  @override
  String get initiative => 'Initiative';

  @override
  String get proficiencyBonus => 'ÜbungsBonus';

  @override
  String get savingThrows => 'Rettungswürfe';

  @override
  String get savingThrow => 'Rettungswurf';

  @override
  String get savingThrowfor => 'Rettungswurf für';

  @override
  String get skills => 'Fertigkeiten';

  @override
  String get skill => 'Fertigkeit';

  @override
  String get editskillfor => 'Bearbeite Fertigkeit für';

  @override
  String get resistances => 'Resistenzen';

  @override
  String get vulnerabilities => 'Verwundbarkeiten';

  @override
  String get immunities => 'Immunitäten';

  @override
  String get conditionImmunities => 'Zustandsimmunitäten';

  @override
  String get senses => 'Sinneswahrnehmungen';

  @override
  String get passivePerception => 'Passive Wahrnehmung';

  @override
  String get addtraits => 'Merkmale hinzufügen';

  @override
  String get action => 'Aktion';

  @override
  String get actions => 'Aktionen';

  @override
  String get addaction => 'Aktion hinzufügen';

  @override
  String get legendaryaction => 'Legendäre Aktion';

  @override
  String get addlegendaryaction => 'Legendäre Aktion hinzufügen';

  @override
  String get editlegendaryaction => 'Legendäre Aktion bearbeiten';

  @override
  String get editattack => 'Angriff bearbeiten';

  @override
  String get attack => 'Angriff';

  @override
  String get attackvalue => 'Angriffswert';

  @override
  String get requirement => 'Voraussetzung';

  @override
  String get modifier => 'Modifikator';

  @override
  String get abilityscoreincrease => 'Fähigkeitspunktsteigerung';

  @override
  String addTraitDialog(Object traitName) {
    return 'Merkmal \"$traitName\" erfolgreich hinzugefügt';
  }

  @override
  String get schoolTransmutation => 'Verwandlungszauber';

  @override
  String get schoolDivination => 'Weissagung';

  @override
  String get schoolEvocation => 'Hervorrufungszauber';

  @override
  String get schoolEnchantment => 'Verzauberungen';

  @override
  String get schoolConjuration => 'Beschwörung';

  @override
  String get schoolAbjuration => 'Bannmagie';

  @override
  String get schoolIllusion => 'Illusion';

  @override
  String get schoolNecromancy => 'Nekromantiezauber';

  @override
  String get schoolNone => 'Keine Schule';

  @override
  String get school => 'Schule';

  @override
  String get castingtime => 'Zauberzeit';

  @override
  String get range => 'Reichweite';

  @override
  String get components => 'Komponenten';

  @override
  String get ritual => 'Ritual';

  @override
  String get chooseclass => 'Klasse auswählen';

  @override
  String get conditionBlind => 'Blind';

  @override
  String get conditionRestrained => 'Festgesetzt';

  @override
  String get conditionStunned => 'Betäubt';

  @override
  String get conditionParalyzed => 'Gelähmt';

  @override
  String get conditionExhaustion => 'Erschöpfung';

  @override
  String get conditionPoisoned => 'Vergiftet';

  @override
  String get conditionFrightened => 'Verängstigt';

  @override
  String get conditionGrappled => 'Gepackt';

  @override
  String get conditionPetrified => 'Versteinert';

  @override
  String get conditionCharmed => 'Bezaubert';

  @override
  String get conditionDeafened => 'Taub';

  @override
  String get conditionUnconscious => 'Bewusstlos';

  @override
  String get conditionProne => 'Liegend';

  @override
  String get conditionIncapacitated => 'Kampfunfähig';

  @override
  String get conditionInvisible => 'Unsichtbar';

  @override
  String get value => 'Wert';

  @override
  String get hpfor => 'HP für';

  @override
  String get currenthp => 'Aktuelle HP';

  @override
  String get maxhp => 'Maximale HP';

  @override
  String get temphp => 'Temporäre HP';

  @override
  String get addtracker => 'Neuen Tracker erstellen';

  @override
  String get edittracker => 'Tracker bearbeiten';

  @override
  String get tracker => 'Tracker';

  @override
  String get trackers => 'Trackers';

  @override
  String get deletetracker => 'Tracker löschen';

  @override
  String get reset => 'Zurücksetzen';

  @override
  String get maximumvalue => 'Maximaler Wert';

  @override
  String get currentvalue => 'Aktueller Wert';

  @override
  String get entertrackername => 'Trackername eingeben';

  @override
  String get trackername => 'Trackername';

  @override
  String get addcondition => 'Zustand hinzufügen';

  @override
  String get choosecondition => 'Zustand auswählen';

  @override
  String get editcondition => 'Zustand bearbeiten';

  @override
  String get statistic => 'Statistik';

  @override
  String get inspiration => 'Inspiration';

  @override
  String get statuseffects => 'Status-Effekte';

  @override
  String get deletestatuseffect => 'Status-Effekt löschen';

  @override
  String get edit => 'Bearbeite';

  @override
  String get proficiency => 'Übung';

  @override
  String get expertise => 'Expertise';

  @override
  String get jack => 'Alleskönner';

  @override
  String get skillAcrobatics => 'Akrobatik';

  @override
  String get skillArcana => 'Arkane Kenntnis';

  @override
  String get skillAthletics => 'Athletik';

  @override
  String get skillPerformance => 'Auftreten';

  @override
  String get skillIntimidation => 'Einschüchtern';

  @override
  String get skillSleightOfHand => 'Fingerfertigkeit';

  @override
  String get skillHistory => 'Geschichte';

  @override
  String get skillMedicine => 'Heilkunde';

  @override
  String get skillStealth => 'Heimlichkeit';

  @override
  String get skillAnimalHandling => 'Mit Tieren umgehen';

  @override
  String get skillInsight => 'Motiv erkennen';

  @override
  String get skillInvestigation => 'Nachforschung';

  @override
  String get skillNature => 'Naturkunde';

  @override
  String get skillReligion => 'Religion';

  @override
  String get skillDeception => 'Täuschen';

  @override
  String get skillSurvival => 'Überlebenskunst';

  @override
  String get skillPersuasion => 'Überzeugen';

  @override
  String get skillPerception => 'Wahrnehmung';

  @override
  String get updateAvailableTitle => 'Aktualisierung verfügbar';

  @override
  String updateAvailableContent(Object latestVersion, Object currentVersion) {
    return 'Eine neue Version ($latestVersion) ist erhältlich. Du verwendest Version $currentVersion.';
  }

  @override
  String get skip => 'Überspringen';

  @override
  String get update => 'Aktualisieren';

  @override
  String get downloadingTitle => 'Herunterladen...';

  @override
  String get downloadingContent => 'Bitte warten, die neue Version wird heruntergeladen.';

  @override
  String get installPermissionTitle => 'Installation nicht erlaubt';

  @override
  String get installPermissionContent => 'Bitte erlaube dieser App die Installation von unbekannten Quellen in den Systemeinstellungen.';

  @override
  String get openSettings => 'Einstellungen öffnen';

  @override
  String get cancel => 'Abbrechen';

  @override
  String get updateFailedTitle => 'Aktualisierung fehlgeschlagen';

  @override
  String get updateFailedContent => 'Die Aktualisierung konnte nicht heruntergeladen oder installiert werden. Bitte versuche es später erneut.';

  @override
  String get ok => 'OK';

  @override
  String get attunement => 'Einstimmung';

  @override
  String get attunementLimit => 'Du kannst dich nur auf maximal 3 Gegenstände einstimmen.';

  @override
  String get attunementlimitReached => 'Einstimmungsgrenze erreicht.';
}
