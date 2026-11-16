import 'dart:math';
import 'package:flutter/foundation.dart';
import 'combat_session.dart';
import 'character.dart';
import 'event_session.dart';
import 'items.dart';
import 'quests.dart';
import 'flavor.dart';
import 'world.dart';
import 'hacking_session.dart';
import 'lockpick_session.dart';

enum GameMode { home, exploring, combat, hacking, lockpicking, event }

enum LogKind { system, narrative, loot, warning, danger, thought }

class LogLine {
  final String text;
  final LogKind kind;
  final int? pauseMs; // extra reading pause after this line (suspense beats)
  final bool silent; // no sound when typed (used for recap lines)
  VoidCallback? effect; // runs when the line finishes typing (e.g. awards scrap)
  LogLine(this.text, this.kind, {this.pauseMs, this.effect, this.silent = false});
}

class GameState extends ChangeNotifier {
  static const int maxLogLines = 200;

  int hp = 100;
  int maxHp = 100;
  int scrap = 40; // a little starting scrap
  double distanceKm = 0;
  String region = 'HOME';
  GameMode mode = GameMode.home;
  final List<LogLine> log = [];
  void Function(LogLine)? onLog; // set by the narrative log typewriter
  void Function(LogLine)? onConsole; // set by the encounter console typewriter
  VoidCallback? onConsoleReset;
  int textSpeed = 1; // 0 slow, 1 normal, 2 fast, 3 instant

  void cycleTextSpeed() {
    textSpeed = (textSpeed + 1) % 4;
    notifyListeners();
  }
  HackingSession? hacking;
  LockpickSession? lockpick;
  int lockpicks = 5;
  int stimpacks = 3;
  Set<String> owned = {'pipe'};
  String weaponId = 'pipe';
  String? armorId;
  int medLevel = 0; // Medical Station: stronger stimpacks
  int benchLevel = 0; // Scavenging Bench: more scrap from finds
  CombatSession? combat;
  double pickStrain = 0; // wear on the current pick; persists between locks

  bool get exploring => mode == GameMode.exploring;

  String get dangerLabel => regionAt(distanceKm).danger;

  // ---- quests and events
  List<QuestProgress> quests = [];
  Set<String> questsDone = {};
  EventSession? event;

  /// Randomly generated, repeatable jobs on the quest board.
  List<String> contracts = [];

  void refreshContracts({bool reroll = false}) {
    if (reroll) contracts.clear();
    final rng = Random();
    var guard = 0;
    while (contracts.length < 4 && guard++ < 40) {
      final id = makeContractId(rng, level);
      if (!contracts.contains(id) && !questActive(id)) contracts.add(id);
    }
  }

  bool questActive(String id) => quests.any((q) => q.id == id);

  bool acceptQuest(String id, {bool force = false}) {
    if (questActive(id) || questsDone.contains(id)) return false;
    if (!force && quests.length >= 3) return false;
    quests.add(QuestProgress(id));
    contracts.remove(id);
    addLog('> QUEST ACCEPTED: ${questById(id).title}', LogKind.system);
    return true;
  }

  /// Progress every matching quest. Callers notify afterwards.
  void questEvent(QuestKind kind, int n, {String? tag, bool absolute = false}) {
    for (final q in quests) {
      if (q.ready) continue;
      final d = questById(q.id);
      if (d.kind != kind) continue;
      if (d.tag != null && d.tag != tag) continue;
      q.progress = absolute ? max(q.progress, n) : q.progress + n;
      if (q.progress >= d.target) {
        q.progress = d.target;
        q.ready = true;
        addLog('> QUEST COMPLETE: ${d.title} (CLAIM AT SAFEHOUSE)', LogKind.loot,
            notify: false);
      }
    }
  }

