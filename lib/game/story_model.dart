import 'combat_session.dart';

/// Story text builder. It receives what the story remembers, so lines can react
/// to earlier discoveries, decisions, skills and other finished stories.
///
/// Line prefixes: none = narration, `~` = the scavenger's thought,
/// `#` = radio / terminal text, `!` = danger, `%` = warning.
/// A trailing `|` adds a long suspense pause after the line.
typedef Lines = List<String> Function(StoryCtx c);

/// Wraps fixed text as a [Lines] builder.
Lines say(List<String> lines) => (StoryCtx c) => lines;

/// Things a scene or checkpoint hands out. Each reward is paid once, ever
/// (see [StoryBook.paid]), so abandoning and restarting cannot farm it.
class Reward {
  final int scrap, xp, stims, picks, parts, hp; // hp < 0 is damage
  final String? gearId;
  const Reward({
    this.scrap = 0,
    this.xp = 0,
    this.stims = 0,
    this.picks = 0,
    this.parts = 0,
    this.hp = 0,
    this.gearId,
  });
}

/// A read-only snapshot handed to text builders and conditions.
class StoryCtx {
  final StoryRun run;
  final StoryBook book;
  final int level, hp, maxHp, scrap;
  final double km;
  final String region;
  final Map<String, int> skills;
  final Set<String> quests; // ids of active and finished quests

  const StoryCtx({
    required this.run,
    required this.book,
    required this.level,
    required this.km,
    required this.hp,
    required this.maxHp,
    required this.scrap,
    required this.region,
    required this.skills,
    required this.quests,
  });

  bool flag(String f) => run.flags.contains(f);
  bool world(String f) => book.world.contains(f);
  bool done(String cp) => run.done.contains(cp);
  int skill(String k) => skills[k] ?? 0;
  bool hasQuest(String id) => quests.contains(id);
  bool get lowHp => hp < maxHp * 0.4;

  /// How another story ended (null if it has not been finished).
  String? ending(String storyId) => book.completed[storyId];
}

class Choice {
  final String label, next;
  final bool Function(StoryCtx c)? show; // hidden when it returns false
  final int needScrap, needStim, needPick, needParts; // spent when chosen
  final List<String> flags; // remembered when chosen
  Choice(
    this.label,
    this.next, {
    this.show,
    this.needScrap = 0,
    this.needStim = 0,
    this.needPick = 0,
    this.needParts = 0,
    this.flags = const [],
  });
}

enum SceneKind { choice, end, hack, lock, fight }

/// One beat of a checkpoint. Scenes form a small graph: choices lead to other
/// scenes, minigame scenes branch on how the minigame went, and `end` scenes
/// finish the checkpoint.
class Scene {
  final String id;
  final SceneKind kind;
  final Lines text;
  final List<Choice> choices;
  final List<String> flags; // remembered on entering
  final Reward? reward; // paid once, on entering
  final EnemyType? enemy;
  final String? onWin, onFail; // minigame branches
  final String? ending; // an `end` scene that finishes the whole story

  Scene._(this.id, this.kind, this.text,
      {this.choices = const [],
      this.flags = const [],
      this.reward,
      this.enemy,
      this.onWin,
      this.onFail,
      this.ending});

  factory Scene.talk(String id, Lines text, List<Choice> choices,
          {List<String> flags = const [], Reward? reward}) =>
      Scene._(id, SceneKind.choice, text, choices: choices, flags: flags, reward: reward);

  factory Scene.end(String id, Lines text,
          {List<String> flags = const [], Reward? reward, String? ending}) =>
      Scene._(id, SceneKind.end, text, flags: flags, reward: reward, ending: ending);

  factory Scene.hack(String id, Lines text,
          {required String win,
          required String fail,
          List<String> flags = const [],
          Reward? reward}) =>
      Scene._(id, SceneKind.hack, text,
          onWin: win, onFail: fail, flags: flags, reward: reward);

  factory Scene.lock(String id, Lines text,
          {required String win,
          required String fail,
          List<String> flags = const [],
          Reward? reward}) =>
      Scene._(id, SceneKind.lock, text,
          onWin: win, onFail: fail, flags: flags, reward: reward);

  factory Scene.fight(String id, Lines text, EnemyType enemy,
          {required String win,
          required String fail,
          List<String> flags = const [],
          Reward? reward}) =>
      Scene._(id, SceneKind.fight, text,
          enemy: enemy, onWin: win, onFail: fail, flags: flags, reward: reward);
}

