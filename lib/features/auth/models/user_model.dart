import 'package:cloud_firestore/cloud_firestore.dart';

enum UserRole {
  organizer,
  volunteer,
}

class GivvUser {
  final String uid;
  final String name;
  final String email;
  final UserRole role; 
  final String? organizationName;
  final String? registrationNumber;
  final String phone;
  final String country;
  final String? state;
  final String city;
  final String? organizationCode;
  final DateTime createdAt;
  final int points;
  final int eventsJoined;
  final int tasksCompleted;
  final List<String> badges;
  final String? profileImageUrl;

  const GivvUser({
    required this.uid,
    required this.name,
    required this.email,
    required this.role,
    this.organizationName,
    this.registrationNumber,
    required this.phone,
    required this.country,
    this.state,
    required this.city,
    this.organizationCode,
    required this.createdAt,
    this.points = 0,
    this.eventsJoined = 0,
    this.tasksCompleted = 0,
    this.badges = const [],
    this.profileImageUrl,
  });

  factory GivvUser.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return GivvUser(
      uid: doc.id,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      role: data['role'] == 'organizationAdmin' ? UserRole.organizer : UserRole.volunteer,
      organizationName: data['organizationName'],
      registrationNumber: data['registrationNumber'],
      phone: data['phone'] ?? '',
      country: data['country'] ?? '',
      state: data['state'],
      city: data['city'] ?? '',
      organizationCode: data['organizationCode'],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      points: data['points'] ?? 0,
      eventsJoined: data['eventsJoined'] ?? 0,
      tasksCompleted: data['tasksCompleted'] ?? 0,
      badges: List<String>.from(data['badges'] ?? []),
      profileImageUrl: data['profileImageUrl'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'email': email,
      'role': role == UserRole.organizer ? 'organizationAdmin' : 'volunteer',
      if (organizationName != null) 'organizationName': organizationName,
      if (registrationNumber != null) 'registrationNumber': registrationNumber,
      'phone': phone,
      'country': country,
      if (state != null) 'state': state,
      'city': city,
      if (organizationCode != null) 'organizationCode': organizationCode,
      'createdAt': Timestamp.fromDate(createdAt),
      'points': points,
      'eventsJoined': eventsJoined,
      'tasksCompleted': tasksCompleted,
      'badges': badges,
      if (profileImageUrl != null) 'profileImageUrl': profileImageUrl,
    };
  }

  bool get isOrgAdmin => role == UserRole.organizer;
  bool get isVolunteer => role == UserRole.volunteer;
}