  void claimQuest(String id) {
    final i = quests.indexWhere((q) => q.id == id);
    if (i < 0 || !quests[i].ready) return;
    final d = questById(id);
    quests.removeAt(i);
    if (!id.startsWith('c|')) questsDone.add(id); // contracts can come round again
    scrap += d.rewardScrap;
    stimpacks += d.rewardStims;
    lockpicks += d.rewardPicks;
    addLog('> QUEST CLAIMED: ${d.title}', LogKind.loot, notify: false);
    final reward = StringBuffer('+ ${d.rewardScrap} SCRAP');
    if (d.rewardStims > 0) reward.write('  + ${d.rewardStims} STIMPACK');
    if (d.rewardPicks > 0) reward.write('  + ${d.rewardPicks} LOCKPICK');
    addLog(reward.toString(), LogKind.loot, notify: false);
    gainXp(d.rewardXp);
    refreshContracts();
    notifyListeners();
  }

  // ---- character
  int level = 1;
  int xp = 0;
  int statPoints = 0;
  Map<String, int> stats = {for (final k in statKeys) k: 1};
  Map<String, int> skillLevel = {for (final k in skillKeys) k: 0};
  Map<String, int> skillXp = {for (final k in skillKeys) k: 0};

  int stat(String k) => stats[k] ?? 1;
  int skill(String k) => skillLevel[k] ?? 0;

  int get strBonus => stat('STR') - 1; // flat weapon damage
  double get critChance => 0.10 + 0.015 * (stat('LCK') - 1);
  double get evadeBonus => 0.02 * (stat('AGI') - 1); // enemies miss more
  int get hackAttempts => 4 + min(3, (stat('INT') - 1) ~/ 3);
  double get discoveryBonus => min(0.2, 0.02 * (stat('PER') - 1));
  double get scavengeMult =>
      1 + 0.04 * skill('SCAVENGING') + 0.03 * (stat('PER') - 1);

  /// Callers notify afterwards (they always end with another log or refresh).
  void gainXp(int n) {
    if (n <= 0) return;
    xp += n;
    addLog('+ $n XP', LogKind.loot, notify: false);
    while (xp >= xpForLevel(level)) {
      xp -= xpForLevel(level);
      level++;
      statPoints++;
      addLog('> LEVEL UP! YOU ARE NOW LEVEL $level. +1 STAT POINT (SPEND AT SAFEHOUSE)',
          LogKind.loot, notify: false);
      addLog(levelUpLines[Random().nextInt(levelUpLines.length)], LogKind.narrative,
          notify: false);
    }
  }

  void gainSkill(String k, [int n = 1]) {
    if (skill(k) >= maxSkill) return;
    skillXp[k] = (skillXp[k] ?? 0) + n;
    while (skill(k) < maxSkill && skillXp[k]! >= skillXpNeeded(skill(k))) {
      skillXp[k] = skillXp[k]! - skillXpNeeded(skill(k));
      skillLevel[k] = skill(k) + 1;
      addLog('> SKILL UP: $k LV ${skill(k)}', LogKind.loot, notify: false);
    }
  }

  void spendStat(String k) {
    if (statPoints <= 0 || stat(k) >= maxStat) return;
    stats[k] = stat(k) + 1;
    statPoints--;
    if (k == 'END') {
      maxHp += 10;
      hp += 10;
    }
    addLog('> ${statNames[k]} INCREASED TO ${stat(k)}', LogKind.loot);
  }

  // ---- crafting and equipment condition
  int parts = 0; // crafting materials
  int kits = 0; // repair kits
  int workshopLevel = 0; // Workshop upgrade: cheaper repairs
  Map<String, int> dura = {}; // durability per gear id (missing = 100)

  int durOf(String id) => dura[id] ?? 100;

  /// Weapons below 50 durability lose damage; a broken one does half.
  double get weaponCondition {
    final d = durOf(weaponId);
    if (d >= 50) return 1.0;
    if (d <= 0) return 0.5;
    return 0.7 + 0.3 * d / 50;
  }

