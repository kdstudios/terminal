import 'dart:math';

enum EnemyType {
  skitter, hound, sentry, raider, crawler, brute, lurker, warmachine,
  swarm, spitter, colossus, captain, straggler, wyrm,
}

enum CombatOutcome { none, won, fled, died }

/// Something the combat stage should animate. The system appends these as a
/// round resolves; the stage drains them and plays them back in order.
enum CombatFxKind { shot, heavy, miss, defend, heal, enemyHit, enemyMiss, enemyCharge, enemyCover }

class CombatFx {
  final CombatFxKind kind;
  final int amount; // damage / healing
  final bool crit; // player critical, or an enemy's charged attack
  final bool blocked; // enemyHit while the player was defending
  final double delay; // seconds the stage waits before playing it (set by the log's typing)
  const CombatFx(this.kind,
      {this.amount = 0, this.crit = false, this.blocked = false, this.delay = 0});

  CombatFx delayed(double d) =>
      CombatFx(kind, amount: amount, crit: crit, blocked: blocked, delay: d);

  /// Seconds from the start of the animation to its IMPACT (when the number shows).
  /// Mirrors the stage's timeline: shot 0.62s * .31, heavy 0.9s * .31, enemy hit 0.75s * .32.
  static double impactSeconds(CombatFxKind k) {
    switch (k) {
      case CombatFxKind.shot:
        return 0.19;
      case CombatFxKind.heavy:
        return 0.28;
      case CombatFxKind.enemyHit:
        return 0.24;
      default:
        return 0;
    }
  }
}

/// Data for one enemy kind. Behaviour comes from a few numbers:
/// chargeChance (telegraphed double hit), coverChance (ducks, halving your next
/// hit), strikes (attacks per turn) and ambush (may strike first). hitLines and
/// dieLines give each enemy its own narration.
class EnemyTemplate {
  final String name, short, verb, flavor, chargeText;
  final int hp, atkMin, atkMax, armor, xp, strikes;
  final double hitChance, escapeMod, scrapMult, chargeChance, coverChance;
  final bool ambush;
  final List<String> hitLines, dieLines;
  const EnemyTemplate({
    required this.name,
    required this.short,
    required this.verb,
    required this.flavor,
    required this.hp,
    required this.atkMin,
    required this.atkMax,
    required this.armor,
    required this.hitChance,
    required this.escapeMod,
    required this.scrapMult,
    required this.xp,
    this.chargeText = 'gathers itself for a crushing blow',
    this.chargeChance = 0,
    this.coverChance = 0,
    this.strikes = 1,
    this.ambush = false,
    this.hitLines = const [],
    this.dieLines = const [],
  });
}

