import 'package:sqflite/sqflite.dart';
import '../database/database_helper.dart';
import '../../domain/models/spirit_log_model.dart';

/// 灵气数据仓库
/// 管理灵气变动记录和累计灵气计算
class SpiritRepository {
  final DatabaseHelper _dbHelper;

  SpiritRepository(this._dbHelper);

  /// 添加灵气变动记录
  Future<SpiritLogModel> addSpiritLog({
    required String id,
    required int amount,
    required String source,
    String? sourceId,
    String? description,
  }) async {
    final db = await _dbHelper.database;
    final now = DateTime.now().toIso8601String();

    await db.insert('spirit_log', {
      'id': id,
      'amount': amount,
      'source': source,
      'source_id': sourceId,
      'description': description,
      'created_at': now,
    });

    return SpiritLogModel(
      id: id,
      amount: amount,
      source: SpiritSource.fromValue(source),
      sourceId: sourceId,
      description: description,
      createdAt: DateTime.now(),
    );
  }

  /// 获取累计灵气（只增不减）
  Future<int> getTotalSpirit() async {
    final db = await _dbHelper.database;
    final result = await db.rawQuery(
      'SELECT COALESCE(SUM(amount), 0) as total FROM spirit_log',
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  /// 获取所有灵气日志（按时间降序）
  Future<List<SpiritLogModel>> getAllLogs() async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'spirit_log',
      orderBy: 'created_at DESC',
    );
    return maps.map((m) => SpiritLogModel.fromMap(m)).toList();
  }

  /// 获取最近 N 条灵气日志
  Future<List<SpiritLogModel>> getRecentLogs(int limit) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'spirit_log',
      orderBy: 'created_at DESC',
      limit: limit,
    );
    return maps.map((m) => SpiritLogModel.fromMap(m)).toList();
  }

  /// 按来源获取灵气日志
  Future<List<SpiritLogModel>> getLogsBySource(String source) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'spirit_log',
      where: 'source = ?',
      whereArgs: [source],
      orderBy: 'created_at DESC',
    );
    return maps.map((m) => SpiritLogModel.fromMap(m)).toList();
  }

  /// 获取指定来源的累计灵气
  Future<int> getSpiritBySource(String source) async {
    final db = await _dbHelper.database;
    final result = await db.rawQuery(
      'SELECT COALESCE(SUM(amount), 0) as total FROM spirit_log WHERE source = ?',
      [source],
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  /// 获取今日获得的灵气
  Future<int> getTodaySpirit() async {
    final db = await _dbHelper.database;
    final today = DateTime.now().toIso8601String().split('T')[0];
    final result = await db.rawQuery(
      "SELECT COALESCE(SUM(amount), 0) as total FROM spirit_log WHERE date(created_at) = ?",
      [today],
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }
}
