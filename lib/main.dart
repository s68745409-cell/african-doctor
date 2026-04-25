import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'services/cache_service.dart';
import 'screens/disclaimer_screen.dart';
import 'screens/home_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // .env.example ships as an asset with placeholder values. To supply real
  // API keys, either edit the file locally (it is gitignored) or pass them
  // via --dart-define at build time — the services check both.
  try {
    await dotenv.load(fileName: '.env.example');
  } catch (_) {
    // ignore — the services will also look at --dart-define values.
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
