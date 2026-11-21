import 'dart:math';
import 'combat_session.dart';

enum QuestKind { kills, scrap, hacks, locks, distance, crafts, events }

class QuestDef {
  final String id, title, desc;
  final QuestKind kind;
  final int target;
  final String? tag; // for kills: the enemy type name it must be
  final int minLevel, rewardScrap, rewardXp, rewardStims, rewardPicks;
  final bool board; // false = only given by an event
  const QuestDef({
    required this.id,
    required this.title,
    required this.desc,
    required this.kind,
    required this.target,
    this.tag,
    this.minLevel = 1,
    this.rewardScrap = 0,
    this.rewardXp = 0,
    this.rewardStims = 0,
    this.rewardPicks = 0,
    this.board = true,
  });
}

const questCatalog = <QuestDef>[
  QuestDef(id: 'pest', title: 'PEST CONTROL', desc: 'KILL 3 HOSTILES',
      kind: QuestKind.kills, target: 3, rewardScrap: 40, rewardXp: 30),
  QuestDef(id: 'hounds', title: 'HOUND SEASON', desc: 'KILL 2 FERAL HOUNDS',
      kind: QuestKind.kills, tag: 'hound', target: 2, rewardScrap: 60, rewardXp: 40),
  QuestDef(id: 'sesame', title: 'OPEN SESAME', desc: 'OPEN 2 LOCKS',
      kind: QuestKind.locks, target: 2, rewardScrap: 50, rewardXp: 35, rewardPicks: 2),
  QuestDef(id: 'ghost', title: 'GHOST IN THE MACHINE', desc: 'HACK 2 TERMINALS',
      kind: QuestKind.hacks, target: 2, rewardScrap: 50, rewardXp: 35, rewardStims: 1),
  QuestDef(id: 'collector', title: 'SCRAP COLLECTOR', desc: 'COLLECT 150 SCRAP',
      kind: QuestKind.scrap, target: 150, rewardScrap: 60, rewardXp: 30, rewardStims: 1),
  QuestDef(id: 'longroad', title: 'THE LONG ROAD', desc: 'REACH 5 KM FROM HOME',
      kind: QuestKind.distance, target: 5, rewardScrap: 80, rewardXp: 50),
  QuestDef(id: 'raiders', title: 'RAIDER BOUNTY', desc: 'KILL 3 RAIDERS',
      kind: QuestKind.kills, tag: 'raider', target: 3, minLevel: 2, rewardScrap: 120, rewardXp: 80),
  QuestDef(id: 'rustmen', title: 'RUST HUNTERS', desc: 'KILL 2 RUSTED SENTRIES',
      kind: QuestKind.kills, tag: 'sentry', target: 2, minLevel: 2, rewardScrap: 90, rewardXp: 70),
  QuestDef(id: 'tunnel', title: 'TUNNEL VISION', desc: 'KILL 2 TUNNEL LURKERS',
      kind: QuestKind.kills, tag: 'lurker', target: 2, minLevel: 3, rewardScrap: 140, rewardXp: 90),
  QuestDef(id: 'edge', title: 'EDGE OF THE MAP', desc: 'REACH 10 KM FROM HOME',
      kind: QuestKind.distance, target: 10, minLevel: 3, rewardScrap: 220, rewardXp: 120, rewardStims: 2),
  QuestDef(id: 'bigame', title: 'BIG GAME', desc: 'KILL 2 IRRADIATED BRUTES',
      kind: QuestKind.kills, tag: 'brute', target: 2, minLevel: 4, rewardScrap: 200, rewardXp: 130),
  QuestDef(id: 'machine', title: 'MACHINE HUNTER', desc: 'DESTROY AN ANCIENT WAR MACHINE',
      kind: QuestKind.kills, tag: 'warmachine', target: 1, minLevel: 5,
      rewardScrap: 500, rewardXp: 250, rewardStims: 3),
  QuestDef(id: 'caravan', title: 'THE LOST CARAVAN',
      desc: "REACH 7 KM. THE SURVIVOR'S CARAVAN WENT DOWN THAT WAY",
      kind: QuestKind.distance, target: 7, rewardScrap: 150, rewardXp: 90, rewardStims: 1, board: false),
];

