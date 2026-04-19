import 'dart:ui';

class AppColors {
  AppColors._();

  // ===== 浅色模式 =====
  // 背景
  static const Color lightBackground = Color(0xFFFAFAFA);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightCardBackground = Color(0xFFFFFFFF);
  static const Color lightSurfaceVariant = Color(0xFFF5F5F5);

  // 文字
  static const Color lightTextPrimary = Color(0xFF1A1A2E);
  static const Color lightTextSecondary = Color(0xFF6B7280);
  static const Color lightTextHint = Color(0xFF9CA3AF);

  // ===== 深色模式 =====
  // 背景
  static const Color darkBackground = Color(0xFF0F0F1A);
  static const Color darkSurface = Color(0xFF1A1A2E);
  static const Color darkCardBackground = Color(0xFF222240);
  static const Color darkSurfaceVariant = Color(0xFF2A2A4A);

  // 文字
  static const Color darkTextPrimary = Color(0xFFE8E8F0);
  static const Color darkTextSecondary = Color(0xFF9E9EB0);
  static const Color darkTextHint = Color(0xFF6B6B80);

  // ===== 品牌色（两种模式共用）=====
  // 主色 - 靛蓝紫（修仙神秘感）
  static const Color primary = Color(0xFF6366F1);
  static const Color primaryLight = Color(0xFF818CF8);
  static const Color primaryDark = Color(0xFF4F46E5);
  static const Color primaryBg = Color(0xFFEEF2FF); // 浅色模式下的主色背景

  // 强调色 - 古铜金（修仙灵气/境界）
  static const Color gold = Color(0xFFD4A574);
  static const Color goldLight = Color(0xFFE8C9A0);
  static const Color goldDark = Color(0xFFB8864E);
  static const Color goldBg = Color(0xFFFDF8F0); // 浅色模式下的金色背景

  // 功能色
  static const Color encounter = Color(0xFF3B82F6);     // 奇遇任务 - 蓝色
  static const Color mainline = Color(0xFF8B5CF6);      // 主线任务 - 紫色
  static const Color success = Color(0xFF22C55E);       // 成功/完成 - 绿色
  static const Color warning = Color(0xFFF59E0B);       // 警告 - 橙色
  static const Color danger = Color(0xFFEF4444);        // 危险/删除 - 红色
  static const Color archived = Color(0xFF9CA3AF);      // 归档 - 灰色

  // 分隔线
  static const Color lightDivider = Color(0xFFE5E7EB);
  static const Color darkDivider = Color(0xFF2D2D4A);

  // 进度条
  static const Color progressBackgroundLight = Color(0xFFE5E7EB);
  static const Color progressBackgroundDark = Color(0xFF2D2D4A);

  // 底部导航
  static const Color navSelected = Color(0xFF6366F1);
  static const Color navUnselectedLight = Color(0xFF9CA3AF);
  static const Color navUnselectedDark = Color(0xFF6B6B80);

  // ===== 兼容性别名（供尚未适配双主题的页面使用）=====
  // 这些别名提供合理的默认值，新代码应直接使用 light/dark 前缀的属性
  static const Color textPrimary = Color(0xFF1A1A2E);     // 浅色主文字（深色模式下由 Theme 处理）
  static const Color textSecondary = Color(0xFF6B7280);   // 浅色辅助文字
  static const Color textHint = Color(0xFF9CA3AF);        // 浅色提示文字
  static const Color surface = Color(0xFFFFFFFF);          // 浅色表面
  static const Color background = Color(0xFFFAFAFA);      // 浅色背景
  static const Color cardBackground = Color(0xFFFFFFFF);  // 浅色卡片
  static const Color divider = Color(0xFFE5E7EB);         // 浅色分割线
  static const Color cinnabarRed = Color(0xFFEF4444);     // 别名 → danger
  static const Color cinnabarRedLight = Color(0xFFEF4444); // 别名 → danger
  static const Color progressBackground = Color(0xFFE5E7EB); // 浅色进度条背景
  static const Color navUnselected = Color(0xFF9CA3AF);   // 浅色导航未选中
}
