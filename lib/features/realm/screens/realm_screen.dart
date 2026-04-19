import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/realm_config.dart';
import '../../../domain/models/user_profile_model.dart';
import '../providers/realm_provider.dart';

/// 境界页面 - 现代简约风格境界展示
class RealmScreen extends ConsumerStatefulWidget {
  const RealmScreen({super.key});

  @override
  ConsumerState<RealmScreen> createState() => _RealmScreenState();
}

class _RealmScreenState extends ConsumerState<RealmScreen> {
  String? _previousRealmId;

  // 颜色常量
  static const Color _indigoPurple = Color(0xFF6366F1);
  static const Color _indigoPurpleLight = Color(0xFF818CF8);
  static const Color _gold = Color(0xFFD4A574);
  static const Color _goldLight = Color(0xFFE8C9A0);

  bool get _isDark => Theme.of(context).brightness == Brightness.dark;

  Color get _cardBg => _isDark ? const Color(0xFF222240) : Colors.white;

  Color get _textPrimary =>
      _isDark ? const Color(0xFFE8E8F0) : const Color(0xFF1A1A2E);

  Color get _textSecondary =>
      _isDark ? const Color(0xFF9E9EB0) : const Color(0xFF6B7280);

  Color get _textHint =>
      _isDark ? const Color(0xFF6B6B80) : const Color(0xFF9CA3AF);

  Color get _progressBg =>
      _isDark ? const Color(0xFF2D2D4A) : const Color(0xFFE5E7EB);

  Color get _listItemBg =>
      _isDark
          ? const Color(0xFF222240).withValues(alpha: 0.5)
          : const Color(0xFFF5F5F5);

  Color get _timelineLineColor =>
      _isDark ? const Color(0xFF3A3A5A) : const Color(0xFFE0E0E0);

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(realmProvider);

