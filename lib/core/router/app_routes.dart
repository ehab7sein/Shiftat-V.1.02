// Named route constants — single source of truth
class AppRoutes {
  AppRoutes._();

  static const String splash          = '/';
  static const String onboarding      = '/onboarding';
  static const String userTypeSelect  = '/user-type';
  static const String login           = '/login';
  static const String otp             = '/otp';
  static const String profile         = '/profile-setup';

  // post-auth placeholders (other phases)
  static const String workerHome      = '/worker/home';
  static const String employerHome    = '/employer/home';
}
