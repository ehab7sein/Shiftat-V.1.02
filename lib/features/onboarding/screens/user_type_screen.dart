import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shiftat/core/router/app_routes.dart';
import 'package:shiftat/core/theme/app_theme.dart';

class UserTypeScreen extends StatefulWidget {
  const UserTypeScreen({super.key});

  @override
  State<UserTypeScreen> createState() => _UserTypeScreenState();
}

class _UserTypeScreenState extends State<UserTypeScreen> {
  String? _selected;

  void _continue() {
    if (_selected == null) return;
    Navigator.pushNamed(
      context,
      AppRoutes.login,
      arguments: _selected,
    );
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
          'سوق العمل',
          style: GoogleFonts.notoSansArabic(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.textMain,
          ),
        ),
      ),
      body: SafeArea(
        child: Stack(
          children: [
            // Decorative blobs (subtle)
            Positioned(
              top: -40,
              right: -40,
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primary.withOpacity(0.05),
                ),
              ),
            ),
            Positioned(
              bottom: 80,
              left: -50,
              child: Container(
                width: 180,
                height: 180,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primary.withOpacity(0.04),
                ),
              ),
            ),

            Column(
              children: [
                // Heading
                Padding(
                  padding: const EdgeInsets.fromLTRB(28, 24, 28, 0),
                  child: Column(
                    children: [
                      Text(
                        'كيف تود استخدام التطبيق؟',
                        style: GoogleFonts.notoSansArabic(
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textMain,
                        ),
                        textAlign: TextAlign.center,
                      ).animate().fadeIn(duration: 500.ms).slideY(
                            begin: 0.2,
                            curve: Curves.easeOutCubic,
                          ),
                      const SizedBox(height: 10),
                      Text(
                        'اختر نوع الحساب المناسب لك للبدء',
                        style: GoogleFonts.notoSansArabic(
                          fontSize: 15,
                          color: AppColors.textSub,
                        ),
                        textAlign: TextAlign.center,
                      ).animate(delay: 100.ms).fadeIn(duration: 400.ms),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // Cards
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: [
                        _TypeCard(
                          icon: Icons.construction_rounded,
                          title: 'أنا أبحث عن عمل',
                          subtitle: 'تصفح الوظائف المتاحة وقدِّم مهاراتك',
                          value: 'worker',
                          selected: _selected,
                          delay: 200,
                          onTap: () => setState(() => _selected = 'worker'),
                        ),
                        const SizedBox(height: 16),
                        _TypeCard(
                          icon: Icons.business_center_rounded,
                          title: 'أريد توظيف شخص ما',
                          subtitle: 'انشر مشروعك وابحث عن محترفين',
                          value: 'employer',
                          selected: _selected,
                          delay: 320,
                          onTap: () => setState(() => _selected = 'employer'),
                        ),
                      ],
                    ),
                  ),
                ),

                // CTA
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                  child: Column(
                    children: [
                      AnimatedOpacity(
                        opacity: _selected != null ? 1.0 : 0.45,
                        duration: const Duration(milliseconds: 250),
                        child: ElevatedButton(
                          onPressed: _selected != null ? _continue : null,
                          child: const Text('استمرار'),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'بالنقر على استمرار، فأنت توافق على شروط الخدمة',
                        style: GoogleFonts.notoSansArabic(
                          fontSize: 11,
                          color: AppColors.textSub,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ).animate(delay: 450.ms).fadeIn(duration: 400.ms),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _TypeCard extends StatelessWidget {
  const _TypeCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.selected,
    required this.onTap,
    required this.delay,
  });
  final IconData icon;
  final String title;
  final String subtitle;
  final String value;
  final String? selected;
  final VoidCallback onTap;
  final int delay;

  bool get _isSelected => selected == value;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: _isSelected
              ? AppColors.primary.withOpacity(0.06)
              : Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: _isSelected ? AppColors.primary : AppColors.border,
            width: _isSelected ? 2.2 : 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: _isSelected
                  ? AppColors.primary.withOpacity(0.12)
                  : Colors.black.withOpacity(0.04),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary.withOpacity(_isSelected ? 0.15 : 0.08),
              ),
              child: Icon(icon,
                  color: AppColors.primary, size: 32),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.notoSansArabic(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textMain,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: GoogleFonts.notoSansArabic(
                      fontSize: 13,
                      color: AppColors.textSub,
                    ),
                  ),
                ],
              ),
            ),
            if (_isSelected)
              const Icon(Icons.check_circle_rounded,
                  color: AppColors.primary, size: 26)
                  .animate()
                  .scale(curve: Curves.elasticOut, duration: 400.ms)
                  .fadeIn(),
          ],
        ),
      ),
    )
        .animate(delay: Duration(milliseconds: delay))
        .fadeIn(duration: 400.ms)
        .slideY(begin: 0.15, curve: Curves.easeOutCubic);
  }
}
