using UnityEngine;
using UnityEngine.UI;
using TMPro;

/// <summary>
/// Event / dialog screen. Displays dialog lines and advances on click.
/// </summary>
public class EventUI : MonoBehaviour
{
    [SerializeField] TextMeshProUGUI speakerText;
    [SerializeField] TextMeshProUGUI dialogText;
    [SerializeField] Button advanceButton;

    int dialogIndex;

    static readonly DialogLine[] cyrusDialog = new DialogLine[]
    {
        new("???", "ここは...どこだ..."),
        new("ソフィ", "あなたは...！ サイラスさん！"),
        new("サイラス", "ソフィ...か？ すまない、頭がぼんやりして...何も思い出せない。"),
        new("ソフィ", "私も同じです。でも、ここから出る方法を探さないと。"),
        new("サイラス", "...そうだな。この剣はまだ握れる。君を守ることくらいはできるだろう。"),
        new("", "サイラスが仲間になった！"),
    };

    void Start()
    {
        dialogIndex = 0;
        UpdateDialog();

        if (advanceButton != null)
            advanceButton.onClick.AddListener(Advance);
    }

    void Update()
    {
        // Also advance on space / enter / click
        if (Input.GetKeyDown(KeyCode.Space) || Input.GetKeyDown(KeyCode.Return))
        {
            Advance();
        }
    }

    void Advance()
    {
        if (dialogIndex < cyrusDialog.Length - 1)
        {
            dialogIndex++;
            UpdateDialog();
        }
        else
        {
            GameManager.Instance.CompleteCyrusEvent();
        }
    }

    void UpdateDialog()
    {
        var line = cyrusDialog[dialogIndex];
        if (speakerText != null)
            speakerText.text = line.speaker;
        if (dialogText != null)
            dialogText.text = line.text;
    }
}

public struct DialogLine
{
    public string speaker;
    public string text;

    public DialogLine(string speaker, string text)
    {
        this.speaker = speaker;
        this.text = text;
    }
}
