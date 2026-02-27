// Dashboard Statistics Model
class DashboardStats {
  final int totalHours;
  final int projectsCompleted;
  final double rating;
  final int certificationsEarned;
  final int upcomingOpportunities;
  final String impactLevel; // e.g., "Beginner", "Intermediate", "Expert"

  DashboardStats({
    required this.totalHours,
    required this.projectsCompleted,
    required this.rating,
    required this.certificationsEarned,
    required this.upcomingOpportunities,
    required this.impactLevel,
  });

  // Factory constructor to create from JSON
  factory DashboardStats.fromJson(Map<String, dynamic> json) {
    return DashboardStats(
      totalHours: json['totalHours'] ?? 0,
      projectsCompleted: json['projectsCompleted'] ?? 0,
      rating: (json['rating'] ?? 0).toDouble(),
      certificationsEarned: json['certificationsEarned'] ?? 0,
      upcomingOpportunities: json['upcomingOpportunities'] ?? 0,
      impactLevel: json['impactLevel'] ?? 'Beginner',
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'totalHours': totalHours,
      'projectsCompleted': projectsCompleted,
      'rating': rating,
      'certificationsEarned': certificationsEarned,
      'upcomingOpportunities': upcomingOpportunities,
      'impactLevel': impactLevel,
    };
  }
}
