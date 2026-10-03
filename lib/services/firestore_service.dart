import 'dart:developer' as developer;
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class FirestoreService {
  final FirebaseFirestore _firestore;

  FirestoreService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _usersCollection =>
      _firestore.collection('users');

  /// Saves or updates a user profile document in Firestore
  Future<bool> saveUserProfile(UserModel user) async {
    try {
      await _usersCollection.doc(user.uid).set(
            user.toMap(),
            SetOptions(merge: true),
          );
      return true;
    } catch (e, stack) {
      developer.log('Firestore saveUserProfile error: $e',
          stackTrace: stack, name: 'FirestoreService');
      return false;
    }
  }

  /// Retrieves user profile data from Firestore
  Future<UserModel?> getUserProfile(String uid) async {
    try {
      final doc = await _usersCollection.doc(uid).get();
      if (doc.exists && doc.data() != null) {
        return UserModel.fromMap(doc.data()!, uid);
      }
      return null;
    } catch (e, stack) {
      developer.log('Firestore getUserProfile error: $e',
          stackTrace: stack, name: 'FirestoreService');
      return null;
    }
  }

  /// Updates specific profile fields (e.g. fullName)
  Future<bool> updateUserProfile(String uid, Map<String, dynamic> data) async {
    try {
      await _usersCollection.doc(uid).update(data);
      return true;
    } catch (e, stack) {
      developer.log('Firestore updateUserProfile error: $e',
          stackTrace: stack, name: 'FirestoreService');
      return false;
    }
  }

  /// Stream of user profile data
  Stream<UserModel?> streamUserProfile(String uid) {
    return _usersCollection.doc(uid).snapshots().map((snapshot) {
      if (snapshot.exists && snapshot.data() != null) {
        return UserModel.fromMap(snapshot.data()!, uid);
      }
      return null;
    }).handleError((error) {
      developer.log('Firestore stream error: $error', name: 'FirestoreService');
      return null;
    });
  }
}