  /// Armor protects less as it wears, and not at all once broken.
  double get armorCondition {
    final id = armorId;
    if (id == null) return 0;
    final d = durOf(id);
    return d >= 50 ? 1.0 : (d <= 0 ? 0.0 : d / 50);
  }

  /// Use wears gear down. Callers notify afterwards.
  void wear(String id, int n) {
    final before = durOf(id);
    final after = max(0, before - n);
    dura[id] = after;
    final name = gearById(id).name;
    if (after == 0 && before > 0) {
      addLog('> YOUR $name HAS BROKEN! REPAIR IT AT THE SAFEHOUSE.', LogKind.danger,
          notify: false);
    } else if (after <= 20 && before > 20) {
      addLog('(YOUR $name IS WEARING OUT)', LogKind.warning, notify: false);
    }
  }

  Gear get weapon => gearById(weaponId);
  int get armorValue =>
      armorId == null ? 0 : (gearById(armorId!).armor * armorCondition).floor();
  int get stimHeal => 35 + 10 * medLevel;

  /// Applies the Scavenging Bench bonus to a scrap reward.
  int withBench(int n) => (n * (1 + 0.1 * benchLevel)).round();

  /// Return to the safehouse. Ends any encounter and pauses exploration.
  void arriveHome({bool intro = false}) {
    mode = GameMode.home;
    walkingPaused = false;
    pending = null;
    region = 'SAFEHOUSE';
    refreshContracts();
    hacking = null;
    lockpick = null;
    combat = null;
    event = null;
    if (intro) {
      addLog('> SAFEHOUSE TERMINAL ONLINE', LogKind.system, notify: false);
      addLog('Dust sifts through the shutters. Stock up, then head out when ready.',
          LogKind.narrative);
    } else {
      addLog('> ARRIVED AT SAFEHOUSE', LogKind.system, notify: false);
      addLog(arrivalHome[Random().nextInt(arrivalHome.length)], LogKind.narrative);
    }
  }

  /// Back to a brand-new game (does not start the expedition).
  void reset() {
    hp = 100;
    maxHp = 100;
    scrap = 40;
    distanceKm = 0;
    region = 'HOME';
    mode = GameMode.home;
    lockpicks = 5;
    pickStrain = 0;
    hacking = null;
    lockpick = null;
    combat = null;
    stimpacks = 3;
    owned = {'pipe'};
    weaponId = 'pipe';
    armorId = null;
    medLevel = 0;
    benchLevel = 0;
    level = 1;
    xp = 0;
    statPoints = 0;
    stats = {for (final k in statKeys) k: 1};
    skillLevel = {for (final k in skillKeys) k: 0};
    skillXp = {for (final k in skillKeys) k: 0};
    quests = [];
    questsDone = {};
    event = null;
    parts = 0;
    kits = 0;
    workshopLevel = 0;
    dura = {};
    log.clear();
    console.clear();
    _recap.clear();
    walkingPaused = false;
    pending = null;
    contracts.clear();
  }

  Map<String, dynamic> toJson() {
    final start = log.length > 60 ? log.length - 60 : 0;
    return {
      'hp': hp,
      'maxHp': maxHp,
      'scrap': scrap,
      'distanceKm': distanceKm,
      'region': region,
      'mode': mode.name,
      'lockpicks': lockpicks,
      'pickStrain': pickStrain,
      'log': [for (final l in log.skip(start)) {'t': l.text, 'k': l.kind.name}],
      'hacking': hacking?.toJson(),
      'lockpick': lockpick?.toJson(),
      'stimpacks': stimpacks,
      'combat': combat?.toJson(),
      'owned': owned.toList(),
      'weapon': weaponId,
      'armor': armorId,
      'med': medLevel,
      'bench': benchLevel,
      'level': level,
      'xp': xp,
      'points': statPoints,
      'stats': stats,
      'skills': skillLevel,
      'skillXp': skillXp,
      'quests': [for (final q in quests) q.toJson()],
      'questsDone': questsDone.toList(),
      'event': event?.toJson(),
      'textSpeed': textSpeed,
      'parts': parts,
      'kits': kits,
      'workshop': workshopLevel,
      'dura': dura,
      'console': [
        for (final l in console.skip(console.length > 30 ? console.length - 30 : 0))
          {'t': l.text, 'k': l.kind.name}
      ],
      'paused': walkingPaused,
      'contracts': contracts,
    };
  }

