import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:shiftat/core/theme/app_theme.dart';
import 'package:shiftat/core/router/app_router.dart';
import 'package:shiftat/core/router/app_routes.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Load environment variables
  try {
    await dotenv.load(fileName: ".env");
    print('✅ .env loaded: ${dotenv.env['SUPABASE_URL']}');
  } catch (e) {
    print('❌ Failed to load .env: $e');
  }

  // Initialize Supabase
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL'] ?? '',
    anonKey: dotenv.env['SUPABASE_ANON_KEY'] ?? '',
  );

  runApp(const ShiftatApp());
}

class ShiftatApp extends StatelessWidget {
  const ShiftatApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'شفتات',
      debugShowCheckedModeBanner: false,

      // RTL Arabic and Global Localizations support
      locale: const Locale('ar'),
      supportedLocales: const [Locale('ar')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      builder: (context, child) => Directionality(
        textDirection: TextDirection.rtl,
        child: child!,
      ),

      theme: AppTheme.light(),
      initialRoute: AppRoutes.splash,
      onGenerateRoute: AppRouter.generateRoute,
    );
  }
}
