/// 任务类型枚举
enum TaskType {
  /// 奇遇任务（简单待办，完成后直接获得灵气）
  adventure('adventure', '奇遇'),

  /// 主线任务（可含子任务，归档后获得灵气）
  mainline('mainline', '主线');

  const TaskType(this.value, this.label);

  /// 数据库存储值
  final String value;

  /// 显示标签
  final String label;

  /// 从数据库值解析
  static TaskType fromValue(String value) {
    return TaskType.values.firstWhere(
      (e) => e.value == value,
      orElse: () => TaskType.adventure,
    );
  }
}

/// 任务状态枚举
enum TaskStatus {
  /// 活跃（进行中）
  active('active'),

  /// 已完成
  completed('completed'),

  /// 已归档
  archived('archived');

  const TaskStatus(this.value);

  final String value;

  static TaskStatus fromValue(String value) {
    return TaskStatus.values.firstWhere(
      (e) => e.value == value,
      orElse: () => TaskStatus.active,
    );
  }
}

/// 任务数据模型
class TaskModel {
  /// 任务唯一标识
  final String id;

  /// 任务标题
  final String title;

  /// 任务描述（可选）
  final String? description;

  /// 任务类型
  final TaskType type;

  /// 父任务 ID，null 表示根节点
  final String? parentId;

  /// 任务状态
  final TaskStatus status;

  /// 同级排序序号
  final int order;

  /// 创建时间
  final DateTime createdAt;

  /// 完成时间
  final DateTime? completedAt;

  /// 归档时间
  final DateTime? archivedAt;

  /// 已发放的灵气（归档时计算）
  final int spiritAwarded;

  const TaskModel({
    required this.id,
    required this.title,
    this.description,
    required this.type,
    this.parentId,
    required this.status,
    required this.order,
    required this.createdAt,
    this.completedAt,
    this.archivedAt,
    this.spiritAwarded = 0,
  });

  /// 是否已完成
  bool get isCompleted => status == TaskStatus.completed;

  /// 是否已归档
  bool get isArchived => status == TaskStatus.archived;

  /// 是否是根节点
  bool get isRoot => parentId == null;

  /// 从数据库 Map 创建
  factory TaskModel.fromMap(Map<String, dynamic> map) {
    return TaskModel(
      id: map['id'] as String,
      title: map['title'] as String,
      description: map['description'] as String?,
      type: TaskType.fromValue(map['type'] as String),
      parentId: map['parent_id'] as String?,
      status: TaskStatus.fromValue(map['status'] as String),
      order: map['sort_order'] as int,
      createdAt: DateTime.parse(map['created_at'] as String),
      completedAt: map['completed_at'] != null
          ? DateTime.parse(map['completed_at'] as String)
          : null,
      archivedAt: map['archived_at'] != null
          ? DateTime.parse(map['archived_at'] as String)
          : null,
      spiritAwarded: (map['spirit_awarded'] as int?) ?? 0,
    );
  }

  /// 转换为数据库 Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'type': type.value,
      'parent_id': parentId,
      'status': status.value,
      'sort_order': order,
      'created_at': createdAt.toIso8601String(),
      'completed_at': completedAt?.toIso8601String(),
      'archived_at': archivedAt?.toIso8601String(),
      'spirit_awarded': spiritAwarded,
    };
  }

  /// 复制并修改部分字段
  TaskModel copyWith({
    String? id,
    String? title,
    String? description,
    TaskType? type,
    String? parentId,
    TaskStatus? status,
    int? order,
    DateTime? createdAt,
    DateTime? completedAt,
    DateTime? archivedAt,
    int? spiritAwarded,
  }) {
    return TaskModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      type: type ?? this.type,
      parentId: parentId ?? this.parentId,
      status: status ?? this.status,
      order: order ?? this.order,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
      archivedAt: archivedAt ?? this.archivedAt,
      spiritAwarded: spiritAwarded ?? this.spiritAwarded,
    );
  }
}
