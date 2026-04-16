/// <summary>
/// Factory methods for creating dungeon maps.
/// </summary>
public static class DungeonDatabase
{
    public static DungeonMap CreateFirstDungeon()
    {
        // # = wall, . = floor
        string[] layout =
        {
            "##############",
            "#............#",
            "#.####.#####.#",
            "#.#..........#",
            "#.#.##.####..#",
            "#....#....#..#",
            "#.##.#.##.#..#",
            "#.#..#..#.#..#",
            "#.#.###.#....#",
            "#...#...#.##.#",
            "#.###.###....#",
            "#............#",
            "##############",
        };

        int height = layout.Length;
        int width = layout[0].Length;
        var tiles = new DungeonTile[height, width];

        for (int y = 0; y < height; y++)
        {
            for (int x = 0; x < width; x++)
            {
                char c = layout[y][x];
                tiles[y, x] = c == '#'
                    ? new DungeonTile(DungeonTileType.Wall)
                    : new DungeonTile(DungeonTileType.Floor);
            }
        }

        // Place Cyrus event at a deeper location
        tiles[9, 10] = new DungeonTile(DungeonTileType.Event, "cyrus_join");

        var dungeon = new DungeonMap(
            id: "memory_corridor",
            dungeonName: "記憶の回廊",
            width: width,
            height: height,
            tiles: tiles,
            playerStartX: 1,
            playerStartY: 1
        );

        // Place enemy spawns
        dungeon.enemySpawns.Add(new EnemySpawn("slime_x2", 5, 3));
        dungeon.enemySpawns.Add(new EnemySpawn("slime_x2", 9, 7));
        dungeon.enemySpawns.Add(new EnemySpawn("shadow_x1", 7, 10));

        return dungeon;
    }
}
