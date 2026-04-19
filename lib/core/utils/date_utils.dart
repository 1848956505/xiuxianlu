import 'package:intl/intl.dart';

/// 日期工具函数
class DateUtils {
  DateUtils._();

  /// 日期格式化器（仅日期部分，不含时间）
  static final DateFormat _dateFormat = DateFormat('yyyy-MM-dd');

  /// 判断两个日期是否是同一天
  static bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  /// 判断两个日期是否是连续的（b 是 a 的下一天）
  static bool isConsecutiveDay(DateTime a, DateTime b) {
    final aNormalized = DateTime(a.year, a.month, a.day);
    final bNormalized = DateTime(b.year, b.month, b.day);
    final diff = bNormalized.difference(aNormalized).inDays;
    return diff == 1;
  }

  /// 将 DateTime 格式化为日期字符串（yyyy-MM-dd）
  static String formatDate(DateTime date) {
    return _dateFormat.format(date);
  }

  /// 将日期字符串解析为 DateTime
  static DateTime parseDate(String dateStr) {
    return _dateFormat.parse(dateStr);
  }

  /// 获取今天的日期字符串
  static String todayStr() {
    return _dateFormat.format(DateTime.now());
  }

  /// 获取今天的日期（仅日期部分，不含时间）
  static DateTime today() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  /// 计算连续签到天数
  /// [dates] 是已排序的日期列表（从新到旧）
  /// 返回从今天开始往回连续签到的天数
  static int calculateConsecutiveDays(List<DateTime> dates) {
    if (dates.isEmpty) return 0;

    final todayDate = today();
    final sortedDates = List<DateTime>.from(dates)
      ..sort((a, b) => b.compareTo(a));

    // 检查最近一天是否是今天或昨天
    final mostRecent = sortedDates.first;
    final mostRecentDay = DateTime(
        mostRecent.year, mostRecent.month, mostRecent.day);

    if (!isSameDay(mostRecentDay, todayDate) &&
        !isConsecutiveDay(mostRecentDay, todayDate)) {
      return 0;
    }

    int consecutive = 1;
    for (int i = 0; i < sortedDates.length - 1; i++) {
      final current = DateTime(
          sortedDates[i].year, sortedDates[i].month, sortedDates[i].day);
      final next = DateTime(
          sortedDates[i + 1].year, sortedDates[i + 1].month, sortedDates[i + 1].day);
      if (isConsecutiveDay(next, current)) {
        consecutive++;
      } else {
        break;
      }
    }

    return consecutive;
  }

  /// 格式化日期为友好显示（如 "今天"、"昨天"、"3天前"）
  static String formatFriendly(DateTime date) {
    final now = DateTime.now();
    final todayDate = DateTime(now.year, now.month, now.day);
    final dateOnly = DateTime(date.year, date.month, date.day);
    final diff = todayDate.difference(dateOnly).inDays;

    if (diff == 0) return '今天';
    if (diff == 1) return '昨天';
    if (diff == 2) return '前天';
    if (diff < 7) return '$diff天前';
    if (diff < 30) return '${diff ~/ 7}周前';
    return '${diff ~/ 30}月前';
  }
}
