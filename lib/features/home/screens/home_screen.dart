import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../task/screens/task_screen.dart';
import '../../checkin/screens/checkin_screen.dart';
import '../../realm/screens/realm_screen.dart';
import '../../realm/providers/realm_provider.dart';

/// 主页 - 底部导航栏（任务、签到、境界），顶部显示当前境界和灵气
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _currentIndex = 0;

  /// 三个 Tab 页面
  static final List<Widget> _screens = [
    const TaskScreen(),
    const CheckinScreen(),
    const RealmScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final realmName = ref.watch(currentRealmNameProvider);
    final totalSpirit = ref.watch(totalSpiritProvider);
    final progress = ref.watch(realmProgressProvider);
    final nextRealmName = ref.watch(nextRealmNameProvider);
    final nextRealmRequired = ref.watch(nextRealmRequiredProvider);

    return Scaffold(
      body: Column(
        children: [
          // 顶部灵气面板
          _buildSpiritPanel(
            context,
            realmName: realmName,
            totalSpirit: totalSpirit,
            progress: progress,
            nextRealmName: nextRealmName,
            nextRealmRequired: nextRealmRequired,
          ),
          // 页面内容
          Expanded(
            child: _screens[_currentIndex],
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.task_alt),
            label: '任务',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.wb_sunny_outlined),
            label: '签到',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.auto_awesome),
            label: '境界',
          ),
        ],
      ),
    );
  }

  /// 构建顶部灵气面板
  Widget _buildSpiritPanel(
    BuildContext context, {
    required String realmName,
    required int totalSpirit,
    required double progress,
    String? nextRealmName,
    int? nextRealmRequired,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 40, 20, 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.surface,
            AppColors.cardBackground,
          ],
        ),
        border: Border(
          bottom: BorderSide(
            color: AppColors.divider.withValues(alpha: 0.3),
          ),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 应用标题
            Text(
              '修仙录',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: AppColors.gold,
                    letterSpacing: 4,
                  ),
            ),
            const SizedBox(height: 12),
            // 境界和灵气信息
            Row(
              children: [
                // 境界徽章
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.gold.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: AppColors.gold.withValues(alpha: 0.4),
                    ),
                  ),
                  child: Text(
                    realmName,
                    style: TextStyle(
                      color: AppColors.gold,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 2,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                // 灵气数值
                Text(
                  '灵气 $totalSpirit',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // 进度条
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 6,
                backgroundColor: AppColors.progressBackground,
                valueColor: const AlwaysStoppedAnimation<Color>(
                  AppColors.gold,
                ),
              ),
            ),
            const SizedBox(height: 4),
            // 下一境界提示
            if (nextRealmName != null && nextRealmRequired != null)
              Text(
                '距 $nextRealmName 还需 ${nextRealmRequired - totalSpirit} 灵气',
                style: TextStyle(
                  color: AppColors.textHint,
                  fontSize: 12,
                ),
              )
            else
              Text(
                '已达到最高境界',
                style: TextStyle(
                  color: AppColors.gold,
                  fontSize: 12,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
