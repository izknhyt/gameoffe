import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/enemies.dart';
import '../models/character.dart';
import '../models/element.dart';
import '../models/enemy.dart';
import '../models/skill.dart';
import 'game_state_provider.dart';

/// A single line in the battle log.
class BattleLogEntry {
  final String message;
  BattleLogEntry(this.message);
}

/// State of an ongoing battle.
class BattleState {
  final List<Character> party;
  final List<Enemy> enemies;
  final List<BattleLogEntry> log;
  final int currentActorIndex; // index into turn order
  final List<dynamic> turnOrder; // Characters and Enemies interleaved
  final bool isPlayerTurn;
  final bool battleOver;
  final bool victory;

  const BattleState({
    this.party = const [],
    this.enemies = const [],
    this.log = const [],
    this.currentActorIndex = 0,
    this.turnOrder = const [],
    this.isPlayerTurn = true,
    this.battleOver = false,
    this.victory = false,
  });

  BattleState copyWith({
    List<Character>? party,
    List<Enemy>? enemies,
    List<BattleLogEntry>? log,
    int? currentActorIndex,
    List<dynamic>? turnOrder,
    bool? isPlayerTurn,
    bool? battleOver,
    bool? victory,
  }) {
    return BattleState(
      party: party ?? this.party,
      enemies: enemies ?? this.enemies,
      log: log ?? this.log,
      currentActorIndex: currentActorIndex ?? this.currentActorIndex,
      turnOrder: turnOrder ?? this.turnOrder,
      isPlayerTurn: isPlayerTurn ?? this.isPlayerTurn,
      battleOver: battleOver ?? this.battleOver,
      victory: victory ?? this.victory,
    );
  }
}

class BattleNotifier extends StateNotifier<BattleState> {
  final Random _rng = Random();
  final GameStateNotifier _gameNotifier;

  BattleNotifier(this._gameNotifier) : super(const BattleState());

  /// Start a battle with the given enemy group.
  void startBattle(List<Character> party, String enemyGroupId) {
    final enemies = _createEnemyGroup(enemyGroupId);
    final log = [BattleLogEntry('${enemies.map((e) => e.name).join('と')}が現れた！')];

    // Build turn order based on speed
    final turnOrder = _buildTurnOrder(party, enemies);
    final firstActor = turnOrder[0];
    final isPlayerTurn = firstActor is Character;

    state = BattleState(
      party: party,
      enemies: enemies,
      log: log,
      currentActorIndex: 0,
      turnOrder: turnOrder,
      isPlayerTurn: isPlayerTurn,
    );
  }

  List<Enemy> _createEnemyGroup(String groupId) {
    switch (groupId) {
      case 'slime_x2':
        return [createSlime(), createSlime()];
      case 'shadow_x1':
        return [createShadow()];
      default:
        return [createSlime()];
    }
  }

  List<dynamic> _buildTurnOrder(List<Character> party, List<Enemy> enemies) {
    final actors = <MapEntry<dynamic, int>>[];
    for (final c in party) {
      if (c.isAlive) actors.add(MapEntry(c, c.speed));
    }
    for (final e in enemies) {
      if (e.isAlive) actors.add(MapEntry(e, e.speed));
    }
    actors.sort((a, b) => b.value.compareTo(a.value));
    return actors.map((e) => e.key).toList();
  }

  /// Player uses a skill on a target enemy.
  void playerAction(Skill skill, int targetIndex) {
    if (state.battleOver || !state.isPlayerTurn) return;

    final actor = state.turnOrder[state.currentActorIndex];
    if (actor is! Character) return;

    final target = state.enemies[targetIndex];
    if (!target.isAlive) return;

    // MP check
    if (actor.mp < skill.mpCost) {
      _addLog('${actor.name}のMPが足りない！');
      return;
    }

    actor.mp -= skill.mpCost;

    // Damage calculation
    final damage = _calcDamage(
      power: skill.power,
      attack: skill.element == Element.none ||
              skill.element == Element.slash ||
              skill.element == Element.strike ||
              skill.element == Element.thrust
          ? actor.attack
          : actor.magicAttack,
      defense: skill.element == Element.none ||
              skill.element == Element.slash ||
              skill.element == Element.strike ||
              skill.element == Element.thrust
          ? target.defense
          : target.magicDefense,
      elementResistance: target.elementResistance[skill.element] ?? 0.0,
    );

    target.hp = (target.hp - damage).clamp(0, target.maxHp);
    _addLog('${actor.name}の${skill.name}！ ${target.name}に${damage}ダメージ！');

    if (!target.isAlive) {
      _addLog('${target.name}を倒した！');
    }

    _checkBattleEnd();
    if (!state.battleOver) {
      _advanceTurn();
    }
  }

