// Volunteer Dashboard State Management Helper
// This file can be used with any state management solution (Provider, Riverpod, BLoC, etc.)

import 'package:flutter/material.dart';
import '../../data/repositories/firebase_volunteer_repository.dart';
import '../../domain/models/volunteer_model.dart';
import '../../domain/models/dashboard_stats.dart';
import '../../domain/models/volunteer_activity.dart';

class VolunteerDashboardController extends ChangeNotifier {
  final FirebaseVolunteerRepository _repository;
  
  Volunteer? _volunteer;
  DashboardStats? _stats;
  List<VolunteerActivity> _activities = [];
  List<Map<String, dynamic>> _opportunities = [];
  String? _error;
  bool _isLoading = false;

  // Getters
  Volunteer? get volunteer => _volunteer;
  DashboardStats? get stats => _stats;
  List<VolunteerActivity> get activities => _activities;
  List<Map<String, dynamic>> get opportunities => _opportunities;
  String? get error => _error;
  bool get isLoading => _isLoading;
  bool get hasError => _error != null;

  VolunteerDashboardController({
    FirebaseVolunteerRepository? repository,
  }) : _repository = repository ?? FirebaseVolunteerRepository();

  /// Load all dashboard data
  Future<void> loadDashboardData(String volunteerId) async {
    _setLoading(true);
    _setError(null);
    
    try {
      await Future.wait([
        _loadVolunteer(volunteerId),
        _loadStats(volunteerId),
        _loadActivities(volunteerId),
        _loadOpportunities(volunteerId),
      ]);
    } catch (e) {
      _setError('Failed to load dashboard: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Load volunteer profile
  Future<void> _loadVolunteer(String volunteerId) async {
    _volunteer = await _repository.getVolunteerById(volunteerId);
    notifyListeners();
  }

  /// Load dashboard statistics
  Future<void> _loadStats(String volunteerId) async {
    _stats = await _repository.getDashboardStats(volunteerId);
    notifyListeners();
  }

  /// Load volunteer activities
  Future<void> _loadActivities(String volunteerId) async {
    _activities = await _repository.getVolunteerActivities(volunteerId);
    notifyListeners();
  }

  /// Load upcoming opportunities
  Future<void> _loadOpportunities(String volunteerId) async {
    _opportunities = await _repository.getUpcomingOpportunities(volunteerId);
    notifyListeners();
  }

  /// Complete an activity
  Future<bool> completeActivity(String activityId) async {
    final success = await _repository.completeActivity(activityId);
    if (success) {
      _activities = _activities.map((activity) {
        if (activity.id == activityId) {
          return activity.copyWith(status: 'completed');
        }
        return activity;
      }).toList();
      notifyListeners();
    }
    return success;
  }

  /// Update volunteer profile
  Future<bool> updateProfile(Volunteer volunteer) async {
    final success = await _repository.updateVolunteerProfile(volunteer);
    if (success) {
      _volunteer = volunteer;
      notifyListeners();
    }
    return success;
  }

  /// Refresh all data
  Future<void> refresh(String volunteerId) async {
    await loadDashboardData(volunteerId);
  }

  // Private helpers
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String? error) {
    _error = error;
    notifyListeners();
  }

  /// Clear all data and errors
  void clear() {
    _volunteer = null;
    _stats = null;
    _activities = [];
    _opportunities = [];
    _error = null;
    notifyListeners();
  }
}
