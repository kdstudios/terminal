import 'dart:math';

enum TokenKind { word, bracket }

/// A selectable span on the character grid: a password word or a bracket pair.
class HackToken {
  final TokenKind kind;
  final int row, start, end; // end is exclusive
  final String text; // original text
  bool removed = false;
  HackToken(this.kind, this.row, this.start, this.end, this.text);
  int get length => end - start;
  bool covers(int r, int c) => !removed && r == row && c >= start && c < end;
}

int likenessOf(String a, String b) {
  int n = 0;
  for (int i = 0; i < a.length && i < b.length; i++) {
    if (a[i] == b[i]) n++;
  }
  return n;
}

bool _isLetter(String ch) {
  final u = ch.codeUnitAt(0);
  return u >= 65 && u <= 90;
}

const _open = ['(', '[', '{', '<'];
const _close = [')', ']', '}', '>'];
const _symbols = r'!@#$%^&*_+-=|;:,./?~';

String _filler(Random rng) => _symbols[rng.nextInt(_symbols.length)];
String _junk(Random rng) =>
    rng.nextDouble() < 0.13 ? '([{<)]}>'[rng.nextInt(8)] : _filler(rng);

/// An opener pairs with the first later closer of the same type on the same
/// row, as long as no letters (password words) sit in between.
List<HackToken> _findBrackets(List<String> rows) {
  final out = <HackToken>[];
  for (int r = 0; r < rows.length; r++) {
    final s = rows[r];
    for (int i = 0; i < s.length; i++) {
      final k = _open.indexOf(s[i]);
      if (k < 0) continue;
      for (int j = i + 1; j < s.length; j++) {
        if (_isLetter(s[j])) break;
        if (s[j] == _close[k]) {
          out.add(HackToken(TokenKind.bracket, r, i, j + 1, s.substring(i, j + 1)));
          break;
        }
      }
    }
  }
  return out;
}

/// Pure rules/data for one terminal hack. No UI, no GameState.
class HackingSession {
  static const int rowsPerColumn = 16;
  static const int rowCount = 32; // two columns of 16 rows
  static const int rowWidth = 12;

  final int level; // 1..4
  final String password;
  final int maxAttempts;
  int attempts;
  final List<String> rows;
  final List<HackToken> tokens;

  int? selected; // index into tokens (tap once to highlight, again to enter)
  bool engaged = false; // false = still showing HACK / IGNORE prompt
  bool finished = false;
  bool success = false;
  bool flawless = false;
  final Map<String, int> tried = {};

  HackingSession._(this.level, this.password, this.maxAttempts, this.rows, this.tokens)
      : attempts = maxAttempts;

  static const _pool = <int, List<String>>{
    4: ['CORE', 'DOOR', 'FUEL', 'GATE', 'HACK', 'LOCK', 'SAFE', 'WIRE',
        'VENT', 'BOLT', 'CODE', 'DUST', 'RUST', 'GRID', 'BURN', 'WIND',
        'SAND', 'BONE', 'GEAR', 'HULL', 'PIPE', 'TANK', 'MINE', 'CAMP',
        'ROAD', 'WALL', 'FIRE', 'FLUX', 'BASE', 'DEAD', 'HEAT', 'ARMS'],
    5: ['POWER', 'METAL', 'WATER', 'STEEL', 'RADIO', 'SIREN', 'TOWER',
        'GUARD', 'ALARM', 'SCRAP', 'FLARE', 'WASTE', 'VAULT', 'CABLE',
        'DRONE', 'ROBOT', 'BLAST', 'SHELL', 'FLAME', 'SMOKE', 'STORM',
        'RUINS', 'CRATE', 'RELAY', 'PANEL', 'VALVE', 'CHAIN', 'BLADE',
        'ARMOR', 'ASHES'],
    6: ['SYSTEM', 'MARKET', 'TARGET', 'MASTER', 'BUNKER', 'SIGNAL', 'ACCESS',
        'SHIELD', 'ENGINE', 'LOCKER', 'FILTER', 'SENSOR', 'DEBRIS', 'ROCKET',
        'TUNNEL', 'CANYON', 'MUTANT', 'RAIDER', 'HUNTER', 'BARREL', 'BATTLE',
        'BULLET', 'ARMORY', 'VAULTS', 'PLATES', 'DEFEND', 'ESCAPE'],
    7: ['CIRCUIT', 'REACTOR', 'BARRIER', 'MONITOR', 'NETWORK', 'BATTERY',
        'MACHINE', 'CONSOLE', 'WARHEAD', 'FACTORY', 'SHELTER', 'CHASSIS',
        'DEFENSE', 'SCANNER', 'WEAPONS', 'SURVIVE', 'ARSENAL', 'BULLETS',
        'LANTERN', 'MISSILE', 'PATROLS', 'TRACKER', 'WARRIOR', 'WRECKED',
        'OUTPOST'],
  };

