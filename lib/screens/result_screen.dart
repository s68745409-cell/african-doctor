import 'dart:io';

import 'package:flutter/material.dart';

import '../data/plant_repository.dart';
import '../models/identification_result.dart';
import '../services/cache_service.dart';
import '../services/huggingface_service.dart';
import '../utils/constants.dart';
import '../widgets/confidence_badge.dart';
import 'plant_detail_screen.dart';

/// Shows the Hugging Face identification result for a captured image and
/// routes the user into the plant-detail screen when confidence is high
/// enough.
class ResultScreen extends StatefulWidget {
  const ResultScreen({super.key, required this.image});

  final File image;

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  final _service = HuggingFaceService();
  late Future<List<IdentificationResult>> _future;

  @override
  void initState() {
    super.initState();
    _future = _service.identify(image: widget.image);
  }

  @override
  void dispose() {
    _service.close();
    super.dispose();
  }

  Future<void> _openDetail(IdentificationResult result) async {
    // Safety-critical: never open medicinal detail for a low-confidence
    // suggestion, even one chosen from the 'Other possibilities' list.
    // Surface the same refusal message the primary result shows.
    if (result.score < AppConstants.minConfidence) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Only ${result.scorePercent}% confident — please consult a '
            'local expert before using this plant.',
          ),
          duration: const Duration(seconds: 4),
        ),
      );
      return;
    }
    final cache = await CacheService.instance();
    await cache.appendHistory(result.scientificName);
    final plant = await PlantRepository.instance.lookup(result.scientificName);
    if (!mounted) return;
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => PlantDetailScreen(
          plant: plant,
          identification: result,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Identification')),
      body: FutureBuilder<List<IdentificationResult>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return _ErrorView(
              message: snapshot.error.toString(),
              onRetry: () =>
                  setState(() => _future = _service.identify(image: widget.image)),
            );
          }
          final results = snapshot.data ?? [];
          if (results.isEmpty) {
            return const _NoMatchView(
              reason:
                  'The model did not return any suggestions for this image. '
                  'Try a clearer photo of a single leaf on a plain background.',
            );
          }
          final best = results.first;
          return _ResultView(
            image: widget.image,
            best: best,
            others: results.skip(1).toList(),
            onOpen: _openDetail,
          );
        },
      ),
    );
  }
}

class _ResultView extends StatelessWidget {
  const _ResultView({
    required this.image,
    required this.best,
    required this.others,
    required this.onOpen,
  });

  final File image;
  final IdentificationResult best;
  final List<IdentificationResult> others;
  final Future<void> Function(IdentificationResult) onOpen;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final confident = best.score >= AppConstants.minConfidence;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.file(image, height: 220, fit: BoxFit.cover),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: Text(
                best.scientificName,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontStyle: FontStyle.italic,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ConfidenceBadge(score: best.score),
          ],
        ),
        if (best.commonNames.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              best.commonNames.join(', '),
              style: theme.textTheme.bodyMedium,
            ),
          ),
        const SizedBox(height: 16),
        if (confident)
          FilledButton.icon(
            onPressed: () => onOpen(best),
            icon: const Icon(Icons.menu_book_outlined),
            label: const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Text('Read traditional uses'),
            ),
          )
        else
          Card(
            color: theme.colorScheme.errorContainer,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  const Icon(Icons.warning_amber_rounded),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Could not identify with certainty '
                      '(${best.scorePercent}% confidence). '
                      'Please consult a local expert before using this plant.',
                      style: TextStyle(
                        color: theme.colorScheme.onErrorContainer,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        if (others.isNotEmpty) ...[
          const SizedBox(height: 24),
          Text('Other possibilities', style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          ...others.map(
            (r) {
              final tappable = r.score >= AppConstants.minConfidence;
              return ListTile(
                contentPadding: EdgeInsets.zero,
                enabled: tappable,
                title: Text(
                  r.scientificName,
                  style: const TextStyle(fontStyle: FontStyle.italic),
                ),
                subtitle: Text(
                  tappable
                      ? r.commonNames.join(', ')
                      : '${r.commonNames.join(', ')}  — below '
                          '${(AppConstants.minConfidence * 100).round()}% '
                          'confidence, cannot show medicinal info.',
                ),
                trailing: ConfidenceBadge(score: r.score, compact: true),
                onTap: tappable ? () => onOpen(r) : null,
              );
            },
          ),
        ],
      ],
    );
  }
}

class _NoMatchView extends StatelessWidget {
  const _NoMatchView({required this.reason});
  final String reason;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.search_off, size: 72),
            const SizedBox(height: 12),
            Text(reason, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 56),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            FilledButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }
}


