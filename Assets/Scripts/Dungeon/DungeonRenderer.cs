using UnityEngine;

/// <summary>
/// Renders the dungeon map using simple colored tiles.
/// Attach to a GameObject in the Dungeon scene.
/// </summary>
public class DungeonRenderer : MonoBehaviour
{
    [SerializeField] float tileSize = 1f;

    GameObject playerObj;
    GameObject[,] tileObjects;
    GameObject[] enemyObjects;
    GameObject[] eventObjects;

    public void RenderDungeon(DungeonMap dungeon)
    {
        ClearAll();

        tileObjects = new GameObject[dungeon.height, dungeon.width];

        for (int y = 0; y < dungeon.height; y++)
        {
            for (int x = 0; x < dungeon.width; x++)
            {
                var tile = dungeon.tiles[y, x];
                var obj = GameObject.CreatePrimitive(PrimitiveType.Quad);
                obj.transform.SetParent(transform);
                obj.transform.position = TileToWorld(x, y);
                obj.transform.localScale = Vector3.one * tileSize * 0.95f;
                obj.GetComponent<Renderer>().material.color = TileColor(tile);
                obj.name = $"Tile_{x}_{y}";
                tileObjects[y, x] = obj;
            }
        }

        RenderEnemySpawns(dungeon);
        RenderEventMarkers(dungeon);
    }

    void RenderEnemySpawns(DungeonMap dungeon)
    {
        int aliveCount = 0;
        foreach (var s in dungeon.enemySpawns)
            if (!s.defeated) aliveCount++;

        enemyObjects = new GameObject[aliveCount];
        int i = 0;
        foreach (var spawn in dungeon.enemySpawns)
        {
            if (spawn.defeated) continue;
            var obj = GameObject.CreatePrimitive(PrimitiveType.Sphere);
            obj.transform.SetParent(transform);
            obj.transform.position = TileToWorld(spawn.x, spawn.y) + Vector3.forward * -0.1f;
            obj.transform.localScale = Vector3.one * tileSize * 0.5f;
            obj.GetComponent<Renderer>().material.color = Color.red;
            obj.name = $"Enemy_{spawn.enemyGroupId}";
            enemyObjects[i++] = obj;
        }
    }

    void RenderEventMarkers(DungeonMap dungeon)
    {
        var events = new System.Collections.Generic.List<GameObject>();
        var completedEvents = GameManager.Instance.CompletedEvents;

        for (int y = 0; y < dungeon.height; y++)
        {
            for (int x = 0; x < dungeon.width; x++)
            {
                var tile = dungeon.tiles[y, x];
                if (tile.type == DungeonTileType.Event &&
                    tile.eventId != null &&
                    !completedEvents.Contains(tile.eventId))
                {
                    var obj = GameObject.CreatePrimitive(PrimitiveType.Sphere);
                    obj.transform.SetParent(transform);
                    obj.transform.position = TileToWorld(x, y) + Vector3.forward * -0.1f;
                    obj.transform.localScale = Vector3.one * tileSize * 0.5f;
                    obj.GetComponent<Renderer>().material.color = Color.cyan;
                    obj.name = $"Event_{tile.eventId}";
                    events.Add(obj);
                }
            }
        }
        eventObjects = events.ToArray();
    }

    public void UpdatePlayer(int x, int y)
    {
        if (playerObj == null)
        {
            playerObj = GameObject.CreatePrimitive(PrimitiveType.Cube);
            playerObj.transform.SetParent(transform);
            playerObj.transform.localScale = Vector3.one * tileSize * 0.7f;
            playerObj.GetComponent<Renderer>().material.color = Color.yellow;
            playerObj.name = "Player";
        }
        playerObj.transform.position = TileToWorld(x, y) + Vector3.forward * -0.2f;
    }

    public Vector3 TileToWorld(int x, int y)
    {
        return new Vector3(x * tileSize, -y * tileSize, 0);
    }

    public void ClearAll()
    {
        for (int i = transform.childCount - 1; i >= 0; i--)
            Destroy(transform.GetChild(i).gameObject);

        playerObj = null;
        tileObjects = null;
        enemyObjects = null;
        eventObjects = null;
    }

    Color TileColor(DungeonTile tile)
    {
        return tile.type switch
        {
            DungeonTileType.Wall => new Color(0.2f, 0.2f, 0.2f),
            DungeonTileType.Floor => new Color(0.4f, 0.4f, 0.4f),
            DungeonTileType.Exit => new Color(0.2f, 0.5f, 0.2f),
            DungeonTileType.Event => new Color(0.4f, 0.4f, 0.4f),
            DungeonTileType.EnemySpawn => new Color(0.4f, 0.4f, 0.4f),
            _ => Color.gray,
        };
    }
}
