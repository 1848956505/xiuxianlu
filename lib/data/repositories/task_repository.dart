import '../database/database_helper.dart';
import '../../domain/models/task_model.dart';

/// 任务数据仓库
/// 负责任务的 CRUD 操作、子任务查询、归档逻辑
class TaskRepository {
  final DatabaseHelper _dbHelper;

  TaskRepository(this._dbHelper);

  // ===== 基础 CRUD =====

  /// 创建任务
  Future<TaskModel> createTask({
    required String id,
    required String title,
    String? description,
    required String type,
    String? parentId,
    int order = 0,
  }) async {
    final db = await _dbHelper.database;
    final now = DateTime.now().toIso8601String();
    final task = TaskModel(
      id: id,
      title: title,
      description: description,
      type: type == 'mainline' ? TaskType.mainline : TaskType.adventure,
      parentId: parentId,
      status: TaskStatus.active,
      order: order,
      createdAt: DateTime.now(),
    );

    await db.insert('tasks', {
      'id': task.id,
      'title': task.title,
      'description': task.description,
      'type': task.type.value,
      'parent_id': task.parentId,
      'status': task.status.value,
      'sort_order': task.order,
      'created_at': now,
      'completed_at': null,
      'archived_at': null,
      'spirit_awarded': 0,
    });

    return task;
  }

  /// 获取所有未归档的任务
  Future<List<TaskModel>> getActiveTasks() async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'tasks',
      where: 'status != ?',
      whereArgs: ['archived'],
      orderBy: 'sort_order ASC, created_at DESC',
    );
    return maps.map((m) => TaskModel.fromMap(m)).toList();
  }

  /// 获取指定父任务的子任务
  Future<List<TaskModel>> getChildren(String parentId) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'tasks',
      where: 'parent_id = ? AND status != ?',
      whereArgs: [parentId, 'archived'],
      orderBy: 'sort_order ASC, created_at DESC',
    );
    return maps.map((m) => TaskModel.fromMap(m)).toList();
  }

  /// 获取根任务（无父节点的未归档任务）
  Future<List<TaskModel>> getRootTasks() async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'tasks',
      where: 'parent_id IS NULL AND status != ?',
      whereArgs: ['archived'],
      orderBy: 'sort_order ASC, created_at DESC',
    );
    return maps.map((m) => TaskModel.fromMap(m)).toList();
  }

  /// 获取单个任务
  Future<TaskModel?> getTask(String id) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'tasks',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isEmpty) return null;
    return TaskModel.fromMap(maps.first);
  }

  /// 更新任务
  Future<void> updateTask(TaskModel task) async {
    final db = await _dbHelper.database;
    await db.update(
      'tasks',
      task.toMap(),
      where: 'id = ?',
      whereArgs: [task.id],
    );
  }

  /// 删除任务及其所有子任务（递归）
  Future<void> deleteTask(String id) async {
    final db = await _dbHelper.database;

    // 先递归删除所有子任务
    final children = await getChildren(id);
    for (final child in children) {
      await deleteTask(child.id);
    }

    // 删除任务本身
    await db.delete(
      'tasks',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// 获取以指定任务为根的整棵子树（包括自身）
  Future<List<TaskModel>> getSubtree(String rootId) async {
    final List<TaskModel> result = [];
    await _collectSubtree(rootId, result);
    return result;
  }

  /// 递归收集子树节点
  Future<void> _collectSubtree(
      String parentId, List<TaskModel> result) async {
    final task = await getTask(parentId);
    if (task == null) return;
    result.add(task);

    final children = await getChildren(parentId);
    for (final child in children) {
      await _collectSubtree(child.id, result);
    }
  }

  /// 获取同级任务的最大排序值
  Future<int> getMaxOrder({String? parentId}) async {
    final db = await _dbHelper.database;
    if (parentId == null) {
      final result = await db.rawQuery(
        'SELECT MAX(sort_order) as max_order FROM tasks WHERE parent_id IS NULL AND status != ?',
        ['archived'],
      );
      return (result.first['max_order'] as int?) ?? -1;
    } else {
      final result = await db.rawQuery(
        'SELECT MAX(sort_order) as max_order FROM tasks WHERE parent_id = ? AND status != ?',
        [parentId, 'archived'],
      );
      return (result.first['max_order'] as int?) ?? -1;
    }
  }

  // ===== 归档逻辑 =====

  /// 检查任务是否可以归档
  /// 条件：任务已完成，且所有后代节点都已完成
  Future<bool> canArchive(String taskId) async {
    final task = await getTask(taskId);
    if (task == null) return false;
    if (task.isArchived) return false;
    if (!task.isCompleted) return false;

    // 获取所有后代节点
    final subtree = await getSubtree(taskId);
    // 排除自身，检查所有后代
    for (final node in subtree) {
      if (node.id != taskId && !node.isCompleted) {
        return false;
      }
    }

    return true;
  }

  /// 归档任务
  /// 1. 检查所有后代节点是否都已完成
  /// 2. 将子树中所有未归档节点标记为 archived
  /// 3. 计算灵气 = 未归档节点数 x 10
  /// 4. 如果是根节点，灵气 x 3
  /// 5. 返回获得的灵气数
  Future<int?> archiveTask(String taskId) async {
    // 检查是否可以归档
    final canArchiveResult = await canArchive(taskId);
    if (!canArchiveResult) return null;

    // 获取整棵子树
    final subtree = await getSubtree(taskId);

    // 筛选出未归档的节点
    final unarchivedNodes =
        subtree.where((node) => !node.isArchived).toList();

    if (unarchivedNodes.isEmpty) return null;

    // 计算灵气
    final nodeCount = unarchivedNodes.length;
    int spirit = nodeCount * 10;

    // 判断是否为根节点
    final task = await getTask(taskId);
    if (task != null && task.isRoot) {
      spirit = spirit * 3;
    }

    // 标记所有未归档节点为已归档
    final now = DateTime.now();
    final db = await _dbHelper.database;
    for (final node in unarchivedNodes) {
      await db.update(
        'tasks',
        {
          'status': 'archived',
          'archived_at': now.toIso8601String(),
          'spirit_awarded': node.spiritAwarded,
        },
        where: 'id = ?',
        whereArgs: [node.id],
      );
    }

    return spirit;
  }

  /// 获取已归档的任务
  Future<List<TaskModel>> getArchivedTasks() async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'tasks',
      where: 'status = ?',
      whereArgs: ['archived'],
      orderBy: 'archived_at DESC',
    );
    return maps.map((m) => TaskModel.fromMap(m)).toList();
  }

  /// 切换任务完成状态
  Future<TaskModel> toggleComplete(String taskId) async {
    final task = await getTask(taskId);
    if (task == null) throw Exception('任务不存在: $taskId');

    final now = DateTime.now();
    if (task.isCompleted) {
      // 取消完成
      return task.copyWith(
        status: TaskStatus.active,
        completedAt: null,
      );
    } else {
      // 标记完成
      return task.copyWith(
        status: TaskStatus.completed,
        completedAt: now,
      );
    }
  }
}
