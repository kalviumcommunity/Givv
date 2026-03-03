// Firebase Setup & Security Rules Guide

/*
FIRESTORE SECURITY RULES
========================

Copy this to your Firebase Console > Firestore > Rules tab:

rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Allow authenticated users to read their own volunteer data
    match /volunteers/{volunteerId} {
      allow read: if request.auth.uid == volunteerId || 
                    request.auth.token.role == 'admin';
      allow write: if request.auth.uid == volunteerId ||
                     request.auth.token.role == 'admin';
      allow create: if request.auth != null;
    }
    
    // Allow volunteers to read activities related to them
    match /activities/{activityId} {
      allow read: if request.auth != null && 
                    (request.auth.uid == resource.data.volunteerId ||
                     request.auth.token.role == 'admin');
      allow write: if request.auth.token.role == 'admin';
      allow create: if request.auth.token.role == 'admin';
    }
    
    // Allow volunteers to read opportunities
    match /opportunities/{opportunityId} {
      allow read: if request.auth != null;
      allow write: if request.auth.token.role == 'org_admin' || 
                    request.auth.token.role == 'admin';
    }
    
    // Default: Deny all
    match /{document=**} {
      allow read, write: if false;
    }
  }
}

*/

/*
FIRESTORE DATA STRUCTURE EXAMPLE
==================================

Collection: volunteers
├── Document: volunteer_123
│   ├── name: "John Doe"
│   ├── email: "john@example.com"
│   ├── phone: "+1234567890"
│   ├── profileImageUrl: "https://storage.googleapis.com/..."
│   ├── bio: "Passionate educator and mentor"
│   ├── skills: ["teaching", "mentoring", "training"]
│   ├── country: "United States"
│   ├── city: "New York"
│   ├── joinDate: Timestamp(2024, 1, 15)
│   ├── hoursContributed: 45
│   ├── projectsCompleted: 3
│   ├── rating: 4.8
│   ├── certifications: ["Teaching 101", "First Aid Certification"]
│   ├── isAvailable: true
│   ├── interests: ["education", "youth", "mentoring"]
│   └── updatedAt: Timestamp(current time)
│
├── Document: volunteer_456
│   ├── name: "Sarah Smith"
│   ├── ... (same structure)

Collection: activities
├── Document: activity_001
│   ├── volunteerId: "volunteer_123"
│   ├── title: "Online Tutoring Session"
│   ├── description: "Taught advanced mathematics to 5 high school students"
│   ├── activityType: "project"
│   ├── date: Timestamp(2024, 2, 20)
│   ├── hoursSpent: 3
│   ├── status: "completed"
│   ├── organizationName: "Education Initiative"
│   ├── imageUrl: "https://..."
│   └── createdAt: Timestamp(current time)
│
├── Document: activity_002
│   ├── volunteerId: "volunteer_123"
│   ├── title: "Community Training Workshop"
│   ├── description: "Conducted digital literacy workshop"
│   ├── activityType: "training"
│   ├── date: Timestamp(2024, 2, 15)
│   ├── hoursSpent: 4
│   ├── status: "in_progress"
│   ├── organizationName: "Digital Skills Initiative"
│   └── ... (more fields)

Collection: opportunities
├── Document: opp_001
│   ├── title: "Community Cleanup Drive"
│   ├── description: "Help restore and clean up local parks and community spaces"
│   ├── organizationName: "Green Future Foundation"
│   ├── location: "Central Park, New York"
│   ├── estimatedHours: 4
│   ├── status: "open"
│   ├── startDate: Timestamp(2024, 3, 1)
│   ├── endDate: Timestamp(2024, 3, 1)
│   ├── imageUrl: "https://..."
│   ├── requiredSkills: ["teamwork", "outdoor-work"]
│   └── interests: ["environment", "community"]
│
├── Document: opp_002
│   ├── title: "Online Coding Mentorship"
│   ├── description: "Mentor beginners in web development"
│   ├── organizationName: "Tech For Good"
│   ├── location: "Remote"
│   ├── estimatedHours: 6
│   ├── status: "open"
│   ├── ... (more fields)

*/

/*
INITIALIZATION IN MAIN.DART
============================

Already done in your main.dart, but here's the complete setup:

import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  runApp(const GivvApp());
}

*/