  static const _bigPool = <int, List<String>>{
    8: ['ARMOURED', 'BACKDOOR', 'BULKHEAD', 'CHAMBERS', 'CHECKSUM', 'CIRCUITS', 'DEFENDER', 'DETONATE', 'DISPATCH', 'ELECTRIC', 'EVACUATE', 'FIREWALL', 'FORTRESS', 'HOSTILES', 'ISOLATED', 'LOCKDOWN', 'MAINTAIN', 'MILITARY', 'OPERATOR', 'OVERRIDE', 'PASSWORD', 'PROTOCOL', 'SALVAGED', 'SCAVENGE', 'SECURITY', 'SENTINEL', 'SHELTERS', 'SHUTDOWN', 'STANDARD', 'SURVIVOR', 'TERMINAL'],
    9: ['ABANDONED', 'ARTILLERY', 'BARRICADE', 'BASEMENTS', 'BLACKOUTS', 'BROADCAST', 'CARTRIDGE', 'CHEMICALS', 'COMMANDER', 'CONTAINER', 'EMERGENCY', 'EXPLOSIVE', 'FIREPOWER', 'GENERATOR', 'HAZARDOUS', 'MECHANISM', 'MUNITIONS', 'OPERATION', 'OVERSIGHT', 'PERIMETER', 'RADIATION', 'RESERVOIR', 'SCAVENGER', 'STRONGBOX', 'SURVIVORS', 'TERMINALS', 'TRANSPORT', 'WASTELAND'],
    10: ['AMMUNITION', 'BARRICADES', 'COMMANDERS', 'COMPOUNDED', 'DEPARTMENT', 'EXPEDITION', 'EXPLOSIVES', 'FIREWALLED', 'FORTIFYING', 'GENERATORS', 'MAINFRAMES', 'OVERSEEING', 'PROCESSORS', 'QUARANTINE', 'REFINERIES', 'REINFORCED', 'SCAVENGERS', 'SURVEILLED', 'WAREHOUSES', 'WASTELANDS'],
  };

  static const _typeNames = [
    'ROADSIDE KIOSK', 'SHOP TERMINAL', 'DEPOT CONSOLE', 'MILITARY TERMINAL',
    'CORPORATE MAINFRAME', 'GOVERNMENT NODE', 'BLACKSITE CORE',
  ];

  String get typeName => _typeNames[level - 1];

  factory HackingSession.generate(int level, Random rng,
      {int attempts = 4, int fewerDecoys = 0}) {
    final length = level + 3; // 4..10 letters
    final pool = List<String>.of(_pool[length] ?? _bigPool[length]!)..shuffle(rng);
    final password = pool.removeLast();
    final need = min(18, max(5, 9 + 2 * level - fewerDecoys)); // decoy words

    // Favour decoys that share letters with the password so likeness clues help.
    final close = pool.where((w) => likenessOf(w, password) > 0).toList();
    final far = pool.where((w) => likenessOf(w, password) == 0).toList();
    final chosen = <String>[...close.take((need * 0.6).ceil())];
    for (final w in [...far, ...close.skip(chosen.length)]) {
      if (chosen.length >= need) break;
      chosen.add(w);
    }
    final words = [...chosen, password]..shuffle(rng);

    // Fill the grid with junk, then drop each word into its own row.
    final grid = List.generate(
        rowCount, (_) => List.generate(rowWidth, (_) => _junk(rng)));
    final order = List<int>.generate(rowCount, (i) => i)..shuffle(rng);
    final tokens = <HackToken>[];
    for (int i = 0; i < words.length; i++) {
      final w = words[i], r = order[i];
      final s = rng.nextInt(rowWidth - w.length + 1);
      for (int k = 0; k < w.length; k++) {
        grid[r][s + k] = w[k];
      }
      tokens.add(HackToken(TokenKind.word, r, s, s + w.length, w));
    }

    // Make sure several bracket pairs exist.
    List<String> asRows() => grid.map((r) => r.join()).toList();
    var pairs = _findBrackets(asRows());
    int tries = 0;
    while (pairs.length < 6 && tries++ < 120) {
      final r = rng.nextInt(rowCount), c = rng.nextInt(rowWidth - 3);
      if (List.generate(4, (k) => grid[r][c + k]).any(_isLetter)) continue;
      final k = rng.nextInt(4);
      grid[r][c] = _open[k];
      grid[r][c + 1] = _filler(rng);
      grid[r][c + 2] = _filler(rng);
      grid[r][c + 3] = _close[k];
      pairs = _findBrackets(asRows());
    }
    tokens.addAll(pairs);
    return HackingSession._(level, password, attempts, asRows(), tokens);
  }

