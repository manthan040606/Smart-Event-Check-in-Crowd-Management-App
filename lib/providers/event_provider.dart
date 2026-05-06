import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/event.dart';

final eventProvider = StateNotifierProvider<EventNotifier, Event?>((ref) {
  return EventNotifier();
});

class EventNotifier extends StateNotifier<Event?> {
  EventNotifier() : super(null) {
    _loadEvent();
  }

  Future<void> _loadEvent() async {
    final box = await Hive.openBox<Event>('event_db');
    if (box.isNotEmpty) {
      state = box.getAt(0);
    }
  }

  Future<void> setEvent(Event event) async {
    final box = await Hive.openBox<Event>('event_db');
    await box.clear();
    await box.add(event);
    state = event;
  }

  Future<void> clearEvent() async {
    final box = await Hive.openBox<Event>('event_db');
    await box.clear();
    state = null;
  }
}
