import '../engine/level_generator.dart';

abstract final class DailyPuzzle {
  static String idFor(DateTime date) {
    final local = date.toLocal();
    final year = local.year.toString().padLeft(4, '0');
    final month = local.month.toString().padLeft(2, '0');
    final day = local.day.toString().padLeft(2, '0');
    return '$year$month$day';
  }

  static int seedFor(String id) => int.parse(id);

  static String labelFor(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    final local = date.toLocal();
    return '${local.day} ${months[local.month - 1]} ${local.year}';
  }

  static CampaignSpec specFor(String id) {
    final variant = seedFor(id) % 3;
    return switch (variant) {
      0 => const CampaignSpec(rows: 36, cols: 36, fillCount: 1230),
      1 => const CampaignSpec(rows: 42, cols: 42, fillCount: 1680),
      _ => const CampaignSpec(rows: 48, cols: 48, fillCount: 2200),
    };
  }
}
