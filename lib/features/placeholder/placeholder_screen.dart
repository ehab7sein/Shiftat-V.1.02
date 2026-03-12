import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shiftat/core/router/app_routes.dart';
import 'package:shiftat/core/theme/app_theme.dart';

/// Temporary placeholder for Worker/Employer home screens
/// (to be replaced in later phases)
class PlaceholderHomeScreen extends StatelessWidget {
  const PlaceholderHomeScreen({super.key, required this.userType});
  final String userType;

  bool get _isWorker => userType == 'worker';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgLight,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        title: Text(
          _isWorker ? 'الرئيسية — باحث عن عمل' : 'الرئيسية — صاحب العمل',
          style: GoogleFonts.notoSansArabic(
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: Colors.white),
            onPressed: () async {
              final prefs = await SharedPreferences.getInstance();
              await prefs.clear();
              if (context.mounted) {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  AppRoutes.onboarding,
                  (r) => false,
                );
              }
            },
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _isWorker
                      ? Icons.construction_rounded
                      : Icons.business_center_rounded,
                  color: AppColors.primary,
                  size: 54,
                ),
              ),
              const SizedBox(height: 28),
              Text(
                '🎉 تم تسجيل الدخول بنجاح!',
                style: GoogleFonts.notoSansArabic(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textMain,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                _isWorker
                    ? 'مرحباً بك! ستظهر هنا قائمة الوظائف المتاحة.'
                    : 'مرحباً بك! ستظهر هنا لوحة تحكم صاحب العمل.',
                style: GoogleFonts.notoSansArabic(
                  fontSize: 15,
                  color: AppColors.textSub,
                  height: 1.6,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Text(
                '(هذه الشاشة سيتم استبدالها في المرحلة القادمة)',
                style: GoogleFonts.notoSansArabic(
                  fontSize: 12,
                  color: AppColors.textSub.withOpacity(0.6),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
