import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/join_request_model.dart';
import '../services/join_request_service.dart';

final joinRequestServiceProvider = Provider<JoinRequestService>((ref) {
  return JoinRequestService();
});

final eventRequestsProvider = StreamProvider.family<List<JoinRequest>, String>((ref, eventId) {
  return ref.watch(joinRequestServiceProvider).streamRequestsByEvent(eventId);
});

class JoinRequestNotifier extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<bool> updateStatus(String requestId, RequestStatus status) async {
    final result = await AsyncValue.guard(() => 
      ref.read(joinRequestServiceProvider).updateRequestStatus(requestId, status)
    );
    return !result.hasError;
  }
}

final joinRequestProvider = AsyncNotifierProvider<JoinRequestNotifier, void>(() => JoinRequestNotifier());
