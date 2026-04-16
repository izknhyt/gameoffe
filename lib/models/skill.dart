import 'element.dart';

/// Target type for a skill.
enum TargetType { singleEnemy, allEnemies, self_, singleAlly, allAllies }

/// A skill or spell usable in battle.
class Skill {
  final String id;
  final String name;
  final String description;
  final Element element;
  final int power;
  final int mpCost;
  final TargetType targetType;

  const Skill({
    required this.id,
    required this.name,
    this.description = '',
    required this.element,
    required this.power,
    this.mpCost = 0,
    this.targetType = TargetType.singleEnemy,
  });
}