  /// Parses everything first and assigns at the end, so a bad save can never
  /// leave the game half-loaded (the caller catches the exception).
  void loadJson(Map<String, dynamic> j) {
    final newHp = (j['hp'] as num).toInt();
    final newMaxHp = (j['maxHp'] as num).toInt();
    final newScrap = (j['scrap'] as num).toInt();
    final newDist = (j['distanceKm'] as num).toDouble();
    final newRegion = j['region'] as String;
    var newMode = GameMode.values.byName(j['mode'] as String);
    final newPicks = (j['lockpicks'] as num).toInt();
    final newStrain = (j['pickStrain'] as num).toDouble();
    final newLog = <LogLine>[];
    for (final e in (j['log'] as List)) {
      final m = e as Map;
      newLog.add(LogLine(m['t'] as String, LogKind.values.byName(m['k'] as String)));
    }
    final h = j['hacking'];
    final newHack =
        h == null ? null : HackingSession.fromJson(Map<String, dynamic>.from(h as Map));
    final l = j['lockpick'];
    final newLock =
        l == null ? null : LockpickSession.fromJson(Map<String, dynamic>.from(l as Map));

    final newStims = (j['stimpacks'] as num?)?.toInt() ?? 3; // older saves lack this
    final cj = j['combat'];
    final newCombat =
        cj == null ? null : CombatSession.fromJson(Map<String, dynamic>.from(cj as Map));

    // Gear and upgrades (older saves lack these, so everything has a default).
    final newOwned = <String>{...?(j['owned'] as List?)?.cast<String>(), 'pipe'}
        .where((id) => gearCatalog.any((g) => g.id == id))
        .toSet();
    final wId = (j['weapon'] as String?) ?? 'pipe';
    final newWeapon = gearCatalog.any((g) => g.id == wId && g.slot == GearSlot.weapon) &&
            newOwned.contains(wId)
        ? wId
        : 'pipe';
    final aId = j['armor'] as String?;
    final String? newArmor =
        aId != null && gearCatalog.any((g) => g.id == aId && g.slot == GearSlot.armor)
            ? aId
            : null;
    final newMed = (j['med'] as num?)?.toInt() ?? 0;
    final newBench = (j['bench'] as num?)?.toInt() ?? 0;

    // Character (older saves lack these: everything defaults to a fresh character).
    Map<String, int> readMap(dynamic raw, List<String> keys, int dflt) {
      final m = raw as Map?;
      return {for (final k in keys) k: (m?[k] as num?)?.toInt() ?? dflt};
    }

    final newLevel = (j['level'] as num?)?.toInt() ?? 1;
    final newXp = (j['xp'] as num?)?.toInt() ?? 0;
    final newPoints = (j['points'] as num?)?.toInt() ?? 0;
    final newStats = readMap(j['stats'], statKeys, 1);
    final newSkills = readMap(j['skills'], skillKeys, 0);
    final newSkillXp = readMap(j['skillXp'], skillKeys, 0);

    final newSpeed = min(3, max(0, (j['textSpeed'] as num?)?.toInt() ?? 1));
    final newConsole = <LogLine>[];
    for (final e in ((j['console'] as List?) ?? [])) {
      final m = e as Map;
      newConsole.add(LogLine(m['t'] as String, LogKind.values.byName(m['k'] as String),
          silent: true));
    }
    final newPaused = (j['paused'] as bool?) ?? false;
    final newContracts = <String>[
      ...((j['contracts'] as List?) ?? []).cast<String>(),
    ].where((c) => c.startsWith('c|')).toList();
    final newParts = (j['parts'] as num?)?.toInt() ?? 0;
    final newKits = (j['kits'] as num?)?.toInt() ?? 0;
    final newWorkshop = (j['workshop'] as num?)?.toInt() ?? 0;
    final newDura = <String, int>{};
    for (final e in ((j['dura'] as Map?) ?? {}).entries) {
      if (gearCatalog.any((g) => g.id == e.key)) {
        newDura[e.key as String] = min(100, max(0, (e.value as num).toInt()));
      }
    }

    // Quests and events (older saves lack these).
    final newQuests = <QuestProgress>[];
    for (final e in (j['quests'] as List? ?? [])) {
      final q = QuestProgress.fromJson(Map<String, dynamic>.from(e as Map));
      if (q.id.startsWith('c|') || questCatalog.any((d) => d.id == q.id)) newQuests.add(q);
    }
    final newDone = <String>{...?(j['questsDone'] as List?)?.cast<String>()};
    final evj = j['event'];
    final newEvent =
        evj == null ? null : EventSession.fromJson(Map<String, dynamic>.from(evj as Map));

    // Keep mode and sessions consistent.
    if (newMode == GameMode.hacking && newHack == null) newMode = GameMode.exploring;
    if (newMode == GameMode.lockpicking && newLock == null) newMode = GameMode.exploring;
    if (newMode == GameMode.combat && newCombat == null) newMode = GameMode.exploring;
    if (newMode == GameMode.event && newEvent == null) newMode = GameMode.exploring;

    hp = newHp;
    maxHp = newMaxHp;
    scrap = newScrap;
    distanceKm = newDist;
    region = newRegion;
    mode = newMode;
    lockpicks = newPicks;
    pickStrain = newStrain;
    hacking = newMode == GameMode.hacking ? newHack : null;
    lockpick = newMode == GameMode.lockpicking ? newLock : null;
    combat = newMode == GameMode.combat ? newCombat : null;
    stimpacks = newStims;
    owned = newOwned;
    weaponId = newWeapon;
    armorId = newArmor;
    medLevel = newMed;
    benchLevel = newBench;
    level = newLevel;
    xp = newXp;
    statPoints = newPoints;
    stats = newStats;
    skillLevel = newSkills;
    skillXp = newSkillXp;
    quests = newQuests;
    textSpeed = newSpeed;
    parts = newParts;
    console
      ..clear()
      ..addAll(newConsole);
    walkingPaused = newPaused;
    contracts = newContracts;
    if (contracts.isEmpty) refreshContracts();
    kits = newKits;
    workshopLevel = newWorkshop;
    dura = newDura;
    questsDone = newDone;
    event = newMode == GameMode.event ? newEvent : null;
    log
      ..clear()
      ..addAll(newLog);
    notifyListeners();
  }

