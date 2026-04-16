using System.Collections.Generic;

/// <summary>
/// Factory methods for creating enemies and enemy groups.
/// </summary>
public static class EnemyDatabase
{
    public static Enemy CreateSlime()
    {
        var slime = new Enemy(
            id: "slime",
            enemyName: "スライム",
            maxHp: 20,
            attack: 6,
            defense: 4,
            speed: 4,
            expReward: 5
        );

        slime.skills.Add(new Skill("bite", "噛みつき", element: Element.Slash, power: 8));
        slime.elementResistance[Element.Strike] = -0.5f;
        slime.elementResistance[Element.Fire] = -0.3f;

        return slime;
    }

    public static Enemy CreateShadow()
    {
        var shadow = new Enemy(
            id: "shadow",
            enemyName: "シャドウ",
            maxHp: 35,
            attack: 10,
            defense: 6,
            speed: 8,
            expReward: 12,
            magicAttack: 12,
            magicDefense: 8
        );

        shadow.skills.Add(new Skill("bite", "噛みつき", element: Element.Slash, power: 8));
        shadow.skills.Add(new Skill("shadow_bolt", "シャドウボルト", element: Element.Dark, power: 12, mpCost: 3));
        shadow.elementResistance[Element.Light] = -0.5f;
        shadow.elementResistance[Element.Dark] = 0.5f;

        return shadow;
    }

    public static List<Enemy> CreateEnemyGroup(string groupId)
    {
        return groupId switch
        {
            "slime_x2" => new List<Enemy> { CreateSlime(), CreateSlime() },
            "shadow_x1" => new List<Enemy> { CreateShadow() },
            _ => new List<Enemy> { CreateSlime() },
        };
    }
}
