enum TaskStatus { pending, completed, verified, rejected }

class Task {
  final String id;
  final String title;
  final String description;
  final String assignedTo; // userId or teamId
  final String eventId;
  final DateTime? deadline;
  final TaskStatus status;
  final String? proofImageUrl;
  final String? proofNote;
  final int points;

  Task({
    required this.id,
    required this.title,
    required this.description,
    required this.assignedTo,
    required this.eventId,
    this.deadline,
    this.status = TaskStatus.pending,
    this.proofImageUrl,
    this.proofNote,
    this.points = 20,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'assignedTo': assignedTo,
      'eventId': eventId,
      'deadline': deadline?.toIso8601String(),
      'status': status.name,
      'proofImageUrl': proofImageUrl,
      'proofNote': proofNote,
      'points': points,
    };
  }

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      assignedTo: json['assignedTo'] ?? '',
      eventId: json['eventId'] ?? '',
      deadline: json['deadline'] != null ? DateTime.parse(json['deadline']) : null,
      status: TaskStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => TaskStatus.pending,
      ),
      proofImageUrl: json['proofImageUrl'],
      proofNote: json['proofNote'],
      points: json['points'] ?? 20,
    );
  }

  Task copyWith({
    String? id,
    String? title,
    String? description,
    String? assignedTo,
    String? eventId,
    DateTime? deadline,
    TaskStatus? status,
    String? proofImageUrl,
    String? proofNote,
    int? points,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      assignedTo: assignedTo ?? this.assignedTo,
      eventId: eventId ?? this.eventId,
      deadline: deadline ?? this.deadline,
      status: status ?? this.status,
      proofImageUrl: proofImageUrl ?? this.proofImageUrl,
      proofNote: proofNote ?? this.proofNote,
      points: points ?? this.points,
    );
  }
}
