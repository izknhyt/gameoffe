using System;
using System.Collections.Generic;

public enum BattleRow { Front, Back }

/// <summary>
/// A playable character in the party.
/// </summary>
[Serializable]
public class Character
{
    public string id;
    public string characterName;

    // Stats
    public int level;
    public int exp;
    public int hp;
    public int maxHp;
    public int mp;
    public int maxMp;
    public int attack;
    public int defense;
    public int magicAttack;
    public int magicDefense;
    public int speed;

    // Equipment & formation
    public BattleRow row;
    public string weaponType;

    // Element resistances: positive = resistant, negative = weak
    public Dictionary<Element, float> elementResistance;

    // Skills learned (by level-up or event)
    public List<Skill> skills;

    // Active party vs reserve
    public bool isActive;

    public bool IsAlive => hp > 0;

    public Character(
        string id,
        string characterName,
        int maxHp,
        int maxMp,
        int attack,
        int defense,
        int magicAttack,
        int magicDefense,
        int speed,
        string weaponType,
        BattleRow row = BattleRow.Front,
        int level = 1)
    {
        this.id = id;
        this.characterName = characterName;
        this.level = level;
        this.exp = 0;
        this.hp = maxHp;
        this.maxHp = maxHp;
        this.mp = maxMp;
        this.maxMp = maxMp;
        this.attack = attack;
        this.defense = defense;
        this.magicAttack = magicAttack;
        this.magicDefense = magicDefense;
        this.speed = speed;
        this.row = row;
        this.weaponType = weaponType;
        this.elementResistance = new Dictionary<Element, float>();
        this.skills = new List<Skill>();
        this.isActive = true;
    }
}
