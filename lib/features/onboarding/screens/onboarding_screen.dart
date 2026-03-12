import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:shiftat/core/router/app_routes.dart';
import 'package:shiftat/core/theme/app_theme.dart';

class _OnboardingPage {
  const _OnboardingPage({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
  });
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
}

const _pages = [
  _OnboardingPage(
    icon: Icons.search_rounded,
    title: 'ابحث عن وظيفتك بسهولة',
    subtitle: 'اكتشف الفرص القريبة منك في دقائق معدودة وابدأ مسيرتك المهنية اليوم.',
    color: Color(0xFF1C74E9),
  ),
  _OnboardingPage(
    icon: Icons.bolt_rounded,
    title: 'تقديم سريع بضغطة واحدة',
    subtitle: 'قدِّم على أي وظيفة بضغطة زر واحدة وتابع حالة طلباتك بسهولة.',
    color: Color(0xFF7C3AED),
  ),
  _OnboardingPage(
    icon: Icons.groups_rounded,
    title: 'وظِّف بسرعة وثقة',
    subtitle: 'انشر فرصة عمل في أقل من دقيقتين وتواصل مع المتقدمين المناسبين.',
    color: Color(0xFF059669),
  ),
];

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _ctrl = PageController();
  int _current = 0;

  void _next() {
    if (_current < _pages.length - 1) {
      _ctrl.nextPage(
        duration: const Duration(milliseconds: 420),
        curve: Curves.easeInOutCubic,
      );
    } else {
      Navigator.pushReplacementNamed(context, AppRoutes.userTypeSelect);
    }
  }

  void _skip() =>
      Navigator.pushReplacementNamed(context, AppRoutes.userTypeSelect);

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgLight,
      body: SafeArea(
        child: Column(
          children: [
            // Header row
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Logo mark
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.handshake_rounded,
                        color: Colors.white, size: 22),
                  ),
                  TextButton(
                    onPressed: _skip,
                    child: Text(
                      'تخطي',
                      style: GoogleFonts.notoSansArabic(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Page view
            Expanded(
              child: PageView.builder(
                controller: _ctrl,
                itemCount: _pages.length,
                onPageChanged: (i) => setState(() => _current = i),
                itemBuilder: (context, index) =>
                    _OnboardingPageView(page: _pages[index], index: index),
              ),
            ),

            // Dots + Button
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 28, vertical: 20),
              child: Column(
                children: [
                  SmoothPageIndicator(
                    controller: _ctrl,
                    count: _pages.length,
                    effect: ExpandingDotsEffect(
                      activeDotColor: _pages[_current].color,
                      dotColor: Colors.grey.shade300,
                      dotHeight: 9,
                      dotWidth: 9,
                      expansionFactor: 3.5,
                    ),
                  ),
                  const SizedBox(height: 28),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    decoration: BoxDecoration(
                      color: _pages[_current].color,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: _pages[_current].color.withOpacity(0.35),
                          blurRadius: 18,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: _next,
                        borderRadius: BorderRadius.circular(14),
                        child: Container(
                          width: double.infinity,
                          height: 56,
                          alignment: Alignment.center,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                _current < _pages.length - 1
                                    ? 'التالي'
                                    : 'ابدأ الآن',
                                style: GoogleFonts.notoSansArabic(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Icon(Icons.arrow_back_ios_new_rounded,
                                  color: Colors.white, size: 18),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'بالمتابعة أنت توافق على شروط الخدمة وسياسة الخصوصية',
                    style: GoogleFonts.notoSansArabic(
                      fontSize: 11,
                      color: AppColors.textSub,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardingPageView extends StatelessWidget {
  const _OnboardingPageView({required this.page, required this.index});
  final _OnboardingPage page;
  final int index;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Illustration circle
          Container(
            width: 220,
            height: 220,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: page.color.withOpacity(0.08),
            ),
            child: Center(
              child: Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: page.color.withOpacity(0.14),
                ),
                child: Icon(page.icon, color: page.color, size: 72),
              ),
            ),
          )
              .animate(key: ValueKey(index))
              .scale(
                begin: const Offset(0.7, 0.7),
                curve: Curves.elasticOut,
                duration: 700.ms,
              )
              .fadeIn(duration: 400.ms),

          const SizedBox(height: 40),

          Text(
            page.title,
            style: GoogleFonts.notoSansArabic(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              color: AppColors.textMain,
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          )
              .animate(key: ValueKey('t_$index'), delay: 150.ms)
              .fadeIn(duration: 500.ms)
              .slideY(begin: 0.2, curve: Curves.easeOutCubic),

          const SizedBox(height: 16),

          Text(
            page.subtitle,
            style: GoogleFonts.notoSansArabic(
              fontSize: 15,
              fontWeight: FontWeight.w400,
              color: AppColors.textSub,
              height: 1.7,
            ),
            textAlign: TextAlign.center,
          )
              .animate(key: ValueKey('s_$index'), delay: 280.ms)
              .fadeIn(duration: 500.ms)
              .slideY(begin: 0.2, curve: Curves.easeOutCubic),
        ],
      ),
    );
  }
}
