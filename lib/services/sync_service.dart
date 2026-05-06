import 'dart:async';
import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/attendance_provider.dart';

final syncServiceProvider = Provider((ref) => SyncService(ref));

class SyncService {
  final Ref ref;
  Timer? _syncTimer;
  bool _isOnline = true;

  SyncService(this.ref) {
    _startPeriodicSync();
  }

  bool get isOnline => _isOnline;

  void toggleOnlineStatus() {
    _isOnline = !_isOnline;
    if (_isOnline) {
      syncNow();
    }
  }

  void _startPeriodicSync() {
    _syncTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      if (_isOnline) {
        syncNow();
      }
    });
  }

  Future<void> syncNow() async {
    final notifier = ref.read(attendanceProvider.notifier);
    final unsynced = notifier.getUnsyncedParticipants();

    if (unsynced.isEmpty) return;

    // Simulate network delay
    await Future.delayed(const Duration(seconds: 2));

    for (final participant in unsynced) {
      // Simulate successful sync
      await notifier.markAsSynced(participant.id);
    }
  }

  void dispose() {
    _syncTimer?.cancel();
  }
}
