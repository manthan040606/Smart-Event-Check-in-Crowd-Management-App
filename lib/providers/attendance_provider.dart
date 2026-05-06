import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/participant.dart';
import 'event_provider.dart';

final attendanceProvider = StateNotifierProvider<AttendanceNotifier, List<Participant>>((ref) {
  return AttendanceNotifier(ref);
});

class AttendanceNotifier extends StateNotifier<List<Participant>> {
  final Ref ref;
  AttendanceNotifier(this.ref) : super([]) {
    _loadParticipants();
  }

  late Box<Participant> _participantBox;

  Future<void> _loadParticipants() async {
    _participantBox = await Hive.openBox<Participant>('participantBox');
    state = _participantBox.values.toList();
  }

  Future<String?> checkIn(String id, String name) async {
    final event = ref.read(eventProvider);
    if (event == null) return "No active event setup.";

    // Check for duplicate
    final existing = state.any((p) => p.id == id && p.isCheckedIn);
    if (existing) return "Participant already checked in.";

    // Check capacity
    final checkedInCount = state.where((p) => p.isCheckedIn).length;
    if (checkedInCount >= event.maxCapacity) return "Event is at full capacity.";

    final participant = Participant(
      id: id,
      name: name,
      isCheckedIn: true,
      checkInTime: DateTime.now(),
    );

    // Save to Hive
    await _participantBox.put(id, participant);
    state = _participantBox.values.toList();
    
    return null; // Success
  }

  Future<void> clearAll() async {
    await _participantBox.clear();
    state = [];
  }
}
