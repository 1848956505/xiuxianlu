import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../task/screens/task_screen.dart';
import '../../checkin/screens/checkin_screen.dart';
import '../../realm/screens/realm_screen.dart';
import '../../realm/providers/realm_provider.dart';

/// 主页 - 响应式布局
/// 手机端：底部 Tab 导航 + 简洁 AppBar
/// 桌面端：左侧 NavigationRail + 无 AppBar
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _currentIndex = 0;

  /// 三个 Tab 页面
  static const List<Widget> _screens = [
    TaskScreen(),
    CheckinScreen(),
    RealmScreen(),
  ];

  /// 响应式断点
  static const double _desktopBreakpoint = 600.0;

  /// 导航项配置
  static const _navItems = [
    _NavItem(icon: Icons.check_circle_outline, label: '任务'),
    _NavItem(icon: Icons.wb_sunny_outlined, label: '签到'),
    _NavItem(icon: Icons.auto_awesome, label: '境界'),
  ];

  /// 选中态颜色
  static const _selectedColor = Color(0xFF6366F1); // 靛蓝紫色

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final isDesktop = screenWidth >= _desktopBreakpoint;

    final realmName = ref.watch(currentRealmNameProvider);
    final totalSpirit = ref.watch(totalSpiritProvider);
    final progress = ref.watch(realmProgressProvider);
    final nextRealmName = ref.watch(nextRealmNameProvider);
    final nextRealmRequired = ref.watch(nextRealmRequiredProvider);

    if (isDesktop) {
      return _buildDesktopLayout(
        context,
        realmName: realmName,
        totalSpirit: totalSpirit,
        progress: progress,
        nextRealmName: nextRealmName,
        nextRealmRequired: nextRealmRequired,
      );
    } else {
      return _buildMobileLayout(
        context,
        realmName: realmName,
        totalSpirit: totalSpirit,
        progress: progress,
        nextRealmName: nextRealmName,
        nextRealmRequired: nextRealmRequired,
      );
    }
  }

  // ==================== 手机端布局 ====================

  Widget _buildMobileLayout(
    BuildContext context, {
    required String realmName,
    required int totalSpirit,
    required double progress,
    String? nextRealmName,
    int? nextRealmRequired,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '修仙录',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            letterSpacing: 1,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 0,
        actions: [
          // 右侧显示境界小标签 + 灵气值
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 境界标签
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: _selectedColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    realmName,
                    style: TextStyle(
                      color: _selectedColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // 灵气值
                Text(
                  '$totalSpirit',
                  style: TextStyle(
                    color: isDark ? AppColors.darkTextSecondary : Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // 灵气进度条 - 3px 细线渐变
          _buildThinProgressBar(progress, isDark),
          // 页面内容
          Expanded(
            child: IndexedStack(
              index: _currentIndex,
              children: _screens,
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: _navItems
            .map(
              (item) => BottomNavigationBarItem(
                icon: Icon(item.icon),
                label: item.label,
              ),
            )
            .toList(),
        selectedItemColor: _selectedColor,
        unselectedItemColor: isDark
            ? AppColors.navUnselectedDark
            : AppColors.navUnselectedLight,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: const TextStyle(fontSize: 12),
        elevation: 8,
        backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
      ),
    );
  }

  // ==================== 桌面端布局 ====================

  Widget _buildDesktopLayout(
    BuildContext context, {
    required String realmName,
    required int totalSpirit,
    required double progress,
    String? nextRealmName,
    int? nextRealmRequired,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Row(
        children: [
          // 左侧 NavigationRail
          NavigationRail(
            selectedIndex: _currentIndex,
            onDestinationSelected: (index) =>
                setState(() => _currentIndex = index),
            labelType: NavigationRailLabelType.all,
            minWidth: 80,
            minExtendedWidth: 80,
            backgroundColor:
                isDark ? AppColors.darkSurface : Colors.grey[50],
            selectedIconTheme: IconThemeData(
              color: _selectedColor,
              size: 24,
            ),
            unselectedIconTheme: IconThemeData(
              color: isDark
                  ? AppColors.navUnselectedDark
                  : AppColors.navUnselectedLight,
              size: 24,
            ),
            selectedLabelTextStyle: TextStyle(
              color: _selectedColor,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
            unselectedLabelTextStyle: TextStyle(
              color: isDark
                  ? AppColors.navUnselectedDark
                  : AppColors.navUnselectedLight,
              fontSize: 12,
            ),
            destinations: _navItems
                .map(
                  (item) => NavigationRailDestination(
                    icon: Icon(item.icon),
                    selectedIcon: Icon(item.icon),
                    label: Text(item.label),
                  ),
                )
                .toList(),
          ),
          // 左侧边栏右侧分割线
          VerticalDivider(
            width: 1,
            thickness: 1,
            color: isDark
                ? AppColors.darkDivider.withValues(alpha: 0.3)
                : AppColors.lightDivider,
          ),
          // 右侧内容区
          Expanded(
            child: Column(
              children: [
                // 顶部：境界信息卡片（桌面端紧凑版）
                _buildDesktopTopBar(
                  context,
                  realmName: realmName,
                  totalSpirit: totalSpirit,
                  progress: progress,
                  nextRealmName: nextRealmName,
                  nextRealmRequired: nextRealmRequired,
                  isDark: isDark,
                ),
                // 页面内容
                Expanded(
                  child: IndexedStack(
                    index: _currentIndex,
                    children: _screens,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==================== 组件方法 ====================

  /// 手机端 3px 细线渐变进度条
  Widget _buildThinProgressBar(double progress, bool isDark) {
    return SizedBox(
      height: 3,
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Stack(
            children: [
              // 背景轨道
              Container(
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.progressBackgroundDark
                      : AppColors.progressBackgroundLight,
                ),
              ),
              // 进度填充 - 渐变
              FractionallySizedBox(
                widthFactor: progress.clamp(0.0, 1.0),
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.primary,
                        AppColors.gold,
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  /// 桌面端顶部信息栏
  Widget _buildDesktopTopBar(
    BuildContext context, {
    required String realmName,
    required int totalSpirit,
    required double progress,
    String? nextRealmName,
    int? nextRealmRequired,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        border: Border(
          bottom: BorderSide(
            color: isDark
                ? AppColors.darkDivider.withValues(alpha: 0.3)
                : AppColors.lightDivider,
          ),
        ),
      ),
      child: Row(
        children: [
          // 境界标签
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 4,
            ),
            decoration: BoxDecoration(
              color: _selectedColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              realmName,
              style: const TextStyle(
                color: _selectedColor,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 16),
          // 灵气值
          Text(
            '灵气 $totalSpirit',
            style: TextStyle(
              color: isDark
                  ? AppColors.darkTextSecondary
                  : Colors.grey[600],
              fontSize: 13,
            ),
          ),
          const SizedBox(width: 24),
          // 进度条（桌面端稍宽一些）
          SizedBox(
            width: 200,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(3),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 4,
                    backgroundColor: isDark
                        ? AppColors.progressBackgroundDark
                        : AppColors.progressBackgroundLight,
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      AppColors.gold,
                    ),
                  ),
                ),
                const SizedBox(height: 2),
                if (nextRealmName != null && nextRealmRequired != null)
                  Text(
                    '距 $nextRealmName 还需 ${nextRealmRequired - totalSpirit} 灵气',
                    style: TextStyle(
                      color: isDark
                          ? AppColors.darkTextHint
                          : Colors.grey[400],
                      fontSize: 11,
                    ),
                  )
                else
                  Text(
                    '已达到最高境界',
                    style: TextStyle(
                      color: AppColors.gold,
                      fontSize: 11,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// 导航项数据模型
class _NavItem {
  final IconData icon;
  final String label;

  const _NavItem({required this.icon, required this.label});
}
