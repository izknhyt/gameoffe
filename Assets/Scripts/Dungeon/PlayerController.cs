using UnityEngine;

/// <summary>
/// Handles keyboard input for player movement on the dungeon map.
/// </summary>
public class PlayerController : MonoBehaviour
{
    [SerializeField] DungeonRenderer dungeonRenderer;
    [SerializeField] float moveInterval = 0.15f;

    float moveTimer;

    void Update()
    {
        if (GameManager.Instance == null) return;
        if (GameManager.Instance.CurrentScreen != GameScreen.Dungeon) return;

        moveTimer -= Time.deltaTime;
        if (moveTimer > 0) return;

        int dx = 0, dy = 0;

        if (Input.GetKey(KeyCode.UpArrow) || Input.GetKey(KeyCode.W))
            dy = -1;
        else if (Input.GetKey(KeyCode.DownArrow) || Input.GetKey(KeyCode.S))
            dy = 1;
        else if (Input.GetKey(KeyCode.LeftArrow) || Input.GetKey(KeyCode.A))
            dx = -1;
        else if (Input.GetKey(KeyCode.RightArrow) || Input.GetKey(KeyCode.D))
            dx = 1;

        if (dx == 0 && dy == 0) return;

        if (GameManager.Instance.MovePlayer(dx, dy))
        {
            moveTimer = moveInterval;
            dungeonRenderer?.UpdatePlayer(
                GameManager.Instance.PlayerX,
                GameManager.Instance.PlayerY);
        }
    }
}
