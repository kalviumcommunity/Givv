// Volunteer Activity Model
class VolunteerActivity {
  final String id;
  final String volunteerId;
  final String title;
  final String description;
  final String activityType; // e.g., "project", "training", "event"
  final DateTime date;
  final int hoursSpent;
  final String status; // e.g., "completed", "in_progress", "pending"
  final String organizationName;
  final String? imageUrl;

  VolunteerActivity({
    required this.id,
    required this.volunteerId,
    required this.title,
    required this.description,
    required this.activityType,
    required this.date,
    required this.hoursSpent,
    required this.status,
    required this.organizationName,
    this.imageUrl,
  });

  // Factory constructor to create from JSON
  factory VolunteerActivity.fromJson(Map<String, dynamic> json) {
    return VolunteerActivity(
      id: json['id'] ?? '',
      volunteerId: json['volunteerId'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      activityType: json['activityType'] ?? 'project',
      date: json['date'] != null ? DateTime.parse(json['date']) : DateTime.now(),
      hoursSpent: json['hoursSpent'] ?? 0,
      status: json['status'] ?? 'pending',
      organizationName: json['organizationName'] ?? '',
      imageUrl: json['imageUrl'],
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'volunteerId': volunteerId,
      'title': title,
      'description': description,
      'activityType': activityType,
      'date': date.toIso8601String(),
      'hoursSpent': hoursSpent,
      'status': status,
      'organizationName': organizationName,
      'imageUrl': imageUrl,
    };
  }

  // copyWith for immutability and updates
  VolunteerActivity copyWith({
    String? id,
    String? volunteerId,
    String? title,
    String? description,
    String? activityType,
    DateTime? date,
    int? hoursSpent,
    String? status,
    String? organizationName,
    String? imageUrl,
  }) {
    return VolunteerActivity(
      id: id ?? this.id,
      volunteerId: volunteerId ?? this.volunteerId,
      title: title ?? this.title,
      description: description ?? this.description,
      activityType: activityType ?? this.activityType,
      date: date ?? this.date,
      hoursSpent: hoursSpent ?? this.hoursSpent,
      status: status ?? this.status,
      organizationName: organizationName ?? this.organizationName,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }
}