QuestDef questById(String id) =>
    id.startsWith('c|') ? parseContract(id) : questCatalog.firstWhere((q) => q.id == id);

class QuestProgress {
  final String id;
  int progress = 0;
  bool ready = false; // target reached; claim it at the safehouse
  QuestProgress(this.id);

  Map<String, dynamic> toJson() => {'id': id, 'p': progress, 'ready': ready};

  factory QuestProgress.fromJson(Map<String, dynamic> j) {
    final q = QuestProgress(j['id'] as String);
    q.progress = (j['p'] as num).toInt();
    q.ready = j['ready'] as bool;
    return q;
  }
}


// ---------------------------------------------------------------- contracts
// Randomly generated, repeatable jobs. The id carries every detail
// (kind, target, rewards, wording) so a contract can be saved and restored
// without any lookup table.

const _contractTitles = <String, List<String>>{
  'kills': ['CULL THE PACK', 'ROAD CLEARING', 'PEST PROBLEM', 'BOUNTY NOTICE', 'CLEAN SWEEP'],
  'tag': ['WANTED', 'HEAD HUNTER', 'PRICE ON ITS HEAD', 'DEAD OR DEAD', 'PROBLEM SOLVER'],
  'scrap': ['SCRAP RUN', 'SALVAGE QUOTA', 'COLLECTION DRIVE', 'FEED THE FORGE', 'PAYDAY'],
  'hacks': ['DATA RETRIEVAL', 'LOCKED OUT', 'BACKDOOR WORK', 'GHOST SIGNAL', 'OLD SECRETS'],
  'locks': ['OPEN THE VAULTS', 'BREAK AND ENTER', 'LOCKSMITH WANTED', 'WHAT THEY HID', 'SKELETON KEYS'],
  'distance': ['SCOUT THE ROAD', 'FAR FRONTIER', 'THE LONG HAUL', 'MAP THE WASTE', 'BEYOND THE MARKERS'],
  'crafts': ['WORKSHOP ORDER', 'BUILD TO SPEC', 'MADE TO LAST', 'SPARE PARTS', 'TINKER'],
  'events': ['ASK AROUND', "SEE WHAT'S OUT THERE", 'FIELD WORK', 'FACE THE ROAD', 'STRANGE ENCOUNTERS'],
};

const _contractBlurbs = <String, List<String>>{
  'kills': [
    '"The road is crawling with them. Make it stop."',
    '"Folks will not travel till it is clear."',
    '"I will pay double if you do not bring any of it back."',
    '"Something keeps hunting the traders."',
    '"Clear them out and the next convoy passes."',
  ],
  'tag': [
    '"It took my brother\'s caravan. I want it gone."',
    '"Nobody sleeps while that thing lives."',
    '"There is a bounty. A real one. Collect."',
    '"Kill it and bring proof. Or just tell me."',
    '"I want to hear it stopped breathing."',
  ],
  'scrap': [
    '"The forge is hungry. Feed it."',
    '"Prices are up. So is my need for scrap."',
    '"Bring a haul, get paid fairly."',
    '"I need more than I can carry. You carry."',
    '"The settlement is rebuilding. Bring materials."',
  ],
  'hacks': [
    '"There are secrets in those old terminals."',
    '"Pre-war records. Worth more than scrap."',
    '"I need access. You have the knack."',
    '"Something is still broadcasting. Find out what."',
    '"Pull whatever you can from the machines."',
  ],
  'locks': [
    '"People hid things. Go find them."',
    '"Sealed doors mean someone had something to protect."',
    '"I will not ask what you take."',
    '"I need a pair of nimble hands."',
    '"Open what is closed. Quietly."',
  ],
  'distance': [
    '"Someone has to see what is out there."',
    '"Rumours of a safe place far out. Check them."',
    '"I need eyes beyond the markers."',
    '"No one comes back from that far. Be the first."',
    '"Chart the road, and I will pay for every kilometre."',
  ],
  'crafts': [
    '"We need things built. Simple things, many of them."',
    '"Show me you can work with your hands."',
    '"Parts are cheap. Skilled hands are not."',
    '"Prove the workshop is worth the rent."',
    '"Build, test, repeat."',
  ],
  'events': [
    '"Meet people. Learn what is going on."',
    '"I need news from the road."',
    '"See who is out there, and what they want."',
    '"Come back with stories. And all your fingers."',
    '"The wasteland is full of surprises. Go collect a few."',
  ],
};

