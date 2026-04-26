import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/community_video.dart';
import '../models/identification_result.dart';
import '../models/plant.dart';
import '../services/cache_service.dart';
import '../services/youtube_service.dart';
import '../widgets/video_card.dart';

/// Plant detail page — shown after a successful identification or when
/// browsing the offline library.
class PlantDetailScreen extends StatefulWidget {
  const PlantDetailScreen({
    super.key,
    required this.plant,
    this.identification,
  });

  /// May be null if we could not find a seed entry for this scientific name.
  final Plant? plant;

  /// The Pl@ntNet result that led us here, if any.
  final IdentificationResult? identification;

  @override
  State<PlantDetailScreen> createState() => _PlantDetailScreenState();
}

class _PlantDetailScreenState extends State<PlantDetailScreen> {
  final _yt = YouTubeService();
  late Future<List<CommunityVideo>> _videos;

  String get _lookupName {
    return widget.plant?.scientificName ??
        widget.identification?.scientificName ??
        '';
  }

  @override
  void initState() {
    super.initState();
    _videos = _loadVideos();
  }

  @override
  void dispose() {
    _yt.close();
    super.dispose();
  }

  Future<List<CommunityVideo>> _loadVideos() async {
    final name = _lookupName;
    if (name.isEmpty) return const [];
    final slug = name.toLowerCase().replaceAll(' ', '-');
    final cache = await CacheService.instance();
    final cached = await cache.readVideos(slug);
    if (cached != null) return cached;
    final fresh = await _yt.searchForPlant(name);
    // Cache empty results too — the YouTube Data API v3 free tier is
    // 100 search.list calls/day, and re-querying for a plant that simply
    // has no matching videos would exhaust that quota quickly.
    await cache.writeVideos(slug, fresh);
    return fresh;
  }

  Future<void> _openTikTok() async {
    final uri = _yt.tikTokHashtag(_lookupName);
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    final plant = widget.plant;
    final theme = Theme.of(context);
    final title = plant?.displayName ??
        widget.identification?.scientificName ??
        'Unknown plant';
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (plant == null)
            _UnknownPlantCard(identification: widget.identification)
          else ...[
            _HeaderCard(plant: plant),
            const SizedBox(height: 16),
            _SafetyWarningCard(warnings: plant.warnings),
            const SizedBox(height: 16),
            _Section(
              icon: Icons.info_outline,
              title: 'Traditional use',
              body: plant.primaryUse,
            ),
            _Section(
              icon: Icons.local_cafe_outlined,
              title: 'Preparation',
              body: plant.preparation,
            ),
            if (plant.partUsed.isNotEmpty)
              _Section(
                icon: Icons.eco_outlined,
                title: 'Parts used',
                body: plant.partUsed.join(', '),
              ),
            if (plant.region.isNotEmpty)
              _Section(
                icon: Icons.public,
                title: 'Region',
                body: plant.region,
              ),
            if (plant.localNames.isNotEmpty)
              _Section(
                icon: Icons.translate_outlined,
                title: 'Local names',
                body: plant.localNames.entries
                    .map((e) => '${e.key}: ${e.value}')
                    .join('\n'),
              ),
            _Section(
              icon: Icons.verified_outlined,
              title: 'Verified by',
              body: plant.verifiedBy,
            ),
          ],
          const SizedBox(height: 16),
          Text('Community wisdom', style: theme.textTheme.titleMedium),
          const SizedBox(height: 4),
          Text(
            'Videos from YouTube and TikTok are community-submitted and may '
            'contain inaccurate information. Flag unsafe content.',
            style: theme.textTheme.bodySmall,
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 210,
            child: FutureBuilder<List<CommunityVideo>>(
              future: _videos,
              builder: (context, snapshot) {
                if (snapshot.connectionState != ConnectionState.done) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  // Real failure — quota exhausted, 403, offline, etc.
                  // Don't tell the user to add a key if they already have one.
                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        'Could not load community videos. Check your '
                        'network connection and try again later.',
                        style: theme.textTheme.bodyMedium,
                      ),
                    ),
                  );
                }
                final videos = snapshot.data ?? [];
                if (videos.isEmpty) {
                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        'No community videos available. Add a YOUTUBE_API_KEY '
                        'to your .env file to enable this section.',
                        style: theme.textTheme.bodyMedium,
                      ),
                    ),
                  );
                }
                return ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: videos.length,
                  itemBuilder: (_, i) => VideoCard(video: videos[i]),
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: _openTikTok,
            icon: const Icon(Icons.music_note),
            label: const Text('Browse TikTok hashtag'),
          ),
          const SizedBox(height: 24),
          Card(
            color: theme.colorScheme.surfaceContainerHighest,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Text(
                'This information is for educational purposes only and is not '
                'a substitute for professional medical advice, diagnosis, or '
                'treatment. Do not ingest any plant based solely on this app.',
                style: theme.textTheme.bodySmall,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeaderCard extends StatelessWidget {
  const _HeaderCard({required this.plant});
  final Plant plant;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              plant.scientificName,
              style: theme.textTheme.titleLarge?.copyWith(
                fontStyle: FontStyle.italic,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (plant.commonNames.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  plant.commonNames.join(', '),
                  style: theme.textTheme.bodyMedium,
                ),
              ),
            if (plant.imageHints.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                'How to recognise: ${plant.imageHints}',
                style: theme.textTheme.bodySmall,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _SafetyWarningCard extends StatelessWidget {
  const _SafetyWarningCard({required this.warnings});
  final String warnings;

  @override
  Widget build(BuildContext context) {
    if (warnings.isEmpty) return const SizedBox.shrink();
    final theme = Theme.of(context);
    return Card(
      color: theme.colorScheme.errorContainer,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.warning_amber_rounded,
                color: theme.colorScheme.onErrorContainer),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Safety warnings',
                    style: TextStyle(
                      color: theme.colorScheme.onErrorContainer,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(warnings,
                      style: TextStyle(
                        color: theme.colorScheme.onErrorContainer,
                      )),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({
    required this.icon,
    required this.title,
    required this.body,
  });

  final IconData icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: theme.textTheme.titleSmall
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

class _UnknownPlantCard extends StatelessWidget {
  const _UnknownPlantCard({required this.identification});
  final IdentificationResult? identification;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      color: theme.colorScheme.surfaceContainerHigh,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              identification?.scientificName ?? 'Unknown plant',
              style: theme.textTheme.titleLarge?.copyWith(
                fontStyle: FontStyle.italic,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (identification?.commonNames.isNotEmpty ?? false)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(identification!.commonNames.join(', ')),
              ),
            const SizedBox(height: 12),
            Text(
              'This plant was identified but is not yet in our verified '
              'medicinal database. No traditional-medicine information will be '
              'shown. Please consult a local botanist or healer.',
              style: theme.textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}
