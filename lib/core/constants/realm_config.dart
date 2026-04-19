/// 境界配置
/// 定义修仙录中所有境界的名称、累计灵气需求和描述
class RealmConfig {
  /// 境界唯一标识
  final String id;

  /// 境界名称
  final String name;

  /// 累计灵气需求（达到此灵气值即可突破到此境界）
  final int requiredSpirit;

  /// 境界描述
  final String description;

  const RealmConfig({
    required this.id,
    required this.name,
    required this.requiredSpirit,
    required this.description,
  });
}

/// 境界配置表，按灵气需求升序排列
const List<RealmConfig> realmConfigs = [
  RealmConfig(
    id: 'lianqi',
    name: '炼气期',
    requiredSpirit: 0,
    description: '初入修仙之路，感应天地灵气',
  ),
  RealmConfig(
    id: 'zhuji',
    name: '筑基期',
    requiredSpirit: 500,
    description: '灵气入体，筑就修仙根基',
  ),
  RealmConfig(
    id: 'jiedan',
    name: '结丹期',
    requiredSpirit: 2000,
    description: '灵气凝结成丹，修为更进一步',
  ),
  RealmConfig(
    id: 'yuanying',
    name: '元婴期',
    requiredSpirit: 6000,
    description: '丹破婴生，神识初现',
  ),
  RealmConfig(
    id: 'huashen',
    name: '化神期',
    requiredSpirit: 15000,
    description: '元婴化神，与天地共鸣',
  ),
  RealmConfig(
    id: 'lianxu',
    name: '炼虚期',
    requiredSpirit: 35000,
    description: '炼化虚空，超脱凡尘',
  ),
  RealmConfig(
    id: 'heti',
    name: '合体期',
    requiredSpirit: 80000,
    description: '天人合一，大道可期',
  ),
];

/// 根据累计灵气获取当前境界索引
int getRealmIndex(int totalSpirit) {
  int index = 0;
  for (int i = 0; i < realmConfigs.length; i++) {
    if (totalSpirit >= realmConfigs[i].requiredSpirit) {
      index = i;
    } else {
      break;
    }
  }
  return index;
}

/// 根据累计灵气获取当前境界配置
RealmConfig getCurrentRealm(int totalSpirit) {
  return realmConfigs[getRealmIndex(totalSpirit)];
}

/// 计算当前境界的进度（0.0 ~ 1.0）
double getRealmProgress(int totalSpirit) {
  final currentIndex = getRealmIndex(totalSpirit);
  final currentRealm = realmConfigs[currentIndex];

  // 已是最高境界
  if (currentIndex >= realmConfigs.length - 1) {
    return 1.0;
  }

  final nextRealm = realmConfigs[currentIndex + 1];
  final range = nextRealm.requiredSpirit - currentRealm.requiredSpirit;
  final progress = totalSpirit - currentRealm.requiredSpirit;

  if (range <= 0) return 1.0;
  return (progress / range).clamp(0.0, 1.0);
}