  int likeness(String guess) => likenessOf(guess, password);

  /// Words win over brackets; among brackets the shortest span wins.
  /// If nothing is hit exactly, a word one cell away still counts (finger slop).
  int? tokenAt(int r, int c) {
    int? best;
    for (int i = 0; i < tokens.length; i++) {
      final t = tokens[i];
      if (!t.covers(r, c)) continue;
      if (t.kind == TokenKind.word) return i;
      if (best == null || t.length < tokens[best].length) best = i;
    }
    if (best != null) return best;
    for (int i = 0; i < tokens.length; i++) {
      final t = tokens[i];
      if (t.kind == TokenKind.word && !t.removed && t.row == r &&
          c >= t.start - 1 && c <= t.end) {
        return i;
      }
    }
    return null;
  }

  /// Replace a token's characters with dots (used exploits, removed words).
  void removeToken(int i) {
    final t = tokens[i];
    t.removed = true;
    rows[t.row] = rows[t.row].replaceRange(t.start, t.end, '.' * t.length);
    if (t.kind == TokenKind.bracket) {
      for (final o in tokens) {
        if (!o.removed && o.kind == TokenKind.bracket && o.row == t.row &&
            o.start < t.end && t.start < o.end) {
          o.removed = true; // overlapping pair is broken now
        }
      }
    }
    if (selected != null && tokens[selected!].removed) selected = null;
  }

  Map<String, dynamic> toJson() => {
        'level': level,
        'password': password,
        'maxAttempts': maxAttempts,
        'attempts': attempts,
        'rows': rows,
        'selected': selected,
        'engaged': engaged,
        'finished': finished,
        'success': success,
        'flawless': flawless,
        'tried': tried,
        'tokens': [
          for (final t in tokens)
            {'k': t.kind.name, 'r': t.row, 's': t.start, 'e': t.end, 't': t.text, 'x': t.removed}
        ],
      };

  factory HackingSession.fromJson(Map<String, dynamic> j) {
    final tokens = <HackToken>[];
    for (final e in (j['tokens'] as List)) {
      final m = e as Map;
      final t = HackToken(
        TokenKind.values.byName(m['k'] as String),
        (m['r'] as num).toInt(),
        (m['s'] as num).toInt(),
        (m['e'] as num).toInt(),
        m['t'] as String,
      );
      t.removed = m['x'] as bool;
      tokens.add(t);
    }
    final s = HackingSession._(
      (j['level'] as num).toInt(),
      j['password'] as String,
      (j['maxAttempts'] as num).toInt(),
      List<String>.from(j['rows'] as List),
      tokens,
    );
    s.attempts = (j['attempts'] as num).toInt();
    s.selected = j['selected'] == null ? null : (j['selected'] as num).toInt();
    s.engaged = j['engaged'] as bool;
    s.finished = j['finished'] as bool;
    s.success = j['success'] as bool;
    s.flawless = j['flawless'] as bool;
    for (final e in (j['tried'] as Map).entries) {
      s.tried[e.key as String] = (e.value as num).toInt();
    }
    return s;
  }

  List<int> get dudIndexes => [
        for (int i = 0; i < tokens.length; i++)
          if (tokens[i].kind == TokenKind.word &&
              !tokens[i].removed &&
              tokens[i].text != password)
            i
      ];
}
