using System;
using System.Collections.Generic;

public enum DungeonTileType
{
    Floor,
    Wall,
    Exit,
    Event,
    EnemySpawn,
}

[Serializable]
public class DungeonTile
{
    public DungeonTileType type;
    public string eventId;

    public bool IsWalkable => type != DungeonTileType.Wall;

    public DungeonTile(DungeonTileType type, string eventId = null)
    {
        this.type = type;
        this.eventId = eventId;
    }
}

[Serializable]
public class EnemySpawn
{
    public string enemyGroupId;
    public int x;
    public int y;
    public bool defeated;

    public EnemySpawn(string enemyGroupId, int x, int y)
    {
        this.enemyGroupId = enemyGroupId;
        this.x = x;
        this.y = y;
        this.defeated = false;
    }
}

[Serializable]
public class DungeonExit
{
    public string targetDungeonId;
    public int targetX;
    public int targetY;

    public DungeonExit(string targetDungeonId, int targetX, int targetY)
    {
        this.targetDungeonId = targetDungeonId;
        this.targetX = targetX;
        this.targetY = targetY;
    }
}

/// <summary>
/// A dungeon map composed of a grid of tiles.
/// </summary>
[Serializable]
public class DungeonMap
{
    public string id;
    public string dungeonName;
    public int width;
    public int height;
    public DungeonTile[,] tiles;
    public int playerStartX;
    public int playerStartY;
    public List<EnemySpawn> enemySpawns;
    public Dictionary<string, DungeonExit> exits;

    public DungeonMap(
        string id,
        string dungeonName,
        int width,
        int height,
        DungeonTile[,] tiles,
        int playerStartX = 1,
        int playerStartY = 1)
    {
        this.id = id;
        this.dungeonName = dungeonName;
        this.width = width;
        this.height = height;
        this.tiles = tiles;
        this.playerStartX = playerStartX;
        this.playerStartY = playerStartY;
        this.enemySpawns = new List<EnemySpawn>();
        this.exits = new Dictionary<string, DungeonExit>();
    }
}
