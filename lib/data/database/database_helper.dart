import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;
import 'tables.dart';

/// SQLite 数据库管理类（单例模式）
class DatabaseHelper {
  static DatabaseHelper? _instance;
  static Database? _database;

  /// 数据库版本
  static const int _databaseVersion = 1;

  /// 数据库名称
  static const String _databaseName = 'xiuxianlu.db';

  DatabaseHelper._();

  /// 获取单例实例
  static DatabaseHelper get instance {
    _instance ??= DatabaseHelper._();
    return _instance!;
  }

  /// 获取数据库实例（异步初始化）
  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  /// 初始化数据库
  Future<Database> _initDatabase() async {
    // 获取数据库路径
    final dbPath = await getDatabasesPath();
    final path = p.join(dbPath, _databaseName);

    // 打开或创建数据库
    return openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  /// 数据库创建回调
  Future<void> _onCreate(Database db, int version) async {
    // 执行 V1 迁移
    for (final sql in Tables.v1Migration) {
      await db.execute(sql);
    }
  }

  /// 数据库升级回调
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // V1 -> V2: 在此添加升级逻辑
    // if (oldVersion < 2) {
    //   await db.execute('ALTER TABLE ...');
    // }
  }

  /// 关闭数据库连接
  Future<void> close() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }
}