class Checkpoint {
  final String id, title, art, start;
  final double km;
  final bool interactive; // false = a quiet discovery told in the log
  final Map<String, Scene> sceneMap;
  final Lines journal; // what the Journal remembers
  final Reward? reward; // paid once when the checkpoint is completed

  Checkpoint({
    required this.id,
    required this.title,
    required this.km,
    required this.start,
    required List<Scene> scenes,
    required this.journal,
    this.art = 'building',
    this.reward,
    this.interactive = true,
  }) : sceneMap = {for (final s in scenes) s.id: s};

  /// A discovery that needs no decision: told in the narrative log.
  factory Checkpoint.auto({
    required String id,
    required String title,
    required double km,
    required Lines text,
    required Lines journal,
    List<String> flags = const [],
    Reward? reward,
  }) =>
      Checkpoint(
        id: id,
        title: title,
        km: km,
        start: 'a',
        scenes: [Scene.end('a', text, flags: flags)],
        journal: journal,
        reward: reward,
        interactive: false,
      );
}

class Ending {
  final String id, title, summary;
  final Reward? bonus;
  final List<String> world; // facts later stories can refer to
  const Ending(this.id, this.title, this.summary, {this.bonus, this.world = const []});
}

/// Short lines that colour the walk while a story is active.
class Ambient {
  final String text;
  final double minKm, maxKm;
  final bool Function(StoryCtx c)? when;
  Ambient(this.text, {this.minKm = 0, this.maxKm = 999, this.when});
}

class Unlock {
  final int minLevel;
  final List<String> allDone, anyDone;
  final String? world;
  final double reachedKm;
  final String hint;
  const Unlock({
    this.minLevel = 1,
    this.allDone = const [],
    this.anyDone = const [],
    this.world,
    this.reachedKm = 0,
    this.hint = '',
  });

  bool met(int level, StoryBook b) {
    if (level < minLevel) return false;
    for (final id in allDone) {
      if (!b.completed.containsKey(id)) return false;
    }
    if (anyDone.isNotEmpty && !anyDone.any(b.completed.containsKey)) return false;
    if (world != null && !b.world.contains(world)) return false;
    if (b.farthest < reachedKm) return false;
    return true;
  }
}

/// How big a story is. Major expeditions are long multi-checkpoint journeys,
/// medium stories have a beginning, escalation and conclusion, and short
/// stories are side encounters of one or two checkpoints.
enum StoryScale { major, medium, short }

String storyScaleLabel(StoryScale s) {
  switch (s) {
    case StoryScale.major:
      return 'MAJOR EXPEDITION';
    case StoryScale.medium:
      return 'MEDIUM STORY';
    case StoryScale.short:
      return 'SHORT ENCOUNTER';
  }
}

class StoryDef {
  final String id, title, tagline, difficulty;
  final StoryScale scale;
  final List<String> intro;
  final double destinationKm;
  final int recommendedLevel;
  final Unlock unlock;
  final List<Checkpoint> checkpoints;
  final Reward reward;
  final Map<String, Ending> endings;
  final List<Ambient> ambient;
  final Lines depart; // narration when leaving the safehouse (first time or resuming)

  const StoryDef({
    required this.id,
    required this.title,
    required this.tagline,
    required this.difficulty,
    required this.intro,
    required this.destinationKm,
    required this.recommendedLevel,
    required this.checkpoints,
    required this.reward,
    required this.endings,
    required this.ambient,
    required this.depart,
    this.unlock = const Unlock(),
    this.scale = StoryScale.major,
  });
}

// ------------------------------------------------------------ persistence

class JournalEntry {
  final String cp, title, text;
  const JournalEntry(this.cp, this.title, this.text);
  Map<String, dynamic> toJson() => {'cp': cp, 'title': title, 'text': text};
  factory JournalEntry.fromJson(Map<String, dynamic> j) => JournalEntry(
      (j['cp'] as String?) ?? '', (j['title'] as String?) ?? '', (j['text'] as String?) ?? '');
}

/// Everything remembered about one Story Expedition.
class StoryRun {
  final String id;
  double km = 0; // saved distance; mirrors GameState.distanceKm while out
  final Set<String> done = {};
  final Set<String> flags = {};
  final Map<String, String> choices = {};
  final List<JournalEntry> journal = [];
  String? openCp; // a checkpoint being played
  String openScene = '';
  bool awaiting = false; // a minigame started by a scene is running
  bool announced = false; // not saved: the ENTER prompt is on its way

