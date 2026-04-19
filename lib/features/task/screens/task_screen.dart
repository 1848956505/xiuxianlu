import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../domain/models/task_model.dart';
import '../providers/task_provider.dart';
import '../../realm/providers/realm_provider.dart';

/// 任务页面 - 现代简约风格 TODO 任务列表
class TaskScreen extends ConsumerStatefulWidget {
  const TaskScreen({super.key});

  @override
  ConsumerState<TaskScreen> createState() => _TaskScreenState();
}

class _TaskScreenState extends ConsumerState<TaskScreen> {
  final TextEditingController _titleController = TextEditingController();
  final Set<String> _expandedTasks = {};

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
      loading: () => const Center(
        child: CircularProgressIndicator(strokeWidth: 2),
      ),
      error: (_, __) => _buildErrorState(),
    );
  }

  // ---------------------------------------------------------------------------
  // Content
  // ---------------------------------------------------------------------------

  Widget _buildContent(List<TaskModel> tasks) {
    final rootTasks = tasks.where((t) => t.isRoot).toList();

    return Column(
      children: [
        _buildInputBar(),
        Expanded(
          child: rootTasks.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
                  padding: const EdgeInsets.only(top: 4, bottom: 80),
                  itemCount: rootTasks.length,
                  itemBuilder: (context, index) {
                    return _buildTaskItem(rootTasks[index], tasks, 0);
                  },
                ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Input bar
  // ---------------------------------------------------------------------------

  Widget _buildInputBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 42,
              decoration: BoxDecoration(
                color: AppColors.lightSurfaceVariant,
                borderRadius: BorderRadius.circular(21),
              ),
              child: TextField(
                controller: _titleController,
                decoration: InputDecoration(
                  hintText: '添加修行任务...',
                  hintStyle: TextStyle(
                    color: AppColors.textHint,
                    fontSize: 14,
                  ),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 18),
                  isDense: true,
                ),
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 14,
                ),
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _addTask(TaskType.adventure),
              ),
            ),
          ),
          const SizedBox(width: 8),
          // 奇遇按钮
          Tooltip(
            message: '奇遇任务',
            child: _iconButton(
              icon: Icons.bolt,
              color: AppColors.encounter,
              onTap: () => _addTask(TaskType.adventure),
            ),
          ),
          const SizedBox(width: 6),
          // 主线按钮
          Tooltip(
            message: '主线任务',
            child: _iconButton(
              icon: Icons.account_tree,
              color: AppColors.mainline,
              onTap: () => _addTask(TaskType.mainline),
            ),
          ),
        ],
      ),
    );
  }

  Widget _iconButton({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: color,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: SizedBox(
          width: 36,
          height: 36,
          child: Icon(icon, color: Colors.white, size: 18),
        ),
      ),
    );
  }

  void _addTask(TaskType type) {
    final title = _titleController.text.trim();
    if (title.isEmpty) return;

    final notifier = ref.read(taskProvider.notifier);
    if (type == TaskType.mainline) {
      notifier.addMainlineTask(title);
    } else {
      notifier.addAdventureTask(title);
    }
    _titleController.clear();
  }

  // ---------------------------------------------------------------------------
  // Empty & Error states
  // ---------------------------------------------------------------------------

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 48),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.self_improvement,
              size: 72,
              color: AppColors.textHint.withValues(alpha: 0.45),
            ),
            const SizedBox(height: 20),
            Text(
              '道途漫漫，从第一个修行目标开始',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              '点击上方按钮添加奇遇或主线任务',
              style: TextStyle(
                color: AppColors.textHint,
                fontSize: 13,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.cloud_off, size: 48, color: AppColors.textHint),
          const SizedBox(height: 16),
          Text(
            '加载失败，请重试',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 12),
          TextButton.icon(
            onPressed: () => ref.read(taskProvider.notifier).refresh(),
            icon: const Icon(Icons.refresh, size: 18),
            label: const Text('重试'),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Task item
  // ---------------------------------------------------------------------------

  Widget _buildTaskItem(
    TaskModel task,
    List<TaskModel> allTasks,
    int depth,
  ) {
    final children = allTasks.where((t) => t.parentId == task.id).toList();
    final isExpanded = _expandedTasks.contains(task.id);
    final isMainline = task.type == TaskType.mainline;
    // Root tasks: 16px indent; subtasks: 16 + 32 = 48px indent
    final leftPadding = 16.0 + depth * 32.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Dismissible(
          key: ValueKey(task.id),
          // 右滑完成（快速，无确认）
          background: _swipeBackground(
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.only(left: 28),
            color: AppColors.success,
            icon: Icons.check_rounded,
          ),
          // 左滑删除（需确认）
          secondaryBackground: _swipeBackground(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 28),
            color: AppColors.cinnabarRed,
            icon: Icons.delete_outline,
          ),
          confirmDismiss: (direction) async {
            if (direction == DismissDirection.startToEnd) {
              // 右滑 -> 直接完成，无需确认
              ref.read(taskProvider.notifier).toggleComplete(task.id);
              return false; // 不移除 widget，让 toggleComplete 刷新状态
            }
            // 左滑 -> 弹出删除确认
            final confirmed = await showDialog<bool>(
              context: context,
              builder: (ctx) => AlertDialog(
                title: const Text('确认删除'),
                content: Text(
                  '确定要删除"${task.title}"吗？'
                  '${children.isNotEmpty ? '\n子任务也将一并删除。' : ''}',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(ctx, false),
                    child: const Text('取消'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(ctx, true),
                    child: Text(
                      '删除',
                      style: TextStyle(color: AppColors.cinnabarRed),
                    ),
                  ),
                ],
              ),
            );
            return confirmed ?? false;
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
                left: leftPadding,
                right: 16,
                top: 13,
                bottom: 13,
              ),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: AppColors.divider.withValues(alpha: 0.25),
                    width: 0.5,
                  ),
                ),
              ),
              child: Row(
                children: [
                  // 圆形勾选框
                  GestureDetector(
                    onTap: () =>
                        ref.read(taskProvider.notifier).toggleComplete(task.id),
                    child: _buildCheckbox(task.isCompleted),
                  ),
                  const SizedBox(width: 12),
                  // 类型小圆点
                  Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isMainline
                          ? AppColors.mainline
                          : AppColors.encounter,
                    ),
                  ),
                  const SizedBox(width: 10),
                  // 任务标题
                  Expanded(
                    child: Text(
                      task.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: task.isCompleted
                            ? AppColors.textHint
                            : AppColors.textPrimary,
                        fontSize: 14,
                        height: 1.4,
                        decoration: task.isCompleted
                            ? TextDecoration.lineThrough
                            : null,
                        decorationColor: AppColors.textHint,
                      ),
                    ),
                  ),
                  // 展开/折叠箭头（主线任务）
                  if (isMainline)
                    Padding(
                      padding: const EdgeInsets.only(left: 4),
                      child: Icon(
                        isExpanded
                            ? Icons.keyboard_arrow_up
                            : Icons.keyboard_arrow_down,
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
        // 子任务列表
        if (isExpanded && children.isNotEmpty)
          ...children.map(
            (child) => _buildTaskItem(child, allTasks, depth + 1),
          ),
        // 添加子任务
        if (isExpanded && isMainline && !task.isArchived)
          _SubTaskInput(parentTask: task, depth: depth + 1),
      ],
    );
  }

  /// 圆形勾选框
  Widget _buildCheckbox(bool completed) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: completed
            ? null
            : Border.all(color: AppColors.textHint, width: 1.5),
        color: completed ? const Color(0xFF6366F1) : Colors.transparent,
      ),
      child: completed
          ? const Icon(Icons.check, size: 13, color: Colors.white)
          : null,
    );
  }

  /// 滑动背景
  Widget _swipeBackground({
    required Alignment alignment,
    required EdgeInsets padding,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      alignment: alignment,
      padding: padding,
      color: color,
      child: Icon(icon, color: Colors.white, size: 22),
    );
  }
}

