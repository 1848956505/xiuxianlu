import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../domain/models/task_model.dart';
import '../providers/task_provider.dart';
import '../../realm/providers/realm_provider.dart';

/// 任务页面 - 任务列表 + 创建任务 + 主线子任务展开/折叠 + 归档功能
class TaskScreen extends ConsumerStatefulWidget {
  const TaskScreen({super.key});

  @override
  ConsumerState<TaskScreen> createState() => _TaskScreenState();
}

class _TaskScreenState extends ConsumerState<TaskScreen> {
  final TextEditingController _titleController = TextEditingController();
  final Set<String> _expandedTasks = {}; // 记录展开的主线任务 ID

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tasksAsync = ref.watch(taskProvider);

    return tasksAsync.when(
      data: (tasks) => _buildContent(tasks),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('加载失败: $error',
                style: TextStyle(color: AppColors.textSecondary)),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => ref.read(taskProvider.notifier).refresh(),
              child: const Text('重试'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(List<TaskModel> tasks) {
    // 分离根任务和子任务
    final rootTasks = tasks.where((t) => t.isRoot).toList();

    return Column(
      children: [
        // 任务输入区域
        _buildInputBar(),
        // 任务列表
        Expanded(
          child: rootTasks.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: rootTasks.length,
                  itemBuilder: (context, index) {
                    return _buildTaskItem(rootTasks[index], tasks, 0);
                  },
                ),
        ),
      ],
    );
  }

  /// 构建任务输入栏
  Widget _buildInputBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppColors.divider.withValues(alpha: 0.3)),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _titleController,
              decoration: InputDecoration(
                hintText: '输入新任务...',
                hintStyle: TextStyle(color: AppColors.textHint),
                filled: true,
                fillColor: AppColors.surfaceVariant,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              ),
              style: TextStyle(color: AppColors.textPrimary),
              onSubmitted: (_) => _addTask('adventure'),
            ),
          ),
          const SizedBox(width: 8),
          // 奇遇按钮
          SizedBox(
            height: 40,
            child: ElevatedButton(
              onPressed: () => _addTask('adventure'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.encounter,
                foregroundColor: AppColors.textPrimary,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('奇遇', style: TextStyle(fontSize: 13)),
            ),
          ),
          const SizedBox(width: 6),
          // 主线按钮
          SizedBox(
            height: 40,
            child: ElevatedButton(
              onPressed: () => _addTask('mainline'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.mainline,
                foregroundColor: AppColors.textPrimary,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('主线', style: TextStyle(fontSize: 13)),
            ),
          ),
        ],
      ),
    );
  }

  /// 添加任务
  void _addTask(String type) {
    final title = _titleController.text.trim();
    if (title.isEmpty) return;

    final notifier = ref.read(taskProvider.notifier);
    if (type == 'mainline') {
      notifier.addMainlineTask(title);
    } else {
      notifier.addAdventureTask(title);
    }
    _titleController.clear();
  }

  /// 构建空状态
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.auto_stories, size: 64, color: AppColors.textHint),
          const SizedBox(height: 16),
          Text(
            '尚无任务',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '添加奇遇或主线任务开始修仙之旅',
            style: TextStyle(
              color: AppColors.textHint,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  /// 构建任务项（支持递归子任务）
  Widget _buildTaskItem(
      TaskModel task, List<TaskModel> allTasks, int depth) {
    final children =
        allTasks.where((t) => t.parentId == task.id).toList();
    final isExpanded = _expandedTasks.contains(task.id);
    final isMainline = task.type == TaskType.mainline;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Dismissible(
          key: ValueKey(task.id),
          direction: DismissDirection.endToStart,
          background: Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20),
            color: AppColors.cinnabarRed,
            child: const Icon(Icons.delete, color: Colors.white),
          ),
          confirmDismiss: (direction) async {
            return await showDialog<bool>(
              context: context,
              builder: (ctx) => AlertDialog(
                title: const Text('确认删除'),
                content: Text('确定要删除"${task.title}"吗？${children.isNotEmpty ? '\n子任务也将一并删除。' : ''}'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(ctx, false),
                    child: const Text('取消'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(ctx, true),
                    child: Text('删除',
                        style: TextStyle(color: AppColors.cinnabarRed)),
                  ),
                ],
              ),
            );
          },
          onDismissed: (_) {
            ref.read(taskProvider.notifier).deleteTask(task.id);
          },
          child: InkWell(
            onTap: () {
              if (isMainline && children.isNotEmpty) {
                setState(() {
                  if (isExpanded) {
                    _expandedTasks.remove(task.id);
                  } else {
                    _expandedTasks.add(task.id);
                  }
                });
              }
            },
            child: Container(
              padding: EdgeInsets.only(
                left: 16.0 + depth * 24.0,
                right: 16,
                top: 10,
                bottom: 10,
              ),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: AppColors.divider.withValues(alpha: 0.2),
                  ),
                ),
              ),
              child: Row(
                children: [
                  // 完成复选框
                  GestureDetector(
                    onTap: () {
                      ref
                          .read(taskProvider.notifier)
                          .toggleComplete(task.id);
                    },
                    child: Container(
                      width: 22,
                      height: 22,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: task.isCompleted
                              ? AppColors.gold
                              : AppColors.textHint,
                          width: 1.5,
                        ),
                        color: task.isCompleted
                            ? AppColors.gold
                            : Colors.transparent,
                      ),
                      child: task.isCompleted
                          ? const Icon(Icons.check,
                              size: 14, color: AppColors.background)
                          : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  // 任务类型标签
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: (isMainline
                              ? AppColors.mainline
                              : AppColors.encounter)
                          .withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      isMainline ? '主线' : '奇遇',
                      style: TextStyle(
                        color: isMainline
                            ? AppColors.mainline
                            : AppColors.encounter,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // 任务标题
                  Expanded(
                    child: Text(
                      task.title,
                      style: TextStyle(
                        color: task.isCompleted
                            ? AppColors.textHint
                            : AppColors.textPrimary,
                        fontSize: 15,
                        decoration: task.isCompleted
                            ? TextDecoration.lineThrough
                            : null,
                      ),
                    ),
                  ),
                  // 展开指示器（主线任务有子任务时）
                  if (isMainline)
                    Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: Icon(
                        isExpanded
                            ? Icons.expand_less
                            : Icons.expand_more,
                        color: AppColors.textHint,
                        size: 20,
                      ),
                    ),
                  // 归档按钮（主线任务已完成时显示）
                  if (isMainline && task.isCompleted)
                    _ArchiveButton(task: task),
                ],
              ),
            ),
          ),
        ),
        // 子任务列表（展开时显示）
        if (isExpanded && children.isNotEmpty)
          ...children.map(
            (child) => _buildTaskItem(child, allTasks, depth + 1),
          ),
        // 添加子任务输入框（展开的主线任务底部）
        if (isExpanded && isMainline && !task.isArchived)
          _SubTaskInput(parentTask: task, depth: depth + 1),
      ],
    );
  }
}

