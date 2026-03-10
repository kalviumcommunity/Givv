import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/organization_stats.dart';

class DashboardService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<OrganizationStats> fetchDashboardStats(String organizerId) async {
    try {
      // 1. Get all events by this organizer
      final eventsSnapshot = await _firestore
          .collection('events')
          .where('organizerId', isEqualTo: organizerId)
          .get();

      final events = eventsSnapshot.docs;
      
      // 2. Calculate stats
      int totalVolunteers = 0;
      Set<String> uniqueVolunteers = {};
      int activeEvents = 0;
      
      for (var doc in events) {
        final data = doc.data();
        final volunteers = List<String>.from(data['volunteersJoined'] ?? []);
        uniqueVolunteers.addAll(volunteers);
        
        final status = data['status'];
        if (status == 'ongoing' || status == 'upcoming') {
          activeEvents++;
        }
      }
      totalVolunteers = uniqueVolunteers.length;

      // 3. Get tasks stats
      int totalTasks = 0;
      int completedTasks = 0;

      final eventIds = events.map((e) => e.id).toList();
      
      if (eventIds.isNotEmpty) {
        // Fetch tasks only for these eventIds to respect security rules and improve performance.
        // Note: Firestore 'whereIn' limit is 30.
        final tasksSnapshot = await _firestore
            .collection('tasks')
            .where('eventId', whereIn: eventIds.take(30).toList())
            .get();

        totalTasks = tasksSnapshot.docs.length;
        completedTasks = tasksSnapshot.docs.where((doc) {
          final status = doc.data()['status'];
          return status == 'completed' || status == 'verified';
        }).length;
      }

      return OrganizationStats(
        totalVolunteers: totalVolunteers,
        activeEvents: activeEvents,
        totalTasks: totalTasks,
        completionRate: totalTasks == 0 ? 0.0 : completedTasks / totalTasks,
      );
    } catch (e) {
      print('Error fetching dashboard stats: $e');
      return OrganizationStats(
        totalVolunteers: 0,
        activeEvents: 0,
        totalTasks: 0,
        completionRate: 0,
      );
    }
  }
}
