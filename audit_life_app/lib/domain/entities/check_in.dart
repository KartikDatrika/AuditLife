class CheckIn {
  final int? id;
  final DateTime timestamp;
  final String type;
  final String? content;
  final String? audioPath;
  final int? durationSeconds;

  const CheckIn({
    this.id,
    required this.timestamp,
    required this.type,
    this.content,
    this.audioPath,
    this.durationSeconds,
  });
}
