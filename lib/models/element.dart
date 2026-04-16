/// Game attribute/element system.
/// Designed to be easily extensible - just add new values to [Element].
enum Element {
  // Physical
  slash('斬'),
  strike('打'),
  thrust('突'),
  // Magical
  fire('火'),
  water('水'),
  wind('風'),
  earth('土'),
  thunder('雷'),
  ice('氷'),
  light('光'),
  dark('闇'),
  // Special / neutral
  none('無');

  final String label;
  const Element(this.label);
}