/// 归档按钮组件
class _ArchiveButton extends ConsumerStatefulWidget {
  final TaskModel task;

  const _ArchiveButton({required this.task});

  @override
  ConsumerState<_ArchiveButton> createState() => _ArchiveButtonState();
}

class _ArchiveButtonState extends ConsumerState<_ArchiveButton> {
  bool _canArchive = false;

  @override
  void initState() {
    super.initState();
    _checkCanArchive();
  }

  Future<void> _checkCanArchive() async {
    final canArchive =
        await ref.read(taskProvider.notifier).canArchive(widget.task.id);
    if (mounted) {
      setState(() {
        _canArchive = canArchive;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_canArchive) return const SizedBox.shrink();

    return GestureDetector(
      onTap: () => _showArchiveDialog(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.gold.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: AppColors.gold.withValues(alpha: 0.4)),
        ),
        child: Text(
          '归档',
          style: TextStyle(
            color: AppColors.gold,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  void _showArchiveDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('确认归档'),
        content: Text(
          '归档后将获得灵气奖励，任务将移入归档列表。\n\n确定要归档"${widget.task.title}"吗？',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final spirit = await ref
                  .read(taskProvider.notifier)
                  .archiveTask(widget.task.id);
              if (spirit != null && mounted) {
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('功法封存，获得 $spirit 灵气'),
                    backgroundColor: AppColors.gold,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
                // 刷新境界信息
                ref.read(realmProvider.notifier).refresh();
              }
            },
            child: Text('归档', style: TextStyle(color: AppColors.gold)),
          ),
        ],
      ),
    );
  }
}

/// 子任务输入组件
class _SubTaskInput extends ConsumerStatefulWidget {
  final TaskModel parentTask;
  final int depth;

  const _SubTaskInput({required this.parentTask, required this.depth});

  @override
  ConsumerState<_SubTaskInput> createState() => _SubTaskInputState();
}

class _SubTaskInputState extends ConsumerState<_SubTaskInput> {
  final TextEditingController _controller = TextEditingController();
  bool _showInput = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_showInput) {
      return InkWell(
        onTap: () => setState(() => _showInput = true),
        child: Container(
          padding: EdgeInsets.only(
            left: 16.0 + widget.depth * 24.0 + 34,
            right: 16,
            top: 6,
            bottom: 6,
          ),
          child: Row(
            children: [
              Icon(Icons.add, size: 16, color: AppColors.textHint),
              const SizedBox(width: 4),
              Text(
                '添加子任务',
                style: TextStyle(color: AppColors.textHint, fontSize: 13),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      padding: EdgeInsets.only(
        left: 16.0 + widget.depth * 24.0,
        right: 16,
        top: 4,
        bottom: 4,
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              autofocus: true,
              decoration: InputDecoration(
                hintText: '子任务标题...',
                hintStyle: TextStyle(color: AppColors.textHint, fontSize: 13),
                filled: true,
                fillColor: AppColors.surfaceVariant,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(6),
                  borderSide: BorderSide.none,
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                isDense: true,
              ),
              style: TextStyle(color: AppColors.textPrimary, fontSize: 13),
              onSubmitted: (_) => _addSubTask(),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.check, size: 18),
            color: AppColors.gold,
            onPressed: _addSubTask,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
          IconButton(
            icon: const Icon(Icons.close, size: 18),
            color: AppColors.textHint,
            onPressed: () {
              setState(() {
                _showInput = false;
                _controller.clear();
              });
            },
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }

  void _addSubTask() {
    final title = _controller.text.trim();
    if (title.isEmpty) return;

    ref.read(taskProvider.notifier).addSubTask(
          widget.parentTask.id,
          title,
          'adventure',
        );
    _controller.clear();
  }
}
