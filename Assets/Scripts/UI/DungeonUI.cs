using System.Text;
using UnityEngine;
using TMPro;

/// <summary>
/// HUD overlay during dungeon exploration. Shows party status.
/// </summary>
public class DungeonUI : MonoBehaviour
{
    [SerializeField] TextMeshProUGUI dungeonNameText;
    [SerializeField] TextMeshProUGUI partyStatusText;

    void Update()
    {
        if (GameManager.Instance == null) return;
        if (GameManager.Instance.CurrentScreen != GameScreen.Dungeon) return;

        var dungeon = GameManager.Instance.CurrentDungeon;
        if (dungeon != null && dungeonNameText != null)
            dungeonNameText.text = dungeon.dungeonName;

        if (partyStatusText != null)
        {
            var sb = new StringBuilder();
            foreach (var c in GameManager.Instance.Party)
            {
                string status = c.IsAlive ? "" : " [戦闘不能]";
                sb.AppendLine($"{c.characterName} HP:{c.hp}/{c.maxHp} MP:{c.mp}/{c.maxMp}{status}");
            }
            partyStatusText.text = sb.ToString();
        }
    }
}
