using UnityEngine;
using UnityEngine.UI;
using TMPro;

/// <summary>
/// Title screen UI controller.
/// Attach to a Canvas in the scene. Wire up buttons in the Inspector.
/// </summary>
public class TitleUI : MonoBehaviour
{
    [SerializeField] Button newGameButton;
    [SerializeField] TextMeshProUGUI titleText;

    void Start()
    {
        if (titleText != null)
            titleText.text = "記憶の夢";

        if (newGameButton != null)
            newGameButton.onClick.AddListener(OnNewGame);
    }

    void OnNewGame()
    {
        GameManager.Instance.NewGame();
    }
}
