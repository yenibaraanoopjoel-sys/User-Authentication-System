import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserModel {
  final String uid;
  final String email;
  final String fullName;
  final String role;
  final DateTime? createdAt;
  final bool isEmailVerified;
  final String? photoUrl;
  final String? phoneNumber;
  final String? bio;

  const UserModel({
    required this.uid,
    required this.email,
    required this.fullName,
    this.role = 'User',
    this.createdAt,
    this.isEmailVerified = false,
    this.photoUrl,
    this.phoneNumber,
    this.bio,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'fullName': fullName,
      'role': role,
      'createdAt': createdAt != null
          ? Timestamp.fromDate(createdAt!)
          : FieldValue.serverTimestamp(),
      'isEmailVerified': isEmailVerified,
      'photoUrl': photoUrl,
      'phoneNumber': phoneNumber,
      'bio': bio,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map, String uid) {
    DateTime? parsedCreatedAt;
    if (map['createdAt'] is Timestamp) {
      parsedCreatedAt = (map['createdAt'] as Timestamp).toDate();
    } else if (map['createdAt'] is String) {
      parsedCreatedAt = DateTime.tryParse(map['createdAt'] as String);
    }

    return UserModel(
      uid: uid,
      email: map['email'] as String? ?? '',
      fullName: map['fullName'] as String? ?? 'User',
      role: map['role'] as String? ?? 'User',
      createdAt: parsedCreatedAt,
      isEmailVerified: map['isEmailVerified'] as bool? ?? false,
      photoUrl: map['photoUrl'] as String?,
      phoneNumber: map['phoneNumber'] as String?,
      bio: map['bio'] as String?,
    );
  }

  factory UserModel.fromFirebaseUser(User user, {String? customFullName}) {
    return UserModel(
      uid: user.uid,
      email: user.email ?? '',
      fullName: customFullName ??
          ((user.displayName != null && user.displayName!.isNotEmpty)
              ? user.displayName!
              : (user.email?.split('@').first ?? 'User')),
      role: 'User',
      createdAt: user.metadata.creationTime,
      isEmailVerified: user.emailVerified,
      photoUrl: user.photoURL,
      phoneNumber: user.phoneNumber,
      bio: null,
    );
  }

  UserModel copyWith({
    String? uid,
    String? email,
    String? fullName,
    String? role,
    DateTime? createdAt,
    bool? isEmailVerified,
    String? photoUrl,
    String? phoneNumber,
    String? bio,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      role: role ?? this.role,
      createdAt: createdAt ?? this.createdAt,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      photoUrl: photoUrl ?? this.photoUrl,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      bio: bio ?? this.bio,
    );
  }
}