    return profileAsync.when(
      data: (profile) {
        // 检测境界变化，触发突破动画
        if (_previousRealmId != null &&
            _previousRealmId != profile.currentRealm.id) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _showBreakthroughDialog(profile.currentRealm);
          });
        }
        _previousRealmId = profile.currentRealm.id;

        return _buildContent(profile);
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(
        child: Text('加载失败: $error', style: TextStyle(color: _textSecondary)),
      ),
    );
  }

  Widget _buildContent(UserProfileModel profile) {
    final currentRealm = profile.currentRealm;
    final progress = profile.realmProgress;
    final totalSpirit = profile.totalSpirit;
    final nextRealm = profile.nextRealm;
    final isMaxRealm = profile.isMaxRealm;

    // 计算下一境界还需多少灵气
    int? spiritNeeded;
    if (!isMaxRealm && nextRealm != null) {
      spiritNeeded = nextRealm.requiredSpirit - totalSpirit;
      if (spiritNeeded < 0) spiritNeeded = 0;
    }

    return RefreshIndicator(
      onRefresh: () => ref.read(realmProvider.notifier).refresh(),
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        children: [
          const SizedBox(height: 12),
          // 当前境界卡片
          _buildCurrentRealmCard(currentRealm, totalSpirit, progress),
          const SizedBox(height: 28),
          // 修炼进度区域
          _buildProgressSection(
            currentRealm: currentRealm,
            progress: progress,
            nextRealm: nextRealm,
            isMaxRealm: isMaxRealm,
            spiritNeeded: spiritNeeded,
          ),
          const SizedBox(height: 28),
          // 境界列表
          _buildRealmListSection(currentRealm, totalSpirit),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  // ==================== 当前境界卡片 ====================

  Widget _buildCurrentRealmCard(
    RealmConfig realm,
    int totalSpirit,
    double progress,
  ) {
    return Container(
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(16),
        boxShadow: _isDark
            ? []
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 16,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 顶部渐变进度条
          SizedBox(
            height: 4,
            width: double.infinity,
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: progress.clamp(0.0, 1.0),
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [_indigoPurple, _gold],
                  ),
                ),
              ),
            ),
          ),
          // 卡片内容
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
            child: Column(
              children: [
                // 境界名称
                Text(
                  realm.name,
                  style: TextStyle(
                    color: _indigoPurple,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 8),
                // 境界描述
                Text(
                  realm.description,
                  style: TextStyle(
                    color: _textSecondary,
                    fontSize: 14,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                // 累计灵气
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '灵气',
                      style: TextStyle(
                        color: _textHint,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '$totalSpirit',
                      style: const TextStyle(
                        color: _gold,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==================== 修炼进度区域 ====================

  Widget _buildProgressSection({
    required RealmConfig currentRealm,
    required double progress,
    required RealmConfig? nextRealm,
    required bool isMaxRealm,
    required int? spiritNeeded,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 标题
        Text(
          '修炼进度',
          style: TextStyle(
            color: _textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 14),
        // 进度条
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: SizedBox(
            height: 8,
            width: double.infinity,
            child: Stack(
              children: [
                // 背景
                Container(
                  decoration: BoxDecoration(
                    color: _progressBg,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                // 前景
                FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: progress.clamp(0.0, 1.0),
                  child: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [_indigoPurple, _indigoPurpleLight],
                      ),
                      borderRadius: BorderRadius.horizontal(
                        left: Radius.circular(8),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 10),
        // 境界变化信息
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '当前：${currentRealm.name}',
              style: TextStyle(
                color: _textSecondary,
                fontSize: 13,
              ),
            ),
            if (nextRealm != null)
              Text(
                '下一境界：${nextRealm.name}',
                style: TextStyle(
                  color: _textSecondary,
                  fontSize: 13,
                ),
              )
            else
              Text(
                '已达到最高境界',
                style: TextStyle(
                  color: _gold,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
          ],
        ),
        const SizedBox(height: 4),
        // 灵气差额
        if (!isMaxRealm && spiritNeeded != null)
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              '还需 $spiritNeeded 灵气突破',
              style: TextStyle(
                color: _textHint,
                fontSize: 12,
              ),
            ),
          ),
      ],
    );
  }

  // ==================== 境界列表 ====================

  Widget _buildRealmListSection(RealmConfig currentRealm, int totalSpirit) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 标题
        Text(
          '修仙境界',
          style: TextStyle(
            color: _textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),
        // 境界时间轴列表
        ...realmConfigs.asMap().entries.map((entry) {
          final index = entry.key;
          final realm = entry.value;
          final isCurrent = realm.id == currentRealm.id;
          final isUnlocked = index <= getRealmIndex(totalSpirit);
          final isLast = index == realmConfigs.length - 1;
          return _buildTimelineRealmItem(
            realm: realm,
            index: index,
            isCurrent: isCurrent,
            isUnlocked: isUnlocked,
            isLast: isLast,
          );
        }),
      ],
    );
  }

  Widget _buildTimelineRealmItem({
    required RealmConfig realm,
    required int index,
    required bool isCurrent,
    required bool isUnlocked,
    required bool isLast,
  }) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 左侧时间轴（圆圈 + 连接线）
          SizedBox(
            width: 36,
            child: Column(
              children: [
                // 序号圆圈
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isCurrent
                        ? _gold
                        : isUnlocked
                            ? _indigoPurple
                            : Colors.transparent,
                    border: Border.all(
                      color: isCurrent
                          ? _gold
                          : isUnlocked
                              ? _indigoPurple
                              : _textHint,
                      width: isCurrent || isUnlocked ? 0 : 1.5,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      '${index + 1}',
                      style: TextStyle(
                        color: (isCurrent || isUnlocked)
                            ? Colors.white
                            : _textHint,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                // 连接线
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      color: isUnlocked ? _indigoPurple : _timelineLineColor,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 14),
          // 右侧内容
          Expanded(
            child: Container(
              margin: EdgeInsets.only(bottom: isLast ? 0 : 12),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: isCurrent
                    ? _isDark
                        ? _indigoPurple.withValues(alpha: 0.12)
                        : _indigoPurple.withValues(alpha: 0.06)
                    : isUnlocked
                        ? _listItemBg
                        : Colors.transparent,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  // 境界名称 + 描述
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          realm.name,
                          style: TextStyle(
                            color: isUnlocked ? _textPrimary : _textHint,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          isUnlocked ? realm.description : '???',
                          style: TextStyle(
                            color: isUnlocked ? _textSecondary : _textHint,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // 灵气数值
                  Text(
                    '${realm.requiredSpirit}',
                    style: TextStyle(
                      color: isUnlocked ? _textSecondary : _textHint,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(width: 8),
                  // 当前标签
                  if (isCurrent)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: _isDark
                            ? _indigoPurple.withValues(alpha: 0.25)
                            : _indigoPurple.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '当前',
                        style: TextStyle(
                          color: _indigoPurple,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==================== 突破动画对话框 ====================

  void _showBreakthroughDialog(RealmConfig newRealm) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => _BreakthroughDialog(realm: newRealm),
    );
  }
}

/// 境界突破动画对话框 - 简约风格
class _BreakthroughDialog extends StatefulWidget {
  final RealmConfig realm;

  const _BreakthroughDialog({required this.realm});

  @override
  State<_BreakthroughDialog> createState() => _BreakthroughDialogState();
}

class _BreakthroughDialogState extends State<_BreakthroughDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  static const Color _gold = Color(0xFFD4A574);

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _scaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Dialog(
            backgroundColor: Colors.transparent,
            child: Container(
              width: 280,
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF222240) : Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: isDark
                    ? []
                    : [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 24,
                          offset: const Offset(0, 8),
                        ),
                      ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 小标签
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _gold.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '突破成功',
                      style: TextStyle(
                        color: _gold,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // 新境界名称
                  Text(
                    widget.realm.name,
                    style: const TextStyle(
                      color: _gold,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 12),
                  // 描述
                  Text(
                    widget.realm.description,
                    style: TextStyle(
                      color: isDark
                          ? const Color(0xFF9E9EB0)
                          : const Color(0xFF6B7280),
                      fontSize: 14,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  // 灵气值
                  Text(
                    '灵气 ${widget.realm.requiredSpirit}',
                    style: TextStyle(
                      color: isDark
                          ? const Color(0xFF6B6B80)
                          : const Color(0xFF9CA3AF),
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 28),
                  // 继续修行按钮
                  SizedBox(
                    width: double.infinity,
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      style: TextButton.styleFrom(
                        backgroundColor: _gold,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        textStyle: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1,
                        ),
                      ),
                      child: const Text('继续修行'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
