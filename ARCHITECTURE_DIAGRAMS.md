# Volunteer Dashboard Architecture Diagram

## High-Level Architecture Flow

```
┌─────────────────────────────────────────────────────────────────┐
│                    USER INTERFACE LAYER                         │
│  ┌────────────────────────────────────────────────────────────┐ │
│  │         VolunteerDashboardScreen                           │ │
│  │  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐   │ │
│  │  │ StatCard │  │Activity  │  │Activity  │  │Opprtunity│   │ │
│  │  │          │  │Card      │  │Card      │  │Card      │   │ │
│  │  └──────────┘  └──────────┘  └──────────┘  └──────────┘   │ │
│  └────────────────────────────────────────────────────────────┘ │
└─────────────────────┬──────────────────────────────────────────┘
                      │ (Uses)
         ┌────────────▼──────────────┐
         │  VolunteerDashboard      │
         │  Controller              │
         │  (State Management)      │
         └────────────┬──────────────┘
                      │ (Calls)
┌─────────────────────▼──────────────────────────────────────────┐
│              REPOSITORY LAYER (Data Access)                    │
│  ┌────────────────────────────────────────────────────────────┐ │
│  │    VolunteerRepository (Abstract Interface)               │ │
│  │  • getCurrentVolunteer()                                  │ │
│  │  • getVolunteerById()                                     │ │
│  │  • getDashboardStats()                                    │ │
│  │  • getVolunteerActivities()                               │ │
│  │  • getUpcomingOpportunities()                             │ │
│  │  • updateVolunteerProfile()                               │ │
│  │  • completeActivity()                                     │ │
│  └────┬─────────────────────────────────────────────────────┘ │
│       │ (Implemented by)                                       │
│  ┌────▼─────────────────────────────────────────────────────┐ │
│  │    FirebaseVolunteerRepository (Concrete Implementation) │ │
│  │    • All methods implemented using Firestore queries     │ │
│  └────┬─────────────────────────────────────────────────────┘ │
└──────┼────────────────────────────────────────────────────────┘
       │ (Uses)
       │
┌──────▼──────────────────────────────────────────────────────────┐
│              DOMAIN LAYER (Data Models)                         │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │  Volunteer                                               │  │
│  │  • id, name, email, skills[], rating                   │  │
│  │  • hoursContributed, projectsCompleted                 │  │
│  │  • Static_- fromJson(), toJson()                        │  │
│  └──────────────────────────────────────────────────────────┘  │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │  DashboardStats                                          │  │
│  │  • totalHours, projectsCompleted, rating                │  │
│  │  • impactLevel (calculated dynamically)                 │  │
│  └──────────────────────────────────────────────────────────┘  │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │  VolunteerActivity                                       │  │
│  │  • id, title, description, activityType                 │  │
│  │  • date, hoursSpent, status, organizationName           │  │
│  └──────────────────────────────────────────────────────────┘  │
└────┬─────────────────────────────────────────────────────────────┘
     │ (Serialized to/from)
     │
┌────▼──────────────────────────────────────────────────────────────┐
│            EXTERNAL SERVICES (Firebase Firestore)                 │
│  ┌───────────────────────────────────────────────────────────┐   │
│  │  Collections:                                             │   │
│  │  • volunteers/{volunteerId}     → Volunteer profiles    │   │
│  │  • activities/{activityId}      → Historical activities │   │
│  │  • opportunities/{opportunityId} → Available tasks      │   │
│  └───────────────────────────────────────────────────────────┘   │
└────────────────────────────────────────────────────────────────────┘
```

---

## Data Flow Diagram

### Fetching Dashboard Data

