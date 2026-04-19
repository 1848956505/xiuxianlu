import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../core/providers.dart';
import '../../../data/repositories/task_repository.dart';
import '../../../data/repositories/spirit_repository.dart';
import '../../../domain/models/task_model.dart';
import '../../../domain/models/spirit_log_model.dart';

const _uuid = Uuid();

/// 任务仓库 Provider
final taskRepositoryProvider = Provider<TaskRepository>((ref) {
  final dbHelper = ref.watch(databaseHelperProvider);
  return TaskRepository(dbHelper);
});

/// 任务列表状态管理
class TaskNotifier extends StateNotifier<AsyncValue<List<TaskModel>>> {
  final TaskRepository _taskRepo;
  final SpiritRepository _spiritRepo;

  TaskNotifier(this._taskRepo, this._spiritRepo) : super(const AsyncValue.loading()) {
    _loadTasks();
  }

  /// 加载所有活跃任务
  Future<void> _loadTasks() async {
    try {
      state = const AsyncValue.loading();
      final tasks = await _taskRepo.getActiveTasks();
      state = AsyncValue.data(tasks);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// 刷新任务列表
  Future<void> refresh() async {
    await _loadTasks();
  }

  /// 创建奇遇任务
  Future<TaskModel> addAdventureTask(String title) async {
    final id = _uuid.v4();
    final maxOrder = await _taskRepo.getMaxOrder();
    final task = await _taskRepo.createTask(
      id: id,
      title: title,
      type: 'adventure',
      order: maxOrder + 1,
    );
    await _loadTasks();
    return task;
  }

  /// 创建主线任务
  Future<TaskModel> addMainlineTask(String title) async {
    final id = _uuid.v4();
    final maxOrder = await _taskRepo.getMaxOrder();
    final task = await _taskRepo.createTask(
      id: id,
      title: title,
      type: 'mainline',
      order: maxOrder + 1,
    );
    await _loadTasks();
    return task;
  }

  /// 添加子任务
  Future<TaskModel> addSubTask(String parentId, String title, String type) async {
    final id = _uuid.v4();
    final maxOrder = await _taskRepo.getMaxOrder(parentId: parentId);
    final task = await _taskRepo.createTask(
      id: id,
      title: title,
      type: type,
      parentId: parentId,
      order: maxOrder + 1,
    );
    await _loadTasks();
    return task;
  }

  /// 切换任务完成状态
  Future<void> toggleComplete(String taskId) async {
    final updatedTask = await _taskRepo.toggleComplete(taskId);
    await _taskRepo.updateTask(updatedTask);

    // 如果是从未完成变为已完成，且是奇遇任务，发放灵气
    if (updatedTask.isCompleted && updatedTask.type == TaskType.adventure) {
      await _spiritRepo.addSpiritLog(
        id: _uuid.v4(),
        amount: 5,
        source: SpiritSource.encounterComplete.value,
        sourceId: taskId,
        description: '完成奇遇: ${updatedTask.title}',
      );
    }

    await _loadTasks();
  }

  /// 删除任务
  Future<void> deleteTask(String taskId) async {
    await _taskRepo.deleteTask(taskId);
    await _loadTasks();
  }

  /// 归档任务
  /// 返回获得的灵气数，如果无法归档返回 null
  Future<int?> archiveTask(String taskId) async {
    final spirit = await _taskRepo.archiveTask(taskId);
    if (spirit != null) {
      // 记录灵气日志
      await _spiritRepo.addSpiritLog(
        id: _uuid.v4(),
        amount: spirit,
        source: SpiritSource.mainlineArchive.value,
        sourceId: taskId,
        description: '主线归档',
      );
      await _loadTasks();
    }
    return spirit;
  }

  /// 检查任务是否可以归档
  Future<bool> canArchive(String taskId) async {
    return _taskRepo.canArchive(taskId);
  }

  /// 获取任务的子任务
  Future<List<TaskModel>> getChildren(String parentId) async {
    return _taskRepo.getChildren(parentId);
  }
}

/// 任务列表 Provider
final taskProvider =
    StateNotifierProvider<TaskNotifier, AsyncValue<List<TaskModel>>>((ref) {
  final taskRepo = ref.watch(taskRepositoryProvider);
  final spiritRepo = ref.watch(spiritRepositoryProvider);
  return TaskNotifier(taskRepo, spiritRepo);
});
