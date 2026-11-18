import 'dart:math';
import 'package:flutter/material.dart';
import '../game/character.dart';
import '../game/game_state.dart';
import '../game/home_system.dart';
import '../game/crafting.dart';
import '../game/items.dart';
import '../game/quests.dart';
import '../game/fx.dart';
import 'sprites.dart';
import 'theme.dart';

/// Terminal A while at the safehouse: a terminal-style menu.
class HomeView extends StatefulWidget {
  final GameState state;
  final HomeSystem system;
  const HomeView({super.key, required this.state, required this.system});
  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  String _tab = 'main';

  static const _titles = {
    'main': 'SAFEHOUSE TERMINAL',
    'supplies': 'SUPPLIES',
    'weapons': 'WEAPONS',
    'armor': 'ARMOR',
    'upgrades': 'SAFEHOUSE UPGRADES',
    'character': 'CHARACTER',
    'quests': 'QUEST BOARD',
    'workshop': 'WORKSHOP',
    'craft': 'CRAFTING',
    'repair': 'REPAIR',
  };

  void _go(String tab) => setState(() => _tab = tab);

  @override
  Widget build(BuildContext context) {
    final s = widget.state;
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(_titles[_tab]!, style: T.mono(T.green, size: 14, bold: true)),
          Text('LV ${s.level}  SCRAP ${s.scrap}  PARTS ${s.parts}  KITS ${s.kits}  HP ${s.hp}/${s.maxHp}',
              style: T.mono(T.loot, size: 12)),
          const SizedBox(height: 6),
          Expanded(child: ListView(children: _body(s))),
        ],
      ),
    );
  }

  List<Widget> _body(GameState s) {
    final sys = widget.system;
    switch (_tab) {
      case 'character':
        return _characterRows(s);
      case 'quests':
        return _questRows(s);
      case 'workshop':
        return _workshopRows(s);
      case 'craft':
        return _craftRows(s);
      case 'repair':
        return _repairRows(s);
      case 'supplies':
        return [
          _back(),
          _row('STIMPACK', 'HEALS ${s.stimHeal} HP   HAVE ${s.stimpacks}',
              'BUY ${HomeSystem.stimCost}', s.scrap >= HomeSystem.stimCost, sys.buyStimpack),
          _row('LOCKPICK', 'HAVE ${s.lockpicks}', 'BUY ${HomeSystem.pickCost}',
              s.scrap >= HomeSystem.pickCost, sys.buyLockpick),
        ];
      case 'weapons':
        return [_back(), ..._gearRows(s, GearSlot.weapon)];
      case 'armor':
        return [_back(), ..._gearRows(s, GearSlot.armor)];
      case 'upgrades':
        final medMax = s.medLevel >= HomeSystem.medCosts.length;
        final benchMax = s.benchLevel >= HomeSystem.benchCosts.length;
        return [
          _back(),
          _row(
            'MEDICAL STATION  LV ${s.medLevel}/${HomeSystem.medCosts.length}',
            'STIMPACKS HEAL ${s.stimHeal} HP (+10 PER LEVEL)',
            medMax ? 'MAX' : 'UPGRADE ${HomeSystem.medCosts[s.medLevel]}',
            !medMax && s.scrap >= HomeSystem.medCosts[s.medLevel],
            sys.upgradeMedical,
          ),
          _row(
            'SCAVENGING BENCH  LV ${s.benchLevel}/${HomeSystem.benchCosts.length}',
            'SCRAP FINDS +${s.benchLevel * 10}% (+10% PER LEVEL)',
            benchMax ? 'MAX' : 'UPGRADE ${HomeSystem.benchCosts[s.benchLevel]}',
            !benchMax && s.scrap >= HomeSystem.benchCosts[s.benchLevel],
            sys.upgradeBench,
          ),
          _row(
            'WORKSHOP  LV ${s.workshopLevel}/${HomeSystem.workshopCosts.length}',
            'REPAIRS -${s.workshopLevel * 15}% COST (-15% PER LEVEL)',
            s.workshopLevel >= HomeSystem.workshopCosts.length
                ? 'MAX'
                : 'UPGRADE ${HomeSystem.workshopCosts[s.workshopLevel]}',
            s.workshopLevel < HomeSystem.workshopCosts.length &&
                s.scrap >= HomeSystem.workshopCosts[s.workshopLevel],
            sys.upgradeWorkshop,
          ),
        ];
      default:
        return [
          const Padding(
            padding: EdgeInsets.only(bottom: 8),
            child: Align(
              alignment: Alignment.centerLeft,
              child: SpriteView(name: 'loc_safehouse', height: 64),
            ),
          ),
          _menuBtn('[DEPART ON EXPEDITION]', T.amber, sys.depart),
          _menuBtn('[REST]  RESTORE HP', T.green, sys.rest),
          _menuBtn('[CHARACTER]${s.statPoints > 0 ? '  (+${s.statPoints})' : ''}',
              s.statPoints > 0 ? T.loot : T.green, () => _go('character')),
          _menuBtn('[QUESTS]${s.quests.any((q) => q.ready) ? '  (!)' : ''}',
              s.quests.any((q) => q.ready) ? T.loot : T.green, () => _go('quests')),
          _menuBtn('[SUPPLIES]', T.green, () => _go('supplies')),
          _menuBtn('[WEAPONS]', T.green, () => _go('weapons')),
          _menuBtn('[ARMOR]', T.green, () => _go('armor')),
          _menuBtn('[WORKSHOP]', T.green, () => _go('workshop')),
          _menuBtn('[UPGRADES]', T.green, () => _go('upgrades')),
        ];
    }
  }

  String _durBar(int d) {
    final f = min(10, max(0, (d / 10).ceil()));
    return '${'■' * f}${'□' * (10 - f)}';
  }

  List<Widget> _workshopRows(GameState s) {
    final saving = min(70, s.workshopLevel * 15 + 2 * s.skill('ENGINEERING'));
    return [
      _back(),
      Text(
        'WORKSHOP LV ${s.workshopLevel}/${HomeSystem.workshopCosts.length}   ENGINEERING ${s.skill('ENGINEERING')}',
        style: T.mono(T.loot, size: 12, bold: true),
      ),
      const SizedBox(height: 4),
      Text('REPAIR COST -$saving%', style: T.mono(T.label, size: 11)),
      const SizedBox(height: 8),
      _menuBtn('[CRAFT]', T.green, () => _go('craft')),
      _menuBtn('[REPAIR]', T.green, () => _go('repair')),
    ];
  }

  List<Widget> _craftRows(GameState s) {
    final sys = widget.system;
    final eng = s.skill('ENGINEERING');
    return [
      _back(),
      Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Text('PARTS ${s.parts}   SCRAP ${s.scrap}   ENGINEERING $eng',
            style: T.mono(T.loot, size: 12, bold: true)),
      ),
      for (final r in recipes) _craftRow(s, sys, r, eng),
    ];
  }

  Widget _craftRow(GameState s, HomeSystem sys, Recipe r, int eng) {
    final locked = eng < r.minEng;
    final owned = r.kind == RecipeKind.gear && s.owned.contains(r.gearId);
    final ok = !locked && !owned && s.parts >= r.parts && s.scrap >= r.scrap;
    final sub = locked
        ? 'NEEDS ENGINEERING ${r.minEng}'
        : '${r.desc}  PARTS ${r.parts}  SCRAP ${r.scrap}';
    return _row(r.name, sub, owned ? 'OWNED' : (locked ? 'LOCKED' : 'CRAFT'), ok,
        () => sys.craft(r));
  }

  List<Widget> _repairRows(GameState s) {
    final sys = widget.system;
    return [
      _back(),
      Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Text('SCRAP ${s.scrap}   REPAIR KITS ${s.kits}',
            style: T.mono(T.loot, size: 12, bold: true)),
      ),
      for (final g in gearCatalog)
        if (s.owned.contains(g.id)) _repairRow(s, sys, g),
    ];
  }

  Widget _repairRow(GameState s, HomeSystem sys, Gear g) {
    final d = s.durOf(g.id);
    final missing = 100 - d;
    final cost = sys.repairCost(g, missing);
    final equipped = s.weaponId == g.id || s.armorId == g.id;
    final canPay = missing > 0 && s.scrap >= cost;
    final canKit = missing > 0 && s.kits > 0;
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        border: Border.all(color: T.dim),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('${g.name}${equipped ? '  (EQUIPPED)' : ''}',
              style: T.mono(T.green, size: 13, bold: true)),
          Text('CONDITION ${_durBar(d)} $d/100',
              style: T.mono(d <= 20 ? T.red : T.label, size: 11)),
          const SizedBox(height: 6),
          Row(children: [
            Expanded(
              child: _Btn(missing <= 0 ? 'FULL' : 'REPAIR $cost', canPay ? T.loot : T.dim,
                  canPay ? () => sys.repair(g) : null),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: _Btn('KIT x${s.kits}', canKit ? T.loot : T.dim,
                  canKit ? () => sys.useKit(g) : null),
            ),
          ]),
        ],
      ),
    );
  }

  String _reward(QuestDef d) {
    final parts = <String>['${d.rewardScrap} SCRAP', '${d.rewardXp} XP'];
    if (d.rewardStims > 0) parts.add('${d.rewardStims} STIM');
    if (d.rewardPicks > 0) parts.add('${d.rewardPicks} PICKS');
    return parts.join(', ');
  }

  List<Widget> _questRows(GameState s) {
    final sys = widget.system;
    final available = [
      for (final d in questCatalog)
        if (d.board &&
            d.minLevel <= s.level &&
            !s.questActive(d.id) &&
            !s.questsDone.contains(d.id))
          d
    ];
    return [
      _back(),
      Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Text('ACTIVE ${s.quests.length}/3', style: T.mono(T.loot, size: 12, bold: true)),
      ),
      if (s.quests.isEmpty) Text('NO ACTIVE QUESTS.', style: T.mono(T.label, size: 12)),
      for (final q in s.quests)
        _row(
          questById(q.id).title,
          '${questById(q.id).desc}  ${q.progress}/${questById(q.id).target}  REWARD: ${_reward(questById(q.id))}',
          q.ready ? 'CLAIM' : '${q.progress}/${questById(q.id).target}',
          q.ready,
          () => sys.claimQuest(q.id),
        ),
      Padding(
        padding: const EdgeInsets.only(top: 6, bottom: 6),
        child: Text('AVAILABLE', style: T.mono(T.label, size: 12)),
      ),
      if (available.isEmpty)
        Text('NOTHING NEW. CHECK BACK AS YOU LEVEL UP.', style: T.mono(T.label, size: 12)),
      for (final d in available)
        _row(d.title, '${d.desc}  REWARD: ${_reward(d)}', 'ACCEPT', s.quests.length < 3,
            () => sys.acceptQuest(d.id)),
      Padding(
        padding: const EdgeInsets.only(top: 6, bottom: 6),
        child: Text('CONTRACTS  (REPEATABLE)', style: T.mono(T.label, size: 12)),
      ),
      for (final id in s.contracts)
        _row(
          questById(id).title,
          '${questById(id).desc}  REWARD: ${_reward(questById(id))}',
          'ACCEPT',
          s.quests.length < 3,
          () => sys.acceptQuest(id),
        ),
      _row('NEW CONTRACTS', 'REPLACE THE BOARD WITH FRESH JOBS', 'REROLL 15',
          s.scrap >= 15, sys.rerollContracts),
    ];
  }

  List<Widget> _characterRows(GameState s) {
    final sys = widget.system;
    String fmt(double v) => v == v.roundToDouble() ? v.toStringAsFixed(0) : v.toStringAsFixed(1);
    String statEffect(String k) {
      final v = s.stat(k);
      switch (k) {
        case 'STR':
          return 'WEAPON DAMAGE +${s.strBonus}';
        case 'END':
          return 'MAX HP ${100 + 10 * (v - 1)}';
        case 'AGI':
          return 'ENEMIES MISS +${fmt(s.evadeBonus * 100)}%   ESCAPE +${3 * (v - 1)}%';
        case 'INT':
          return 'HACK ATTEMPTS ${s.hackAttempts}';
        case 'PER':
          return 'SCRAP FINDS +${3 * (v - 1)}%   MORE DISCOVERIES';
        default:
          return 'CRIT CHANCE ${fmt(s.critChance * 100)}%   BETTER DROPS';
      }
    }

    String skillEffect(String k) {
      final l = s.skill(k);
      switch (k) {
        case 'HACKING':
          return 'FEWER DECOY WORDS: ${l ~/ 2}';
        case 'LOCKPICKING':
          return 'SWEET SPOT +${fmt(0.8 * l)} DEG   STRAIN -${min(50, 4 * l)}%';
        case 'COMBAT':
          return 'HIT CHANCE +${min(20, 2 * l)}%';
        case 'SURVIVAL':
          return 'FASTER REGEN   HAZARD DAMAGE -${min(40, 4 * l)}%';
        case 'ENGINEERING':
          return 'REPAIR COST -${min(30, 2 * l)}%   SAVE PARTS ${min(30, 3 * l)}%';
        default:
          return 'SCRAP FINDS +${4 * l}%';
      }
    }

    return [
      _back(),
      Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Text(
          'LEVEL ${s.level}   XP ${s.xp}/${xpForLevel(s.level)}   POINTS ${s.statPoints}',
          style: T.mono(T.loot, size: 12, bold: true),
        ),
      ),
      for (final k in statKeys)
        _row(
          '${statNames[k]}  ${s.stat(k)}',
          statEffect(k),
          s.stat(k) >= maxStat ? 'MAX' : '+1',
          s.statPoints > 0 && s.stat(k) < maxStat,
          () => sys.spendStat(k),
        ),
      Padding(
        padding: const EdgeInsets.only(top: 6, bottom: 6),
        child: Text('SKILLS  (IMPROVE BY USE)', style: T.mono(T.label, size: 12)),
      ),
      for (final k in skillKeys)
        _info(
          '$k  LV ${s.skill(k)}',
          s.skill(k) >= maxSkill
              ? 'MAXED   ${skillEffect(k)}'
              : 'XP ${s.skillXp[k]}/${skillXpNeeded(s.skill(k))}   ${skillEffect(k)}',
        ),
    ];
  }

  Widget _info(String title, String sub) => Container(
        margin: const EdgeInsets.only(bottom: 6),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          border: Border.all(color: T.dim),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: T.mono(T.green, size: 13, bold: true)),
            Text(sub, style: T.mono(T.label, size: 11)),
          ],
        ),
      );

  List<Widget> _gearRows(GameState s, GearSlot slot) {
    final sys = widget.system;
    return [
      for (final g in gearCatalog.where((g) => g.slot == slot && (!g.craft || s.owned.contains(g.id))))
        _gearRow(s, sys, g, slot),
    ];
  }

  Widget _gearRow(GameState s, HomeSystem sys, Gear g, GearSlot slot) {
    final owned = s.owned.contains(g.id);
    final equipped = slot == GearSlot.weapon ? s.weaponId == g.id : s.armorId == g.id;
    final stats = slot == GearSlot.weapon
        ? 'DMG ${g.dmgMin}-${g.dmgMax}'
        : 'ARMOR ${g.armor}';
    final dur = owned ? '  DUR ${s.durOf(g.id)}' : '';
    if (equipped) return _row(g.name, '$stats$dur  ${g.blurb}', 'EQUIPPED', false, null);
    if (owned) return _row(g.name, '$stats$dur  ${g.blurb}', 'EQUIP', true, () => sys.equip(g));
    return _row(g.name, '$stats$dur  ${g.blurb}', 'BUY ${g.cost}', s.scrap >= g.cost,
        () => sys.buyGear(g));
  }

  Widget _back() => _menuBtn('◀ BACK', T.dim, () => _go('main'));

  Widget _menuBtn(String label, Color color, VoidCallback onTap) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: _Btn(label, color, onTap),
      );

  Widget _row(String title, String sub, String label, bool enabled, VoidCallback? onTap) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        border: Border.all(color: T.dim),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: T.mono(T.green, size: 13, bold: true)),
              Text(sub, style: T.mono(T.label, size: 11)),
            ],
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: 104,
          child: _Btn(label, enabled ? T.loot : T.dim, enabled ? onTap : null),
        ),
      ]),
    );
  }
}

class _Btn extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback? onTap;
  const _Btn(this.label, this.color, this.onTap);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap == null
          ? null
          : () {
              Fx.play(Sfx.beep);
              onTap!();
            },
      child: Container(
        constraints: const BoxConstraints(minHeight: 40),
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 6),
        decoration: BoxDecoration(
          border: Border.all(color: color),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(label,
            textAlign: TextAlign.center, style: T.mono(color, size: 12, bold: true)),
      ),
    );
  }
}
