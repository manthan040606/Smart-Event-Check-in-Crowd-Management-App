import 'package:hive/hive.dart';

part 'event.g.dart';

@HiveType(typeId: 1)
class Event extends HiveObject {
  @HiveField(0)
  final String name;

  @HiveField(1)
  final DateTime dateTime;

  @HiveField(2)
  final int maxCapacity;

  @HiveField(3)
  final String? description;

  @HiveField(4)
  final String? instructions;

  @HiveField(5)
  final String? location;

  Event({
    required this.name,
    required this.dateTime,
    required this.maxCapacity,
    this.description,
    this.instructions,
    this.location,
  });
}
