/// 灵气来源枚举
enum SpiritSource {
  /// 完成奇遇任务
  encounterComplete('encounterComplete', '奇遇完成'),

  /// 主线任务归档
  mainlineArchive('mainlineArchive', '主线归档'),

  /// 每日签到
  dailyCheckIn('dailyCheckIn', '每日签到'),

  /// 习惯打卡（V1.5 预留）
  habitCheckIn('habitCheckIn', '习惯打卡'),

  /// 番茄时钟（V1.5 预留）
  pomodoro('pomodoro', '番茄时钟');

  const SpiritSource(this.value, this.label);

  /// 数据库存储值
  final String value;

  /// 显示标签
  final String label;

  /// 从数据库值解析
  static SpiritSource fromValue(String value) {
    return SpiritSource.values.firstWhere(
      (e) => e.value == value,
      orElse: () => SpiritSource.dailyCheckIn,
    );
  }
}

/// 灵气日志数据模型
class SpiritLogModel {
  /// 日志唯一标识
  final String id;

  /// 灵气变动量（始终为正数）
  final int amount;

  /// 灵气来源
  final SpiritSource source;

  /// 关联的任务 ID（可选）
  final String? sourceId;

  /// 描述信息
  final String? description;

  /// 创建时间
  final DateTime createdAt;

  const SpiritLogModel({
    required this.id,
    required this.amount,
    required this.source,
    this.sourceId,
    this.description,
    required this.createdAt,
  });

  /// 从数据库 Map 创建
  factory SpiritLogModel.fromMap(Map<String, dynamic> map) {
    return SpiritLogModel(
      id: map['id'] as String,
      amount: map['amount'] as int,
      source: SpiritSource.fromValue(map['source'] as String),
      sourceId: map['source_id'] as String?,
      description: map['description'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  /// 转换为数据库 Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'amount': amount,
      'source': source.value,
      'source_id': sourceId,
      'description': description,
      'created_at': createdAt.toIso8601String(),
    };
  }

  /// 复制并修改部分字段
  SpiritLogModel copyWith({
    String? id,
    int? amount,
    SpiritSource? source,
    String? sourceId,
    String? description,
    DateTime? createdAt,
  }) {
    return SpiritLogModel(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      source: source ?? this.source,
      sourceId: sourceId ?? this.sourceId,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
