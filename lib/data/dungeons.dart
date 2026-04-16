import '../models/dungeon.dart';

/// Build the first prototype dungeon - a small map where Sophie starts
/// and eventually finds Cyrus.
DungeonMap createFirstDungeon() {
  // Legend: . = floor, # = wall, E = exit, C = event (Cyrus), S = enemy spawn
  const layout = [
    '##############',
    '#............#',
    '#.####.#####.#',
    '#.#..........#',
    '#.#.##.####..#',
    '#....#....#..#',
    '#.##.#.##.#..#',
    '#.#..#..#.#..#',
    '#.#.###.#....#',
    '#...#...#.##.#',
    '#.###.###....#',
    '#............#',
    '##############',
  ];

  final height = layout.length;
  final width = layout[0].length;

  final tiles = <List<DungeonTile>>[];
  final enemySpawns = <EnemySpawn>[];
  final exits = <String, DungeonExit>{};

  for (var y = 0; y < height; y++) {
    final row = <DungeonTile>[];
    for (var x = 0; x < width; x++) {
      final c = layout[y][x];
      switch (c) {
        case '#':
          row.add(const DungeonTile(type: DungeonTileType.wall));
        case '.':
          row.add(const DungeonTile(type: DungeonTileType.floor));
        default:
          row.add(const DungeonTile(type: DungeonTileType.floor));
      }
    }
    tiles.add(row);
  }

  // Place Cyrus event at a deeper location
  tiles[9][10] = const DungeonTile(
    type: DungeonTileType.event,
    eventId: 'cyrus_join',
  );

  // Place enemy spawns
  enemySpawns.addAll([
    const EnemySpawn(enemyGroupId: 'slime_x2', x: 5, y: 3),
    const EnemySpawn(enemyGroupId: 'slime_x2', x: 9, y: 7),
    const EnemySpawn(enemyGroupId: 'shadow_x1', x: 7, y: 10),
  ]);

  return DungeonMap(
    id: 'memory_corridor',
    name: '記憶の回廊',
    width: width,
    height: height,
    tiles: tiles,
    playerStartX: 1,
    playerStartY: 1,
    enemySpawns: enemySpawns,
    exits: exits,
  );
}
