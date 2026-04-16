using System;

public enum TargetType
{
    SingleEnemy,
    AllEnemies,
    Self,
    SingleAlly,
    AllAllies,
}

/// <summary>
/// A skill or spell usable in battle.
/// </summary>
[Serializable]
public class Skill
{
    public string id;
    public string skillName;
    public string description;
    public Element element;
    public int power;
    public int mpCost;
    public TargetType targetType;

    public Skill(
        string id,
        string skillName,
        string description = "",
        Element element = Element.None,
        int power = 0,
        int mpCost = 0,
        TargetType targetType = TargetType.SingleEnemy)
    {
        this.id = id;
        this.skillName = skillName;
        this.description = description;
        this.element = element;
        this.power = power;
        this.mpCost = mpCost;
        this.targetType = targetType;
    }
}
