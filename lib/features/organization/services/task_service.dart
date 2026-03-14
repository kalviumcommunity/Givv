import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart' hide Task;
import 'dart:io';
import 'dart:typed_data';
import '../models/task_model.dart';

class TaskService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final String _collection = 'tasks';

  Future<bool> createTask(Task task) async {
    try {
      await _firestore.collection(_collection).doc(task.id).set(task.toJson());
      return true;
    } catch (e) {
      print('Error creating task: $e');
      return false;
    }
  }

  Stream<List<Task>> streamTasksByEvent(String eventId) {
    return _firestore
        .collection(_collection)
        .where('eventId', isEqualTo: eventId)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map<Task>((doc) => Task.fromJson(doc.data())).toList());
  }

  Stream<List<Task>> streamTasksByVolunteer(String userId) {
    return _firestore
        .collection(_collection)
        .where('assignedTo', isEqualTo: userId)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map<Task>((doc) => Task.fromJson(doc.data())).toList());
  }

  Future<bool> updateTaskStatus(String taskId, TaskStatus status) async {
    try {
      await _firestore.collection(_collection).doc(taskId).update({
        'status': status.name,
      });
      return true;
    } catch (e) {
      print('Error updating task status: $e');
      return false;
    }
  }

  Future<String?> uploadProofImage(String taskId, File imageFile) async {
    try {
      final ref = _storage.ref().child('task_proofs/$taskId.jpg');
      await ref.putFile(imageFile);
      return await ref.getDownloadURL();
    } catch (e) {
      print('Error uploading proof image: $e');
      return null;
    }
  }

  Future<String?> uploadProofImageBytes(String taskId, Uint8List imageBytes, String fileName) async {
    try {
      final ref = _storage.ref().child('task_proofs/${taskId}_$fileName');
      final metadata = SettableMetadata(contentType: 'image/jpeg');
      await ref.putData(imageBytes, metadata);
      return await ref.getDownloadURL();
    } catch (e) {
      print('Error uploading proof image bytes: $e');
      return null;
    }
  }

  Future<bool> submitTaskProof(String taskId, String imageUrl, String note) async {
    try {
      await _firestore.collection(_collection).doc(taskId).update({
        'proofImageUrl': imageUrl,
        'proofNote': note,
        'status': TaskStatus.completed.name,
      });
      return true;
    } catch (e) {
      print('Error submitting task proof: $e');
      return false;
    }
  }

  Future<bool> verifyTask(String taskId, bool approved) async {
    try {
      final status = approved ? TaskStatus.verified : TaskStatus.rejected;
      await _firestore.collection(_collection).doc(taskId).update({
        'status': status.name,
      });
      return true;
    } catch (e) {
      print('Error verifying task: $e');
      return false;
    }
  }
}