```
User Opens Dashboard
         │
         ▼
┌─────────────────────────────────┐
│ VolunteerDashboardScreen init   │
│ • Sets _loadDataFuture          │
│ • Calls _loadDashboardData()    │
└────────┬────────────────────────┘
         │
         ▼
┌────────────────────────────────────────┐
│ FutureBuilder triggers                 │
│ Fetches 4 parallel futures:            │
│ 1. getVolunteerById()                  │
│ 2. getDashboardStats()                 │
│ 3. getVolunteerActivities()            │
│ 4. getUpcomingOpportunities()          │
└────────┬───────────────────────────────┘
         │
         ▼
┌────────────────────────────────────────┐
│ Each call hits Firebase Firestore      │
│ • Query documents                      │
│ • Parse to model objects               │
│ • Return in parallel                   │
└────────┬───────────────────────────────┘
         │
         ▼
┌────────────────────────────────────────┐
│ setState() updates local variables     │
│ • _volunteer = result                  │
│ • _stats = result                      │
│ • _activities = result                 │
│ • _opportunities = result              │
└────────┬───────────────────────────────┘
         │
         ▼
┌────────────────────────────────────────┐
│ FutureBuilder builds UI                │
│ • Displays volunteer header            │
│ • Renders stat cards                   │
│ • Lists activities                     │
│ • Shows opportunities                  │
└────────────────────────────────────────┘
```

---

## Component Interaction Diagram

```
┌──────────────────────────────────────────────┐
│  VolunteerDashboardScreen (Stateful)         │
│                                              │
│  State:                                      │
│  • _volunteer: Volunteer?                    │
│  • _stats: DashboardStats?                   │
│  • _activities: List<VolunteerActivity>      │
│  • _opportunities: List<Map>                 │
│  • _error: String?                           │
│  • _repository: FirebaseVolunteerRepository  │
│                                              │
│  Methods:                                    │
│  • _loadDashboardData()                      │
│  • _refreshDashboard()                       │
│  • _buildVolunteerHeader()                   │
│  • _buildStatsGrid()                         │
└──┬───────────────────────────────────────────┘
   │
   ├──► Creates: StatCard (4x in grid)
   │    Each shows one metric with icon
   │
   ├──► Creates: ActivityCard (up to 5)
   │    Each displays one activity
   │
   └──► Creates: OpportunityCard (up to 5)
        Each shows one opportunity

```

---

## Database Query Patterns

### Get Volunteer Profile
```
volunteers/{volunteerId}
    ↓ (Firestore.get())
Volunteer.fromJson()
    ↓
Display in header
```

### Get Dashboard Stats
```
volunteers/{volunteerId}
    ↓ (Extract fields)
┌─────────────────────────────────────┐
│ DashboardStats(                     │
│   totalHours: data['hoursContrib'], │
│   projectsCompleted: data['proj'],  │
│   impactLevel: _calculate()         │ ← Dynamic!
│ )                                   │
└─────────────────────────────────────┘
    ↓
Display in 4-card grid
```

### Get Activities
```
activities
    ↓ (Where: volunteerId == current)
    ↓ (OrderBy: date descending)
    ↓ (Limit: 20)
List<VolunteerActivity>
    ↓ (Take 5)
Display in list
```

### Get Opportunities
```
opportunities
    ↓ (Where: status == 'open')
    ↓ (OrderBy: startDate ascending)
List<Opportunity>
    ↓
Display to volunteer
```

---

## State Management Options

### Without External Library (Current)
```
Widget State
    ↓
setState()
    ↓
Rebuild
```

### With Provider (Recommended)
```
VolunteerDashboardController
    ↓ (Extends ChangeNotifier)
    ↓ (notifyListeners())
Consumer <VolunteerDashboardController>
    ↓
Rebuild only affected widgets
```

### With Riverpod
```
Provider.family<Data, String>
    ↓
Caches based on volunteerId
    ↓
Widget watches provider
    ↓
Auto-rebuild on update
```

### With BLoC
```
Event
    ↓
VolunteerDashboardBloc
    ↓
State
    ↓
BlocBuilder rebuilds UI
```

---

## Error Handling Flow

```
Network Request
    │
    ├─ Success ──► Parse ──► State Update ──► Display Data
    │
    └─ Error ──► Catch ──► Set _error ──► FutureBuilder.error
                │
                └─► Show Error Widget
                    with Retry Button ──► User taps ──► Retry
```

---

## Widget Tree Structure