/*
UPLOADING SAMPLE DATA
======================

Option 1: Using Firebase Console (Easiest)
-------------------------------------------
1. Go to Firebase Console > Firestore Database
2. Click "+ Start collection"
3. Create "volunteers" collection
4. Add documents manually with the fields above
5. Repeat for "activities" and "opportunities"

Option 2: Using Flutter Code (Testing)
---------------------------------------
Import in your test/debug screen:
import 'package:cloud_firestore/cloud_firestore.dart';

// Create sample volunteer
Future<void> _createSampleData() async {
  final volunteers = FirebaseFirestore.instance.collection('volunteers');
  
  await volunteers.doc('test_volunteer_1').set({
    'name': 'John Doe',
    'email': 'john@example.com',
    'phone': '+1234567890',
    'profileImageUrl': 'https://via.placeholder.com/150',
    'bio': 'Passionate about education',
    'skills': ['teaching', 'mentoring'],
    'country': 'United States',
    'city': 'New York',
    'joinDate': DateTime(2024, 1, 15).toIso8601String(),
    'hoursContributed': 45,
    'projectsCompleted': 3,
    'rating': 4.8,
    'certifications': ['Teaching 101'],
    'isAvailable': true,
    'interests': ['education', 'youth'],
  });
  
  // Create sample activities
  final activities = FirebaseFirestore.instance.collection('activities');
  
  await activities.doc('activity_1').set({
    'volunteerId': 'test_volunteer_1',
    'title': 'Online Tutoring',
    'description': 'Taught math to students',
    'activityType': 'project',
    'date': DateTime(2024, 2, 20).toIso8601String(),
    'hoursSpent': 3,
    'status': 'completed',
    'organizationName': 'Education Initiative',
  });
  
  // Create sample opportunities
  final opportunities = FirebaseFirestore.instance.collection('opportunities');
  
  await opportunities.doc('opp_1').set({
    'title': 'Community Cleanup',
    'organizationName': 'Green Future',
    'description': 'Help clean local parks',
    'location': 'Central Park',
    'estimatedHours': 4,
    'status': 'open',
    'startDate': DateTime(2024, 3, 1).toIso8601String(),
  });
  
  print('Sample data created!');
}

Option 3: Using Firebase CLI
------------------------------
firebase firestore:set volunteers/test_volunteer_1 < sample_data.json

(Where sample_data.json contains the volunteer data)

*/

/*
TESTING THE DASHBOARD
======================

1. Create sample volunteer in Firestore using Console
2. Use their document ID as volunteerId in the route:
   Navigator.pushNamed(
     context,
     '/volunteer-dashboard',
     arguments: 'test_volunteer_1',  // Use the document ID
   );
3. Dashboard will automatically load and display the data

Expected to see:
- Profile with name and location
- Stats showing hours, projects, certifications
- Any activities you created
- Any opportunities you created

*/

/*
COMMON FIRESTORE QUERY PATTERNS
===================================

In firebase_volunteer_repository.dart:

// Get all activities for a volunteer
db.collection('activities')
  .where('volunteerId', isEqualTo: volunteerId)
  .orderBy('date', descending: true)
  .limit(20)
  .get();

// Get open opportunities
db.collection('opportunities')
  .where('status', isEqualTo: 'open')
  .orderBy('startDate')
  .get();

// Get volunteer with highest rating
db.collection('volunteers')
  .orderBy('rating', descending: true)
  .limit(1)
  .get();

// Get volunteers by skill
db.collection('volunteers')
  .where('skills', arrayContains: 'teaching')
  .get();

*/

/*
OPTIMIZATION TIPS
==================

1. Index Queries
   Firestore will suggest indexes - Create them!
   
2. Limit Data Retrieved
   Use .limit(20) to prevent loading too much
   
3. Cache Results
   Use local storage for frequently accessed data
   
4. Batch Operations
   For multiple updates, use batch:
   
   final batch = db.batch();
   batch.update(doc1, data1);
   batch.update(doc2, data2);
   await batch.commit();

5. Use Subcollections for Related Data
   activities could be: volunteers/{id}/activities/{activityId}

*/

/*
AUTHENTICATION INTEGRATION
===========================

Connect Firebase Auth with Volunteer Data:

import 'package:firebase_auth/firebase_auth.dart';

// After login, use userId as volunteerId
class VolunteerDashboardScreen extends StatefulWidget {
  const VolunteerDashboardScreen({super.key});
  
  @override
  State<VolunteerDashboardScreen> createState() => 
    _VolunteerDashboardScreenState();
}

class _VolunteerDashboardScreenState extends State<VolunteerDashboardScreen> {
  late String volunteerId;
  
  @override
  void initState() {
    super.initState();
    // Get current user's ID from Firebase Auth
    volunteerId = FirebaseAuth.instance.currentUser?.uid ?? '';
  }
  
  @override
  Widget build(BuildContext context) {
    return VolunteerDashboardScreen(volunteerId: volunteerId);
  }
}

*/

/*
MONITORING & ANALYTICS
=======================

Track dashboard usage with Firebase Analytics:

import 'package:firebase_analytics/firebase_analytics.dart';

void _trackDashboardView() {
  FirebaseAnalytics.instance.logEvent(
    name: 'volunteer_dashboard_view',
    parameters: {
      'volunteerId': volunteerId,
      'timestamp': DateTime.now().toIso8601String(),
    },
  );
}

*/
