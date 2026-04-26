import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'services/cache_service.dart';
import 'screens/disclaimer_screen.dart';
import 'screens/home_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Load env vars from the bundled asset. `.env` is the developer's real
  // file (gitignored); `.env.example` is the committed template with empty
  // placeholders and ships so fresh clones still have *some* asset to load.
  // --dart-define values are ALWAYS preferred over dotenv — see the
  // services' _readEnv helpers — so CI / production builds can skip files
  // entirely.
  try {
    await dotenv.load(fileName: '.env');
  } catch (_) {
    try {
      await dotenv.load(fileName: '.env.example');
    } catch (_) {
      // No env asset bundled. Services fall back to --dart-define.
    }
  }
  final cache = await CacheService.instance();
  runApp(AfricanDoctorApp(showDisclaimer: !cache.hasAcceptedDisclaimer));
}

class AfricanDoctorApp extends StatelessWidget {
  const AfricanDoctorApp({super.key, required this.showDisclaimer});

  final bool showDisclaimer;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'African Doctor',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2E7D32),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2E7D32),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: showDisclaimer
          ? const DisclaimerScreen(firstLaunch: true)
          : const HomeScreen(),
    );
  }
}
