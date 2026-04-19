import 'package:sqflite/sqflite.dart';
import '../database/database_helper.dart';
import '../../domain/models/checkin_model.dart';
import '../../core/utils/date_utils.dart';

/// 签到数据仓库
class CheckinRepository {
  final DatabaseHelper _dbHelper;

  CheckinRepository(this._dbHelper);

  /// 签到
  /// 如果今天已签到，返回 null；否则返回获得的灵气数
  Future<int?> checkIn(String id, int spiritGained) async {
    final db = await _dbHelper.database;
    final today = DateUtils.todayStr();

    // 检查今天是否已签到
    final existing = await db.query(
      'check_ins',
      where: 'date = ?',
      whereArgs: [today],
    );
    if (existing.isNotEmpty) return null;

    // 插入签到记录
    final now = DateTime.now().toIso8601String();
    await db.insert('check_ins', {
      'id': id,
      'date': today,
      'spirit_gained': spiritGained,
      'created_at': now,
    });

    return spiritGained;
  }

  /// 检查今天是否已签到
  Future<bool> hasCheckedInToday() async {
    final db = await _dbHelper.database;
    final today = DateUtils.todayStr();
    final result = await db.query(
      'check_ins',
      where: 'date = ?',
      whereArgs: [today],
    );
    return result.isNotEmpty;
  }

  /// 获取今天的签到记录
  Future<CheckinModel?> getTodayCheckin() async {
    final db = await _dbHelper.database;
    final today = DateUtils.todayStr();
    final result = await db.query(
      'check_ins',
      where: 'date = ?',
      whereArgs: [today],
    );
    if (result.isEmpty) return null;
    return CheckinModel.fromMap(result.first);
  }

  /// 获取所有签到记录（按日期降序）
  Future<List<CheckinModel>> getAllCheckins() async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'check_ins',
      orderBy: 'date DESC',
    );
    return maps.map((m) => CheckinModel.fromMap(m)).toList();
  }

  /// 获取最近 N 天的签到记录
  Future<List<CheckinModel>> getRecentCheckins(int days) async {
    final db = await _dbHelper.database;
    final cutoff = DateTime.now().subtract(Duration(days: days));
    final cutoffStr = DateUtils.formatDate(cutoff);
    final maps = await db.query(
      'check_ins',
      where: 'date >= ?',
      whereArgs: [cutoffStr],
      orderBy: 'date DESC',
    );
    return maps.map((m) => CheckinModel.fromMap(m)).toList();
  }

  /// 计算连续签到天数
  Future<int> getConsecutiveDays() async {
    final checkins = await getAllCheckins();
    if (checkins.isEmpty) return 0;
    final dates = checkins.map((c) => c.date).toList();
    return DateUtils.calculateConsecutiveDays(dates);
  }

  /// 获取总签到天数
  Future<int> getTotalCheckinDays() async {
    final db = await _dbHelper.database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM check_ins',
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }
}
