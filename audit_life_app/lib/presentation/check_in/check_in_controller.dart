import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/entities/check_in.dart';
import '../../data/repositories/check_in_repository_impl.dart';

part 'check_in_controller.g.dart';

@riverpod
class CheckInController extends _$CheckInController {
  @override
  FutureOr<void> build() {
    // Initial state is void (idle)
  }

  Future<void> submitCheckIn({
    required String type,
    String? content,
    String? audioPath,
    int? durationSeconds,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(checkInRepositoryProvider);
      final checkIn = CheckIn(
        timestamp: DateTime.now(),
        type: type,
        content: content,
        audioPath: audioPath,
        durationSeconds: durationSeconds,
      );
      await repository.addCheckIn(checkIn);
    });
  }
}
