using System.Collections;
using System.Collections.Generic;
using System.Text;
using UnityEngine;
using UnityEngine.UI;
using TMPro;

/// <summary>
/// Battle screen UI. Handles skill selection, target selection,
/// enemy display, party status, and battle log.
/// </summary>
public class BattleUI : MonoBehaviour
{
    [Header("Panels")]
    [SerializeField] GameObject skillPanel;
    [SerializeField] GameObject targetPanel;
    [SerializeField] GameObject resultPanel;

    [Header("Text")]
    [SerializeField] TextMeshProUGUI battleLogText;
    [SerializeField] TextMeshProUGUI partyStatusText;
    [SerializeField] TextMeshProUGUI enemyStatusText;
    [SerializeField] TextMeshProUGUI turnIndicatorText;
    [SerializeField] TextMeshProUGUI resultText;

    [Header("Buttons")]
    [SerializeField] Transform skillButtonContainer;
    [SerializeField] Transform targetButtonContainer;
    [SerializeField] Button skillButtonPrefab;
    [SerializeField] Button targetButtonPrefab;
    [SerializeField] Button resultConfirmButton;

    Skill selectedSkill;

    void OnEnable()
    {
        if (BattleManager.Instance != null)
            BattleManager.Instance.OnBattleStateChanged += RefreshUI;
    }

    void OnDisable()
    {
        if (BattleManager.Instance != null)
            BattleManager.Instance.OnBattleStateChanged -= RefreshUI;
    }

    void Start()
    {
        if (resultConfirmButton != null)
            resultConfirmButton.onClick.AddListener(OnResultConfirm);
    }

    void Update()
    {
        if (BattleManager.Instance == null) return;

        // Auto-execute enemy turn with delay
        if (!BattleManager.Instance.IsPlayerTurn && !BattleManager.Instance.BattleOver)
        {
            StartCoroutine(EnemyTurnCoroutine());
        }
    }

    IEnumerator EnemyTurnCoroutine()
    {
        yield return new WaitForSeconds(0.6f);
        if (!BattleManager.Instance.IsPlayerTurn && !BattleManager.Instance.BattleOver)
        {
            BattleManager.Instance.ExecuteEnemyTurn();
        }
    }

    public void RefreshUI()
    {
        var bm = BattleManager.Instance;
        if (bm == null) return;

        UpdateBattleLog(bm);
        UpdatePartyStatus(bm);
        UpdateEnemyStatus(bm);
        UpdateTurnIndicator(bm);

        if (bm.BattleOver)
        {
            ShowResult(bm);
        }
        else if (bm.IsPlayerTurn)
        {
            ShowSkillPanel(bm);
        }
        else
        {
            HideAllPanels();
        }
    }

    void UpdateBattleLog(BattleManager bm)
    {
        if (battleLogText == null) return;
        var sb = new StringBuilder();
        // Show last 8 lines
        int start = Mathf.Max(0, bm.BattleLog.Count - 8);
        for (int i = start; i < bm.BattleLog.Count; i++)
            sb.AppendLine(bm.BattleLog[i]);
        battleLogText.text = sb.ToString();
    }

    void UpdatePartyStatus(BattleManager bm)
    {
        if (partyStatusText == null) return;
        var sb = new StringBuilder();
        foreach (var c in bm.Party)
        {
            string rowLabel = c.row == BattleRow.Front ? "前衛" : "後衛";
            string alive = c.IsAlive ? "" : " [戦闘不能]";
            sb.AppendLine($"{c.characterName} [{rowLabel}] HP:{c.hp}/{c.maxHp} MP:{c.mp}/{c.maxMp}{alive}");
        }
        partyStatusText.text = sb.ToString();
    }

