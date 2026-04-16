import 'element.dart';
import 'skill.dart';

/// An enemy encountered in battle.
class Enemy {
  final String id;
  final String name;
  int hp;
  final int maxHp;
  final int mp;
  final int maxMp;
  final int attack;
  final int defense;
  final int magicAttack;
  final int magicDefense;
  final int speed;
  final int expReward;

  final Map<Element, double> elementResistance;
  final List<Skill> skills;

  Enemy({
    required this.id,
    required this.name,
    required this.hp,
    required this.maxHp,
    this.mp = 0,
    this.maxMp = 0,
    required this.attack,
    required this.defense,
    this.magicAttack = 0,
    this.magicDefense = 0,
    required this.speed,
    this.expReward = 10,
    Map<Element, double>? elementResistance,
    List<Skill>? skills,
  })  : elementResistance = elementResistance ?? {},
        skills = skills ?? [];

  bool get isAlive => hp > 0;
}
