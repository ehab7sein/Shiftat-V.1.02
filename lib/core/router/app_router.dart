import 'package:flutter/material.dart';
import 'package:shiftat/core/router/app_routes.dart';
import 'package:shiftat/features/auth/screens/login_screen.dart';
import 'package:shiftat/features/auth/screens/otp_screen.dart';
import 'package:shiftat/features/auth/screens/profile_setup_screen.dart';
import 'package:shiftat/features/onboarding/screens/onboarding_screen.dart';
import 'package:shiftat/features/onboarding/screens/splash_screen.dart';
import 'package:shiftat/features/onboarding/screens/user_type_screen.dart';
import 'package:shiftat/features/placeholder/placeholder_screen.dart';

class AppRouter {
  AppRouter._();

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.splash:
        return _fade(const SplashScreen());

      case AppRoutes.onboarding:
        return _fade(const OnboardingScreen());

      case AppRoutes.userTypeSelect:
        return _slide(const UserTypeScreen());

      case AppRoutes.login:
        final userType = settings.arguments as String? ?? 'worker';
        return _slide(LoginScreen(userType: userType));

      case AppRoutes.otp:
        final args = settings.arguments as Map<String, dynamic>? ?? {};
        return _slide(OtpScreen(
          phone: args['phone'] as String? ?? '',
          userType: args['userType'] as String? ?? 'worker',
        ));

      case AppRoutes.profile:
        final userType = settings.arguments as String? ?? 'worker';
        return _slide(ProfileSetupScreen(userType: userType));

      case AppRoutes.workerHome:
        return _fade(const PlaceholderHomeScreen(userType: 'worker'));

      case AppRoutes.employerHome:
        return _fade(const PlaceholderHomeScreen(userType: 'employer'));

      default:
        return _fade(const SplashScreen());
    }
  }

  static PageRoute<T> _fade<T>(Widget page) => PageRouteBuilder<T>(
        pageBuilder: (_, __, ___) => page,
        transitionsBuilder: (_, anim, __, child) =>
            FadeTransition(opacity: anim, child: child),
        transitionDuration: const Duration(milliseconds: 400),
      );

  static PageRoute<T> _slide<T>(Widget page) => PageRouteBuilder<T>(
        pageBuilder: (_, __, ___) => page,
        transitionsBuilder: (_, anim, __, child) {
          final tween = Tween(
            begin: const Offset(0, 0.06),
            end: Offset.zero,
          ).chain(CurveTween(curve: Curves.easeOutCubic));
          return FadeTransition(
            opacity: anim,
            child: SlideTransition(position: anim.drive(tween), child: child),
          );
        },
        transitionDuration: const Duration(milliseconds: 380),
      );
}
