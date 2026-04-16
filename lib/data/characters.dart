import '../models/character.dart';
import '../models/element.dart';
import '../models/skill.dart';

/// Initial skill definitions.
const kSkillStaffStrike = Skill(
  id: 'staff_strike',
  name: '杖打ち',
  description: '杖で殴る基本攻撃',
  element: Element.strike,
  power: 10,
);

const kSkillMiniFlare = Skill(
  id: 'mini_flare',
  name: 'プチフレア',
  description: '小さな火の魔法',
  element: Element.fire,
  power: 15,
  mpCost: 3,
);

const kSkillShieldBash = Skill(
  id: 'shield_bash',
  name: 'シールドバッシュ',
  description: '盾で敵を殴りつけ、身を守る',
  element: Element.strike,
  power: 12,
  mpCost: 2,
);

const kSkillSlash = Skill(
  id: 'slash',
  name: '斬撃',
  description: '剣で斬りつける基本攻撃',
  element: Element.slash,
  power: 14,
);

/// Create Sophie's initial state.
Character createSophie() {
  return Character(
    id: 'sophie',
    name: 'ソフィ',
    hp: 45,
    maxHp: 45,
    mp: 20,
    maxMp: 20,
    attack: 8,
    defense: 6,
    magicAttack: 12,
    magicDefense: 10,
    speed: 9,
    weaponType: 'staff',
    row: BattleRow.back,
    skills: [kSkillStaffStrike, kSkillMiniFlare],
  );
}

/// Create Cyrus's initial state.
Character createCyrus() {
  return Character(
    id: 'cyrus',
    name: 'サイラス',
    hp: 70,
    maxHp: 70,
    mp: 5,
    maxMp: 5,
    attack: 14,
    defense: 16,
    magicAttack: 4,
    magicDefense: 8,
    speed: 6,
    weaponType: 'sword',
    row: BattleRow.front,
    skills: [kSkillSlash, kSkillShieldBash],
    elementResistance: {Element.slash: 0.2, Element.strike: 0.2},
  );
}