  /// Execute enemy AI turn.
  void executeEnemyTurn() {
    if (state.battleOver || state.isPlayerTurn) return;

    final actor = state.turnOrder[state.currentActorIndex];
    if (actor is! Enemy || !actor.isAlive) {
      _advanceTurn();
      return;
    }

    // Simple AI: pick a random alive party member and attack
    final aliveParty = state.party.where((c) => c.isAlive).toList();
    if (aliveParty.isEmpty) return;

    final target = aliveParty[_rng.nextInt(aliveParty.length)];

    // Pick a skill (or basic attack)
    final skill = actor.skills.isNotEmpty
        ? actor.skills[_rng.nextInt(actor.skills.length)]
        : const Skill(
            id: 'attack', name: '攻撃', element: Element.none, power: 10);

    final isPhysical = skill.element == Element.none ||
        skill.element == Element.slash ||
        skill.element == Element.strike ||
        skill.element == Element.thrust;

    final damage = _calcDamage(
      power: skill.power,
      attack: isPhysical ? actor.attack : actor.magicAttack,
      defense: isPhysical ? target.defense : target.magicDefense,
      elementResistance: target.elementResistance[skill.element] ?? 0.0,
    );

    target.hp = (target.hp - damage).clamp(0, target.maxHp);
    _addLog('${actor.name}の${skill.name}！ ${target.name}に${damage}ダメージ！');

    if (!target.isAlive) {
      _addLog('${target.name}は倒れた...');
    }

    _checkBattleEnd();
    if (!state.battleOver) {
      _advanceTurn();
    }
  }

  int _calcDamage({
    required int power,
    required int attack,
    required int defense,
    required double elementResistance,
  }) {
    final base = (power * (attack / max(defense, 1))).round();
    final modified = (base * (1.0 - elementResistance)).round();
    // Add slight randomness
    final variance = max(1, (modified * 0.1).round());
    return max(1, modified + _rng.nextInt(variance * 2 + 1) - variance);
  }

  void _addLog(String message) {
    state = state.copyWith(log: [...state.log, BattleLogEntry(message)]);
  }

  void _checkBattleEnd() {
    if (state.enemies.every((e) => !e.isAlive)) {
      // Victory
      final totalExp =
          state.enemies.fold<int>(0, (sum, e) => sum + e.expReward);
      _addLog('戦闘に勝利した！ ${totalExp}EXP獲得！');
      for (final c in state.party) {
        if (c.isAlive) c.exp += totalExp;
      }
      state = state.copyWith(battleOver: true, victory: true);
    } else if (state.party.every((c) => !c.isAlive)) {
      // Defeat
      _addLog('全滅した...');
      state = state.copyWith(battleOver: true, victory: false);
    }
  }

  void _advanceTurn() {
    var next = (state.currentActorIndex + 1) % state.turnOrder.length;

    // Skip dead actors
    var attempts = 0;
    while (attempts < state.turnOrder.length) {
      final actor = state.turnOrder[next];
      if (actor is Character && actor.isAlive) {
        state = state.copyWith(currentActorIndex: next, isPlayerTurn: true);
        return;
      } else if (actor is Enemy && actor.isAlive) {
        state = state.copyWith(currentActorIndex: next, isPlayerTurn: false);
        return;
      }
      next = (next + 1) % state.turnOrder.length;
      attempts++;
    }
  }

  /// End the battle and return to dungeon.
  void finishBattle() {
    _gameNotifier.endBattle(victory: state.victory);
  }
}

final battleProvider =
    StateNotifierProvider<BattleNotifier, BattleState>((ref) {
  final gameNotifier = ref.read(gameStateProvider.notifier);
  return BattleNotifier(gameNotifier);
});
