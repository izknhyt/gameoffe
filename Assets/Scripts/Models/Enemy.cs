using System;
using System.Collections.Generic;

/// <summary>
/// An enemy encountered in battle.
/// </summary>
[Serializable]
public class Enemy
{
    public string id;
    public string enemyName;
    public int hp;
    public int maxHp;
    public int mp;
    public int maxMp;
    public int attack;
    public int defense;
    public int magicAttack;
    public int magicDefense;
    public int speed;
    public int expReward;

    public Dictionary<Element, float> elementResistance;
    public List<Skill> skills;

    public bool IsAlive => hp > 0;

    public Enemy(
        string id,
        string enemyName,
        int maxHp,
        int attack,
        int defense,
        int speed,
        int expReward = 10,
        int maxMp = 0,
        int magicAttack = 0,
        int magicDefense = 0)
    {
        this.id = id;
        this.enemyName = enemyName;
        this.hp = maxHp;
        this.maxHp = maxHp;
        this.mp = maxMp;
        this.maxMp = maxMp;
        this.attack = attack;
        this.defense = defense;
        this.magicAttack = magicAttack;
        this.magicDefense = magicDefense;
        this.speed = speed;
        this.expReward = expReward;
        this.elementResistance = new Dictionary<Element, float>();
        this.skills = new List<Skill>();
    }
}
