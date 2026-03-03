// Integration Guide for State Management

/*
USING WITH PROVIDER PACKAGE
============================

1. Add to pubspec.yaml:
   provider: ^6.0.0

2. In main.dart or app.dart:
   import 'package:provider/provider.dart';
   import 'features/volunteer/presentation/controllers/volunteer_dashboard_controller.dart';

   // Wrap your app with MultiProvider
   MultiProvider(
     providers: [
       ChangeNotifierProvider(
         create: (_) => VolunteerDashboardController(),
       ),
     ],
     child: GivvApp(),
   )

3. In volunteer_dashboard_screen.dart, replace initState:
   @override
   void initState() {
     super.initState();
     // Get controller from Provider
     final controller = Provider.of<VolunteerDashboardController>(context, listen: false);
     controller.loadDashboardData(widget.volunteerId);
   }

4. Build with Consumer:
   @override
   Widget build(BuildContext context) {
     return Consumer<VolunteerDashboardController>(
       builder: (context, controller, _) {
         if (controller.isLoading) {
           return const Center(child: CircularProgressIndicator());
         }
         if (controller.hasError) {
           return _buildErrorWidget(controller.error!);
         }
         // Use controller.volunteer, controller.stats, etc.
       },
     );
   }


USING WITH RIVERPOD PACKAGE
============================

1. Add to pubspec.yaml:
   riverpod: ^2.0.0
   flutter_riverpod: ^2.0.0

2. Create a provider file (volunteer_dashboard_provider.dart):
   import 'package:flutter_riverpod/flutter_riverpod.dart';
   
   final volunteerDashboardProvider = 
     FutureProvider.family<Map<String, dynamic>, String>((ref, volunteerId) async {
       final repo = FirebaseVolunteerRepository();
       final volunteer = await repo.getVolunteerById(volunteerId);
       final stats = await repo.getDashboardStats(volunteerId);
       final activities = await repo.getVolunteerActivities(volunteerId);
       final opportunities = await repo.getUpcomingOpportunities(volunteerId);
       
       return {
         'volunteer': volunteer,
         'stats': stats,
         'activities': activities,
         'opportunities': opportunities,
       };
     });

3. In widget:
   @override
   Widget build(BuildContext context, WidgetRef ref) {
     final dashboard = ref.watch(volunteerDashboardProvider(widget.volunteerId));
     
     return dashboard.when(
       data: (data) {
         // Use data['volunteer'], data['stats'], etc.
       },
       loading: () => const CircularProgressIndicator(),
       error: (err, stack) => Text('Error: $err'),
     );
   }


USING WITH BLOC PACKAGE
========================

1. Add to pubspec.yaml:
   flutter_bloc: ^8.0.0

2. Create events and states:
   abstract class VolunteerDashboardEvent {}
   
   class LoadDashboard extends VolunteerDashboardEvent {
     final String volunteerId;
     LoadDashboard(this.volunteerId);
   }
   
   abstract class VolunteerDashboardState {}
   
   class DashboardInitial extends VolunteerDashboardState {}
   class DashboardLoading extends VolunteerDashboardState {}
   class DashboardLoaded extends VolunteerDashboardState {
     final Volunteer volunteer;
     final DashboardStats stats;
     // ... other fields
   }
   class DashboardError extends VolunteerDashboardState {
     final String message;
   }

3. Create the BLoC:
   class VolunteerDashboardBloc 
     extends Bloc<VolunteerDashboardEvent, VolunteerDashboardState> {
     
     final FirebaseVolunteerRepository repository;
     
     VolunteerDashboardBloc(this.repository) : super(DashboardInitial()) {
       on<LoadDashboard>((event, emit) async {
         emit(DashboardLoading());
         try {
           final volunteer = await repository.getVolunteerById(event.volunteerId);
           final stats = await repository.getDashboardStats(event.volunteerId);
           // ... load other data
           emit(DashboardLoaded(...));
         } catch (e) {
           emit(DashboardError(e.toString()));
         }
       });
     }
   }

4. In app.dart:
   home: BlocProvider(
     create: (context) => VolunteerDashboardBloc(FirebaseVolunteerRepository()),
     child: const VolunteerDashboardScreen(...),
   )


RECOMMENDED APPROACH FOR THIS PROJECT
========================================

Given this is a GIVV project, I recommend using PROVIDER pattern as it's:
- Easier to understand and implement
- Less boilerplate than BLoC
- More flexible than Riverpod for mixed usage

*/

// Quick setup steps:
/*
1. Run: flutter pub add provider

2. Wrap app in providers (in app.dart or main.dart):
   import 'package:provider/provider.dart';
   
   MultiProvider(
     providers: [
       ChangeNotifierProvider(
         create: (_) => VolunteerDashboardController(),
       ),
     ],
     child: const GivvApp(),
   )

3. Use in screens:
   final controller = Provider.of<VolunteerDashboardController>(context);
   
   // In initState:
   controller.loadDashboardData(volunteerId);
   
   // In build:
   if (controller.isLoading) {
     return const LoadingWidget();
   }
   if (controller.hasError) {
     return ErrorWidget(controller.error!);
   }
   // Use controller.volunteer, controller.stats, etc.
*/
