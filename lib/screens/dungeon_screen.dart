import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/dungeon.dart';
import '../providers/battle_provider.dart';
import '../providers/game_state_provider.dart';

class DungeonScreen extends ConsumerStatefulWidget {
  const DungeonScreen({super.key});

  @override
  ConsumerState<DungeonScreen> createState() => _DungeonScreenState();
}

class _DungeonScreenState extends ConsumerState<DungeonScreen> {
  final FocusNode _focusNode = FocusNode();

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  void _handleKey(KeyEvent event) {
    if (event is! KeyDownEvent) return;

    int dx = 0, dy = 0;
    switch (event.logicalKey) {
      case LogicalKeyboardKey.arrowUp:
      case LogicalKeyboardKey.keyW:
        dy = -1;
      case LogicalKeyboardKey.arrowDown:
      case LogicalKeyboardKey.keyS:
        dy = 1;
      case LogicalKeyboardKey.arrowLeft:
      case LogicalKeyboardKey.keyA:
        dx = -1;
      case LogicalKeyboardKey.arrowRight:
      case LogicalKeyboardKey.keyD:
        dx = 1;
      default:
        return;
    }

    final notifier = ref.read(gameStateProvider.notifier);
    notifier.movePlayer(dx, dy);

    // If battle triggered, start it
    final gameState = ref.read(gameStateProvider);
    if (gameState.currentScreen == GameScreen.battle) {
      _startBattle(gameState);
    }
  }

  void _startBattle(GameState gameState) {
    for (final spawn in gameState.activeEnemySpawns) {
      if (!spawn.defeated &&
          spawn.x == gameState.playerX &&
          spawn.y == gameState.playerY) {
        ref
            .read(battleProvider.notifier)
            .startBattle(gameState.party, spawn.enemyGroupId);
        break;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final gameState = ref.watch(gameStateProvider);
    final dungeon = gameState.currentDungeon;

    if (dungeon == null) return const SizedBox.shrink();

    return Scaffold(
      backgroundColor: Colors.black,
      body: KeyboardListener(
        focusNode: _focusNode,
        autofocus: true,
        onKeyEvent: _handleKey,
        child: Column(
          children: [
            // Dungeon name
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(8),
              color: Colors.black87,
              child: Text(
                dungeon.name,
                style: const TextStyle(color: Colors.white, fontSize: 16),
                textAlign: TextAlign.center,
              ),
            ),
            // Map view
            Expanded(
              child: Center(
                child: _DungeonMapView(
                  dungeon: dungeon,
                  playerX: gameState.playerX,
                  playerY: gameState.playerY,
                  enemySpawns: gameState.activeEnemySpawns,
                  completedEvents: gameState.completedEvents,
                ),
              ),
            ),
            // Party status bar
            Container(
              padding: const EdgeInsets.all(8),
              color: Colors.grey[900],
              child: Row(
                children: gameState.party.map((c) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 16),
                    child: Text(
                      '${c.name} HP:${c.hp}/${c.maxHp} MP:${c.mp}/${c.maxMp}',
                      style: TextStyle(
                        color: c.isAlive ? Colors.white : Colors.red,
                        fontSize: 14,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DungeonMapView extends StatelessWidget {
  final DungeonMap dungeon;
  final int playerX;
  final int playerY;
  final List<EnemySpawnState> enemySpawns;
  final Set<String> completedEvents;

  const _DungeonMapView({
    required this.dungeon,
    required this.playerX,
    required this.playerY,
    required this.enemySpawns,
    required this.completedEvents,
  });

  @override
  Widget build(BuildContext context) {
    const tileSize = 32.0;

    return SizedBox(
      width: dungeon.width * tileSize,
      height: dungeon.height * tileSize,
      child: Stack(
        children: [
          // Draw tiles
          for (var y = 0; y < dungeon.height; y++)
            for (var x = 0; x < dungeon.width; x++)
              Positioned(
                left: x * tileSize,
                top: y * tileSize,
                child: Container(
                  width: tileSize,
                  height: tileSize,
                  decoration: BoxDecoration(
                    color: _tileColor(dungeon.tiles[y][x]),
                    border: Border.all(color: Colors.black26, width: 0.5),
                  ),
                ),
              ),
          // Draw enemy symbols
          for (final spawn in enemySpawns)
            if (!spawn.defeated)
              Positioned(
                left: spawn.x * tileSize + 4,
                top: spawn.y * tileSize + 4,
                child: Container(
                  width: tileSize - 8,
                  height: tileSize - 8,
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Text('!', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
                  ),
                ),
              ),
          // Draw event markers
          for (var y = 0; y < dungeon.height; y++)
            for (var x = 0; x < dungeon.width; x++)
              if (dungeon.tiles[y][x].type == DungeonTileType.event &&
                  dungeon.tiles[y][x].eventId != null &&
                  !completedEvents.contains(dungeon.tiles[y][x].eventId))
                Positioned(
                  left: x * tileSize + 4,
                  top: y * tileSize + 4,
                  child: Container(
                    width: tileSize - 8,
                    height: tileSize - 8,
                    decoration: const BoxDecoration(
                      color: Colors.blue,
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: Text('?', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ),
          // Draw player
          Positioned(
            left: playerX * tileSize + 2,
            top: playerY * tileSize + 2,
            child: Container(
              width: tileSize - 4,
              height: tileSize - 4,
              decoration: BoxDecoration(
                color: Colors.amber,
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Center(
                child: Text('P', style: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _tileColor(DungeonTile tile) {
    switch (tile.type) {
      case DungeonTileType.wall:
        return Colors.grey[800]!;
      case DungeonTileType.floor:
      case DungeonTileType.event:
      case DungeonTileType.enemySpawn:
        return Colors.grey[600]!;
      case DungeonTileType.exit:
        return Colors.green[800]!;
    }
  }
}
