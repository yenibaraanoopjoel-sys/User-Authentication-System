import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../models/user_model.dart';
import '../routes/app_routes.dart';
import '../utils/app_colors.dart';
import '../widgets/primary_button.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final _authService = AuthService();
  final _firestoreService = FirestoreService();
  UserModel? _userProfile;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    if (_authService.isDemoMode) {
      if (!mounted) return;
      setState(() {
        _userProfile = _authService.demoUser;
      });
      return;
    }

    final user = _authService.currentUser;
    if (user == null) {
      if (mounted) {
        Navigator.pushReplacementNamed(context, AppRoutes.login);
      }
      return;
    }

    // Try fetching from Firestore; fallback to Firebase Auth user data
    final profile = await _firestoreService.getUserProfile(user.uid);
    if (!mounted) return;

    setState(() {
      _userProfile = profile ?? UserModel.fromFirebaseUser(user);
    });
  }

  Future<void> _refreshState() async {
    final user = await _authService.reloadUser();
    if (!mounted) return;
    if (user != null) {
      final profile = await _firestoreService.getUserProfile(user.uid);
      if (!mounted) return;
      setState(() {
        _userProfile = profile ?? UserModel.fromFirebaseUser(user);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Session state refreshed successfully.'),
          backgroundColor: AppColors.surfaceLight,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  Future<void> _confirmLogout() async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Row(
          children: [
            Icon(Icons.logout_rounded, color: AppColors.error, size: 24),
            SizedBox(width: 10),
            Text(
              'Sign Out',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: const Text(
          'Are you sure you want to log out of your account?',
          style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text(
              'Cancel',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (shouldLogout == true && mounted) {
      await _authService.logoutUser();
      if (!mounted) return;
      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRoutes.login,
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = _authService.currentUser;
    final isDemo = _authService.isDemoMode;
    if (user == null && !isDemo) {
      return const SizedBox.shrink();
    }

    final displayName = _userProfile?.fullName.isNotEmpty == true
        ? _userProfile!.fullName
        : (user?.displayName ?? user?.email?.split('@').first ?? 'Demo User');

    final email = _userProfile?.email ?? user?.email ?? 'demo@authguard.com';
    final isVerified = _userProfile?.isEmailVerified ?? user?.emailVerified ?? true;
    final creationDate = user?.metadata.creationTime != null
        ? DateFormat('MMMM dd, yyyy').format(user!.metadata.creationTime!)
        : DateFormat('MMMM dd, yyyy').format(_userProfile?.createdAt ?? DateTime.now());

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        centerTitle: false,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.shield,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'AuthGuard',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Refresh state',
            icon: const Icon(Icons.refresh_rounded, color: AppColors.textSecondary),
            onPressed: _refreshState,
          ),
          IconButton(
            tooltip: 'Profile',
            icon: const Icon(Icons.account_circle_outlined,
                color: AppColors.textPrimary),
            onPressed: () async {
              await Navigator.pushNamed(context, AppRoutes.profile);
              _loadUserProfile();
            },
          ),
          IconButton(
            tooltip: 'Logout',
            icon: const Icon(Icons.logout_rounded, color: AppColors.error),
            onPressed: _confirmLogout,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refreshState,
          color: AppColors.primaryLight,
          backgroundColor: AppColors.surface,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 800),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Welcome Banner Card
                    _buildWelcomeCard(displayName, email, isVerified),
                    const SizedBox(height: 20),

                    // Email verification notice if not verified
                    if (!isVerified) ...[
                      _buildVerificationNoticeCard(),
                      const SizedBox(height: 20),
                    ],

                    // Section Heading
                    const Text(
                      'Account Overview',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                        letterSpacing: 0.2,
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Information Cards Grid
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final isWide = constraints.maxWidth > 580;
                        return Wrap(
                          spacing: 16,
                          runSpacing: 16,
                          children: [
                            SizedBox(
                              width: isWide
                                  ? (constraints.maxWidth - 16) / 2
                                  : constraints.maxWidth,
                              child: _buildInfoCard(
                                title: 'Account Status',
                                value: 'Active & Secured',
                                subtitle: 'Role: ${_userProfile?.role ?? "User"}',
                                icon: Icons.check_circle_outline,
                                iconColor: AppColors.success,
                                badgeColor: AppColors.successBg,
                              ),
                            ),
                            SizedBox(
                              width: isWide
                                  ? (constraints.maxWidth - 16) / 2
                                  : constraints.maxWidth,
                              child: _buildInfoCard(
                                title: 'Email Verification',
                                value: isVerified ? 'Verified' : 'Unverified',
                                subtitle: isVerified
                                    ? 'Full access granted'
                                    : 'Action recommended',
                                icon: isVerified
                                    ? Icons.verified
                                    : Icons.warning_amber_rounded,
                                iconColor: isVerified
                                    ? AppColors.success
                                    : AppColors.warning,
                                badgeColor: isVerified
                                    ? AppColors.successBg
                                    : AppColors.warningBg,
                                actionText: isVerified ? null : 'Verify Now',
                                onAction: () async {
                                  await Navigator.pushNamed(
                                      context, AppRoutes.verifyEmail);
                                  _refreshState();
                                },
                              ),
                            ),
                            SizedBox(
                              width: isWide
                                  ? (constraints.maxWidth - 16) / 2
                                  : constraints.maxWidth,
                              child: _buildInfoCard(
                                title: 'Account Created',
                                value: creationDate,
                                subtitle: 'Registered via Email/Password',
                                icon: Icons.calendar_today_outlined,
                                iconColor: AppColors.secondary,
                                badgeColor: AppColors.infoBg,
                              ),
                            ),
                            SizedBox(
                              width: isWide
                                  ? (constraints.maxWidth - 16) / 2
                                  : constraints.maxWidth,
                              child: _buildInfoCard(
                                title: 'Authentication Status',
                                value: 'Authenticated',
                                subtitle: 'UID: ${(user?.uid ?? _userProfile?.uid ?? "demo").substring(0, 8)}...',
                                icon: Icons.lock_clock_outlined,
                                iconColor: AppColors.primaryLight,
                                badgeColor: AppColors.primaryBgLight.withValues(alpha: 0.15),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 28),

                    // Quick Actions Section
                    const Text(
                      'Quick Actions',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                        letterSpacing: 0.2,
                      ),
                    ),
                    const SizedBox(height: 14),

                    Row(
                      children: [
                        Expanded(
                          child: PrimaryButton(
                            text: 'Manage Profile',
                            icon: Icons.person_outline,
                            isOutlined: true,
                            onPressed: () async {
                              await Navigator.pushNamed(
                                  context, AppRoutes.profile);
                              _loadUserProfile();
                            },
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: PrimaryButton(
                            text: 'Sign Out',
                            icon: Icons.logout_rounded,
                            backgroundColor: AppColors.error.withValues(alpha: 0.15),
                            textColor: AppColors.error,
                            onPressed: _confirmLogout,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeCard(String name, String email, bool isVerified) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: AppColors.heroGradient,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Center(
              child: Text(
                name.isNotEmpty ? name[0].toUpperCase() : 'U',
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome back, $name!',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  email,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVerificationNoticeCard() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.warningBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.warning.withValues(alpha: 0.6)),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline, color: AppColors.warning, size: 24),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Email Not Verified',
                  style: TextStyle(
                    color: AppColors.warning,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Please verify your email address to ensure full account recovery.',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          TextButton(
            onPressed: () async {
              await Navigator.pushNamed(context, AppRoutes.verifyEmail);
              _refreshState();
            },
            style: TextButton.styleFrom(
              backgroundColor: AppColors.warning.withValues(alpha: 0.2),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            ),
            child: const Text(
              'Verify',
              style: TextStyle(
                color: AppColors.warning,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required Color badgeColor,
    String? actionText,
    VoidCallback? onAction,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: badgeColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              if (actionText != null && onAction != null)
                TextButton(
                  onPressed: onAction,
                  style: TextButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  ),
                  child: Text(
                    actionText,
                    style: TextStyle(
                      color: iconColor,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            title,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textMuted,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
