enum RequestStatus { pending, accepted, rejected }

class JoinRequest {
  final String id;
  final String eventId;
  final String userId;
  final String userName;
  final String? userImageUrl;
  final RequestStatus status;
  final DateTime timestamp;

  JoinRequest({
    required this.id,
    required this.eventId,
    required this.userId,
    required this.userName,
    this.userImageUrl,
    this.status = RequestStatus.pending,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'eventId': eventId,
      'userId': userId,
      'userName': userName,
      'userImageUrl': userImageUrl,
      'status': status.name,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory JoinRequest.fromJson(Map<String, dynamic> json) {
    return JoinRequest(
      id: json['id'] ?? '',
      eventId: json['eventId'] ?? '',
      userId: json['userId'] ?? '',
      userName: json['userName'] ?? '',
      userImageUrl: json['userImageUrl'],
      status: RequestStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => RequestStatus.pending,
      ),
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'])
          : DateTime.now(),
    );
  }
}