String makeContractId(Random rng, int level) {
  const kinds = ['kills', 'tag', 'scrap', 'hacks', 'locks', 'distance', 'crafts', 'events'];
  final kind = kinds[rng.nextInt(kinds.length)];
  var tag = '-';
  var target = 3;
  var scrap = 60;
  switch (kind) {
    case 'kills':
      target = 3 + rng.nextInt(3) + level ~/ 3;
      scrap = 22 * target;
      break;
    case 'tag':
      final pool = <EnemyType>[
        EnemyType.skitter, EnemyType.hound, EnemyType.swarm,
        EnemyType.straggler, EnemyType.raider, EnemyType.crawler,
        if (level >= 3) ...[EnemyType.sentry, EnemyType.lurker, EnemyType.spitter, EnemyType.captain],
        if (level >= 6) ...[EnemyType.brute, EnemyType.colossus, EnemyType.wyrm],
      ];
      tag = pool[rng.nextInt(pool.length)].name;
      target = 2 + rng.nextInt(3);
      scrap = 32 * target;
      break;
    case 'scrap':
      target = 80 + 40 * level + rng.nextInt(80);
      scrap = 30 + target ~/ 2;
      break;
    case 'hacks':
    case 'locks':
      target = 2 + rng.nextInt(3);
      scrap = 38 * target;
      break;
    case 'distance':
      target = min(18, 4 + level * 2 + rng.nextInt(3));
      scrap = 18 * target;
      break;
    case 'crafts':
      target = 2 + rng.nextInt(3);
      scrap = 28 * target;
      break;
    default:
      target = 2 + rng.nextInt(3);
      scrap = 25 * target;
  }
  scrap = (scrap * (1 + 0.15 * level)).round();
  final xp = (scrap * 0.6).round();
  final stims = (target >= 4 || rng.nextDouble() < 0.3) ? 1 : 0;
  final picks = kind == 'locks' ? 1 : 0;
  final titleIdx = rng.nextInt(5);
  return ['c', kind, tag, target, scrap, xp, stims, picks, titleIdx].join('|');
}

QuestDef parseContract(String id) {
  final p = id.split('|');
  final kind = p[1], tag = p[2];
  final target = int.parse(p[3]);
  final idx = int.parse(p[8]);
  final titles = _contractTitles[kind]!;
  final blurbs = _contractBlurbs[kind]!;
  var title = titles[idx % titles.length];
  QuestKind k;
  String action;
  String? qtag;
  switch (kind) {
    case 'kills':
      k = QuestKind.kills;
      action = 'KILL $target HOSTILES';
      break;
    case 'tag':
      k = QuestKind.kills;
      qtag = tag;
      final name = enemyTemplates[EnemyType.values.byName(tag)]!.name;
      action = 'KILL $target ${name}S';
      title = '$title: $name';
      break;
    case 'scrap':
      k = QuestKind.scrap;
      action = 'COLLECT $target SCRAP';
      break;
    case 'hacks':
      k = QuestKind.hacks;
      action = 'HACK $target TERMINALS';
      break;
    case 'locks':
      k = QuestKind.locks;
      action = 'OPEN $target LOCKS';
      break;
    case 'distance':
      k = QuestKind.distance;
      action = 'REACH $target KM FROM HOME';
      break;
    case 'crafts':
      k = QuestKind.crafts;
      action = 'CRAFT $target ITEMS';
      break;
    default:
      k = QuestKind.events;
      action = 'RESOLVE $target ENCOUNTERS';
  }
  return QuestDef(
    id: id,
    title: title,
    desc: '$action  ${blurbs[idx % blurbs.length]}',
    kind: k,
    target: target,
    tag: qtag,
    rewardScrap: int.parse(p[4]),
    rewardXp: int.parse(p[5]),
    rewardStims: int.parse(p[6]),
    rewardPicks: int.parse(p[7]),
  );
}
