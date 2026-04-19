import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/providers.dart';
import '../../../domain/models/spirit_log_model.dart';
import '../providers/checkin_provider.dart';
import '../../realm/providers/realm_provider.dart';

/// 签到页面 - 现代简约风格
class CheckinScreen extends ConsumerStatefulWidget {
  const CheckinScreen({super.key});

  @override
  ConsumerState<CheckinScreen> createState() => _CheckinScreenState();
}

class _CheckinScreenState extends ConsumerState<CheckinScreen>
    with SingleTickerProviderStateMixin {
  List<SpiritLogModel> _recentLogs = [];
  bool _isLoadingLogs = false;
  bool _logsError = false;
  int _consecutiveDays = 0;

  // 签到成功动画
  bool _showSpiritAnimation = false;
  double _spiritAnimOpacity = 0.0;
  double _spiritAnimOffset = 0.0;

  @override
  void initState() {
    super.initState();
    _loadLogs();
    _loadConsecutiveDays();
  }

  Future<void> _loadLogs() async {
    setState(() {
      _isLoadingLogs = true;
      _logsError = false;
    });
    try {
      final spiritRepo = ref.read(spiritRepositoryProvider);
      final logs = await spiritRepo.getRecentLogs(20);
      if (mounted) {
        setState(() {
          _recentLogs = logs;
          _isLoadingLogs = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _isLoadingLogs = false;
          _logsError = true;
        });
      }
    }
  }

  Future<void> _loadConsecutiveDays() async {
    try {
      final days =
          await ref.read(checkinProvider.notifier).getConsecutiveDays();
      if (mounted) {
        setState(() {
          _consecutiveDays = days;
        });
      }
    } catch (_) {
      // 静默失败，不影响主流程
    }
  }

  void _showSpiritGainAnimation() {
    setState(() {
      _showSpiritAnimation = true;
      _spiritAnimOpacity = 1.0;
      _spiritAnimOffset = 0.0;
    });

    // 动画：上浮并淡出
    Future.delayed(const Duration(milliseconds: 50), () {
      if (mounted) {
        setState(() {
          _spiritAnimOffset = -40.0;
          _spiritAnimOpacity = 0.0;
        });
      }
    });

    // 动画结束后清理
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) {
        setState(() {
          _showSpiritAnimation = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final checkinAsync = ref.watch(checkinProvider);

    return checkinAsync.when(
      data: (hasCheckedIn) => _buildContent(hasCheckedIn),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => _buildErrorState(error.toString()),
    );
  }

  /// 错误状态
  Widget _buildErrorState(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline,
              size: 48,
              color: AppColors.textHint,
            ),
            const SizedBox(height: 16),
            Text(
              '加载失败',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              style: TextStyle(
                color: AppColors.textHint,
                fontSize: 13,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () {
                ref.read(checkinProvider.notifier).refresh();
              },
              icon: const Icon(Icons.refresh, size: 18),
              label: const Text('重试'),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(bool hasCheckedIn) {
    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: () async {
        await ref.read(checkinProvider.notifier).refresh();
        await _loadLogs();
        await _loadConsecutiveDays();
        ref.read(realmProvider.notifier).refresh();
      },
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        children: [
          const SizedBox(height: 32),
          // 签到按钮区域
          _buildCheckinArea(hasCheckedIn),
          const SizedBox(height: 36),
          // 灵气记录标题
          _buildSectionHeader(),
          const SizedBox(height: 8),
          // 灵气记录列表
          _buildLogsList(),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  /// 签到区域
  Widget _buildCheckinArea(bool hasCheckedIn) {
    return Center(
      child: Column(
        children: [
          // 签到按钮 + 浮动灵气动画
          Stack(
            clipBehavior: Clip.none,
            children: [
              // 签到按钮
              _buildCheckinButton(hasCheckedIn),
              // +5 灵气浮动动画
              if (_showSpiritAnimation)
                Positioned(
                  top: -20,
                  left: 0,
                  right: 0,
                  child: AnimatedOpacity(
                    opacity: _spiritAnimOpacity,
                    duration: const Duration(milliseconds: 700),
                    child: AnimatedSlide(
                      offset: Offset(0, _spiritAnimOffset / 40),
                      duration: const Duration(milliseconds: 700),
                      curve: Curves.easeOut,
                      child: Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.success,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color:
                                    AppColors.success.withValues(alpha: 0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Text(
                            '+5 灵气',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          // 连续签到天数
          if (_consecutiveDays > 0)
            Text(
              '连续签到 $_consecutiveDays 天',
              style: TextStyle(
                color: AppColors.textHint,
                fontSize: 13,
              ),
            ),
        ],
      ),
    );
  }

  /// 签到按钮
  Widget _buildCheckinButton(bool hasCheckedIn) {
    return GestureDetector(
      onTap: hasCheckedIn ? null : _handleCheckin,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        width: 120,
        height: 120,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: hasCheckedIn
              ? null
              : const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF6366F1),
                    Color(0xFF818CF8),
                  ],
                ),
          color: hasCheckedIn ? const Color(0xFFF3F4F6) : null,
          boxShadow: hasCheckedIn
              ? []
              : [
                  BoxShadow(
                    color: const Color(0xFF6366F1).withValues(alpha: 0.35),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ],
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                hasCheckedIn ? Icons.check_circle : Icons.wb_sunny,
                size: 36,
                color: hasCheckedIn ? AppColors.success : Colors.white,
              ),
              const SizedBox(height: 6),
              Text(
                hasCheckedIn ? '已签到 \u2713' : '今日签到',
                style: TextStyle(
                  color: hasCheckedIn
                      ? AppColors.success
                      : Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 灵气记录标题
  Widget _buildSectionHeader() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        '灵气记录',
        style: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  /// 灵气记录列表
  Widget _buildLogsList() {
    if (_isLoadingLogs) {
      return const Padding(
        padding: EdgeInsets.only(top: 40),
        child: Center(
          child: SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      );
    }

    if (_logsError) {
      return Padding(
        padding: const EdgeInsets.only(top: 40),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.cloud_off, size: 36, color: AppColors.textHint),
              const SizedBox(height: 12),
              Text(
                '加载失败',
                style: TextStyle(color: AppColors.textHint, fontSize: 14),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: _loadLogs,
                child: Text(
                  '重试',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_recentLogs.isEmpty) {
      return Padding(
        padding: const EdgeInsets.only(top: 48),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.inbox_outlined, size: 40, color: AppColors.textHint),
              const SizedBox(height: 12),
              Text(
                '暂无灵气记录',
                style: TextStyle(color: AppColors.textHint, fontSize: 14),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: List.generate(_recentLogs.length, (index) {
        final log = _recentLogs[index];
        final isLast = index == _recentLogs.length - 1;
        return _buildLogItem(log, isLast);
      }),
    );
  }

  /// 灵气日志项
  Widget _buildLogItem(SpiritLogModel log, bool isLast) {
    final iconData = _getSourceIcon(log.source);
    final iconColor = _getSourceColor(log.source);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        border: isLast
            ? null
            : Border(
                bottom: BorderSide(
                  color: AppColors.lightDivider,
                  width: 0.5,
                ),
              ),
      ),
      child: Row(
        children: [
          // 来源图标
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(iconData, color: iconColor, size: 18),
          ),
          const SizedBox(width: 12),
          // 描述 + 时间
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  log.description ?? log.source.label,
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 3),
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
            style: const TextStyle(
              color: AppColors.success,
              fontSize: 15,
              fontWeight: FontWeight.w600,
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
      _showSpiritGainAnimation();
      // 刷新灵气记录、连续天数和境界
      await _loadLogs();
      await _loadConsecutiveDays();
      ref.read(realmProvider.notifier).refresh();
    }
  }

  /// 获取来源图标
  IconData _getSourceIcon(SpiritSource source) {
    switch (source) {
      case SpiritSource.dailyCheckIn:
        return Icons.wb_sunny;
      case SpiritSource.encounterComplete:
        return Icons.check_circle;
      case SpiritSource.mainlineArchive:
        return Icons.archive;
      case SpiritSource.habitCheckIn:
        return Icons.repeat;
      case SpiritSource.pomodoro:
        return Icons.star;
    }
  }

  /// 获取来源颜色
  Color _getSourceColor(SpiritSource source) {
    switch (source) {
      case SpiritSource.dailyCheckIn:
        return AppColors.primary; // 靛蓝紫
      case SpiritSource.encounterComplete:
        return AppColors.success; // 绿色
      case SpiritSource.mainlineArchive:
        return AppColors.gold; // 金色
      case SpiritSource.habitCheckIn:
        return AppColors.mainline; // 紫色
      case SpiritSource.pomodoro:
        return AppColors.textHint; // 灰色
    }
  }

  /// 格式化日期
  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dateOnly = DateTime(date.year, date.month, date.day);
    final diff = today.difference(dateOnly).inDays;

    final time =
        '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';

    if (diff == 0) {
      return '今天 $time';
    } else if (diff == 1) {
      return '昨天 $time';
    } else {
      return '${date.month}月${date.day}日 $time';
    }
  }
}
