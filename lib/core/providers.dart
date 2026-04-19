import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/database/database_helper.dart';
import '../../data/repositories/spirit_repository.dart';

/// 数据库实例 Provider（全局共享）
final databaseHelperProvider = Provider<DatabaseHelper>((ref) {
  return DatabaseHelper.instance;
});

/// 灵气仓库 Provider（全局共享）
final spiritRepositoryProvider = Provider<SpiritRepository>((ref) {
  final dbHelper = ref.watch(databaseHelperProvider);
  return SpiritRepository(dbHelper);
});
