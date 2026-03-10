import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/event_model.dart';
import '../services/event_service.dart';

final eventServiceProvider = Provider<EventService>((ref) {
  return EventService();
});

final eventByIdProvider = FutureProvider.family<Event?, String>((ref, id) async {
  return ref.watch(eventServiceProvider).getEventById(id);
});

final eventsByOrganizerProvider = StreamProvider.family<List<Event>, String>((ref, organizerId) {
  return ref.watch(eventServiceProvider).streamEventsByOrganizer(organizerId);
});

class EventNotifier extends AsyncNotifier<void> {
  @override
  Future<void> build() async {
    // Initial state is idle
  }

  Future<bool> createEvent(Event event) async {
    state = const AsyncValue.loading();
    final result = await AsyncValue.guard(() => 
      ref.read(eventServiceProvider).createEvent(event)
    );
    return !result.hasError;
  }

  Future<bool> updateEvent(Event event) async {
    state = const AsyncValue.loading();
    final result = await AsyncValue.guard(() => 
      ref.read(eventServiceProvider).updateEvent(event)
    );
    return !result.hasError;
  }
}

final eventProvider = AsyncNotifierProvider<EventNotifier, void>(() {
  return EventNotifier();
});
