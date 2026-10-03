import 'dart:developer' as developer;
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';
import 'firestore_service.dart';

class AuthResult {
  final bool isSuccess;
  final String? errorMessage;
  final User? user;

  const AuthResult({
    required this.isSuccess,
    this.errorMessage,
    this.user,
  });

  factory AuthResult.success(User user) => AuthResult(
        isSuccess: true,
        user: user,
      );

  factory AuthResult.failure(String message) => AuthResult(
        isSuccess: false,
        errorMessage: message,
      );
}

class AuthService {
  final FirebaseAuth _firebaseAuth;
  final FirestoreService _firestoreService;

  AuthService({
    FirebaseAuth? firebaseAuth,
    FirestoreService? firestoreService,
  })  : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
        _firestoreService = firestoreService ?? FirestoreService();

  /// Stream of authentication state changes
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  /// Get currently signed-in Firebase user
  User? get currentUser => _firebaseAuth.currentUser;

  /// Check if a user is currently logged in
  bool get isAuthenticated => _firebaseAuth.currentUser != null;

  /// Registers a new user with email, password, and full name
  Future<AuthResult> registerUser({
    required String email,
    required String password,
    required String fullName,
  }) async {
    try {
      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final user = userCredential.user;
      if (user != null) {
        // Update Firebase Auth display name
        await user.updateDisplayName(fullName.trim());

        // Send initial email verification
        try {
          await user.sendEmailVerification();
        } catch (e) {
          developer.log('Initial email verification send error: $e',
              name: 'AuthService');
        }

        // Save user profile to Firestore
        final userModel = UserModel(
          uid: user.uid,
          email: user.email ?? email.trim(),
          fullName: fullName.trim(),
          role: 'User',
          createdAt: DateTime.now(),
          isEmailVerified: user.emailVerified,
        );
        await _firestoreService.saveUserProfile(userModel);

        return AuthResult.success(user);
      }
      return AuthResult.failure('Failed to create account. Please try again.');
    } on FirebaseAuthException catch (e) {
      return AuthResult.failure(_mapFirebaseAuthError(e));
    } catch (e) {
      return AuthResult.failure('An unexpected error occurred: ${e.toString()}');
    }
  }

  /// Logs in existing user with email and password
  Future<AuthResult> loginUser({
    required String email,
    required String password,
  }) async {
    try {
      final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final user = userCredential.user;
      if (user != null) {
        return AuthResult.success(user);
      }
      return AuthResult.failure('Could not sign in. Please try again.');
    } on FirebaseAuthException catch (e) {
      return AuthResult.failure(_mapFirebaseAuthError(e));
    } catch (e) {
      return AuthResult.failure('An unexpected error occurred: ${e.toString()}');
    }
  }

  /// Sends a password reset email to the given address
  Future<AuthResult> resetPassword(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email.trim());
      return const AuthResult(isSuccess: true);
    } on FirebaseAuthException catch (e) {
      return AuthResult.failure(_mapFirebaseAuthError(e));
    } catch (e) {
      return AuthResult.failure('An unexpected error occurred: ${e.toString()}');
    }
  }

  /// Sends or resends email verification to currently logged in user
  Future<AuthResult> sendEmailVerification() async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) {
        return AuthResult.failure('No authenticated user found.');
      }
      await user.sendEmailVerification();
      return const AuthResult(isSuccess: true);
    } on FirebaseAuthException catch (e) {
      return AuthResult.failure(_mapFirebaseAuthError(e));
    } catch (e) {
      return AuthResult.failure('Could not send verification email: $e');
    }
  }

  /// Reloads the current user state to refresh emailVerified status
  Future<User?> reloadUser() async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user != null) {
        await user.reload();
        return _firebaseAuth.currentUser;
      }
      return null;
    } catch (e) {
      developer.log('Error reloading user: $e', name: 'AuthService');
      return _firebaseAuth.currentUser;
    }
  }

  /// Updates current user profile (displayName) in Auth and Firestore
  Future<AuthResult> updateProfile({required String fullName}) async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) {
        return AuthResult.failure('No authenticated user found.');
      }
      await user.updateDisplayName(fullName.trim());
      await _firestoreService.updateUserProfile(user.uid, {
        'fullName': fullName.trim(),
      });
      return AuthResult.success(user);
    } on FirebaseAuthException catch (e) {
      return AuthResult.failure(_mapFirebaseAuthError(e));
    } catch (e) {
      return AuthResult.failure('Failed to update profile: ${e.toString()}');
    }
  }

  /// Signs out the user
  Future<void> logoutUser() async {
    try {
      await _firebaseAuth.signOut();
    } catch (e) {
      developer.log('Logout error: $e', name: 'AuthService');
      rethrow;
    }
  }

  /// Maps technical Firebase error codes to user-friendly messages
  String _mapFirebaseAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No account was found with this email.';
      case 'wrong-password':
        return 'The password is incorrect.';
      case 'invalid-credential':
        return 'Invalid email or password. Please verify your credentials.';
      case 'email-already-in-use':
        return 'An account with this email already exists.';
      case 'invalid-email':
        return 'The email address format is invalid.';
      case 'weak-password':
        return 'The password provided is too weak. Please use at least 6 characters.';
      case 'user-disabled':
        return 'This account has been disabled. Please contact support.';
      case 'too-many-requests':
        return 'Too many attempts. Please wait a few minutes before trying again.';
      case 'network-request-failed':
        return 'Network connection failed. Please check your internet connection.';
      case 'operation-not-allowed':
        return 'Email/Password sign-in is not enabled in Firebase Console.';
      default:
        return e.message ?? 'An authentication error occurred. Please try again.';
    }
  }
}
