import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shiftat/core/router/app_routes.dart';
import 'package:shiftat/core/theme/app_theme.dart';

/// The FIXED test OTP code — will bypass real SMS provider
const String _kTestOtp = '1234';

class OtpScreen extends StatefulWidget {
  const OtpScreen({super.key, required this.phone, required this.userType});
  final String phone;
  final String userType;

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final _streamCtrl = StreamController<ErrorAnimationType>();
  String _pin = '';
  bool _loading = false;
  bool _hasError = false;

  // Resend countdown
  int _secondsLeft = 60;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    setState(() => _secondsLeft = 60);
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_secondsLeft == 0) {
        t.cancel();
      } else {
        setState(() => _secondsLeft--);
      }
    });
  }

  Future<void> _verify() async {
    if (_pin.length < 4) return;
    
    // ── BYPASS LOGIC ───────────────────────────────────────
    // 1. Check if the code is the bypass code (1234)
    // 2. Perform a "Silent Auth" using Email/Password bypass
    //    mapping the phone number to a simulated email.
    // ────────────────────────────────────────────────────────

    setState(() {
      _loading = true;
      _hasError = false;
    });

    if (_pin == _kTestOtp) {
      try {
        final supabase = Supabase.instance.client;
        
        final email = "${widget.phone.replaceAll('+', '')}@shiftat.sim";
        final password = "shiftat_${widget.phone.replaceAll('+', '')}";

        AuthResponse res;
        bool isNewUserFlag = false;

        try {
          res = await supabase.auth.signInWithPassword(
            email: email,
            password: password,
          );
        } on AuthException {
          isNewUserFlag = true;
          res = await supabase.auth.signUp(
            email: email,
            password: password,
            data: {
              'user_type': widget.userType,
              'full_name': 'مستخدم جديد',
              'phone': widget.phone,
            },
          );
        }

        if (res.session != null) {
          final isNewUser = isNewUserFlag;
          final userId = res.user!.id;

          // ── SYNC PROFILE ─────────────────────────────────────
          // Using upsert ensures that even if the DB trigger failed, 
          // we create/update the profile row manually from the app.
          try {
            await supabase.from('profiles').upsert({
              'id': userId,
              'phone': widget.phone,
              'user_type': widget.userType,
              'full_name': 'مستخدم جديد', // Required field
              'is_verified': true,
              'updated_at': DateTime.now().toIso8601String(),
            });
          } catch (profileError) {
            print('⚠️ Non-fatal profile sync error: $profileError');
            // We proceed anyway, as the profile row might already exist 
            // or the trigger might have actually succeeded.
          }

          // Save to local prefs
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('user_type', widget.userType);
          await prefs.setBool('logged_in', true);

          if (mounted) {
            if (isNewUser) {
              Navigator.pushNamedAndRemoveUntil(
                context,
                AppRoutes.profile,
                (r) => false,
                arguments: widget.userType,
              );
            } else {
              final route = widget.userType == 'employer'
                  ? AppRoutes.employerHome
                  : AppRoutes.workerHome;
              Navigator.pushNamedAndRemoveUntil(
                context,
                route,
                (r) => false,
              );
            }
          }
        }
      } catch (e) {
        String msg = e.toString();
        if (msg.contains('database error saving new user')) {
          msg = 'خطأ في قاعدة البيانات: قد يكون هذا الرقم مسجلاً حساب آخر أو لم يتم تفعيل البريد الإلكتروني في Supabase';
        }
        _handleError('فشل الاتصال: $msg');
      }
    } else {
      _handleError('رمز التحقق غير صحيح');
    }
  }

  void _handleError(String message) {
    if (!mounted) return;
    setState(() {
      _loading = false;
      _hasError = true;
    });
    _streamCtrl.add(ErrorAnimationType.shake);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: GoogleFonts.notoSansArabic()),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _resend() {
    if (_secondsLeft > 0) return;
    _startTimer();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'تم إعادة إرسال الرمز (وضع الاختبار: 1234)',
          style: GoogleFonts.notoSansArabic(),
          textDirection: TextDirection.rtl,
        ),
        backgroundColor: AppColors.primary,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _streamCtrl.close();
    super.dispose();
  }

  String get _timerStr {
    final m = (_secondsLeft ~/ 60).toString().padLeft(2, '0');
    final s = (_secondsLeft % 60).toString().padLeft(2, '0');
    return '$m:$s';
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
          'التحقق من الحساب',
          style: GoogleFonts.notoSansArabic(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.textMain,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
          child: Column(
            children: [
              const SizedBox(height: 20),

              // Icon
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primary.withOpacity(0.1),
                ),
                child: const Icon(Icons.vibration_rounded,
                    color: AppColors.primary, size: 44),
              )
                  .animate()
                  .scale(curve: Curves.elasticOut, duration: 700.ms)
                  .fadeIn(),

              const SizedBox(height: 24),

              Text(
                'أدخل رمز التحقق',
                style: GoogleFonts.notoSansArabic(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textMain,
                ),
              ).animate(delay: 150.ms).fadeIn().slideY(begin: 0.2),

              const SizedBox(height: 10),

              Text(
                'لقد أرسلنا رمزاً مكوناً من 4 أرقام إلى',
                style: GoogleFonts.notoSansArabic(
                  fontSize: 14,
                  color: AppColors.textSub,
                ),
                textAlign: TextAlign.center,
              ).animate(delay: 220.ms).fadeIn(),

              const SizedBox(height: 4),

              Text(
                widget.phone,
                style: GoogleFonts.roboto(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                  letterSpacing: 1.4,
                ),
                textDirection: TextDirection.ltr,
              ).animate(delay: 260.ms).fadeIn(),

              // ── BYPASS MODE BANNER ──
              const SizedBox(height: 20),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline_rounded,
                        color: AppColors.primary, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'وضع التحقق المباشر نشط: استخدم الرمز 1234',
                        style: GoogleFonts.notoSansArabic(
                          fontSize: 13,
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ).animate(delay: 300.ms).fadeIn(),

              const SizedBox(height: 36),

              // PIN input
              Directionality(
                textDirection: TextDirection.ltr,
                child: PinCodeTextField(
                  appContext: context,
                  length: 4,
                  errorAnimationController: _streamCtrl,
                  animationType: AnimationType.scale,
                  pinTheme: PinTheme(
                    shape: PinCodeFieldShape.box,
                    borderRadius: BorderRadius.circular(14),
                    fieldHeight: 68,
                    fieldWidth: 64,
                    activeColor:
                        _hasError ? Colors.red.shade400 : AppColors.primary,
                    selectedColor: AppColors.primary,
                    inactiveColor: AppColors.border,
                    activeFillColor: _hasError
                        ? Colors.red.shade50
                        : AppColors.primary.withOpacity(0.05),
                    selectedFillColor: AppColors.primary.withOpacity(0.05),
                    inactiveFillColor: Colors.white,
                  ),
                  enableActiveFill: true,
                  cursorColor: AppColors.primary,
                  keyboardType: TextInputType.number,
                  textStyle: GoogleFonts.roboto(
                    fontSize: 26,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textMain,
                  ),
                  onChanged: (v) {
                    setState(() {
                      _pin = v;
                      if (_hasError) _hasError = false;
                    });
                  },
                  onCompleted: (_) => _verify(),
                ),
              ).animate(delay: 380.ms).fadeIn().slideY(begin: 0.2),

              if (_hasError) ...[
                const SizedBox(height: 4),
                Text(
                  'الرمز غير صحيح، حاول مرة أخرى',
                  style: GoogleFonts.notoSansArabic(
                    fontSize: 13,
                    color: Colors.red.shade600,
                    fontWeight: FontWeight.w600,
                  ),
                ).animate().shakeX(),
              ],

              const SizedBox(height: 28),

              // Resend section
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'لم يصلك الرمز؟ ',
                    style: GoogleFonts.notoSansArabic(
                      fontSize: 14,
                      color: AppColors.textSub,
                    ),
                  ),
                  if (_secondsLeft > 0)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _timerStr,
                        style: GoogleFonts.roboto(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                    )
                  else
                    GestureDetector(
                      onTap: _resend,
                      child: Text(
                        'إعادة الإرسال',
                        style: GoogleFonts.notoSansArabic(
                          fontSize: 14,
                          color: AppColors.primary,
                          fontWeight: FontWeight.w700,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                ],
              ).animate(delay: 460.ms).fadeIn(),

              const SizedBox(height: 36),

              // Verify button
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
                            width: 26,
                            height: 26,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2.5,
                            ),
                          ),
                        ),
                      )
                    : ElevatedButton.icon(
                        onPressed: _pin.length == 4 ? _verify : null,
                        icon: const Icon(Icons.check_circle_outline_rounded,
                            size: 22),
                        label: const Text('تحقق ومتابعة'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _pin.length == 4
                              ? AppColors.primary
                              : AppColors.primary.withOpacity(0.4),
                        ),
                      ),
              ).animate(delay: 520.ms).fadeIn().slideY(begin: 0.2),

              const SizedBox(height: 20),

              Text.rich(
                TextSpan(
                  style: GoogleFonts.notoSansArabic(
                      fontSize: 12, color: AppColors.textSub),
                  children: [
                    const TextSpan(text: 'هل تواجه مشكلة؟ '),
                    TextSpan(
                      text: 'تواصل مع الدعم الفني',
                      style: GoogleFonts.notoSansArabic(
                        color: AppColors.primary,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ],
                ),
              ).animate(delay: 600.ms).fadeIn(),
            ],
          ),
        ),
      ),
    );
  }
}
