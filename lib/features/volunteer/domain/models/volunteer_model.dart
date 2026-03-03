// Volunteer Model - Domain layer (not hardcoded)
class Volunteer {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String profileImageUrl;
  final String bio;
  final List<String> skills;
  final String country;
  final String city;
  final DateTime joinDate;
  final int hoursContributed;
  final int projectsCompleted;
  final double rating;
  final List<String> certifications;
  final bool isAvailable;
  final List<String> interests;

  Volunteer({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.profileImageUrl,
    required this.bio,
    required this.skills,
    required this.country,
    required this.city,
    required this.joinDate,
    required this.hoursContributed,
    required this.projectsCompleted,
    required this.rating,
    required this.certifications,
    required this.isAvailable,
    required this.interests,
  });

  // Factory constructor to create from JSON (Firebase)
  factory Volunteer.fromJson(Map<String, dynamic> json) {
    return Volunteer(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      profileImageUrl: json['profileImageUrl'] ?? '',
      bio: json['bio'] ?? '',
      skills: List<String>.from(json['skills'] ?? []),
      country: json['country'] ?? '',
      city: json['city'] ?? '',
      joinDate: json['joinDate'] != null
          ? DateTime.parse(json['joinDate'])
          : DateTime.now(),
      hoursContributed: json['hoursContributed'] ?? 0,
      projectsCompleted: json['projectsCompleted'] ?? 0,
      rating: (json['rating'] ?? 0).toDouble(),
      certifications: List<String>.from(json['certifications'] ?? []),
      isAvailable: json['isAvailable'] ?? true,
      interests: List<String>.from(json['interests'] ?? []),
    );
  }

  // Convert to JSON for Firebase
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'profileImageUrl': profileImageUrl,
      'bio': bio,
      'skills': skills,
      'country': country,
      'city': city,
      'joinDate': joinDate.toIso8601String(),
      'hoursContributed': hoursContributed,
      'projectsCompleted': projectsCompleted,
      'rating': rating,
      'certifications': certifications,
      'isAvailable': isAvailable,
      'interests': interests,
    };
  }

  // Copy with method for immutability
  Volunteer copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? profileImageUrl,
    String? bio,
    List<String>? skills,
    String? country,
    String? city,
    DateTime? joinDate,
    int? hoursContributed,
    int? projectsCompleted,
    double? rating,
    List<String>? certifications,
    bool? isAvailable,
    List<String>? interests,
  }) {
    return Volunteer(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      bio: bio ?? this.bio,
      skills: skills ?? this.skills,
      country: country ?? this.country,
      city: city ?? this.city,
      joinDate: joinDate ?? this.joinDate,
      hoursContributed: hoursContributed ?? this.hoursContributed,
      projectsCompleted: projectsCompleted ?? this.projectsCompleted,
      rating: rating ?? this.rating,
      certifications: certifications ?? this.certifications,
      isAvailable: isAvailable ?? this.isAvailable,
      interests: interests ?? this.interests,
    );
  }
}
