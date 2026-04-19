/// 签到数据模型
class CheckinModel {
  /// 签到唯一标识
  final String id;

  /// 签到日期（仅日期部分）
  final DateTime date;

  /// 获得的灵气
  final int spiritGained;

  const CheckinModel({
    required this.id,
    required this.date,
    required this.spiritGained,
  });

  /// 从数据库 Map 创建
  factory CheckinModel.fromMap(Map<String, dynamic> map) {
    return CheckinModel(
      id: map['id'] as String,
      date: DateTime.parse(map['date'] as String),
      spiritGained: map['spirit_gained'] as int,
    );
  }

  /// 转换为数据库 Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date.toIso8601String().split('T')[0],
      'spirit_gained': spiritGained,
    };
  }

  /// 复制并修改部分字段
  CheckinModel copyWith({
    String? id,
    DateTime? date,
    int? spiritGained,
  }) {
    return CheckinModel(
      id: id ?? this.id,
      date: date ?? this.date,
      spiritGained: spiritGained ?? this.spiritGained,
    );
  }
}
