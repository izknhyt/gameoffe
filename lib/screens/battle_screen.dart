import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/character.dart';
import '../models/enemy.dart';
import '../models/skill.dart';
import '../providers/battle_provider.dart';

class BattleScreen extends ConsumerWidget {
  const BattleScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final battle = ref.watch(battleProvider);
    final notifier = ref.read(battleProvider.notifier);

    // Auto-execute enemy turn
    if (!battle.isPlayerTurn && !battle.battleOver) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Future.delayed(const Duration(milliseconds: 600), () {
          notifier.executeEnemyTurn();
        });
      });
    }

    return Scaffold(
      backgroundColor: const Color(0xFF1a1a2e),
      body: Column(
        children: [
          // Enemy display area
          Expanded(
            flex: 3,
            child: _EnemyArea(enemies: battle.enemies),
          ),
          // Battle log
          Expanded(
            flex: 2,
            child: _BattleLog(log: battle.log),
          ),
          // Party status
          _PartyStatus(party: battle.party),
          // Command area
          if (!battle.battleOver && battle.isPlayerTurn)
            _CommandArea(battle: battle, notifier: notifier)
          else if (battle.battleOver)
            _BattleResult(battle: battle, notifier: notifier),
        ],
      ),
    );
  }
}

class _EnemyArea extends StatelessWidget {
  final List<Enemy> enemies;
  const _EnemyArea({required this.enemies});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: enemies.map((enemy) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Enemy sprite placeholder
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: enemy.isAlive ? Colors.red[400] : Colors.grey[700],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      enemy.isAlive ? enemy.name[0] : 'X',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  enemy.name,
                  style: TextStyle(
                    color: enemy.isAlive ? Colors.white : Colors.grey,
                    fontSize: 14,
                  ),
                ),
                Text(
                  'HP: ${enemy.hp}/${enemy.maxHp}',
                  style: TextStyle(
                    color: enemy.isAlive ? Colors.green[300] : Colors.grey,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _BattleLog extends StatelessWidget {
  final List<BattleLogEntry> log;
  const _BattleLog({required this.log});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(8),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.black54,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.white24),
      ),
      child: ListView.builder(
        reverse: true,
        itemCount: log.length,
        itemBuilder: (context, index) {
          final entry = log[log.length - 1 - index];
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 1),
            child: Text(
              entry.message,
              style: const TextStyle(color: Colors.white70, fontSize: 13),
            ),
          );
        },
      ),
    );
  }
}

class _PartyStatus extends StatelessWidget {
  final List<Character> party;
  const _PartyStatus({required this.party});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      color: Colors.black87,
      child: Row(
        children: party.map((c) {
          return Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${c.name} [${c.row == BattleRow.front ? "前衛" : "後衛"}]',
                  style: TextStyle(
                    color: c.isAlive ? Colors.white : Colors.red[300],
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                // HP bar
                _StatBar(
                  label: 'HP',
                  current: c.hp,
                  max: c.maxHp,
                  color: Colors.green,
                ),
                _StatBar(
                  label: 'MP',
                  current: c.mp,
                  max: c.maxMp,
                  color: Colors.blue,
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _StatBar extends StatelessWidget {
  final String label;
  final int current;
  final int max;
  final Color color;

  const _StatBar({
    required this.label,
    required this.current,
    required this.max,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final ratio = max > 0 ? current / max : 0.0;
    return Row(
      children: [
        SizedBox(
          width: 24,
          child: Text(
            label,
            style: const TextStyle(color: Colors.white54, fontSize: 11),
          ),
        ),
        Expanded(
          child: Container(
            height: 8,
            decoration: BoxDecoration(
              color: Colors.grey[800],
              borderRadius: BorderRadius.circular(4),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: ratio,
              child: Container(
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 4),
        SizedBox(
          width: 48,
          child: Text(
            '$current/$max',
            style: const TextStyle(color: Colors.white70, fontSize: 10),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }
}

class _CommandArea extends StatefulWidget {
  final BattleState battle;
  final BattleNotifier notifier;

  const _CommandArea({required this.battle, required this.notifier});

  @override
  State<_CommandArea> createState() => _CommandAreaState();
}

class _CommandAreaState extends State<_CommandArea> {
  Skill? _selectedSkill;

  Character? get _currentCharacter {
    final actor = widget.battle.turnOrder[widget.battle.currentActorIndex];
    return actor is Character ? actor : null;
  }

  @override
  Widget build(BuildContext context) {
    final character = _currentCharacter;
    if (character == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(8),
      color: const Color(0xFF16213e),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${character.name}のターン',
            style: const TextStyle(
              color: Colors.amber,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          if (_selectedSkill == null)
            // Show skill list
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: character.skills.map((skill) {
                return _CommandButton(
                  label: '${skill.name}${skill.mpCost > 0 ? " (MP${skill.mpCost})" : ""}',
                  enabled: character.mp >= skill.mpCost,
                  onTap: () {
                    setState(() => _selectedSkill = skill);
                  },
                );
              }).toList(),
            )
          else
            // Show target selection
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${_selectedSkill!.name} → ターゲットを選択',
                  style: const TextStyle(color: Colors.white70, fontSize: 13),
                ),
                const SizedBox(height: 4),
                Wrap(
                  spacing: 8,
                  children: [
                    for (var i = 0; i < widget.battle.enemies.length; i++)
                      if (widget.battle.enemies[i].isAlive)
                        _CommandButton(
                          label: widget.battle.enemies[i].name,
                          onTap: () {
                            widget.notifier
                                .playerAction(_selectedSkill!, i);
                            setState(() => _selectedSkill = null);
                          },
                        ),
                    _CommandButton(
                      label: '戻る',
                      onTap: () => setState(() => _selectedSkill = null),
                    ),
                  ],
                ),
              ],
            ),
        ],
      ),
    );
  }
}

class _CommandButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final bool enabled;

  const _CommandButton({
    required this.label,
    required this.onTap,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          border: Border.all(
            color: enabled ? Colors.white54 : Colors.grey[700]!,
          ),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: enabled ? Colors.white : Colors.grey[600],
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}

class _BattleResult extends StatelessWidget {
  final BattleState battle;
  final BattleNotifier notifier;

  const _BattleResult({required this.battle, required this.notifier});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: const Color(0xFF16213e),
      child: Center(
        child: GestureDetector(
          onTap: () => notifier.finishBattle(),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.white54),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              battle.victory ? '勝利！ タップで続行' : 'ゲームオーバー...',
              style: TextStyle(
                color: battle.victory ? Colors.amber : Colors.red,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
