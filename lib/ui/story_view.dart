import 'package:flutter/material.dart';
import '../game/fx.dart';
import '../game/game_state.dart';
import '../game/home_system.dart';
import '../game/story_content.dart';
import '../game/story_model.dart';
import '../game/story_system.dart';
import 'theme.dart';

/// The Story Expedition section of the safehouse terminal. Separate from the
/// quest/contract board: persistent, story-driven journeys that are walked with
/// the ordinary [DEPART ON EXPEDITION] action.
class StoryView extends StatefulWidget {
  final GameState state;
  final HomeSystem system;
  final VoidCallback onBack;
  const StoryView({super.key, required this.state, required this.system, required this.onBack});

  @override
  State<StoryView> createState() => _StoryViewState();
}

class _StoryViewState extends State<StoryView> {
  String? _id; // the story being looked at
  bool _journal = false;
  bool _confirm = false;

  StorySystem get _st => widget.system.story;

  @override
  Widget build(BuildContext context) {
    final d = _id == null ? null : storyDefOrNull(_id!);
    final kids = d == null ? _list() : (_journal ? _journalRows(d) : _detail(d));
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: kids);
  }

  // ----------------------------------------------------------------- bits

  Widget _btn(String label, Color color, VoidCallback? onTap) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: InkWell(
          onTap: onTap == null
              ? null
              : () {
                  Fx.play(Sfx.beep);
                  onTap();
                },
          child: Container(
            constraints: const BoxConstraints(minHeight: 40),
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(horizontal: 6),
            decoration: BoxDecoration(
              border: Border.all(color: onTap == null ? T.dim : color),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(label,
                textAlign: TextAlign.center,
                style: T.mono(onTap == null ? T.dim : color, size: 12, bold: true)),
          ),
        ),
      );

  Widget _label(String t, [Color? c]) => Padding(
        padding: const EdgeInsets.only(top: 6, bottom: 6),
        child: Text(t, style: T.mono(c ?? T.label, size: 12, bold: true)),
      );

  Widget _para(String t, {Color? color}) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Text(t, style: T.mono(color ?? T.label, size: 12)),
      );

  String _bar(int done, int total) => '${'■' * done}${'□' * (total - done)}';

  String _statusText(StoryDef d, StoryStatus s) {
    final run = widget.state.story.runs[d.id];
    switch (s) {
      case StoryStatus.locked:
        return 'LOCKED';
      case StoryStatus.available:
        return 'AVAILABLE';
      case StoryStatus.active:
        return 'ACTIVE';
      case StoryStatus.paused:
        return (run != null && run.km > 0) ? 'PAUSED' : 'ACCEPTED';
      case StoryStatus.completed:
        final e = d.endings[widget.state.story.completed[d.id]];
        return 'COMPLETED${e == null ? '' : ': ${e.title}'}';
    }
  }

  Color _statusColor(StoryStatus s) {
    switch (s) {
      case StoryStatus.locked:
        return T.dim;
      case StoryStatus.available:
        return T.loot;
      case StoryStatus.active:
      case StoryStatus.paused:
        return T.amber;
      case StoryStatus.completed:
        return T.green;
    }
  }

  String _rewardText(StoryDef d) {
    final r = d.reward;
    final parts = <String>[
      if (r.scrap > 0) '${r.scrap} SCRAP',
      if (r.xp > 0) '${r.xp} XP',
      if (r.stims > 0) '${r.stims} STIMPACK',
      if (r.picks > 0) '${r.picks} LOCKPICK',
      if (r.parts > 0) '${r.parts} PARTS',
    ];
    return '${parts.join(', ')}, PLUS A BONUS FOR HOW IT ENDS';
  }

  // ----------------------------------------------------------------- list

  List<Widget> _list() {
    final active = <StoryDef>[], open = <StoryDef>[], locked = <StoryDef>[], done = <StoryDef>[];
    for (final d in storyCatalog) {
      switch (_st.statusOf(d)) {
        case StoryStatus.active:
        case StoryStatus.paused:
          active.add(d);
        case StoryStatus.available:
          open.add(d);
        case StoryStatus.locked:
          locked.add(d);
        case StoryStatus.completed:
          done.add(d);
      }
    }
    return [
      _btn('◀ BACK', T.dim, widget.onBack),
      _para('LONG JOURNEYS WITH A STORY. ONE CAN BE ACTIVE AT A TIME. WALK THEM WITH [DEPART ON EXPEDITION]. RETURNING HOME PAUSES THEM, NEVER RESETS THEM.'),
      if (active.isNotEmpty) ...[
        _label('ACTIVE', T.amber),
        for (final d in active) _card(d),
      ],
      _label('AVAILABLE', T.loot),
      if (open.isEmpty) _para('NOTHING NEW RIGHT NOW.'),
      for (final d in open) _card(d),
      if (locked.isNotEmpty) ...[
        _label('LOCKED'),
        for (final d in locked) _card(d),
      ],
      if (done.isNotEmpty) ...[
        _label('COMPLETED', T.green),
        for (final d in done) _card(d),
      ],
    ];
  }

  Widget _card(StoryDef d) {
    final s = _st.statusOf(d);
    final run = widget.state.story.runs[d.id];
    final c = _statusColor(s);
    final locked = s == StoryStatus.locked;
    final started = run != null && (s == StoryStatus.active || s == StoryStatus.paused);
    return InkWell(
      onTap: () => setState(() {
        _id = d.id;
        _journal = false;
        _confirm = false;
      }),
      child: Container(
        margin: const EdgeInsets.only(bottom: 6),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          border: Border.all(color: locked ? T.dim : c),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(d.title, style: T.mono(locked ? T.dim : T.green, size: 13, bold: true)),
          Text(_statusText(d, s), style: T.mono(c, size: 11, bold: true)),
          Text(
              'DESTINATION ${d.destinationKm} KM   REC. LV ${d.recommendedLevel}   DANGER: ${d.difficulty}',
              style: T.mono(T.label, size: 11)),
          if (started)
            Text(
                '${_bar(run!.done.length, d.checkpoints.length)}  ${run.km.toStringAsFixed(1)} / ${d.destinationKm} KM',
                style: T.mono(T.amber, size: 11)),
          if (locked && d.unlock.hint.isNotEmpty)
            Text(d.unlock.hint, style: T.mono(T.dim, size: 11)),
        ]),
      ),
    );
  }

  // --------------------------------------------------------------- detail

  List<Widget> _detail(StoryDef d) {
    final s = _st.statusOf(d);
    final run = widget.state.story.runs[d.id];
    final c = _statusColor(s);
    final locked = s == StoryStatus.locked;
    final runActive = s == StoryStatus.active || s == StoryStatus.paused;
    final hasActive = widget.state.story.activeId != null;
    return [
      _btn('◀ BACK', T.dim, () => setState(() {
            _id = null;
            _confirm = false;
          })),
      Text(d.title, style: T.mono(T.amber, size: 14, bold: true)),
      Text(_statusText(d, s), style: T.mono(c, size: 12, bold: true)),
      const SizedBox(height: 4),
      Text('DESTINATION ${d.destinationKm} KM   RECOMMENDED LV ${d.recommendedLevel}   DANGER: ${d.difficulty}',
          style: T.mono(T.label, size: 11)),
      const SizedBox(height: 8),
      if (locked) ...[
        _para(d.tagline, color: T.dim),
        _para('LOCKED. ${d.unlock.hint}', color: T.amber),
      ] else ...[
        for (final p in d.intro) _para(p),
        _para('REWARD: ${_rewardText(d)}.', color: T.loot),
      ],
      if (run != null) ...[
        _label('PROGRESS'),
        _para(
            '${_bar(run.done.length, d.checkpoints.length)}  ${run.km.toStringAsFixed(2)} / ${d.destinationKm} KM',
            color: T.amber),
        for (final cp in d.checkpoints)
          _para(
            run.done.contains(cp.id)
                ? '■ ${cp.km.toStringAsFixed(1)} KM  ${cp.title}'
                : '□ ${cp.km.toStringAsFixed(1)} KM  ${cp == d.checkpoints.last ? 'DESTINATION' : '???'}',
            color: run.done.contains(cp.id) ? T.green : T.dim,
          ),
      ],
      const SizedBox(height: 6),
      if (s == StoryStatus.available)
        _btn('[ACCEPT STORY EXPEDITION]', T.loot,
            hasActive ? null : () => widget.system.acceptStory(d.id)),
      if (s == StoryStatus.available && hasActive)
        _para('FINISH OR ABANDON YOUR ACTIVE STORY EXPEDITION FIRST.', color: T.amber),
      if (runActive && s == StoryStatus.paused)
        _btn('[DEPART ON EXPEDITION]  RESUME AT ${run?.km.toStringAsFixed(1)} KM', T.amber,
            widget.system.depart),
      if (run != null && run.journal.isNotEmpty)
        _btn('[JOURNAL]', T.green, () => setState(() => _journal = true)),
      if (runActive && s == StoryStatus.paused && !_confirm)
        _btn('[ABANDON STORY EXPEDITION]', T.red, () => setState(() => _confirm = true)),
      if (runActive && _confirm) ..._confirmRows(d, run),
    ];
  }

  List<Widget> _confirmRows(StoryDef d, StoryRun? run) {
    final n = run?.done.length ?? 0;
    final km = (run?.km ?? 0).toStringAsFixed(1);
    return [
      Container(
        margin: const EdgeInsets.only(bottom: 6),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          border: Border.all(color: T.red),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('ABANDON ${d.title}?', style: T.mono(T.red, size: 13, bold: true)),
          const SizedBox(height: 4),
          Text('YOU WILL LOSE:', style: T.mono(T.amber, size: 11, bold: true)),
          Text('- THE $km KM YOU HAVE TRAVELLED ON THIS JOURNEY', style: T.mono(T.label, size: 11)),
          Text('- $n COMPLETED CHECKPOINT${n == 1 ? '' : 'S'}', style: T.mono(T.label, size: 11)),
          Text('- EVERY DECISION YOU MADE AND EVERYTHING YOU DISCOVERED', style: T.mono(T.label, size: 11)),
          Text('- THE JOURNAL FOR THIS ATTEMPT', style: T.mono(T.label, size: 11)),
          const SizedBox(height: 4),
          Text('YOU KEEP:', style: T.mono(T.green, size: 11, bold: true)),
          Text('- ALL SCRAP, XP AND ITEMS YOU HAVE ALREADY EARNED', style: T.mono(T.label, size: 11)),
          Text('- THE CHANCE TO START THIS OR ANOTHER STORY EXPEDITION AGAIN FROM 0 KM',
              style: T.mono(T.label, size: 11)),
          Text('REWARDS ALREADY PAID WILL NOT BE PAID A SECOND TIME.',
              style: T.mono(T.amber, size: 11)),
        ]),
      ),
      _btn('[YES, ABANDON IT]', T.red, () {
        widget.system.abandonStory();
        setState(() {
          _confirm = false;
          _id = null;
        });
      }),
      _btn('[KEEP IT]', T.green, () => setState(() => _confirm = false)),
    ];
  }

  // -------------------------------------------------------------- journal

  List<Widget> _journalRows(StoryDef d) {
    final run = widget.state.story.runs[d.id];
    final entries = run?.journal ?? const <JournalEntry>[];
    return [
      _btn('◀ BACK', T.dim, () => setState(() => _journal = false)),
      Text('JOURNAL: ${d.title}', style: T.mono(T.amber, size: 14, bold: true)),
      const SizedBox(height: 6),
      if (entries.isEmpty) _para('NOTHING RECORDED YET.'),
      for (final e in entries) ...[
        Text(e.title, style: T.mono(e.cp == 'end' ? T.loot : T.green, size: 12, bold: true)),
        _para(e.text),
      ],
    ];
  }
}
