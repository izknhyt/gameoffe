import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/characters.dart';
import '../data/dungeons.dart';
import '../models/character.dart';
import '../models/dungeon.dart';

/// Represents which screen the game is currently showing.
enum GameScreen { title, dungeon, battle, event }

/// The entire game state.
class GameState {
  final GameScreen currentScreen;
  final List<Character> party;
  final DungeonMap? currentDungeon;
  final int playerX;
  final int playerY;
  final Set<String> completedEvents;
  final List<EnemySpawnState> activeEnemySpawns;

  const GameState({
    this.currentScreen = GameScreen.title,
    this.party = const [],
    this.currentDungeon,
    this.playerX = 1,
    this.playerY = 1,
    this.completedEvents = const {},
    this.activeEnemySpawns = const [],
  });

  GameState copyWith({
    GameScreen? currentScreen,
    List<Character>? party,
    DungeonMap? currentDungeon,
    int? playerX,
    int? playerY,
    Set<String>? completedEvents,
    List<EnemySpawnState>? activeEnemySpawns,
  }) {
    return GameState(
      currentScreen: currentScreen ?? this.currentScreen,
      party: party ?? this.party,
      currentDungeon: currentDungeon ?? this.currentDungeon,
      playerX: playerX ?? this.playerX,
      playerY: playerY ?? this.playerY,
      completedEvents: completedEvents ?? this.completedEvents,
      activeEnemySpawns: activeEnemySpawns ?? this.activeEnemySpawns,
    );
  }
}

/// Tracks a symbol encounter enemy on the dungeon map.
class EnemySpawnState {
  final String enemyGroupId;
  int x;
  int y;
  bool defeated;

  EnemySpawnState({
    required this.enemyGroupId,
    required this.x,
    required this.y,
    this.defeated = false,
  });
}

class GameStateNotifier extends StateNotifier<GameState> {
  GameStateNotifier() : super(const GameState());

  /// Start a new game.
  void newGame() {
    final dungeon = createFirstDungeon();
    final spawns = dungeon.enemySpawns
        .map((s) => EnemySpawnState(
              enemyGroupId: s.enemyGroupId,
              x: s.x,
              y: s.y,
            ))
        .toList();

    state = GameState(
      currentScreen: GameScreen.dungeon,
      party: [createSophie()],
      currentDungeon: dungeon,
      playerX: dungeon.playerStartX,
      playerY: dungeon.playerStartY,
      completedEvents: {},
      activeEnemySpawns: spawns,
    );
  }

  /// Move the player by a delta. Returns true if movement happened.
  bool movePlayer(int dx, int dy) {
    final dungeon = state.currentDungeon;
    if (dungeon == null) return false;

    final newX = state.playerX + dx;
    final newY = state.playerY + dy;

    // Bounds check
    if (newX < 0 || newX >= dungeon.width) return false;
    if (newY < 0 || newY >= dungeon.height) return false;

    // Wall check
    if (!dungeon.tiles[newY][newX].isWalkable) return false;

    state = state.copyWith(playerX: newX, playerY: newY);

    // Check for event trigger
    final tile = dungeon.tiles[newY][newX];
    if (tile.type == DungeonTileType.event && tile.eventId != null) {
      if (!state.completedEvents.contains(tile.eventId)) {
        _triggerEvent(tile.eventId!);
      }
    }

    // Check for enemy encounter
    _checkEnemyEncounter(newX, newY);

    return true;
  }

  void _triggerEvent(String eventId) {
    if (eventId == 'cyrus_join') {
      state = state.copyWith(
        currentScreen: GameScreen.event,
      );
    }
  }

  /// Complete the Cyrus join event.
  void completeCyrusEvent() {
    final updatedParty = [...state.party, createCyrus()];
    final updatedEvents = {...state.completedEvents, 'cyrus_join'};
    state = state.copyWith(
      currentScreen: GameScreen.dungeon,
      party: updatedParty,
      completedEvents: updatedEvents,
    );
  }

  void _checkEnemyEncounter(int x, int y) {
    for (final spawn in state.activeEnemySpawns) {
      if (!spawn.defeated && spawn.x == x && spawn.y == y) {
        state = state.copyWith(currentScreen: GameScreen.battle);
        return;
      }
    }
  }

  /// Mark the current encounter enemy as defeated and return to dungeon.
  void endBattle({required bool victory}) {
    if (victory) {
      final spawns = state.activeEnemySpawns;
      for (final spawn in spawns) {
        if (spawn.x == state.playerX && spawn.y == state.playerY) {
          spawn.defeated = true;
          break;
        }
      }
      state = state.copyWith(
        currentScreen: GameScreen.dungeon,
        activeEnemySpawns: spawns,
      );
    } else {
      // Game over - back to title for now
      state = const GameState(currentScreen: GameScreen.title);
    }
  }

  void returnToTitle() {
    state = const GameState(currentScreen: GameScreen.title);
  }

  void switchScreen(GameScreen screen) {
    state = state.copyWith(currentScreen: screen);
  }
}

final gameStateProvider =
    StateNotifierProvider<GameStateNotifier, GameState>((ref) {
  return GameStateNotifier();
});
