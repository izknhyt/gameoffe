/// Types of dungeon tiles the player can walk on or interact with.
enum DungeonTileType {
  floor,
  wall,
  exit, // connects to another dungeon / area
  event, // triggers an event (e.g. Cyrus joins)
  enemySpawn, // symbol encounter spawn point
}

/// A single tile in a dungeon map.
class DungeonTile {
  final DungeonTileType type;
  final String? eventId; // id of event to trigger, if type == event

  const DungeonTile({required this.type, this.eventId});

  bool get isWalkable => type != DungeonTileType.wall;
}

/// A dungeon map composed of a grid of tiles.
class DungeonMap {
  final String id;
  final String name;
  final int width;
  final int height;
  final List<List<DungeonTile>> tiles;
  final int playerStartX;
  final int playerStartY;
  final List<EnemySpawn> enemySpawns;
  final Map<String, DungeonExit> exits;

  const DungeonMap({
    required this.id,
    required this.name,
    required this.width,
    required this.height,
    required this.tiles,
    this.playerStartX = 1,
    this.playerStartY = 1,
    this.enemySpawns = const [],
    this.exits = const {},
  });
}

/// An enemy symbol that moves on the dungeon map.
class EnemySpawn {
  final String enemyGroupId;
  final int x;
  final int y;

  const EnemySpawn({
    required this.enemyGroupId,
    required this.x,
    required this.y,
  });
}

/// An exit point linking to another dungeon.
class DungeonExit {
  final String targetDungeonId;
  final int targetX;
  final int targetY;

  const DungeonExit({
    required this.targetDungeonId,
    required this.targetX,
    required this.targetY,
  });
}
