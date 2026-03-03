import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/event_model.dart';
import '../services/event_service.dart';

final eventServiceProvider = Provider<EventService>((ref) {
  return EventService();
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

    if (result.hasError) {
      state = AsyncValue.error(result.error!, result.stackTrace!);
      return false;
    } else {
      state = const AsyncValue.data(null);
      return true;
    }
  }
}

final eventProvider = AsyncNotifierProvider<EventNotifier, void>(() {
  return EventNotifier();
});
