import 'package:hive/hive.dart';

part 'participant.g.dart';

@HiveType(typeId: 0)
class Participant extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final DateTime? checkInTime;

  @HiveField(3)
  final bool isCheckedIn;

  @HiveField(4)
  final bool isSynced;

  @HiveField(5)
  final String? email;

  Participant({
    required this.id,
    required this.name,
    this.checkInTime,
    this.isCheckedIn = false,
    this.isSynced = false,
    this.email,
  });

  Participant copyWith({
    String? id,
    String? name,
    DateTime? checkInTime,
    bool? isCheckedIn,
    bool? isSynced,
    String? email,
  }) {
    return Participant(
      id: id ?? this.id,
      name: name ?? this.name,
      checkInTime: checkInTime ?? this.checkInTime,
      isCheckedIn: isCheckedIn ?? this.isCheckedIn,
      isSynced: isSynced ?? this.isSynced,
      email: email ?? this.email,
    );
  }
}
