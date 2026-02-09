import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:drift/drift.dart' as drift;
import '../../core/providers/database_provider.dart';
import '../../data/local/db/app_database.dart';
import '../../domain/entities/check_in.dart';
import '../../domain/repositories/check_in_repository.dart';

part 'check_in_repository_impl.g.dart';

class CheckInRepositoryImpl implements CheckInRepository {
  final AppDatabase _db;

  CheckInRepositoryImpl(this._db);

  @override
  Future<List<CheckIn>> getAllCheckIns() async {
    final create = await _db.select(_db.checkIns).get();
    return create.map((e) => _toDomain(e)).toList();
  }

  @override
  Future<void> addCheckIn(CheckIn checkIn) async {
    await _db.into(_db.checkIns).insert(
          CheckInsCompanion(
            timestamp: drift.Value(checkIn.timestamp),
            type: drift.Value(checkIn.type),
            content: drift.Value(checkIn.content),
            audioPath: drift.Value(checkIn.audioPath),
            durationSeconds: drift.Value(checkIn.durationSeconds),
          ),
        );
  }

  @override
  Stream<List<CheckIn>> watchAllCheckIns() {
    return _db.select(_db.checkIns).watch().map(
          (rows) => rows.map((row) => _toDomain(row)).toList(),
        );
  }

  CheckIn _toDomain(CheckInEntity entity) {
    return CheckIn(
      id: entity.id,
      timestamp: entity.timestamp,
      type: entity.type,
      content: entity.content,
      audioPath: entity.audioPath,
      durationSeconds: entity.durationSeconds,
    );
  }
}

@Riverpod(keepAlive: true)
CheckInRepository checkInRepository(Ref ref) {
  final db = ref.watch(databaseProvider);
  return CheckInRepositoryImpl(db);
}
