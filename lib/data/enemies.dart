import '../models/element.dart';
import '../models/enemy.dart';
import '../models/skill.dart';

/// Prototype enemy skills.
const _kBite = Skill(
  id: 'bite',
  name: '噛みつき',
  element: Element.slash,
  power: 8,
);

const _kShadowBolt = Skill(
  id: 'shadow_bolt',
  name: 'シャドウボルト',
  element: Element.dark,
  power: 12,
  mpCost: 3,
);

/// Create prototype enemies.
Enemy createSlime() {
  return Enemy(
    id: 'slime',
    name: 'スライム',
    hp: 20,
    maxHp: 20,
    attack: 6,
    defense: 4,
    speed: 4,
    expReward: 5,
    elementResistance: {Element.strike: -0.5, Element.fire: -0.3},
    skills: [_kBite],
  );
}

Enemy createShadow() {
  return Enemy(
    id: 'shadow',
    name: 'シャドウ',
    hp: 35,
    maxHp: 35,
    attack: 10,
    defense: 6,
    magicAttack: 12,
    magicDefense: 8,
    speed: 8,
    expReward: 12,
    elementResistance: {Element.light: -0.5, Element.dark: 0.5},
    skills: [_kBite, _kShadowBolt],
  );
}
