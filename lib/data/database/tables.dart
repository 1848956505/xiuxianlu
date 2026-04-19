/// 数据库建表语句
/// V1 版本包含三张表：tasks、check_ins、spirit_log
class Tables {
  Tables._();

  // ===== 任务表 =====
  static const String createTasksTable = '''
    CREATE TABLE IF NOT EXISTS tasks (
      id              TEXT PRIMARY KEY,
      parent_id       TEXT,
      title           TEXT NOT NULL,
      description     TEXT,
      type            TEXT NOT NULL CHECK(type IN ('adventure', 'mainline')),
      status          TEXT NOT NULL DEFAULT 'active' CHECK(status IN ('active', 'completed', 'archived')),
      sort_order      INTEGER NOT NULL DEFAULT 0,
      created_at      TEXT NOT NULL,
      completed_at    TEXT,
      archived_at     TEXT,
      spirit_awarded  INTEGER NOT NULL DEFAULT 0,
      FOREIGN KEY (parent_id) REFERENCES tasks(id) ON DELETE CASCADE
    )
  ''';

  static const String createTasksParentIndex =
      'CREATE INDEX IF NOT EXISTS idx_tasks_parent ON tasks(parent_id)';
  static const String createTasksStatusIndex =
      'CREATE INDEX IF NOT EXISTS idx_tasks_status ON tasks(status)';
  static const String createTasksTypeIndex =
      'CREATE INDEX IF NOT EXISTS idx_tasks_type ON tasks(type)';

  // ===== 签到表 =====
  static const String createCheckinsTable = '''
    CREATE TABLE IF NOT EXISTS check_ins (
      id            TEXT PRIMARY KEY,
      date          TEXT NOT NULL UNIQUE,
      spirit_gained INTEGER NOT NULL DEFAULT 5,
      created_at    TEXT NOT NULL
    )
  ''';

  static const String createCheckinsDateIndex =
      'CREATE INDEX IF NOT EXISTS idx_checkins_date ON check_ins(date)';

  // ===== 灵气日志表 =====
  static const String createSpiritLogTable = '''
    CREATE TABLE IF NOT EXISTS spirit_log (
      id          TEXT PRIMARY KEY,
      amount      INTEGER NOT NULL,
      source      TEXT NOT NULL CHECK(source IN (
        'encounterComplete',
        'mainlineArchive',
        'dailyCheckIn',
        'habitCheckIn',
        'pomodoro'
      )),
      source_id   TEXT,
      description TEXT,
      created_at  TEXT NOT NULL
    )
  ''';

  static const String createSpiritLogCreatedIndex =
      'CREATE INDEX IF NOT EXISTS idx_spirit_log_created ON spirit_log(created_at)';
  static const String createSpiritLogSourceIndex =
      'CREATE INDEX IF NOT EXISTS idx_spirit_log_source ON spirit_log(source)';

  /// V1 数据库初始化 SQL
  static const List<String> v1Migration = [
    createTasksTable,
    createTasksParentIndex,
    createTasksStatusIndex,
    createTasksTypeIndex,
    createCheckinsTable,
    createCheckinsDateIndex,
    createSpiritLogTable,
    createSpiritLogCreatedIndex,
    createSpiritLogSourceIndex,
  ];
}
