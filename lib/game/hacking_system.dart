import 'dart:math';
import 'game_state.dart';
import 'fx.dart';
import 'hacking_session.dart';
import 'quests.dart';

/// Runs terminal hacking: offering, selecting, rewards and failure penalties.
class HackingSystem {
  final GameState state;
  final Random _rng;
  HackingSystem(this.state, {Random? rng}) : _rng = rng ?? Random();

  /// Called by exploration when a terminal is found. Pauses exploration.
  void offerTerminal() {
    state.resetConsole();
    final level = min(7, 1 + state.distanceKm ~/ 2.2);
    state.hacking = HackingSession.generate(level, _rng,
        attempts: max(3, state.hackAttempts - (level >= 6 ? 1 : 0)),
        fewerDecoys: state.skill('HACKING') ~/ 2);
    state.mode = GameMode.hacking;
    state.refresh(); // the prompt screen shows the terminal and its level
  }

  void engage() {
    final s = state.hacking;
    if (s == null || s.engaged) return;
    s.engaged = true;
    state.addLog('> TERMINAL ONLINE. ATTEMPTS: ${s.attempts}', LogKind.system,
        notify: false);
    state.addLog('Tap a word, tap again to enter it. Matched brackets are exploits.',
        LogKind.narrative);
  }

  void ignore() {
    _end();
    state.addLog('You leave the terminal alone and press on.', LogKind.narrative);
  }

  void leave() {
    final s = state.hacking;
    if (s == null || !s.finished) return;
    _end();
  }

  /// First tap highlights a token, a second tap on it enters it.
  /// Tapping empty noise clears the highlight.
  void tap(int row, int col) {
    final s = state.hacking;
    if (s == null || !s.engaged || s.finished) return;
    final i = s.tokenAt(row, col);
    if (i == null) {
      if (s.selected != null) {
        s.selected = null;
        state.refresh();
      }
      return;
    }
    Fx.play(Sfx.click);
    if (s.selected == i) {
      s.selected = null;
      s.tokens[i].kind == TokenKind.word ? _guess(s, i) : _bracket(s, i);
    } else {
      s.selected = i;
      state.refresh();
    }
  }

  void _guess(HackingSession s, int i) {
    final word = s.tokens[i].text;
    state.addLog('> PASSWORD SELECTED: $word', LogKind.system, notify: false);

    if (word == s.password) {
      s.finished = true;
      s.success = true;
      s.flawless = s.tried.isEmpty;
      final reward = state.withBench(15 * s.level + _rng.nextInt(10));
      final bonus = s.flawless ? 10 * s.level : 0;
      Fx.play(Sfx.confirm);
      state.addLog('> ACCESS GRANTED', LogKind.system, notify: false);
      if (s.flawless) {
        state.addLog('> FLAWLESS INTRUSION BONUS', LogKind.loot, notify: false, recap: false);
      }
      state.addLog('+ ${reward + bonus} SCRAP', LogKind.loot, notify: false);
      state.gainXp(15 * s.level);
      state.gainSkill('HACKING');
      state.questEvent(QuestKind.hacks, 1);
      state.addScrap(reward + bonus);
      return;
    }

    final m = s.likeness(word);
    s.tried[word] = m;
    s.attempts--;
    s.removeToken(i); // wrong word is dotted out
    Fx.play(Sfx.deny);
    state.addLog('MATCHING CHARACTERS: $m/${word.length}', LogKind.warning,
        notify: false);
    state.addLog('> ENTRY DENIED. ATTEMPTS LEFT: ${s.attempts}', LogKind.danger,
        notify: s.attempts > 0);

    if (s.attempts <= 0) {
      s.finished = true;
      final dmg = 5 * s.level;
      Fx.play(Sfx.alarm);
      state.addLog('> TERMINAL LOCKED. SECURITY SURGE!', LogKind.danger,
          notify: false);
      state.addLog('DAMAGE RECEIVED: $dmg', LogKind.danger, notify: false);
      state.damage(dmg); // notifies
    }
  }

  void _bracket(HackingSession s, int i) {
    final t = s.tokens[i];
    final shown = s.rows[t.row].substring(t.start, t.end);
    s.removeToken(i);
    Fx.play(Sfx.loot);
    state.addLog('> EXPLOIT RUN: $shown', LogKind.system, notify: false);

    final duds = s.dudIndexes;
    final options = <int>[
      if (duds.isNotEmpty) 0,
      if (s.attempts < s.maxAttempts) 1,
    ];
    if (options.isEmpty) {
      state.addLog('> NO EFFECT', LogKind.warning);
      return;
    }
    if (options[_rng.nextInt(options.length)] == 0) {
      s.removeToken(duds[_rng.nextInt(duds.length)]);
      state.addLog('> DUD REMOVED', LogKind.loot, recap: false);
    } else {
      s.attempts = s.maxAttempts;
      state.addLog('> ATTEMPTS RESTORED', LogKind.loot, recap: false);
    }
  }

  void _end() {
    final s = state.hacking;
    final String result = s == null || !s.finished ? 'IGNORED' : (s.success ? 'SUCCESS' : 'FAILED');
    state.hacking = null;
    state.mode = GameMode.exploring;
    state.endEncounter(
        summary: '> TERMINAL ACCESS: $result',
        kind: result == 'FAILED' ? LogKind.warning : LogKind.system);
    state.refresh();
  }
}
