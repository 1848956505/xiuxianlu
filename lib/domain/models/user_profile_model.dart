import '../../core/constants/realm_config.dart';

/// 用户档案模型（运行时聚合，不单独建表）
class UserProfileModel {
  /// 用户唯一标识
  final String id;

  /// 累计灵气（只增不减）
  final int totalSpirit;

  /// 当前境界索引
  final int currentRealmIndex;

  /// 创建时间
  final DateTime createdAt;

  const UserProfileModel({
    required this.id,
    required this.totalSpirit,
    required this.currentRealmIndex,
    required this.createdAt,
  });

  /// 获取当前境界配置
  RealmConfig get currentRealm => realmConfigs[currentRealmIndex];

  /// 获取当前境界名称
  String get currentRealmName => currentRealm.name;

  /// 是否已是最高境界
  bool get isMaxRealm =>
      currentRealmIndex >= realmConfigs.length - 1;

  /// 获取下一境界配置（如果存在）
  RealmConfig? get nextRealm {
    if (isMaxRealm) return null;
    return realmConfigs[currentRealmIndex + 1];
  }

  /// 计算当前境界进度（0.0 ~ 1.0）
  double get realmProgress {
    if (isMaxRealm) return 1.0;

    final current = currentRealm;
    final next = nextRealm!;
    final range = next.requiredSpirit - current.requiredSpirit;
    final progress = totalSpirit - current.requiredSpirit;

    if (range <= 0) return 1.0;
    return (progress / range).clamp(0.0, 1.0);
  }

  /// 获取下一境界所需灵气（如果存在）
  int? get nextRealmRequired {
    if (isMaxRealm) return null;
    return nextRealm!.requiredSpirit;
  }

  /// 复制并修改部分字段
  UserProfileModel copyWith({
    String? id,
    int? totalSpirit,
    int? currentRealmIndex,
    DateTime? createdAt,
  }) {
    return UserProfileModel(
      id: id ?? this.id,
      totalSpirit: totalSpirit ?? this.totalSpirit,
      currentRealmIndex: currentRealmIndex ?? this.currentRealmIndex,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
