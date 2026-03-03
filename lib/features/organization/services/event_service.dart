import '../models/event_model.dart';

class EventService {
  Future<bool> createEvent(Event event) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 2));
    
    // Always return true for mock service
    return true;
  }
}