    void UpdateEnemyStatus(BattleManager bm)
    {
        if (enemyStatusText == null) return;
        var sb = new StringBuilder();
        foreach (var e in bm.Enemies)
        {
            string alive = e.IsAlive ? $"HP:{e.hp}/{e.maxHp}" : "撃破";
            sb.AppendLine($"{e.enemyName} {alive}");
        }
        enemyStatusText.text = sb.ToString();
    }

    void UpdateTurnIndicator(BattleManager bm)
    {
        if (turnIndicatorText == null) return;
        var actor = bm.GetCurrentActor();
        if (actor is Character c)
            turnIndicatorText.text = $"{c.characterName}のターン";
        else if (actor is Enemy e)
            turnIndicatorText.text = $"{e.enemyName}のターン";
    }

    void ShowSkillPanel(BattleManager bm)
    {
        if (skillPanel != null) skillPanel.SetActive(true);
        if (targetPanel != null) targetPanel.SetActive(false);
        if (resultPanel != null) resultPanel.SetActive(false);

        if (skillButtonContainer == null || skillButtonPrefab == null) return;

        // Clear old buttons
        foreach (Transform child in skillButtonContainer)
            Destroy(child.gameObject);

        var actor = bm.GetCurrentActor() as Character;
        if (actor == null) return;

        foreach (var skill in actor.skills)
        {
            var btn = Instantiate(skillButtonPrefab, skillButtonContainer);
            var label = btn.GetComponentInChildren<TextMeshProUGUI>();
            string mpLabel = skill.mpCost > 0 ? $" (MP{skill.mpCost})" : "";
            if (label != null) label.text = $"{skill.skillName}{mpLabel}";

            bool canUse = actor.mp >= skill.mpCost;
            btn.interactable = canUse;

            var capturedSkill = skill;
            btn.onClick.AddListener(() => OnSkillSelected(capturedSkill));
        }
    }

    void OnSkillSelected(Skill skill)
    {
        selectedSkill = skill;
        ShowTargetPanel();
    }

    void ShowTargetPanel()
    {
        if (skillPanel != null) skillPanel.SetActive(false);
        if (targetPanel != null) targetPanel.SetActive(true);
        if (resultPanel != null) resultPanel.SetActive(false);

        if (targetButtonContainer == null || targetButtonPrefab == null) return;

        foreach (Transform child in targetButtonContainer)
            Destroy(child.gameObject);

        for (int i = 0; i < BattleManager.Instance.Enemies.Count; i++)
        {
            var enemy = BattleManager.Instance.Enemies[i];
            if (!enemy.IsAlive) continue;

            var btn = Instantiate(targetButtonPrefab, targetButtonContainer);
            var label = btn.GetComponentInChildren<TextMeshProUGUI>();
            if (label != null) label.text = enemy.enemyName;

            int index = i;
            btn.onClick.AddListener(() => OnTargetSelected(index));
        }

        // Back button
        var backBtn = Instantiate(targetButtonPrefab, targetButtonContainer);
        var backLabel = backBtn.GetComponentInChildren<TextMeshProUGUI>();
        if (backLabel != null) backLabel.text = "戻る";
        backBtn.onClick.AddListener(() => RefreshUI());
    }

    void OnTargetSelected(int index)
    {
        BattleManager.Instance.PlayerAction(selectedSkill, index);
        selectedSkill = null;
    }

    void ShowResult(BattleManager bm)
    {
        if (skillPanel != null) skillPanel.SetActive(false);
        if (targetPanel != null) targetPanel.SetActive(false);
        if (resultPanel != null) resultPanel.SetActive(true);

        if (resultText != null)
            resultText.text = bm.Victory ? "勝利！" : "ゲームオーバー...";
    }

    void HideAllPanels()
    {
        if (skillPanel != null) skillPanel.SetActive(false);
        if (targetPanel != null) targetPanel.SetActive(false);
        if (resultPanel != null) resultPanel.SetActive(false);
    }

    void OnResultConfirm()
    {
        BattleManager.Instance.FinishBattle();
    }
}
