import 'package:cloud_firestore/cloud_firestore.dart';

class GivvUser {
  final String uid;
  final String name;
  final String email;
  final String role; // 'organizationAdmin' or 'volunteer'
  final String? organizationName;
  final String? registrationNumber;
  final String phone;
  final String country;
  final String city;
  final String? organizationCode;
  final DateTime createdAt;

  const GivvUser({
    required this.uid,
    required this.name,
    required this.email,
    required this.role,
    this.organizationName,
    this.registrationNumber,
    required this.phone,
    required this.country,
    required this.city,
    this.organizationCode,
    required this.createdAt,
  });

  factory GivvUser.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return GivvUser(
      uid: doc.id,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      role: data['role'] ?? '',
      organizationName: data['organizationName'],
      registrationNumber: data['registrationNumber'],
      phone: data['phone'] ?? '',
      country: data['country'] ?? '',
      city: data['city'] ?? '',
      organizationCode: data['organizationCode'],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'email': email,
      'role': role,
      if (organizationName != null) 'organizationName': organizationName,
      if (registrationNumber != null) 'registrationNumber': registrationNumber,
      'phone': phone,
      'country': country,
      'city': city,
      if (organizationCode != null) 'organizationCode': organizationCode,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  bool get isOrgAdmin => role == 'organizationAdmin';
  bool get isVolunteer => role == 'volunteer';
}
