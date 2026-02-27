# Volunteer Dashboard Documentation

## Overview
The Volunteer Dashboard is a comprehensive feature that displays volunteer profile information, statistics, recent activities, and upcoming opportunities. The implementation follows clean architecture principles with clear separation between data, domain, and presentation layers.

## Architecture

### Folder Structure
```
lib/features/volunteer/
├── data/
│   └── repositories/
│       └── firebase_volunteer_repository.dart    # Firebase implementation
├── domain/
│   ├── models/
│   │   ├── volunteer_model.dart                  # Core volunteer data
│   │   ├── dashboard_stats.dart                  # Dashboard statistics
│   │   └── volunteer_activity.dart               # Activity history
│   └── repositories/
│       └── volunteer_repository.dart             # Abstract interface
└── presentation/
    ├── screens/
    │   └── volunteer_dashboard_screen.dart       # Main dashboard screen
    └── widgets/
        ├── stat_card.dart                        # Stats display widget
        ├── activity_card.dart                    # Activity card widget
        └── opportunity_card.dart                 # Opportunity card widget
```

## Key Features

### 1. **Non-Hardcoded Dynamic Data**
- All data is fetched from Firebase Firestore
- Dashboard adapts to actual volunteer data
- Statistics calculated dynamically based on Firebase data
- No hardcoded values or mock data

### 2. **Data Models**

#### Volunteer Model
```dart
Volunteer(
  id: String,
  name: String,
  email: String,
  phone: String,
  profileImageUrl: String,
  bio: String,
  skills: List<String>,
  country: String,
  city: String,
  joinDate: DateTime,
  hoursContributed: int,
  projectsCompleted: int,
  rating: double,
  certifications: List<String>,
  isAvailable: bool,
  interests: List<String>,
)
```

#### Dashboard Stats Model
```dart
DashboardStats(
  totalHours: int,
  projectsCompleted: int,
  rating: double,
  certificationsEarned: int,
  upcomingOpportunities: int,
  impactLevel: String, // Beginner, Intermediate, Advanced, Expert
)
```

#### Volunteer Activity Model
```dart
VolunteerActivity(
  id: String,
  volunteerId: String,
  title: String,
  description: String,
  activityType: String, // 'project', 'training', 'event'
  date: DateTime,
  hoursSpent: int,
  status: String, // 'completed', 'in_progress', 'pending'
  organizationName: String,
  imageUrl: String?,
)
```

### 3. **Repository Pattern**
The dashboard uses the Repository pattern for data access:

- **VolunteerRepository** (Abstract): Defines the interface for data operations
- **FirebaseVolunteerRepository** (Implementation): Fetches data from Firestore

Methods available:
- `getCurrentVolunteer()` - Get current logged-in volunteer
- `getVolunteerById(volunteerId)` - Fetch volunteer details
- `updateVolunteerProfile(volunteer)` - Update volunteer info
- `getDashboardStats(volunteerId)` - Calculate dashboard statistics
- `getVolunteerActivities(volunteerId)` - Get activity history
- `getUpcomingOpportunities(volunteerId)` - Fetch opportunities
- `completeActivity(activityId)` - Mark activity as done

### 4. **Dashboard Screen Features**

#### Header Section
- Volunteer profile picture
- Name and location
- Star rating

#### Statistics Section (4-Card Grid)
- Total hours contributed
- Projects completed
- Certifications earned
- Impact level (calculated dynamically)

#### Recent Activities Section
- Last 5 activities with timestamps
- Activity type icons
- Status badges (Completed, In Progress, Pending)
- Hours spent and dates

#### Upcoming Opportunities Section
- Location and estimated hours
- Organization name
- Quick view option
- Matching opportunities based on skills

### 5. **Data Sync with Firebase**
The dashboard automatically syncs with Firestore collections:

