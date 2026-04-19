import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../core/providers.dart';
import '../../../data/repositories/checkin_repository.dart';
import '../../../data/repositories/spirit_repository.dart';
import '../../../domain/models/spirit_log_model.dart';

const _uuid = Uuid();

/// 签到仓库 Provider
final checkinRepositoryProvider = Provider<CheckinRepository>((ref) {
  final dbHelper = ref.watch(databaseHelperProvider);
  return CheckinRepository(dbHelper);
});

/// 签到状态管理
class CheckinNotifier extends StateNotifier<AsyncValue<bool>> {
  final CheckinRepository _checkinRepo;
  final SpiritRepository _spiritRepo;

  CheckinNotifier(this._checkinRepo, this._spiritRepo)
      : super(const AsyncValue.data(false)) {
    _checkTodayStatus();
  }

  /// 检查今天是否已签到
  Future<void> _checkTodayStatus() async {
    try {
      final hasCheckedIn = await _checkinRepo.hasCheckedInToday();
      state = AsyncValue.data(hasCheckedIn);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// 签到
  /// 返回获得的灵气数，如果已签到返回 null
  Future<int?> checkIn() async {
    final id = _uuid.v4();
    final spiritGained = await _checkinRepo.checkIn(id, 5);

    if (spiritGained != null) {
      // 记录灵气日志
      await _spiritRepo.addSpiritLog(
        id: _uuid.v4(),
        amount: spiritGained,
        source: SpiritSource.dailyCheckIn.value,
        description: '每日签到',
      );
      state = const AsyncValue.data(true);
      return spiritGained;
    }

    return null;
  }

  /// 刷新签到状态
  Future<void> refresh() async {
    await _checkTodayStatus();
  }

  /// 获取连续签到天数
  Future<int> getConsecutiveDays() async {
    return _checkinRepo.getConsecutiveDays();
  }
}

/// 签到状态 Provider
final checkinProvider =
    StateNotifierProvider<CheckinNotifier, AsyncValue<bool>>((ref) {
  final checkinRepo = ref.watch(checkinRepositoryProvider);
  final spiritRepo = ref.watch(spiritRepositoryProvider);
  return CheckinNotifier(checkinRepo, spiritRepo);
});