const enemyTemplates = <EnemyType, EnemyTemplate>{
  EnemyType.skitter: EnemyTemplate(
    name: 'SCRAP SKITTER', short: 'skitter', verb: 'claws',
    flavor: 'A chittering mass of scrap-plated limbs scuttles out of the wreckage.',
    hp: 28, atkMin: 3, atkMax: 6, armor: 0,
    hitChance: 0.85, escapeMod: 1.4, scrapMult: 0.8, xp: 12,
    hitLines: [
      'The skitter scrabbles up your leg and rakes at you with serrated limbs.',
      'A scrap-plated claw snags your sleeve and drags across your arm.',
      'It leaps, all clatter and rust, and sinks its mandibles into you.',
    ],
    dieLines: [
      'The skitter folds in on itself with a sound like a dropped toolbox.',
      'Its legs spasm once, twice, and stop. Quiet returns to the ruins.',
    ],
  ),
  EnemyType.hound: EnemyTemplate(
    name: 'FERAL HOUND', short: 'hound', verb: 'bites',
    flavor: 'A gaunt, mutated hound circles you, hackles raised.',
    hp: 45, atkMin: 6, atkMax: 9, armor: 1,
    hitChance: 0.80, escapeMod: 0.9, scrapMult: 1.0, xp: 20,
    hitLines: [
      'The hound lunges, jaws snapping shut on your forearm.',
      'Fangs tear at you as the beast twists, strong and starving.',
      'It hits you low and fast, a blur of matted fur and teeth.',
    ],
    dieLines: [
      'The hound whimpers, a sound too human, and goes still.',
      'It collapses mid-snarl, ribs showing through the hide.',
    ],
  ),
  EnemyType.sentry: EnemyTemplate(
    name: 'RUSTED SENTRY', short: 'sentry', verb: 'strikes',
    flavor: 'A rusted sentry unit grinds to life, optics glowing red.',
    hp: 70, atkMin: 8, atkMax: 12, armor: 4,
    hitChance: 0.85, escapeMod: 0.6, scrapMult: 1.8, xp: 40,
    chargeChance: 0.35, chargeText: 'powers up its cannon',
    hitLines: [
      'The sentry swings a servo arm into your ribs with a screech of metal.',
      'A burst from its shoulder cannon chews the dirt, and you.',
      'Rusted fingers clamp and twist before you tear free.',
    ],
    dieLines: [
      'Its red eye gutters out. Somewhere inside, a final, polite beep.',
      'The sentry topples, still muttering a security warning nobody will hear.',
    ],
  ),
  EnemyType.raider: EnemyTemplate(
    name: 'WASTELAND RAIDER', short: 'raider', verb: 'shoots',
    flavor: 'A raider steps out from behind a wreck, weapon raised. "Drop your pack, scav."',
    hp: 55, atkMin: 6, atkMax: 10, armor: 1,
    hitChance: 0.85, escapeMod: 0.8, scrapMult: 1.4, xp: 28,
    coverChance: 0.25,
    hitLines: [
      'The raider rakes you with a burst of cheap, stolen ammunition.',
      'A rifle butt cracks across your jaw. Dirty fighters, these.',
      'You feel the sting of a shot as the raider laughs from cover.',
    ],
    dieLines: [
      'The raider drops, cursing the last of his luck. His pockets jingle.',
      'She falls without a word. The wasteland takes another debtor.',
    ],
  ),
  EnemyType.crawler: EnemyTemplate(
    name: 'MUTANT CRAWLER', short: 'crawler', verb: 'lashes',
    flavor: 'A mutated crawler drags itself from the wreckage, too many joints bending the wrong way.',
    hp: 38, atkMin: 3, atkMax: 5, armor: 0,
    hitChance: 0.80, escapeMod: 1.2, scrapMult: 1.0, xp: 22,
    strikes: 2,
    hitLines: [
      'The crawler lashes out with a barbed limb, then another, faster than thought.',
      'Too many joints bend the wrong way, and all of them strike at once.',
      'It drags you down with clicking claws, hissing wetly.',
    ],
    dieLines: [
      'The crawler curls up, legs twitching like dying wires.',
      'It stops moving, finally, and the sound of it clicking fades.',
    ],
  ),
  EnemyType.brute: EnemyTemplate(
    name: 'IRRADIATED BRUTE', short: 'brute', verb: 'pummels',
    flavor: 'The ground trembles. An irradiated brute lumbers into view, skin blistered and swollen.',
    hp: 90, atkMin: 12, atkMax: 18, armor: 1,
    hitChance: 0.70, escapeMod: 0.5, scrapMult: 1.8, xp: 45,
    hitLines: [
      'The brute pounds you with a fist like a cinder block.',
      'A swollen arm swings and the world goes white for a moment.',
      'It grabs you, squeezes, and throws you like a rag doll.',
    ],
    dieLines: [
      'The brute sinks to its knees, and finally, mercifully, the ground.',
      'It dies roaring at a sky that never answered it.',
    ],
  ),
  EnemyType.lurker: EnemyTemplate(
    name: 'TUNNEL LURKER', short: 'lurker', verb: 'rakes',
    flavor: 'Something pale uncoils from the shadows. A lurker.',
    hp: 50, atkMin: 7, atkMax: 11, armor: 0,
    hitChance: 0.85, escapeMod: 0.8, scrapMult: 1.3, xp: 30,
    ambush: true,
    hitLines: [
      'Long fingers rake out of the dark and find your shoulder.',
      'The lurker is on you before the shadow resolves into a shape.',
      'Pale claws slash, then it vanishes back into the gloom.',
    ],
    dieLines: [
      'The lurker shrinks as it dies, pale and small and wrong.',
      'It slides to the ground and the tunnel feels, briefly, safe.',
    ],
  ),
  EnemyType.warmachine: EnemyTemplate(
    name: 'ANCIENT WAR MACHINE', short: 'war machine', verb: 'blasts',
    flavor: 'Servos whine to life. An ancient war machine rises from the scrap, its targeting lens locking onto you.',
    hp: 160, atkMin: 14, atkMax: 20, armor: 6,
    hitChance: 0.90, escapeMod: 0.3, scrapMult: 5.0, xp: 120,
    chargeChance: 0.45, chargeText: 'spins up its heavy weapons',
    hitLines: [
      'The war machine hammers you with a burst from its chain gun.',
      'A servo-driven limb swats you aside like a fly.',
      'Heat and noise roll over you as its cannon speaks.',
    ],
    dieLines: [
      'The ancient machine groans, sags, and shuts down with a long, slow sigh.',
      'Its lens cracks. A century of orders go unanswered at last.',
    ],
  ),
  EnemyType.swarm: EnemyTemplate(
    name: 'CARRION SWARM', short: 'swarm', verb: 'pecks',
    flavor: 'A black cloud lifts off a heap of bones, shrieking. The carrion swarm has noticed you.',
    hp: 24, atkMin: 2, atkMax: 4, armor: 0,
    hitChance: 0.75, escapeMod: 1.5, scrapMult: 0.7, xp: 14,
    strikes: 3,
    hitLines: [
      'The swarm descends in a shrieking cloud, pecking at your face and hands.',
      'Dozens of small beaks stab at you from every side.',
      'Wings beat against your ears as tiny talons rake your skin.',
    ],
    dieLines: [
      'The last of the flock scatters, and feathers drift down like grey snow.',
      'The carrion birds break and flee, leaving only dust and bones.',
    ],
  ),
  EnemyType.spitter: EnemyTemplate(
    name: 'ACID SPITTER', short: 'spitter', verb: 'spits at',
    flavor: 'Something wet and green-toothed uncoils from a rusted drum. An acid spitter hisses and takes aim.',
    hp: 34, atkMin: 9, atkMax: 13, armor: 0,
    hitChance: 0.85, escapeMod: 1.0, scrapMult: 1.2, xp: 26,
    coverChance: 0.3,
    hitLines: [
      'The spitter hawks and a stream of acid hisses across your armour.',
      'Green bile spatters your arm and eats through cloth and skin.',
      'It spits again, and the smell of burning is your own.',
    ],
    dieLines: [
      'The spitter bursts, its acid sac pooling harmlessly across the dirt.',
      'It gurgles, deflates, and stains the ground a sickly yellow.',
    ],
  ),
  EnemyType.colossus: EnemyTemplate(
    name: 'JUNK COLOSSUS', short: 'colossus', verb: 'crushes',
    flavor: 'The pile of scrap you walked past stands up. A junk colossus, held together with wire and spite, turns its single lens toward you.',
    hp: 120, atkMin: 11, atkMax: 16, armor: 3,
    hitChance: 0.80, escapeMod: 0.4, scrapMult: 2.5, xp: 70,
    chargeChance: 0.3, chargeText: 'hauls back a fist made of engine blocks',
    hitLines: [
      'The colossus slams a fist of engine blocks down where you stood.',
      'A pipe-bundle arm sweeps you off your feet.',
      'Scrap shrieks as the thing grinds you against a wall.',
    ],
    dieLines: [
      'The colossus comes apart in an avalanche of junk, a thousand clanging pieces.',
      'Its single lens goes dark, and the whole heap collapses with a groan.',
    ],
  ),
  EnemyType.captain: EnemyTemplate(
    name: 'MARAUDER CAPTAIN', short: 'captain', verb: 'cuts down',
    flavor: 'A tall figure in a horned helmet steps into the road, flanked by empty space where his gang used to stand. "Pay the toll," says the marauder captain.',
    hp: 85, atkMin: 9, atkMax: 14, armor: 2,
    hitChance: 0.88, escapeMod: 0.6, scrapMult: 2.2, xp: 55,
    coverChance: 0.25, chargeChance: 0.2, chargeText: 'levels a stolen rifle at you',
    hitLines: [
      'The captain carves a gash across you with a notched blade.',
      'He fires from the hip, laughing, and the shot finds you.',
      'A steel-toed boot and a vicious backhand: the captain fights dirty.',
    ],
    dieLines: [
      'The captain falls, spitting threats, his banner trailing in the dust.',
      'His helmet rolls free. Underneath: just a tired man who wanted to be feared.',
    ],
  ),
  EnemyType.straggler: EnemyTemplate(
    name: 'FERAL STRAGGLER', short: 'straggler', verb: 'tears at',
    flavor: 'A figure in rags staggers out of the dark, jaw working. The feral straggler lunges.',
    hp: 40, atkMin: 5, atkMax: 8, armor: 0,
    hitChance: 0.75, escapeMod: 1.0, scrapMult: 1.0, xp: 24,
    strikes: 2,
    hitLines: [
      'The straggler claws at you, moaning, with nails like broken glass.',
      'It lurches in and bites, desperate and wordless.',
      'Ragged hands grab and tear at you with horrible strength.',
    ],
    dieLines: [
      'The straggler slumps, and for one second it looks almost like a person.',
      'It sighs, a human sound, and does not rise again.',
    ],
  ),
  EnemyType.wyrm: EnemyTemplate(
    name: 'SAND WYRM', short: 'wyrm', verb: 'gores',
    flavor: 'The ground trembles and the dune ahead splits open. A sand wyrm rears up, teeth in rings.',
    hp: 110, atkMin: 13, atkMax: 19, armor: 2,
    hitChance: 0.85, escapeMod: 0.4, scrapMult: 2.6, xp: 75,
    ambush: true,
    hitLines: [
      'The wyrm erupts from the ground and gores you with a ring of teeth.',
      'Its coils whip around you and squeeze, grinding sand into your wounds.',
      'The sand itself seems to strike at you, and then it is a mouth.',
    ],
    dieLines: [
      'The wyrm thrashes once, buries its head in the sand, and is still.',
      'It sinks beneath the dunes, and the sand slowly smooths over.',
    ],
  ),
};

