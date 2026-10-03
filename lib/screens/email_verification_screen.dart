import 'dart:async';
import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../routes/app_routes.dart';
import '../utils/app_colors.dart';
import '../widgets/primary_button.dart';

class EmailVerificationScreen extends StatefulWidget {
  const EmailVerificationScreen({super.key});

  @override
  State<EmailVerificationScreen> createState() =>
      _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen> {
  final _authService = AuthService();
  bool _isChecking = false;
  bool _isResending = false;
  bool _isVerified = false;
  String? _feedbackMessage;
  bool _isSuccessFeedback = false;
  Timer? _autoCheckTimer;

  @override
  void initState() {
    super.initState();
    _isVerified = _authService.currentUser?.emailVerified ?? false;
    // Periodically check in background if user opened email in browser
    if (!_isVerified) {
      _autoCheckTimer = Timer.periodic(
        const Duration(seconds: 4),
        (_) => _checkVerificationSilently(),
      );
    }
  }

  @override
  void dispose() {
    _autoCheckTimer?.cancel();
    super.dispose();
  }

  Future<void> _checkVerificationSilently() async {
    final user = await _authService.reloadUser();
    if (user != null && user.emailVerified && mounted) {
      _autoCheckTimer?.cancel();
      setState(() {
        _isVerified = true;
        _isSuccessFeedback = true;
        _feedbackMessage = 'Email verified successfully!';
      });
    }
  }

  Future<void> _manualCheckVerification() async {
    setState(() {
      _isChecking = true;
      _feedbackMessage = null;
    });

    if (_authService.isDemoMode) {
      _autoCheckTimer?.cancel();
      setState(() {
        _isChecking = false;
        _isVerified = true;
        _isSuccessFeedback = true;
        _feedbackMessage = 'Great! Your email has been verified.';
      });
      return;
    }

    final user = await _authService.reloadUser();
    if (!mounted) return;

    setState(() {
      _isChecking = false;
    });

    if (user != null && user.emailVerified) {
      _autoCheckTimer?.cancel();
      setState(() {
        _isVerified = true;
        _isSuccessFeedback = true;
        _feedbackMessage = 'Great! Your email has been verified.';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Email verified! You now have full access.'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    } else {
      setState(() {
        _isSuccessFeedback = false;
        _feedbackMessage =
            'Email is not verified yet. Please check your inbox and click the verification link.';
      });
    }
  }

  Future<void> _resendVerificationEmail() async {
    setState(() {
      _isResending = true;
      _feedbackMessage = null;
    });

    final result = await _authService.sendEmailVerification();
    if (!mounted) return;

    setState(() {
      _isResending = false;
    });

    if (result.isSuccess) {
      setState(() {
        _isSuccessFeedback = true;
        _feedbackMessage =
            'A new verification link has been sent to your email address.';
      });
    } else {
      setState(() {
        _isSuccessFeedback = false;
        _feedbackMessage = result.errorMessage ?? 'Could not send verification email.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = _authService.currentUser;
    final email = user?.email ?? 'your email';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Email Verification',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Verification Status Icon
                  Center(
                    child: Container(
                      width: 90,
                      height: 90,
                      decoration: BoxDecoration(
                        color: _isVerified
                            ? AppColors.successBg
                            : AppColors.warningBg,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: _isVerified
                              ? AppColors.success
                              : AppColors.warning,
                          width: 2.2,
                        ),
                      ),
                      child: Icon(
                        _isVerified
                            ? Icons.verified_user_rounded
                            : Icons.mark_email_unread_outlined,
                        color: _isVerified
                            ? AppColors.success
                            : AppColors.warning,
                        size: 46,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Title
                  Center(
                    child: Text(
                      _isVerified
                          ? 'Email Verified'
                          : 'Verify Your Email',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Subtitle / instructions
                  Center(
                    child: Text(
                      _isVerified
                          ? 'Your email address is verified and active.'
                          : 'A verification link was sent to:\n$email\n\nPlease check your inbox and click the link to confirm your account.',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                        height: 1.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Feedback Message
                  if (_feedbackMessage != null) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: _isSuccessFeedback
                            ? AppColors.successBg
                            : AppColors.errorBg,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _isSuccessFeedback
                              ? AppColors.success.withValues(alpha: 0.5)
                              : AppColors.error.withValues(alpha: 0.5),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            _isSuccessFeedback
                                ? Icons.check_circle_outline
                                : Icons.info_outline,
                            color: _isSuccessFeedback
                                ? AppColors.success
                                : AppColors.error,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              _feedbackMessage!,
                              style: TextStyle(
                                color: _isSuccessFeedback
                                    ? AppColors.success
                                    : AppColors.error,
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],

                  if (!_isVerified) ...[
                    // Check Verification Button
                    PrimaryButton(
                      text: 'Check Verification Status',
                      icon: Icons.refresh_rounded,
                      isLoading: _isChecking,
                      onPressed: _isChecking || _isResending
                          ? null
                          : _manualCheckVerification,
                    ),
                    const SizedBox(height: 14),

                    // Resend Email Button
                    PrimaryButton(
                      text: 'Resend Verification Email',
                      icon: Icons.outgoing_mail,
                      isOutlined: true,
                      isLoading: _isResending,
                      onPressed: _isChecking || _isResending
                          ? null
                          : _resendVerificationEmail,
                    ),
                  ] else ...[
                    PrimaryButton(
                      text: 'Continue to Dashboard',
                      icon: Icons.dashboard_rounded,
                      onPressed: () {
                        Navigator.pushNamedAndRemoveUntil(
                          context,
                          AppRoutes.dashboard,
                          (route) => false,
                        );
                      },
                    ),
                  ],
                  const SizedBox(height: 20),

                  // Return to Dashboard or Logout
                  Center(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text(
                        'Back to Dashboard',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
