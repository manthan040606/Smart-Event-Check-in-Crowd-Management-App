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

  late Box<Event> _eventBox;

  Future<void> _loadEvent() async {
    _eventBox = await Hive.openBox<Event>('eventBox');
    if (_eventBox.isNotEmpty) {
      state = _eventBox.getAt(0);
    }
  }

  Future<void> setEvent(Event event) async {
    await _eventBox.clear();
    await _eventBox.add(event);
    state = event;
  }
}
