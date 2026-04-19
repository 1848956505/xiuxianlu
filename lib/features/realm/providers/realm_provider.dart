import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/realm_config.dart';
import '../../../core/providers.dart';
import '../../../data/repositories/spirit_repository.dart';
import '../../../domain/models/user_profile_model.dart';

/// 用户档案状态管理
class RealmNotifier extends StateNotifier<AsyncValue<UserProfileModel>> {
  final SpiritRepository _spiritRepo;

  RealmNotifier(this._spiritRepo)
      : super(AsyncValue.data(UserProfileModel(
          id: 'user_1',
          totalSpirit: 0,
          currentRealmIndex: 0,
          createdAt: DateTime.now(),
        ))) {
    _loadProfile();
  }

  /// 加载用户档案
  Future<void> _loadProfile() async {
    try {
      final totalSpirit = await _spiritRepo.getTotalSpirit();
      final realmIndex = getRealmIndex(totalSpirit);
      state = AsyncValue.data(UserProfileModel(
        id: 'user_1',
        totalSpirit: totalSpirit,
        currentRealmIndex: realmIndex,
        createdAt: DateTime.now(),
      ));
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// 刷新用户档案（灵气变动后调用）
  Future<void> refresh() async {
    await _loadProfile();
  }

  /// 获取累计灵气
  Future<int> getTotalSpirit() async {
    return _spiritRepo.getTotalSpirit();
  }
}

/// 用户档案 Provider
final realmProvider =
    StateNotifierProvider<RealmNotifier, AsyncValue<UserProfileModel>>((ref) {
  final spiritRepo = ref.watch(spiritRepositoryProvider);
  return RealmNotifier(spiritRepo);
});

/// 便捷 Provider：获取当前境界名称
final currentRealmNameProvider = Provider<String>((ref) {
  final profileAsync = ref.watch(realmProvider);
  return profileAsync.when(
    data: (profile) => profile.currentRealmName,
    loading: () => '...',
    error: (_, __) => '未知',
  );
});

/// 便捷 Provider：获取累计灵气
final totalSpiritProvider = Provider<int>((ref) {
  final profileAsync = ref.watch(realmProvider);
  return profileAsync.when(
    data: (profile) => profile.totalSpirit,
    loading: () => 0,
    error: (_, __) => 0,
  );
});

/// 便捷 Provider：获取境界进度
final realmProgressProvider = Provider<double>((ref) {
  final profileAsync = ref.watch(realmProvider);
  return profileAsync.when(
    data: (profile) => profile.realmProgress,
    loading: () => 0.0,
    error: (_, __) => 0.0,
  );
});

/// 便捷 Provider：获取下一境界所需灵气
final nextRealmRequiredProvider = Provider<int?>((ref) {
  final profileAsync = ref.watch(realmProvider);
  return profileAsync.when(
    data: (profile) => profile.nextRealmRequired,
    loading: () => null,
    error: (_, __) => null,
  );
});

/// 便捷 Provider：获取下一境界名称
final nextRealmNameProvider = Provider<String?>((ref) {
  final profileAsync = ref.watch(realmProvider);
  return profileAsync.when(
    data: (profile) => profile.nextRealm?.name,
    loading: () => null,
    error: (_, __) => null,
  );
});
