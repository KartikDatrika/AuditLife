import '../entities/check_in.dart';

abstract class CheckInRepository {
  Future<List<CheckIn>> getAllCheckIns();
  Future<void> addCheckIn(CheckIn checkIn);
  Stream<List<CheckIn>> watchAllCheckIns();
}
