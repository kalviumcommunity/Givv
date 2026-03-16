enum JoinType { open, requestApproval }
enum EventStatus { upcoming, ongoing, past }

class Event {
  final String id;
  final String title;
  final String description;
  final String category;
  final String city;
  final String state;
  final String country;
  final double? latitude;
  final double? longitude;
  final DateTime date;
  final int maxVolunteers;
  final JoinType joinType;
  final String? tasksDescription;
  final String organizerId;
  final EventStatus status;
  final List<String> volunteersJoined;
  final List<String> pendingRequests;

  EventStatus get computedStatus {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final eventDate = DateTime(date.year, date.month, date.day);
    
    if (eventDate.isBefore(today)) return EventStatus.past;
    if (eventDate.isAtSameMomentAs(today)) return EventStatus.ongoing;
    return EventStatus.upcoming;
  }

  Event({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.city,
    this.state = '',
    this.country = '',
    this.latitude,
    this.longitude,
    required this.date,
    required this.maxVolunteers,
    required this.joinType,
    this.tasksDescription,
    required this.organizerId,
    this.status = EventStatus.upcoming,
    this.volunteersJoined = const [],
    this.pendingRequests = const [],
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category,
      'city': city,
      'state': state,
      'country': country,
      'latitude': latitude,
      'longitude': longitude,
      'date': date.toIso8601String(),
      'maxVolunteers': maxVolunteers,
      'joinType': joinType.name,
      'tasksDescription': tasksDescription,
      'organizerId': organizerId,
      'status': status.name,
      'volunteersJoined': volunteersJoined,
      'pendingRequests': pendingRequests,
    };
  }

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      category: json['category'] ?? 'Other',
      city: json['city'] ?? '',
      state: json['state'] ?? '',
      country: json['country'] ?? '',
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      date: json['date'] != null ? DateTime.parse(json['date']) : DateTime.now(),
      maxVolunteers: json['maxVolunteers'] ?? 0,
      joinType: JoinType.values.firstWhere(
        (e) => e.name == json['joinType'],
        orElse: () => JoinType.open,
      ),
      tasksDescription: json['tasksDescription'],
      organizerId: json['organizerId'] ?? '',
      status: EventStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => EventStatus.upcoming,
      ),
      volunteersJoined: List<String>.from(json['volunteersJoined'] ?? []),
      pendingRequests: List<String>.from(json['pendingRequests'] ?? []),
    );
  }

  Event copyWith({
    String? id,
    String? title,
    String? description,
    String? category,
    String? city,
    String? state,
    String? country,
    double? latitude,
    double? longitude,
    DateTime? date,
    int? maxVolunteers,
    JoinType? joinType,
    String? tasksDescription,
    String? organizerId,
    EventStatus? status,
    List<String>? volunteersJoined,
    List<String>? pendingRequests,
  }) {
    return Event(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      city: city ?? this.city,
      state: state ?? this.state,
      country: country ?? this.country,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      date: date ?? this.date,
      maxVolunteers: maxVolunteers ?? this.maxVolunteers,
      joinType: joinType ?? this.joinType,
      tasksDescription: tasksDescription ?? this.tasksDescription,
      organizerId: organizerId ?? this.organizerId,
      status: status ?? this.status,
      volunteersJoined: volunteersJoined ?? this.volunteersJoined,
      pendingRequests: pendingRequests ?? this.pendingRequests,
    );
  }
}