// =============================================================================
// Archive button
// =============================================================================

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
      setState(() => _canArchive = canArchive);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_canArchive) return const SizedBox.shrink();

    return GestureDetector(
      onTap: () => _showArchiveDialog(context),
      child: Padding(
        padding: const EdgeInsets.only(left: 4),
        child: Icon(
          Icons.archive_outlined,
          size: 18,
          color: AppColors.gold,
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
          '归档后将获得灵气奖励，任务将移入归档列表。\n\n'
          '确定要归档"${widget.task.title}"吗？',
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

// =============================================================================
// Sub-task input
// =============================================================================

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
    final leftPadding = 16.0 + widget.depth * 32.0;

    if (!_showInput) {
      return InkWell(
        onTap: () => setState(() => _showInput = true),
        child: Container(
          padding: EdgeInsets.only(
            left: leftPadding + 20 + 12 + 6 + 10, // checkbox + gap + dot + gap
            right: 16,
            top: 8,
            bottom: 8,
          ),
          child: Row(
            children: [
              Icon(Icons.add, size: 15, color: AppColors.textHint),
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
        left: leftPadding,
        right: 16,
        top: 4,
        bottom: 8,
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
                fillColor: AppColors.lightSurfaceVariant,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                isDense: true,
              ),
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 13,
              ),
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _addSubTask(),
            ),
          ),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: _addSubTask,
            child: const Padding(
              padding: EdgeInsets.all(4),
              child: Icon(Icons.check, size: 18, color: AppColors.success),
            ),
          ),
          GestureDetector(
            onTap: () {
              setState(() {
                _showInput = false;
                _controller.clear();
              });
            },
            child: const Padding(
              padding: EdgeInsets.all(4),
              child: Icon(Icons.close, size: 18, color: AppColors.textHint),
            ),
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
