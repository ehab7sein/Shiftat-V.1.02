import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shiftat/core/router/app_routes.dart';
import 'package:shiftat/core/theme/app_theme.dart';

class ProfileSetupScreen extends StatefulWidget {
  const ProfileSetupScreen({super.key, required this.userType});
  final String userType;

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _bioCtrl = TextEditingController();
  String? _selectedCity;
  bool _loading = false;

  final List<String> _cities = [
    'القاهرة',
    'الجيزة',
    'الإسكندرية',
    'المنصورة',
    'طنطا',
    'أسيوط',
    'الأقصر',
    'أسوان',
    'بورسعيد',
    'السويس',
  ];

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _loading = true);

    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user != null) {
        await Supabase.instance.client.from('profiles').update({
          'full_name': _nameCtrl.text.trim(),
          'city': _selectedCity,
          'bio': _bioCtrl.text.trim(),
          'updated_at': DateTime.now().toIso8601String(),
        }).eq('id', user.id);

        if (mounted) {
          final route = widget.userType == 'employer'
              ? AppRoutes.employerHome
              : AppRoutes.workerHome;
          Navigator.pushNamedAndRemoveUntil(context, route, (r) => false);
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _loading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('حدث خطأ أثناء حفظ البيانات', style: GoogleFonts.notoSansArabic()),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _bioCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgLight,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'أهلاً بك في شفتات 👋',
                  style: GoogleFonts.notoSansArabic(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textMain,
                  ),
                ).animate().fadeIn().slideX(begin: 0.1),

                const SizedBox(height: 8),

                Text(
                  'لنكمل إعداد ملفك الشخصي لنتمكن من توصيلك بأفضل الفرص',
                  style: GoogleFonts.notoSansArabic(
                    fontSize: 15,
                    color: AppColors.textSub,
                  ),
                ).animate(delay: 100.ms).fadeIn(),

                const SizedBox(height: 40),

                // Avatar Placeholder
                Center(
                  child: Stack(
                    children: [
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.primary, width: 2),
                        ),
                        child: const Icon(Icons.person_rounded, 
                            size: 50, color: AppColors.primary),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.camera_alt_rounded, 
                              size: 18, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ).animate(delay: 200.ms).scale().fadeIn(),

                const SizedBox(height: 48),

                // Full Name
                Text(
                  'الاسم الكامل',
                  style: GoogleFonts.notoSansArabic(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textMain,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _nameCtrl,
                  decoration: const InputDecoration(
                    hintText: 'أدخل اسمك بالكامل',
                    prefixIcon: Icon(Icons.person_outline_rounded),
                  ),
                  validator: (v) => (v == null || v.isEmpty) ? 'يرجى إدخال الاسم' : null,
                ),

                const SizedBox(height: 24),

                // City Dropdown
                Text(
                  'المدينة / المحافظة',
                  style: GoogleFonts.notoSansArabic(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textMain,
                  ),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: _selectedCity,
                  items: _cities.map((city) => DropdownMenuItem(
                    value: city,
                    child: Text(city, style: GoogleFonts.notoSansArabic(fontSize: 14)),
                  )).toList(),
                  onChanged: (v) => setState(() => _selectedCity = v),
                  decoration: const InputDecoration(
                    hintText: 'اختر مدينتك',
                    prefixIcon: Icon(Icons.location_on_outlined),
                  ),
                  validator: (v) => v == null ? 'يرجى اختيار المدينة' : null,
                  icon: const Icon(Icons.keyboard_arrow_down_rounded),
                  dropdownColor: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),

                const SizedBox(height: 24),

                // Bio
                Text(
                  'نبذة قصيرة (اختياري)',
                  style: GoogleFonts.notoSansArabic(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textMain,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _bioCtrl,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    hintText: 'تحدث عن خبرتك أو ما تبحث عنه...',
                    contentPadding: EdgeInsets.all(16),
                  ),
                ),

                const SizedBox(height: 48),

                // Submit Button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _loading ? null : _saveProfile,
                    child: _loading 
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('حفظ ومتابعة'),
                  ),
                ).animate(delay: 400.ms).fadeIn(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