```
VolunteerDashboardScreen
├── Scaffold
│   ├── AppBar (optional)
│   └── SafeArea
│       └── FutureBuilder
│           ├── Loading State: CircularProgressIndicator
│           ├── Error State: ErrorWidget with Retry Button
│           └── Success State: RefreshIndicator
│               └── SingleChildScrollView
│                   └── Column
│                       ├── _buildVolunteerHeader()
│                       │   └── Container with Row
│                       │       ├── CircleAvatar (profile image)
│                       │       ├── Column (name, location)
│                       │       └── Rating badge
│                       │
│                       ├── Title "Your Impact"
│                       ├── _buildStatsGrid()
│                       │   └── GridView.count (crossAxisCount: 2)
│                       │       ├── StatCard (hours)
│                       │       ├── StatCard (projects)
│                       │       ├── StatCard (certs)
│                       │       └── StatCard (level)
│                       │
│                       ├── Title "Recent Activities"
│                       ├── ListView.builder
│                       │   └── ActivityCard (x5)
│                       │       └── Container with:
│                       │           ├── Activity icon
│                       │           ├── Title & org
│                       │           ├── Status badge
│                       │           ├── Description
│                       │           └── Hours & date
│                       │
│                       ├── Title "Upcoming Opportunities"
│                       └── ListView.builder
│                           └── OpportunityCard (x5)
│                               └── Container with:
│                                   ├── Title
│                                   ├── Organization
│                                   ├── Description
│                                   ├── Location & hours
│                                   └── View button
```

---

## Data Model Relationships

```
┌──────────────┐
│  Volunteer   │
│  (Profile)   │
└────────┬─────┘
         │ has many
         │
┌────────▼──────────────┐
│  VolunteerActivity    │ ───┐
│  (Historical Records) │    │ uses data from
└───────────────────────┘    │
                              │
         ┌────────────────────┘
         │
         ▼
┌──────────────────────┐
│  DashboardStats      │
│  (Calculated View)   │
│  └─ Derived from     │
│     volunteer fields │
└──────────────────────┘
         │
         └─ feeds into
         │
         ▼
┌──────────────────────┐
│  Opportunity         │
│  (Recommendations)   │
│  └─ Matched by       │
│     skills/interests │
└──────────────────────┘
```

---

## Sequence Diagram: Loading Dashboard

```
User              Widget              Repository           Firebase
 │                  │                    │                    │
 ├─ Tap Dashboard   │                    │                    │
 │                  │                    │                    │
 │                  ├─ initState()       │                    │
 │                  │                    │                    │
 │                  ├─ _loadDashboard()  │                    │
 │                  │                    │                    │
 │                  ├─────────────────────► getVolunteerById()│
 │                  │                    │                    │
 │                  │                    ├─ Firestore Query   │
 │                  │                    │─────────────────────►
 │                  │                    │                    │
 │                  │                    │◄─ Firestore Result─┤
 │                  │                    │                    │
 │                  │                    ├─ fromJson()        │
 │                  │◄─ Volunteer data ──┤                    │
 │                  │                    │                    │
 │                  ├─ setState()        │                    │
 │                  │                    │                    │
 │                  ├─ FutureBuilder.now │                    │
 │                  │   (data loaded)    │                    │
 │                  │                    │                    │
 │                  ├─ Build UI          │                    │
 │◄─ Display ───────┤                    │                    │
 │                  │                    │                    │
```

---

## Color Scheme & Design System

```
Colors Used:
├── Primary: #6794AA (Blue-Grey)
│   └── Used for: CTA buttons, icons, badges, highlights
├── Text: #1F2937 (Dark)
│   └── Used for: Body text, titles, main content
├── Secondary: #6B7280 (Light Grey)
│   └── Used for: Secondary text, labels
├── Background: #F9FAFB (Off-white)
│   └── Used for: Screen background
├── White: #FFFFFF
│   └── Used for: Card backgrounds
└── Status Colors:
    ├── Green: Completed activities
    ├── Blue: In-progress activities
    └── Orange: Pending activities

Spacing System:
├── Padding: 16px, 20px, 24px
├── Margin: 12px, 16px, 24px
└── Border Radius: 8px, 12px, 16px, 20px

Typography:
├── Headlines: 28px bold
├── Titles: 16-18px bold
├── Body: 13-14px regular
└── Labels: 10-12px light
```

---

**Diagram Version:** 1.0
**Last Updated:** February 26, 2026
