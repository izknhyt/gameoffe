import 'element.dart';
import 'skill.dart';

/// Position in battle formation.
enum BattleRow { front, back }

/// A playable character in the party.
class Character {
  final String id;
  final String name;

  // Base stats
  int level;
  int exp;
  int hp;
  int maxHp;
  int mp;
  int maxMp;
  int attack;
  int defense;
  int magicAttack;
  int magicDefense;
  int speed;

  // Equipment & formation
  BattleRow row;
  String weaponType; // e.g. 'staff', 'sword', 'lance', 'shield'

  // Element resistances: positive = resistant, negative = weak
  Map<Element, double> elementResistance;

  // Skills learned (by level-up or event)
  List<Skill> skills;

  // Whether this character is currently in the active party (vs reserve)
  bool isActive;

  Character({
    required this.id,
    required this.name,
    this.level = 1,
    this.exp = 0,
    required this.hp,
    required this.maxHp,
    required this.mp,
    required this.maxMp,
    required this.attack,
    required this.defense,
    required this.magicAttack,
    required this.magicDefense,
    required this.speed,
    this.row = BattleRow.front,
    required this.weaponType,
    Map<Element, double>? elementResistance,
    List<Skill>? skills,
    this.isActive = true,
  })  : elementResistance = elementResistance ?? {},
        skills = skills ?? [];

  bool get isAlive => hp > 0;
}
