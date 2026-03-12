import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shiftat/core/router/app_routes.dart';
import 'package:shiftat/core/theme/app_theme.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key, required this.userType});
  final String userType;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneCtrl = TextEditingController();
  bool _loading = false;

  // Egypt (+20) is default, hardcoded as per spec
  static const String _countryCode = '+20';

  String get _userTypeLabel =>
      widget.userType == 'employer' ? 'صاحب العمل' : 'الباحث عن عمل';

  Future<void> _sendOtp() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);

    // ── BYPASS MODE: No real SMS provider required ──
    // Simply simulate the "Sending" UX and proceed to local verification
    await Future.delayed(const Duration(milliseconds: 1000));

    if (mounted) {
      setState(() => _loading = false);
      Navigator.pushNamed(
        context,
        AppRoutes.otp,
        arguments: {
          'phone': '$_countryCode${_phoneCtrl.text.trim()}',
          'userType': widget.userType,
        },
      );
    }
  }

  @override
  void dispose() {
    _phoneCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgLight,
      appBar: AppBar(
        backgroundColor: AppColors.bgLight,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_forward_ios_rounded,
              color: AppColors.textMain),
          onPressed: () => Navigator.maybePop(context),
        ),
        title: Text(
          'بوابة التوظيف',
          style: GoogleFonts.notoSansArabic(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.textMain,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const SizedBox(height: 20),

                // Icon badge
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(Icons.work_rounded,
                      color: AppColors.primary, size: 46),
                )
                    .animate()
                    .scale(curve: Curves.elasticOut, duration: 700.ms)
                    .fadeIn(duration: 400.ms),

                const SizedBox(height: 24),

                Text(
                  'مرحباً بكم في سوق العمل',
                  style: GoogleFonts.notoSansArabic(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textMain,
                  ),
                  textAlign: TextAlign.center,
                ).animate(delay: 150.ms).fadeIn().slideY(begin: 0.2),

                const SizedBox(height: 8),

                Text(
                  'تسجيل الدخول كـ $_userTypeLabel',
                  style: GoogleFonts.notoSansArabic(
                    fontSize: 15,
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ).animate(delay: 220.ms).fadeIn(),

                const SizedBox(height: 6),

                Text(
                  'المنصة الأكبر للفرص الوظيفية في المنطقة',
                  style: GoogleFonts.notoSansArabic(
                    fontSize: 14,
                    color: AppColors.textSub,
                  ),
                  textAlign: TextAlign.center,
                ).animate(delay: 280.ms).fadeIn(),

                const SizedBox(height: 40),

                // Country code + Phone input row
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Country code badge
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'رمز الدولة',
                          style: GoogleFonts.notoSansArabic(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textMain,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          height: 54,
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.border, width: 1.5),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text('🇪🇬', style: TextStyle(fontSize: 20)),
                              const SizedBox(width: 6),
                              Text(
                                _countryCode,
                                style: GoogleFonts.notoSansArabic(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textMain,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(width: 12),

                    // Phone number field
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'رقم الهاتف',
                            style: GoogleFonts.notoSansArabic(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textMain,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _phoneCtrl,
                            keyboardType: TextInputType.phone,
                            textDirection: TextDirection.ltr,
                            textAlign: TextAlign.left,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(11),
                            ],
                            style: GoogleFonts.roboto(
                              fontSize: 16,
                              letterSpacing: 1.5,
                              color: AppColors.textMain,
                            ),
                            decoration: InputDecoration(
                              hintText: '10XXXXXXXX',
                              hintStyle: GoogleFonts.roboto(
                                color: AppColors.textSub.withOpacity(0.6),
                                letterSpacing: 1.2,
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 16),
                            ),
                            validator: (v) {
                              if (v == null || v.trim().isEmpty) {
                                return 'أدخل رقم الهاتف';
                              }
                              if (v.trim().length < 10) {
                                return 'الرقم غير مكتمل';
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ).animate(delay: 350.ms).fadeIn().slideY(begin: 0.15),

                const SizedBox(height: 12),

                // Info text
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.06),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline_rounded,
                          color: AppColors.primary, size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'سنرسل لك رمز تحقق عبر رسالة نصية',
                          style: GoogleFonts.notoSansArabic(
                            fontSize: 13,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ).animate(delay: 430.ms).fadeIn(),

                const SizedBox(height: 36),

                // Send OTP button
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  child: _loading
                      ? Container(
                          height: 56,
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Center(
                            child: SizedBox(
                              width: 28,
                              height: 28,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2.5,
                              ),
                            ),
                          ),
                        )
                      : ElevatedButton.icon(
                          onPressed: _sendOtp,
                          icon: const Icon(Icons.send_rounded, size: 20),
                          label: const Text('إرسال رمز التحقق'),
                        ),
                ).animate(delay: 500.ms).fadeIn().slideY(begin: 0.2),

                const SizedBox(height: 28),

                // Terms
                Text.rich(
                  TextSpan(
                    style: GoogleFonts.notoSansArabic(
                      fontSize: 12,
                      color: AppColors.textSub,
                    ),
                    children: [
                      const TextSpan(text: 'باستمرارك، أنت توافق على '),
                      TextSpan(
                        text: 'شروط الاستخدام',
                        style: GoogleFonts.notoSansArabic(
                          color: AppColors.primary,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                      const TextSpan(text: ' و '),
                      TextSpan(
                        text: 'سياسة الخصوصية',
                        style: GoogleFonts.notoSansArabic(
                          color: AppColors.primary,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ],
                  ),
                  textAlign: TextAlign.center,
                ).animate(delay: 580.ms).fadeIn(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