  void beginExpedition() {
    mode = GameMode.exploring;
    walkingPaused = false;
    distanceKm = 0;
    region = 'DUSTY HIGHWAY';
    addLog('> EXPEDITION INITIATED', LogKind.system, notify: false);
    addLog('> LOCATION: $region', LogKind.system, notify: false);
    addLog('You step onto a cracked highway. Wind carries dust through the ruins.',
        LogKind.narrative);
  }

  // ---- narrative log vs. encounter console

  /// Text for the encounter on the main screen. It is typed there instead of
  /// in the narrative log, which stays quiet until the encounter is over.
  final List<LogLine> console = [];
  final List<LogLine> _recap = []; // results to recap in the log afterwards
  bool walkingPaused = false; // "Stop Walking" in the menu

  bool get inEncounter =>
      mode == GameMode.combat ||
      mode == GameMode.hacking ||
      mode == GameMode.lockpicking ||
      mode == GameMode.event;

  /// While an encounter is on the main screen, everything said goes to its
  /// console. Otherwise it goes to the narrative log.
  void addLog(String text, LogKind kind,
      {bool notify = true,
      int? pauseMs,
      VoidCallback? effect,
      bool silent = false,
      bool recap = true}) {
    // recap: false keeps a line in the encounter log only (it is not replayed
    // into the narrative log when the encounter ends).
    final line = LogLine(text, kind, pauseMs: pauseMs, effect: effect, silent: silent);
    final toConsole = inEncounter;
    if (toConsole) {
      console.add(line);
      if (!silent &&
          recap &&
          (kind == LogKind.loot ||
              text.startsWith('> LEVEL UP') ||
              text.startsWith('> QUEST'))) {
        _recap.add(LogLine(text, kind, silent: true));
      }
    } else {
      log.add(line);
      if (log.length > maxLogLines) log.removeAt(0);
    }
    final hook = toConsole ? onConsole : onLog;
    if (hook != null) {
      hook(line); // the typewriter queues it and runs the effect when revealed
    } else if (effect != null) {
      line.effect = null;
      effect(); // no typewriter attached: apply right away
    }
    if (notify) notifyListeners();
  }