**Firestore Collections Required:**
```
volunteers/
├── {volunteerId}/
│   ├── name: String
│   ├── email: String
│   ├── phone: String
│   ├── profileImageUrl: String
│   ├── bio: String
│   ├── skills: Array<String>
│   ├── country: String
│   ├── city: String
│   ├── joinDate: Timestamp
│   ├── hoursContributed: Number
│   ├── projectsCompleted: Number
│   ├── rating: Number
│   ├── certifications: Array<String>
│   ├── isAvailable: Boolean
│   └── interests: Array<String>

activities/
├── {activityId}/
│   ├── volunteerId: String
│   ├── title: String
│   ├── description: String
│   ├── activityType: String
│   ├── date: Timestamp
│   ├── hoursSpent: Number
│   ├── status: String
│   ├── organizationName: String
│   └── imageUrl: String (optional)

opportunities/
├── {opportunityId}/
│   ├── title: String
│   ├── organizationName: String
│   ├── description: String
│   ├── location: String
│   ├── estimatedHours: Number
│   ├── status: String
│   └── startDate: Timestamp
```

## Usage

### Navigating to Dashboard
```dart
// From any screen, navigate using the named route
Navigator.pushNamed(
  context,
  '/volunteer-dashboard',
  arguments: 'volunteer_id_here', // Pass the volunteer ID
);

// Or without arguments (uses default ID)
Navigator.pushNamed(context, '/volunteer-dashboard');
```

### Example Integration with Login
```dart
// After successful login
final userId = firebaseAuth.currentUser?.uid;
Navigator.pushNamed(
  context,
  '/volunteer-dashboard',
  arguments: userId,
);
```

## Customization

### Modifying Impact Level Calculation
Edit `firebase_volunteer_repository.dart`:
```dart
String _calculateImpactLevel(int hours, int projects) {
  if (hours < 10 || projects < 1) {
    return 'Beginner';
  } else if (hours < 50 || projects < 5) {
    return 'Intermediate';
  } else if (hours < 100 || projects < 10) {
    return 'Advanced';
  } else {
    return 'Expert';
  }
}
```

### Changing Colors
All colors follow the app theme:
- Primary Color: `#6794AA`
- Text Color: `#1F2937`
- Background: `#F9FAFB`

Modify in `volunteer_dashboard_screen.dart`:
```dart
const primaryColor = Color(0xFF6794AA);
const textColor = Color(0xFF1F2937);
const backgroundColor = Color(0xFFFAFAFB);
```

### Adjusting Data Limits
In `firebase_volunteer_repository.dart`, modify `.limit()`:
```dart
// Get last 10 activities instead of 20
.limit(10)
.get();
```

## Error Handling
- Network errors display a retry button
- Graceful fallbacks for missing images
- Null-safe data access
- Try-catch blocks on all Firebase calls

## Performance Optimization
- FutureBuilder for asynchronous data loading
- RefreshIndicator for manual data refresh
- Data is fetched once on screen load
- Images loaded with NetworkImage caching

## Future Enhancements
1. Add pagination for activities and opportunities
2. Implement search/filter functionality
3. Add activity statistics charts
4. Enable volunteer profile editing from dashboard
5. Push notifications for new opportunities
6. Leaderboard/achievement system
7. Skill endorsement system

## Testing Firebase Locally
To test with sample data:

```dart
// Add this to your Firebase console or use a test script
db.collection('volunteers').doc('test_volunteer_1').set({
  'name': 'John Doe',
  'email': 'john@example.com',
  'hoursContributed': 45,
  'projectsCompleted': 3,
  'rating': 4.5,
  'country': 'USA',
  'city': 'New York',
  'skills': ['teaching', 'mentoring'],
  'certifications': ['Teaching 101'],
  'isAvailable': true,
  'interests': ['education', 'youth'],
});
```

## Troubleshooting

### Dashboard Shows Blank Screen
- Verify volunteer ID is passed correctly
- Check Firebase permissions in Firestore rules
- Ensure Firestore collections exist with sample data

### Missing Images
- Verify `profileImageUrl` field contains valid URL
- Check Firebase Storage permissions

### No Activities Showing
- Create sample activities in Firestore
- Verify `volunteerId` in activities matches volunteer doc ID

## Related Files Modified
- `/lib/app.dart` - Added `/volunteer-dashboard` route
- Added new feature module at `/lib/features/volunteer/`

---

**Last Updated:** February 26, 2026
**Version:** 1.0.0