/// Pure data for one fight. Rules live in CombatSystem.
class CombatSession {
  final EnemyType type;
  final int maxHp;
  int hp;
  final int atkMin, atkMax;
  bool charging = false; // telegraphed heavy attack
  bool guarding = false; // enemy is behind cover: your next hit is halved
  bool playerDefending = false;
  final List<CombatFx> fx = []; // animation events, drained by the combat stage
  int turn = 1;
  CombatOutcome outcome = CombatOutcome.none;
  int scrapGained = 0; // negative if scrap was lost on defeat

  CombatSession._(this.type, this.maxHp, this.hp, this.atkMin, this.atkMax);

  EnemyTemplate get template => enemyTemplates[type]!;
  String get name => template.name;
  int get armor => template.armor;
  bool get finished => outcome != CombatOutcome.none;

  /// Enemies grow tougher with expedition distance.
  factory CombatSession.spawn(EnemyType t, double distanceKm) {
    final tpl = enemyTemplates[t]!;
    final hpScale = 1 + 0.12 * distanceKm;
    final dmgScale = 1 + 0.08 * distanceKm;
    final hp = (tpl.hp * hpScale).round();
    return CombatSession._(
      t,
      hp,
      hp,
      max(1, (tpl.atkMin * dmgScale).round()),
      max(1, (tpl.atkMax * dmgScale).round()),
    );
  }

  Map<String, dynamic> toJson() => {
        'type': type.name,
        'maxHp': maxHp,
        'hp': hp,
        'atkMin': atkMin,
        'atkMax': atkMax,
        'charging': charging,
        'guarding': guarding,
        'defending': playerDefending,
        'turn': turn,
        'outcome': outcome.name,
        'scrapGained': scrapGained,
      };

  factory CombatSession.fromJson(Map<String, dynamic> j) {
    final s = CombatSession._(
      EnemyType.values.byName(j['type'] as String),
      (j['maxHp'] as num).toInt(),
      (j['hp'] as num).toInt(),
      (j['atkMin'] as num).toInt(),
      (j['atkMax'] as num).toInt(),
    );
    s.charging = j['charging'] as bool;
    s.guarding = (j['guarding'] as bool?) ?? false;
    s.playerDefending = j['defending'] as bool;
    s.turn = (j['turn'] as num).toInt();
    s.outcome = CombatOutcome.values.byName(j['outcome'] as String);
    s.scrapGained = (j['scrapGained'] as num).toInt();
    return s;
  }
}
