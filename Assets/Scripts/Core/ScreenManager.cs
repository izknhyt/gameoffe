using UnityEngine;

/// <summary>
/// Switches active UI panels based on the current GameScreen.
/// Attach to the root Canvas or a manager object. Assign panels in the Inspector.
/// </summary>
public class ScreenManager : MonoBehaviour
{
    [SerializeField] GameObject titlePanel;
    [SerializeField] GameObject dungeonPanel;
    [SerializeField] GameObject battlePanel;
    [SerializeField] GameObject eventPanel;

    [SerializeField] DungeonRenderer dungeonRenderer;

    void OnEnable()
    {
        if (GameManager.Instance != null)
            GameManager.Instance.OnScreenChanged += OnScreenChanged;
    }

    void OnDisable()
    {
        if (GameManager.Instance != null)
            GameManager.Instance.OnScreenChanged -= OnScreenChanged;
    }

    void Start()
    {
        OnScreenChanged(GameScreen.Title);
    }

    void OnScreenChanged(GameScreen screen)
    {
        titlePanel?.SetActive(screen == GameScreen.Title);
        dungeonPanel?.SetActive(screen == GameScreen.Dungeon);
        battlePanel?.SetActive(screen == GameScreen.Battle);
        eventPanel?.SetActive(screen == GameScreen.Event);

        if (screen == GameScreen.Dungeon && dungeonRenderer != null)
        {
            var dungeon = GameManager.Instance.CurrentDungeon;
            if (dungeon != null)
            {
                dungeonRenderer.RenderDungeon(dungeon);
                dungeonRenderer.UpdatePlayer(
                    GameManager.Instance.PlayerX,
                    GameManager.Instance.PlayerY);
            }
        }

        if (screen == GameScreen.Battle)
        {
            BattleManager.Instance?.StartBattle(
                GameManager.Instance.Party,
                GameManager.Instance.CurrentBattleEnemyGroupId);
        }
    }
}