  StoryRun(this.id);

  Map<String, dynamic> toJson() => {
        'id': id,
        'km': km,
        'done': done.toList(),
        'flags': flags.toList(),
        'choices': choices,
        'journal': [for (final e in journal) e.toJson()],
        'open': openCp,
        'scene': openScene,
        'awaiting': awaiting,
      };

  factory StoryRun.fromJson(Map<String, dynamic> j) {
    final r = StoryRun(j['id'] as String);
    r.km = ((j['km'] as num?) ?? 0).toDouble();
    r.done.addAll(((j['done'] as List?) ?? const []).cast<String>());
    r.flags.addAll(((j['flags'] as List?) ?? const []).cast<String>());
    final ch = j['choices'] as Map?;
    if (ch != null) {
      for (final e in ch.entries) {
        r.choices['${e.key}'] = '${e.value}';
      }
    }
    for (final e in ((j['journal'] as List?) ?? const [])) {
      r.journal.add(JournalEntry.fromJson(Map<String, dynamic>.from(e as Map)));
    }
    r.openCp = j['open'] as String?;
    r.openScene = (j['scene'] as String?) ?? '';
    r.awaiting = (j['awaiting'] as bool?) ?? false;
    return r;
  }
}

/// All Story Expedition state: the active one, every run (so finished stories
/// keep their journal), how each finished, and facts carried between stories.
class StoryBook {
  StoryBook();

  String? activeId;
  final Map<String, StoryRun> runs = {};
  final Map<String, String> completed = {}; // story id -> ending id
  final Set<String> world = {};
  final Set<String> paid = {}; // reward keys already handed out
  double farthest = 0; // furthest distance ever reached (unlocks)

  StoryRun? get activeRun => activeId == null ? null : runs[activeId];

  /// Keeps the saved distance in step with the live one.
  void syncKm(double km) {
    final r = activeRun;
    if (r != null) r.km = km;
    if (km > farthest) farthest = km;
  }

  /// Leaving the wilderness: remember exactly where we were.
  void pauseAt(double km) {
    syncKm(km);
    activeRun?.announced = false;
  }

  void clear() {
    activeId = null;
    runs.clear();
    completed.clear();
    world.clear();
    paid.clear();
    farthest = 0;
  }

  void assign(StoryBook o) {
    activeId = o.activeId;
    runs
      ..clear()
      ..addAll(o.runs);
    completed
      ..clear()
      ..addAll(o.completed);
    world
      ..clear()
      ..addAll(o.world);
    paid
      ..clear()
      ..addAll(o.paid);
    farthest = o.farthest;
  }

  /// Drops anything whose story no longer exists (so old content can't crash a load).
  void prune(bool Function(String id) exists) {
    runs.removeWhere((id, _) => !exists(id));
    completed.removeWhere((id, _) => !exists(id));
    if (activeId != null && !runs.containsKey(activeId)) activeId = null;
  }

  Map<String, dynamic> toJson() => {
        'active': activeId,
        'runs': {for (final e in runs.entries) e.key: e.value.toJson()},
        'completed': completed,
        'world': world.toList(),
        'paid': paid.toList(),
        'farthest': farthest,
      };

  /// A missing or damaged section simply means "no stories yet" (old saves).
  factory StoryBook.fromJson(Map<String, dynamic>? j) {
    final b = StoryBook();
    if (j == null) return b;
    final runs = j['runs'] as Map?;
    if (runs != null) {
      for (final e in runs.entries) {
        final r = StoryRun.fromJson(Map<String, dynamic>.from(e.value as Map));
        b.runs[r.id] = r;
      }
    }
    final comp = j['completed'] as Map?;
    if (comp != null) {
      for (final e in comp.entries) {
        b.completed['${e.key}'] = '${e.value}';
      }
    }
    b.world.addAll(((j['world'] as List?) ?? const []).cast<String>());
    b.paid.addAll(((j['paid'] as List?) ?? const []).cast<String>());
    b.farthest = ((j['farthest'] as num?) ?? 0).toDouble();
    final a = j['active'] as String?;
    b.activeId = (a != null && b.runs.containsKey(a) && !b.completed.containsKey(a)) ? a : null;
    return b;
  }
}
