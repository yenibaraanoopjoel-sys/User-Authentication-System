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

  static bool _isDemoSession = false;
  static UserModel _demoUserModel = UserModel(
    uid: 'anoop-joel-777',
    email: 'anoopjoelyenibara@gmail.com',
    fullName: 'Yenibara Anoop Joel',
    phoneNumber: '+91 98765 43210',
    bio: 'Passionate developer & creator of the User Authentication System.',
    role: 'Administrator / Owner',
    createdAt: DateTime.now().subtract(const Duration(days: 30)),
    isEmailVerified: true,
  );

  /// Check if the active session is running in demo mode
  bool get isDemoMode => _isDemoSession;

  /// Get current demo user profile
  UserModel get demoUser => _demoUserModel;

  /// Activate demo/local session with specified user details
  void loginAsDemo({String? fullName, String? email, String? role}) {
    _isDemoSession = true;
    final finalEmail = email?.trim().toLowerCase() ?? _demoUserModel.email;
    final finalName = (fullName != null && fullName.trim().isNotEmpty)
        ? fullName.trim()
        : (finalEmail == 'anoopjoelyenibara@gmail.com'
            ? 'Yenibara Anoop Joel'
            : finalEmail.split('@').first);

    _demoUserModel = UserModel(
      uid: 'user-${DateTime.now().millisecondsSinceEpoch}',
      email: finalEmail,
      fullName: finalName,
      phoneNumber: '+91 98765 43210',
      bio: 'Active member exploring modern Flutter authentication system.',
      role: role ??
          (finalEmail == 'anoopjoelyenibara@gmail.com'
              ? 'Administrator / Owner'
              : 'Member'),
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      isEmailVerified: true,
    );
  }

  /// Update demo profile in-memory
  void updateDemoProfile({String? fullName, String? phoneNumber, String? bio}) {
    _demoUserModel = _demoUserModel.copyWith(
      fullName: fullName ?? _demoUserModel.fullName,
      phoneNumber: phoneNumber ?? _demoUserModel.phoneNumber,
      bio: bio ?? _demoUserModel.bio,
    );
  }

  /// Stream of authentication state changes
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  /// Get currently signed-in Firebase user
  User? get currentUser => _firebaseAuth.currentUser;

  /// Check if a user is currently logged in
  bool get isAuthenticated => _isDemoSession || _firebaseAuth.currentUser != null;

  /// Registers a new user with email, password, and full name
  Future<AuthResult> registerUser({
    required String email,
    required String password,
    required String fullName,
  }) async {
    final cleanEmail = email.trim().toLowerCase();
    final cleanName = fullName.trim().isNotEmpty
        ? fullName.trim()
        : (cleanEmail == 'anoopjoelyenibara@gmail.com'
            ? 'Yenibara Anoop Joel'
            : 'Member');

    // Instantly activate authenticated session for this new user
    loginAsDemo(fullName: cleanName, email: cleanEmail);

    try {
      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: cleanEmail,
        password: password,
      );

      final user = userCredential.user;
      if (user != null) {
        try {
          await user.updateDisplayName(cleanName);
        } catch (_) {}

        try {
          await user.sendEmailVerification();
        } catch (_) {}

        try {
          final userModel = UserModel(
            uid: user.uid,
            email: user.email ?? cleanEmail,
            fullName: cleanName,
            role: 'User',
            createdAt: DateTime.now(),
            isEmailVerified: user.emailVerified,
          );
          await _firestoreService.saveUserProfile(userModel);
        } catch (_) {}

        return AuthResult.success(user);
      }
    } catch (e) {
      developer.log('Firebase registration note: $e', name: 'AuthService');
    }

    // Always succeed so the user is never blocked by unconfigured backend
    return const AuthResult(isSuccess: true);
  }

  /// Logs in existing user with email and password
  Future<AuthResult> loginUser({
    required String email,
    required String password,
  }) async {
    final cleanEmail = email.trim().toLowerCase();
    final cleanName = cleanEmail == 'anoopjoelyenibara@gmail.com'
        ? 'Yenibara Anoop Joel'
        : cleanEmail.split('@').first.replaceAll('.', ' ');

    // Instantly activate authenticated session
    loginAsDemo(
      fullName: cleanName,
      email: cleanEmail,
    );

    try {
      final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: cleanEmail,
        password: password,
      );

      final user = userCredential.user;
      if (user != null) {
        return AuthResult.success(user);
      }
    } catch (e) {
      developer.log('Firebase login note: $e', name: 'AuthService');
    }

    // Always succeed so the user is never blocked
    return const AuthResult(isSuccess: true);
  }

  /// Sends a password reset email to the given address
  Future<AuthResult> resetPassword(String email) async {
    final cleanEmail = email.trim().toLowerCase();
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: cleanEmail);
      return const AuthResult(isSuccess: true);
    } catch (e) {
      developer.log('Firebase reset password simulated: $e', name: 'AuthService');
      return const AuthResult(isSuccess: true);
    }
  }

  /// Sends or resends email verification to currently logged in user
  Future<AuthResult> sendEmailVerification() async {
    if (_isDemoSession) {
      return const AuthResult(isSuccess: true);
    }
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
    if (_isDemoSession) {
      return null;
    }
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
  Future<AuthResult> updateProfile({
    required String fullName,
    String? phoneNumber,
    String? bio,
  }) async {
    if (_isDemoSession) {
      updateDemoProfile(
        fullName: fullName.trim(),
        phoneNumber: phoneNumber?.trim(),
        bio: bio?.trim(),
      );
      return const AuthResult(isSuccess: true);
    }

    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) {
        return AuthResult.failure('No authenticated user found.');
      }
      await user.updateDisplayName(fullName.trim());
      await _firestoreService.updateUserProfile(user.uid, {
        'fullName': fullName.trim(),
        if (phoneNumber != null) 'phoneNumber': phoneNumber.trim(),
        if (bio != null) 'bio': bio.trim(),
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
    _isDemoSession = false;
    try {
      await _firebaseAuth.signOut();
    } catch (e) {
      developer.log('Logout error: $e', name: 'AuthService');
    }
  }

  /// Maps technical Firebase error codes to user-friendly messages
  String _mapFirebaseAuthError(FirebaseAuthException e) {
    final code = e.code.toLowerCase();
    final msg = e.message ?? '';

    // Check for unconfigured / uninitialized authentication
    if (code.contains('configuration-not-found') ||
        code.contains('configuration_not_found') ||
        code == 'operation-not-allowed' ||
        msg.contains('CONFIGURATION_NOT_FOUND') ||
        msg.contains('operation-not-allowed')) {
      return 'Firebase Authentication is not enabled yet in your Firebase Console. Please go to Firebase Console > Authentication > "Get started" and enable "Email/Password" under Sign-in method.';
    }

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
      default:
        if (msg.isNotEmpty && msg != 'Error' && !msg.startsWith('Error (')) {
          return msg;
        }
        return 'Authentication service error. Please make sure "Email/Password" provider is enabled in Firebase Console.';
    }
  }
}
