import 'dart:ui';

/// 水墨风配色方案
class AppColors {
  AppColors._();

  // ===== 基础色 =====

  /// 深色背景（墨色）
  static const Color background = Color(0xFF1A1A2E);

  /// 次级背景（深灰蓝）
  static const Color surface = Color(0xFF16213E);

  /// 卡片背景（水墨灰）
  static const Color cardBackground = Color(0xFF1F2940);

  /// 悬浮/高亮背景
  static const Color surfaceVariant = Color(0xFF2A3A5C);

  // ===== 文字色 =====

  /// 主要文字（宣纸白）
  static const Color textPrimary = Color(0xFFE8E0D0);

  /// 次要文字（淡灰）
  static const Color textSecondary = Color(0xFF9E9E9E);

  /// 辅助文字（暗灰）
  static const Color textHint = Color(0xFF6B6B6B);

  // ===== 强调色 =====

  /// 金色点缀（灵气/重要元素）
  static const Color gold = Color(0xFFD4A843);

  /// 金色亮色
  static const Color goldLight = Color(0xFFF0D68A);

  /// 朱砂红（签到/重要按钮）
  static const Color cinnabarRed = Color(0xFFC0392B);

  /// 朱砂红亮色
  static const Color cinnabarRedLight = Color(0xFFE74C3C);

  // ===== 功能色 =====

  /// 奇遇任务标签色（靛蓝）
  static const Color encounter = Color(0xFF5B8DEF);

  /// 主线任务标签色（紫）
  static const Color mainline = Color(0xFF9B59B6);

  /// 成功/完成色（翠绿）
  static const Color success = Color(0xFF27AE60);

  /// 归档色（暗金）
  static const Color archived = Color(0xFF7D6608);

  // ===== 分隔线 =====

  /// 分隔线颜色
  static const Color divider = Color(0xFF2C3E50);

  // ===== 进度条 =====

  /// 进度条背景
  static const Color progressBackground = Color(0xFF2C3E50);

  /// 进度条填充（渐变起始）
  static const Color progressStart = Color(0xFFD4A843);

  /// 进度条填充（渐变结束）
  static const Color progressEnd = Color(0xFFF0D68A);

  // ===== 底部导航 =====

  /// 底部导航选中色
  static const Color navSelected = Color(0xFFD4A843);

  /// 底部导航未选中色
  static const Color navUnselected = Color(0xFF6B6B6B);
}
