using System;
using System.Collections.Generic;
using System.Linq;
using UnityEngine;

/// <summary>
/// Manages battle state and turn-based combat logic.
/// </summary>
public class BattleManager : MonoBehaviour
{
    public static BattleManager Instance { get; private set; }

    public List<Character> Party { get; private set; } = new();
    public List<Enemy> Enemies { get; private set; } = new();
    public List<string> BattleLog { get; private set; } = new();
    public bool IsPlayerTurn { get; private set; } = true;
    public bool BattleOver { get; private set; }
    public bool Victory { get; private set; }

    // Turn order
    List<object> turnOrder = new();
    int currentActorIndex;

    public event Action OnBattleStateChanged;

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

    public void StartBattle(List<Character> party, string enemyGroupId)
    {
        Party = party;
        Enemies = EnemyDatabase.CreateEnemyGroup(enemyGroupId);
        BattleLog.Clear();
        BattleOver = false;
        Victory = false;

        string enemyNames = string.Join("と", Enemies.Select(e => e.enemyName));
        AddLog($"{enemyNames}が現れた！");

        BuildTurnOrder();
        currentActorIndex = 0;
        DetermineCurrentTurn();

        OnBattleStateChanged?.Invoke();
    }

    void BuildTurnOrder()
    {
        turnOrder.Clear();
        var actors = new List<(object actor, int speed)>();

        foreach (var c in Party)
            if (c.IsAlive) actors.Add((c, c.speed));
        foreach (var e in Enemies)
            if (e.IsAlive) actors.Add((e, e.speed));

        actors.Sort((a, b) => b.speed.CompareTo(a.speed));
        turnOrder = actors.Select(a => a.actor).ToList();
    }

    void DetermineCurrentTurn()
    {
        var actor = turnOrder[currentActorIndex];
        IsPlayerTurn = actor is Character;
    }

    public object GetCurrentActor()
    {
        if (turnOrder.Count == 0) return null;
        return turnOrder[currentActorIndex];
    }

    /// <summary>
    /// Player uses a skill on a target enemy.
    /// </summary>
    public void PlayerAction(Skill skill, int targetIndex)
    {
        if (BattleOver || !IsPlayerTurn) return;

        var actor = turnOrder[currentActorIndex] as Character;
        if (actor == null) return;

        var target = Enemies[targetIndex];
        if (!target.IsAlive) return;

        if (actor.mp < skill.mpCost)
        {
            AddLog($"{actor.characterName}のMPが足りない！");
            return;
        }

        actor.mp -= skill.mpCost;

        bool isPhysical = skill.element.IsPhysical();
        int atk = isPhysical ? actor.attack : actor.magicAttack;
        int def = isPhysical ? target.defense : target.magicDefense;
        float resistance = target.elementResistance.GetValueOrDefault(skill.element, 0f);

        int damage = CalcDamage(skill.power, atk, def, resistance);
        target.hp = Mathf.Clamp(target.hp - damage, 0, target.maxHp);

        AddLog($"{actor.characterName}の{skill.skillName}！ {target.enemyName}に{damage}ダメージ！");

        if (!target.IsAlive)
            AddLog($"{target.enemyName}を倒した！");

        if (CheckBattleEnd()) return;
        AdvanceTurn();
    }

    /// <summary>
    /// Execute enemy AI turn.
    /// </summary>
    public void ExecuteEnemyTurn()
    {
        if (BattleOver || IsPlayerTurn) return;

        var actor = turnOrder[currentActorIndex] as Enemy;
        if (actor == null || !actor.IsAlive)
        {
            AdvanceTurn();
            return;
        }

        // Simple AI: random alive party member
        var aliveParty = Party.Where(c => c.IsAlive).ToList();
        if (aliveParty.Count == 0) return;

        var target = aliveParty[UnityEngine.Random.Range(0, aliveParty.Count)];

        Skill skill;
        if (actor.skills.Count > 0)
            skill = actor.skills[UnityEngine.Random.Range(0, actor.skills.Count)];
        else
            skill = new Skill("attack", "攻撃", element: Element.None, power: 10);

        bool isPhysical = skill.element.IsPhysical();
        int atk = isPhysical ? actor.attack : actor.magicAttack;
        int def = isPhysical ? target.defense : target.magicDefense;
        float resistance = target.elementResistance.GetValueOrDefault(skill.element, 0f);

        int damage = CalcDamage(skill.power, atk, def, resistance);
        target.hp = Mathf.Clamp(target.hp - damage, 0, target.maxHp);

        AddLog($"{actor.enemyName}の{skill.skillName}！ {target.characterName}に{damage}ダメージ！");

        if (!target.IsAlive)
            AddLog($"{target.characterName}は倒れた...");

        if (CheckBattleEnd()) return;
        AdvanceTurn();
    }

    int CalcDamage(int power, int atk, int def, float resistance)
    {
        float baseDmg = power * ((float)atk / Mathf.Max(def, 1));
        float modified = baseDmg * (1f - resistance);
        int variance = Mathf.Max(1, Mathf.RoundToInt(modified * 0.1f));
        int result = Mathf.RoundToInt(modified) + UnityEngine.Random.Range(-variance, variance + 1);
        return Mathf.Max(1, result);
    }

    bool CheckBattleEnd()
    {
        if (Enemies.All(e => !e.IsAlive))
        {
            int totalExp = Enemies.Sum(e => e.expReward);
            AddLog($"戦闘に勝利した！ {totalExp}EXP獲得！");
            foreach (var c in Party)
                if (c.IsAlive) c.exp += totalExp;
            BattleOver = true;
            Victory = true;
            OnBattleStateChanged?.Invoke();
            return true;
        }

        if (Party.All(c => !c.IsAlive))
        {
            AddLog("全滅した...");
            BattleOver = true;
            Victory = false;
            OnBattleStateChanged?.Invoke();
            return true;
        }

        return false;
    }

    void AdvanceTurn()
    {
        int next = (currentActorIndex + 1) % turnOrder.Count;
        int attempts = 0;

        while (attempts < turnOrder.Count)
        {
            var actor = turnOrder[next];
            if (actor is Character c && c.IsAlive)
            {
                currentActorIndex = next;
                IsPlayerTurn = true;
                OnBattleStateChanged?.Invoke();
                return;
            }
            if (actor is Enemy e && e.IsAlive)
            {
                currentActorIndex = next;
                IsPlayerTurn = false;
                OnBattleStateChanged?.Invoke();
                return;
            }
            next = (next + 1) % turnOrder.Count;
            attempts++;
        }
    }

    void AddLog(string message)
    {
        BattleLog.Add(message);
        OnBattleStateChanged?.Invoke();
    }

    public void FinishBattle()
    {
        GameManager.Instance.EndBattle(Victory);
    }
}
