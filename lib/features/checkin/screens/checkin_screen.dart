import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/providers.dart';
import '../../../domain/models/spirit_log_model.dart';
import '../providers/checkin_provider.dart';
import '../../realm/providers/realm_provider.dart';

/// 签到页面 - 签到按钮 + 灵气获取记录
class CheckinScreen extends ConsumerStatefulWidget {
  const CheckinScreen({super.key});

  @override
  ConsumerState<CheckinScreen> createState() => _CheckinScreenState();
}

class _CheckinScreenState extends ConsumerState<CheckinScreen> {
  List<SpiritLogModel> _recentLogs = [];

  @override
  void initState() {
    super.initState();
    _loadLogs();
  }

  Future<void> _loadLogs() async {
    final spiritRepo = ref.read(spiritRepositoryProvider);
    final logs = await spiritRepo.getRecentLogs(20);
    if (mounted) {
      setState(() {
        _recentLogs = logs;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final checkinAsync = ref.watch(checkinProvider);

    return checkinAsync.when(
      data: (hasCheckedIn) => _buildContent(hasCheckedIn),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(
        child: Text('加载失败: $error',
            style: TextStyle(color: AppColors.textSecondary)),
      ),
    );
  }

  Widget _buildContent(bool hasCheckedIn) {
    return RefreshIndicator(
      onRefresh: () async {
        await ref.read(checkinProvider.notifier).refresh();
        await _loadLogs();
        ref.read(realmProvider.notifier).refresh();
      },
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const SizedBox(height: 20),
          // 签到按钮区域
          _buildCheckinButton(hasCheckedIn),
          const SizedBox(height: 32),
          // 灵气获取记录标题
          Text(
            '灵气记录',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          // 灵气记录列表
          if (_recentLogs.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.only(top: 40),
                child: Text(
                  '暂无灵气记录',
                  style: TextStyle(color: AppColors.textHint, fontSize: 14),
                ),
              ),
            )
          else
            ..._recentLogs.map((log) => _buildLogItem(log)),
        ],
      ),
    );
  }

  /// 构建签到按钮
  Widget _buildCheckinButton(bool hasCheckedIn) {
    return Center(
      child: Column(
        children: [
          // 签到按钮
          GestureDetector(
            onTap: hasCheckedIn ? null : _handleCheckin,
            child: Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: hasCheckedIn
                    ? LinearGradient(
                        colors: [
                          AppColors.surfaceVariant,
                          AppColors.cardBackground,
                        ],
                      )
                    : LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppColors.cinnabarRed,
                          AppColors.cinnabarRedLight,
                        ],
                      ),
                boxShadow: hasCheckedIn
                    ? []
                    : [
                        BoxShadow(
                          color: AppColors.cinnabarRed.withValues(alpha: 0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                border: Border.all(
                  color: hasCheckedIn
                      ? AppColors.divider
                      : AppColors.cinnabarRedLight.withValues(alpha: 0.5),
                  width: 2,
                ),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      hasCheckedIn
                          ? Icons.check_circle_outline
                          : Icons.wb_sunny,
                      size: 40,
                      color: hasCheckedIn
                          ? AppColors.textHint
                          : AppColors.textPrimary,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      hasCheckedIn ? '已签到' : '晨练签到',
                      style: TextStyle(
                        color: hasCheckedIn
                            ? AppColors.textHint
                            : AppColors.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 2,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            hasCheckedIn ? '今日已修炼' : '点击签到获取 5 灵气',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  /// 处理签到
  Future<void> _handleCheckin() async {
    final spirit = await ref.read(checkinProvider.notifier).checkIn();
    if (spirit != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('签到成功，获得 $spirit 灵气'),
          backgroundColor: AppColors.gold,
          behavior: SnackBarBehavior.floating,
        ),
      );
      // 刷新灵气记录和境界
      await _loadLogs();
      ref.read(realmProvider.notifier).refresh();
    }
  }

  /// 构建灵气日志项
  Widget _buildLogItem(SpiritLogModel log) {
    final iconData = _getSourceIcon(log.source);
    final iconColor = _getSourceColor(log.source);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppColors.divider.withValues(alpha: 0.2)),
        ),
      ),
      child: Row(
        children: [
          // 来源图标
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(iconData, color: iconColor, size: 18),
          ),
          const SizedBox(width: 12),
          // 描述
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  log.description ?? log.source.label,
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _formatDate(log.createdAt),
                  style: TextStyle(
                    color: AppColors.textHint,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          // 灵气数量
          Text(
            '+${log.amount}',
            style: TextStyle(
              color: AppColors.gold,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  /// 获取来源图标
  IconData _getSourceIcon(SpiritSource source) {
    switch (source) {
      case SpiritSource.encounterComplete:
        return Icons.task_alt;
      case SpiritSource.mainlineArchive:
        return Icons.folder_special;
      case SpiritSource.dailyCheckIn:
        return Icons.wb_sunny;
      case SpiritSource.habitCheckIn:
        return Icons.repeat;
      case SpiritSource.pomodoro:
        return Icons.timer;
    }
  }

  /// 获取来源颜色
  Color _getSourceColor(SpiritSource source) {
    switch (source) {
      case SpiritSource.encounterComplete:
        return AppColors.encounter;
      case SpiritSource.mainlineArchive:
        return AppColors.mainline;
      case SpiritSource.dailyCheckIn:
        return AppColors.cinnabarRed;
      case SpiritSource.habitCheckIn:
        return AppColors.success;
      case SpiritSource.pomodoro:
        return AppColors.gold;
    }
  }

  /// 格式化日期
  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dateOnly = DateTime(date.year, date.month, date.day);
    final diff = today.difference(dateOnly).inDays;

    if (diff == 0) {
      return '今天 ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } else if (diff == 1) {
      return '昨天 ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } else {
      return '${date.month}月${date.day}日 ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    }
  }
}