  // ---- encounters wait for the player to press ENTER

  /// Set by the narrative log's heads-up line when an encounter is waiting.
  /// Pressing ENTER starts it.
  void Function()? pending;
  final ValueNotifier<bool> hasPending = ValueNotifier<bool>(false);

  /// True while the right-hand panel should be the Encounter Log (fights,
  /// choice encounters, and hacks once you choose to hack).
  final ValueNotifier<bool> encounterLog = ValueNotifier<bool>(false);

  bool get encounterLogShown =>
      mode == GameMode.combat ||
      mode == GameMode.event ||
      (mode == GameMode.hacking && (hacking?.engaged ?? false));

  void acknowledgeEncounter() {
    final start = pending;
    if (start == null) return;
    pending = null;
    notifyListeners();
    start();
  }

  @override
  void notifyListeners() {
    final shown = encounterLogShown;
    if (encounterLog.value != shown) encounterLog.value = shown;
    final waiting = pending != null;
    if (hasPending.value != waiting) hasPending.value = waiting;
    super.notifyListeners();
  }

  @override
  void dispose() {
    encounterLog.dispose();
    hasPending.dispose();
    super.dispose();
  }

  /// Start a fresh encounter console.
  void resetConsole() {
    console.clear();
    onConsoleReset?.call();
  }

  /// Call after the mode has left the encounter: clears the console and
  /// recaps anything gained (scrap, XP, quests) in the narrative log.
  /// Leave the encounter console. Nothing from it is replayed into the narrative
  /// log (the console already told the story); at most ONE short result line is
  /// added, e.g. "> LOCKPICK: SUCCESS".
  void endEncounter({String? summary, LogKind kind = LogKind.system}) {
    _recap.clear();
    console.clear();
    onConsoleReset?.call();
    if (summary != null) addLog(summary, kind, notify: false, silent: true);
  }

  void toggleWalking() {
    walkingPaused = !walkingPaused;
    addLog(
      walkingPaused
          ? 'You stop and take stock of your surroundings.'
          : 'You shoulder your pack and start walking again.',
      LogKind.narrative,
    );
  }

  void advance(double km) {
    distanceKm += km;
    notifyListeners();
  }

  void addScrap(int n) {
    scrap += n;
    questEvent(QuestKind.scrap, n);
    notifyListeners();
  }

  /// Lets other systems announce a change after mutating state.
  void refresh() => notifyListeners();

  void damage(int n) {
    // TODO(phase3/5): real death handling. For now HP floors at 1.
    hp = hp - n < 1 ? 1 : hp - n;
    notifyListeners();
  }

  void setRegion(String r) {
    region = r;
    notifyListeners();
  }
}
