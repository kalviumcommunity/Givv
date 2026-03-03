class OrganizationStats {
  final int totalVolunteers;
  final int activeEvents;
  final int totalTasks;
  final double completionRate;

  OrganizationStats({
    required this.totalVolunteers,
    required this.activeEvents,
    required this.totalTasks,
    required this.completionRate,
  });

  factory OrganizationStats.fromJson(Map<String, dynamic> json) {
    return OrganizationStats(
      totalVolunteers: json['totalVolunteers'] as int,
      activeEvents: json['activeEvents'] as int,
      totalTasks: json['totalTasks'] as int,
      completionRate: (json['completionRate'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalVolunteers': totalVolunteers,
      'activeEvents': activeEvents,
      'totalTasks': totalTasks,
      'completionRate': completionRate,
    };
  }
}
