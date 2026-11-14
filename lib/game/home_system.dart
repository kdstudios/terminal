import 'dart:math';
import 'crafting.dart';
import 'game_state.dart';
import 'items.dart';
import 'quests.dart';
import 'flavor.dart';
import 'world.dart';

/// Everything you can do at the safehouse: rest, shop, equip, upgrade, depart.
class HomeSystem {
  static const stimCost = 30;
  static const pickCost = 20;
  static const medCosts = [120, 250, 450]; // 3 levels
  static const benchCosts = [100, 220, 400]; // 3 levels
  static const workshopCosts = [110, 240, 420]; // 3 levels

  final GameState state;
  final Random _rng = Random();
  HomeSystem(this.state);

  bool get atHome => state.mode == GameMode.home;

  bool _pay(int cost) {
    if (state.scrap < cost) {
      state.addLog('> NOT ENOUGH SCRAP.', LogKind.warning);
      return false;
    }
    state.scrap -= cost;
    return true;
  }

  void rest() {
    if (!atHome) return;
    if (state.hp >= state.maxHp) {
      state.addLog('> YOU ARE ALREADY RESTED.', LogKind.narrative);
      return;
    }
    state.hp = state.maxHp;
    state.addLog('> RESTED. HP RESTORED.', LogKind.loot);
  }

  void buyStimpack() {
    if (!atHome || !_pay(stimCost)) return;
    state.stimpacks++;
    state.addLog('> PURCHASED: STIMPACK (-$stimCost SCRAP)', LogKind.loot);
  }

  void buyLockpick() {
    if (!atHome || !_pay(pickCost)) return;
    state.lockpicks++;
    state.addLog('> PURCHASED: LOCKPICK (-$pickCost SCRAP)', LogKind.loot);
  }

  void buyGear(Gear g) {
    if (!atHome || state.owned.contains(g.id) || !_pay(g.cost)) return;
    state.owned.add(g.id);
    _equip(g);
    state.addLog('> PURCHASED: ${g.name} (-${g.cost} SCRAP)', LogKind.loot);
  }

  void equip(Gear g) {
    if (!atHome || !state.owned.contains(g.id)) return;
    _equip(g);
    state.addLog('> EQUIPPED: ${g.name}', LogKind.system);
  }

  void _equip(Gear g) {
    if (g.slot == GearSlot.weapon) {
      state.weaponId = g.id;
    } else {
      state.armorId = g.id;
    }
  }

  void upgradeMedical() {
    if (!atHome || state.medLevel >= medCosts.length) return;
    if (!_pay(medCosts[state.medLevel])) return;
    state.medLevel++;
    state.addLog(
        '> MEDICAL STATION LV ${state.medLevel}: STIMPACKS NOW HEAL ${state.stimHeal} HP',
        LogKind.loot);
  }

  void upgradeBench() {
    if (!atHome || state.benchLevel >= benchCosts.length) return;
    if (!_pay(benchCosts[state.benchLevel])) return;
    state.benchLevel++;
    state.addLog(
        '> SCAVENGING BENCH LV ${state.benchLevel}: SCRAP FINDS +${state.benchLevel * 10}%',
        LogKind.loot);
  }

  /// A full repair costs roughly 30% of the item's price. The Workshop and
  /// Engineering skill make it cheaper.
  int repairCost(Gear g, int points) {
    if (points <= 0) return 0;
    final base = max(40, g.cost) * points * 0.003;
    final discount =
        max(0.3, 1 - 0.15 * state.workshopLevel - 0.02 * state.skill('ENGINEERING'));
    return max(1, (base * discount).ceil());
  }

  void repair(Gear g) {
    if (!atHome) return;
    final missing = 100 - state.durOf(g.id);
    if (missing <= 0) return;
    final cost = repairCost(g, missing);
    if (!_pay(cost)) return;
    state.dura[g.id] = 100;
    state.gainSkill('ENGINEERING');
    state.addLog('> REPAIRED: ${g.name} (-$cost SCRAP)', LogKind.loot);
  }

  void useKit(Gear g) {
    if (!atHome || state.kits <= 0) return;
    if (100 - state.durOf(g.id) <= 0) return;
    state.kits--;
    state.dura[g.id] = min(100, state.durOf(g.id) + 40);
    state.gainSkill('ENGINEERING');
    state.addLog('> REPAIR KIT USED ON ${g.name}', LogKind.loot);
  }

  void upgradeWorkshop() {
    if (!atHome || state.workshopLevel >= workshopCosts.length) return;
    if (!_pay(workshopCosts[state.workshopLevel])) return;
    state.workshopLevel++;
    state.addLog('> WORKSHOP LV ${state.workshopLevel}: REPAIRS -${state.workshopLevel * 15}% COST',
        LogKind.loot);
  }

  void craft(Recipe r) {
    if (!atHome) return;
    final eng = state.skill('ENGINEERING');
    if (eng < r.minEng) {
      state.addLog('> NEEDS ENGINEERING ${r.minEng}.', LogKind.warning);
      return;
    }
    if (r.kind == RecipeKind.gear && state.owned.contains(r.gearId)) return;
    if (state.parts < r.parts) {
      state.addLog('> NOT ENOUGH PARTS.', LogKind.warning);
      return;
    }
    if (!_pay(r.scrap)) return;
    state.parts -= r.parts;
    if (_rng.nextDouble() < min(0.3, 0.03 * eng)) {
      state.parts += r.parts;
      state.addLog('(YOUR ENGINEERING SAVES THE PARTS)', LogKind.narrative, notify: false);
    }
    switch (r.kind) {
      case RecipeKind.stimpack:
        state.stimpacks += r.amount;
        break;
      case RecipeKind.lockpicks:
        state.lockpicks += r.amount;
        break;
      case RecipeKind.kit:
        state.kits += r.amount;
        break;
      case RecipeKind.gear:
        state.owned.add(r.gearId!);
        state.dura[r.gearId!] = 100;
        state.addLog('(EQUIP IT FROM THE WEAPONS OR ARMOR MENU)', LogKind.narrative,
            notify: false);
        break;
    }
    state.gainXp(8);
    state.gainSkill('ENGINEERING', 2);
    state.questEvent(QuestKind.crafts, 1);
    state.addLog('> CRAFTED: ${r.name}', LogKind.loot);
  }

  /// Swap the board's contracts for fresh ones (costs a little scrap).
  void rerollContracts() {
    if (!atHome || !_pay(15)) return;
    state.refreshContracts(reroll: true);
    state.addLog('> THE BOARD IS REFRESHED.', LogKind.system);
  }

  void acceptQuest(String id) {
    if (!atHome) return;
    state.acceptQuest(id);
  }

  void claimQuest(String id) {
    if (!atHome) return;
    state.claimQuest(id);
  }

  void spendStat(String key) {
    if (!atHome) return;
    state.spendStat(key);
  }

  /// Head out on a fresh expedition from 0 km.
  void depart() {
    if (!atHome) return;
    state.beginExpedition();
    final starts = [...startThoughts, ...extraStartThoughts];
    state.addLog(starts[_rng.nextInt(starts.length)], LogKind.thought);
  }

  /// Abandon the expedition and come home with what you have.
  void returnHome() {
    if (state.mode != GameMode.exploring) return;
    state.arriveHome();
  }
}
