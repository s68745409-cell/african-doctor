import 'package:flutter/material.dart';

import '../services/cache_service.dart';
import 'home_screen.dart';

/// Safety interstitial shown on first launch and every subsequent launch
/// until the user confirms they understand.
class DisclaimerScreen extends StatelessWidget {
  const DisclaimerScreen({super.key, required this.firstLaunch});

  final bool firstLaunch;

  static Future<void> _accept(BuildContext context) async {
    final cache = await CacheService.instance();
    await cache.acceptDisclaimer();
    if (!context.mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(builder: (_) => const HomeScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 24),
              Icon(Icons.local_hospital_outlined,
                  size: 72, color: theme.colorScheme.primary),
              const SizedBox(height: 16),
              Text(
                'African Doctor',
                textAlign: TextAlign.center,
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Traditional medicinal plants of Africa',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 32),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _Section(
                        icon: Icons.warning_amber_rounded,
                        color: Colors.amber.shade800,
                        title: 'This is not a medical app.',
                        body:
                            'African Doctor helps you identify plants and read '
                            'about how they are traditionally used. It is for '
                            'educational purposes only and is NOT a substitute '
                            'for professional medical advice, diagnosis or '
                            'treatment.',
                      ),
                      _Section(
                        icon: Icons.eco_outlined,
                        color: Colors.green.shade700,
                        title: 'Never eat a plant based only on this app.',
                        body:
                            'Many plants look alike. A mis-identification '
                            'can be fatal. Always confirm with a qualified '
                            'botanist, pharmacist, or experienced traditional '
                            'healer before using any plant medicinally.',
                      ),
                      _Section(
                        icon: Icons.handshake_outlined,
                        color: Colors.blue.shade700,
                        title: 'Knowledge belongs to communities.',
                        body:
                            'The information shown here is curated in '
                            'partnership with traditional healers and '
                            'botanists. It is shared for educational use; it '
                            'must not be exploited commercially without the '
                            'consent of the knowledge-holding community.',
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () => _accept(context),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text(firstLaunch ? 'I understand — continue' : 'Confirm'),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({
    required this.icon,
    required this.color,
    required this.title,
    required this.body,
  });

  final IconData icon;
  final Color color;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: theme.textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(body, style: theme.textTheme.bodyMedium),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
