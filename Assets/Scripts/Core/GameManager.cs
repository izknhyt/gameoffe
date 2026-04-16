using System;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.SceneManagement;

public enum GameScreen { Title, Dungeon, Battle, Event }

/// <summary>
/// Central game state manager. Singleton that persists across scenes.
/// </summary>
public class GameManager : MonoBehaviour
{
    public static GameManager Instance { get; private set; }

    public GameScreen CurrentScreen { get; private set; } = GameScreen.Title;
    public List<Character> Party { get; private set; } = new();
    public DungeonMap CurrentDungeon { get; private set; }
    public int PlayerX { get; set; }
    public int PlayerY { get; set; }
    public HashSet<string> CompletedEvents { get; private set; } = new();

    // The enemy group that triggered the current battle
    public string CurrentBattleEnemyGroupId { get; private set; }

    public event Action<GameScreen> OnScreenChanged;

    void Awake()
    {
        if (Instance != null && Instance != this)
        {
            Destroy(gameObject);
            return;
        }
        Instance = this;
        DontDestroyOnLoad(gameObject);
    }

    public void NewGame()
    {
        Party.Clear();
        CompletedEvents.Clear();

        Party.Add(CharacterDatabase.CreateSophie());

        CurrentDungeon = DungeonDatabase.CreateFirstDungeon();
        PlayerX = CurrentDungeon.playerStartX;
        PlayerY = CurrentDungeon.playerStartY;

        SwitchScreen(GameScreen.Dungeon);
    }

    public bool MovePlayer(int dx, int dy)
    {
        if (CurrentDungeon == null) return false;

        int newX = PlayerX + dx;
        int newY = PlayerY + dy;

        if (newX < 0 || newX >= CurrentDungeon.width) return false;
        if (newY < 0 || newY >= CurrentDungeon.height) return false;
        if (!CurrentDungeon.tiles[newY, newX].IsWalkable) return false;

        PlayerX = newX;
        PlayerY = newY;

        // Check event trigger
        var tile = CurrentDungeon.tiles[newY, newX];
        if (tile.type == DungeonTileType.Event && tile.eventId != null)
        {
            if (!CompletedEvents.Contains(tile.eventId))
            {
                TriggerEvent(tile.eventId);
                return true;
            }
        }

        // Check enemy encounter
        CheckEnemyEncounter(newX, newY);

        return true;
    }

    void TriggerEvent(string eventId)
    {
        if (eventId == "cyrus_join")
        {
            SwitchScreen(GameScreen.Event);
        }
    }

    public void CompleteCyrusEvent()
    {
        Party.Add(CharacterDatabase.CreateCyrus());
        CompletedEvents.Add("cyrus_join");
        SwitchScreen(GameScreen.Dungeon);
    }

    void CheckEnemyEncounter(int x, int y)
    {
        if (CurrentDungeon == null) return;

        foreach (var spawn in CurrentDungeon.enemySpawns)
        {
            if (!spawn.defeated && spawn.x == x && spawn.y == y)
            {
                CurrentBattleEnemyGroupId = spawn.enemyGroupId;
                SwitchScreen(GameScreen.Battle);
                return;
            }
        }
    }

    public void EndBattle(bool victory)
    {
        if (victory && CurrentDungeon != null)
        {
            foreach (var spawn in CurrentDungeon.enemySpawns)
            {
                if (spawn.x == PlayerX && spawn.y == PlayerY)
                {
                    spawn.defeated = true;
                    break;
                }
            }
        }

        if (victory)
        {
            SwitchScreen(GameScreen.Dungeon);
        }
        else
        {
            SwitchScreen(GameScreen.Title);
        }
    }

    public void SwitchScreen(GameScreen screen)
    {
        CurrentScreen = screen;
        OnScreenChanged?.Invoke(screen);
    }
}
