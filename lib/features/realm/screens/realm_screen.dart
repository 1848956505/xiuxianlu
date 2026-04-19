import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/realm_config.dart';
import '../providers/realm_provider.dart';

/// 境界页面 - 境界展示 + 灵气进度条 + 突破动画
class RealmScreen extends ConsumerStatefulWidget {
  const RealmScreen({super.key});

  @override
  ConsumerState<RealmScreen> createState() => _RealmScreenState();
}

class _RealmScreenState extends ConsumerState<RealmScreen> {
  String? _previousRealmId;

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
        child: Text('加载失败: $error',
            style: TextStyle(color: AppColors.textSecondary)),
      ),
    );
  }

  Widget _buildContent(dynamic profile) {
    final currentRealm = profile.currentRealm as RealmConfig;
    final progress = profile.realmProgress as double;
    final totalSpirit = profile.totalSpirit as int;
    final nextRealm = profile.nextRealm as RealmConfig?;

    return RefreshIndicator(
      onRefresh: () => ref.read(realmProvider.notifier).refresh(),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const SizedBox(height: 20),
          _buildCurrentRealmCard(currentRealm, totalSpirit),
          const SizedBox(height: 24),
          _buildProgressCard(currentRealm, progress, nextRealm, totalSpirit),
          const SizedBox(height: 24),
          Text(
            '修仙之路',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          ...realmConfigs.asMap().entries.map((entry) {
            final index = entry.key;
            final realm = entry.value;
            final isCurrent = realm.id == currentRealm.id;
            final isUnlocked = index <= getRealmIndex(totalSpirit);
            return _buildRealmItem(realm, isCurrent, isUnlocked, index);
          }),
        ],
      ),
    );
  }

  /// 构建当前境界卡片
  Widget _buildCurrentRealmCard(RealmConfig realm, int totalSpirit) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.gold.withValues(alpha: 0.1),
            AppColors.cardBackground,
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.gold.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        children: [
          Text(
            realm.name,
            style: TextStyle(
              color: AppColors.gold,
              fontSize: 32,
              fontWeight: FontWeight.bold,
              letterSpacing: 6,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            realm.description,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '累计灵气',
                style: TextStyle(
                  color: AppColors.textHint,
                  fontSize: 13,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '$totalSpirit',
                style: TextStyle(
                  color: AppColors.gold,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 构建进度卡片
  Widget _buildProgressCard(
    RealmConfig currentRealm,
    double progress,
    RealmConfig? nextRealm,
    int totalSpirit,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.divider.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '修炼进度',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 12,
              backgroundColor: AppColors.progressBackground,
              valueColor: const AlwaysStoppedAnimation<Color>(
                AppColors.gold,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${currentRealm.name} (${currentRealm.requiredSpirit})',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                ),
              ),
              if (nextRealm != null)
                Text(
                  '${nextRealm.name} (${nextRealm.requiredSpirit})',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                )
              else
                Text(
                  '最高境界',
                  style: TextStyle(
                    color: AppColors.gold,
                    fontSize: 12,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '进度 ${(progress * 100).toStringAsFixed(1)}%',
            style: TextStyle(
              color: AppColors.textHint,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  /// 构建境界列表项
  Widget _buildRealmItem(
    RealmConfig realm,
    bool isCurrent,
    bool isUnlocked,
    int index,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isCurrent
            ? AppColors.gold.withValues(alpha: 0.1)
            : AppColors.cardBackground,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isCurrent
              ? AppColors.gold.withValues(alpha: 0.4)
              : AppColors.divider.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isUnlocked
                  ? AppColors.gold.withValues(alpha: 0.2)
                  : AppColors.surfaceVariant,
              border: Border.all(
                color: isUnlocked
                    ? AppColors.gold.withValues(alpha: 0.5)
                    : AppColors.divider,
              ),
            ),
            child: Center(
              child: Text(
                isUnlocked ? '${index + 1}' : '?',
                style: TextStyle(
                  color: isUnlocked ? AppColors.gold : AppColors.textHint,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  realm.name,
                  style: TextStyle(
                    color: isUnlocked
                        ? AppColors.textPrimary
                        : AppColors.textHint,
                    fontSize: 15,
                    fontWeight: isCurrent ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  isUnlocked ? realm.description : '未解锁',
                  style: TextStyle(
                    color: isUnlocked
                        ? AppColors.textSecondary
                        : AppColors.textHint,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${realm.requiredSpirit}',
            style: TextStyle(
              color: isUnlocked ? AppColors.gold : AppColors.textHint,
              fontSize: 13,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            '灵气',
            style: TextStyle(
              color: AppColors.textHint,
              fontSize: 11,
            ),
          ),
          if (isCurrent)
            Container(
              margin: const EdgeInsets.only(left: 8),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.gold.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                '当前',
                style: TextStyle(
                  color: AppColors.gold,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// 显示突破动画对话框
  void _showBreakthroughDialog(RealmConfig newRealm) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => _BreakthroughDialog(realm: newRealm),
    );
  }
}

/// 境界突破动画对话框
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
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _scaleAnimation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.elasticOut,
      ),
    );

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.3, 1.0, curve: Curves.easeIn),
      ),
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
    return Dialog(
      backgroundColor: Colors.transparent,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Opacity(
              opacity: _opacityAnimation.value,
              child: child,
            ),
          );
        },
        child: Container(
          width: 280,
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppColors.surface,
                AppColors.cardBackground,
              ],
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: AppColors.gold.withValues(alpha: 0.5),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.gold.withValues(alpha: 0.2),
                blurRadius: 30,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '突破成功',
                style: TextStyle(
                  color: AppColors.gold,
                  fontSize: 16,
                  letterSpacing: 4,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                widget.realm.name,
                style: TextStyle(
                  color: AppColors.gold,
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 8,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                widget.realm.description,
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 32, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppColors.gold.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppColors.gold.withValues(alpha: 0.4),
                    ),
                  ),
                  child: Text(
                    '继续修炼',
                    style: TextStyle(
                      color: AppColors.gold,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 2,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
