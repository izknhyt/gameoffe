using System.Collections.Generic;

/// <summary>
/// Factory methods for creating initial character data.
/// </summary>
public static class CharacterDatabase
{
    public static Character CreateSophie()
    {
        var sophie = new Character(
            id: "sophie",
            characterName: "ソフィ",
            maxHp: 45,
            maxMp: 20,
            attack: 8,
            defense: 6,
            magicAttack: 12,
            magicDefense: 10,
            speed: 9,
            weaponType: "staff",
            row: BattleRow.Back
        );

        sophie.skills.Add(new Skill(
            "staff_strike", "杖打ち",
            description: "杖で殴る基本攻撃",
            element: Element.Strike,
            power: 10
        ));

        sophie.skills.Add(new Skill(
            "mini_flare", "プチフレア",
            description: "小さな火の魔法",
            element: Element.Fire,
            power: 15,
            mpCost: 3
        ));

        return sophie;
    }

    public static Character CreateCyrus()
    {
        var cyrus = new Character(
            id: "cyrus",
            characterName: "サイラス",
            maxHp: 70,
            maxMp: 5,
            attack: 14,
            defense: 16,
            magicAttack: 4,
            magicDefense: 8,
            speed: 6,
            weaponType: "sword",
            row: BattleRow.Front
        );

        cyrus.skills.Add(new Skill(
            "slash", "斬撃",
            description: "剣で斬りつける基本攻撃",
            element: Element.Slash,
            power: 14
        ));

        cyrus.skills.Add(new Skill(
            "shield_bash", "シールドバッシュ",
            description: "盾で敵を殴りつける",
            element: Element.Strike,
            power: 12,
            mpCost: 2
        ));

        cyrus.elementResistance[Element.Slash] = 0.2f;
        cyrus.elementResistance[Element.Strike] = 0.2f;

        return cyrus;
    }
}
