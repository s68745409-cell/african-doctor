import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/community_video.dart';
import '../services/cache_service.dart';

class VideoCard extends StatefulWidget {
  const VideoCard({super.key, required this.video});

  final CommunityVideo video;

  @override
  State<VideoCard> createState() => _VideoCardState();
}

class _VideoCardState extends State<VideoCard> {
  int _flags = 0;
  int _upvotes = 0;
  bool _hidden = false;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final cache = await CacheService.instance();
    final flags = await cache.flagCount(widget.video.videoId);
    final upvotes = await cache.upvoteCount(widget.video.videoId);
    final hidden = await cache.isHidden(widget.video.videoId);
    if (!mounted) return;
    setState(() {
      _flags = flags;
      _upvotes = upvotes;
      _hidden = hidden;
      _loading = false;
    });
  }

  Future<void> _open() async {
    final ok = await launchUrl(
      widget.video.watchUrl,
      mode: LaunchMode.externalApplication,
    );
    if (!ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open YouTube')),
      );
    }
  }

  Future<void> _flag() async {
    final cache = await CacheService.instance();
    final next = await cache.flag(widget.video.videoId);
    if (!mounted) return;
    setState(() {
      _flags = next;
      _hidden = next >= 3;
    });
  }

  Future<void> _upvote() async {
    final cache = await CacheService.instance();
    final next = await cache.upvote(widget.video.videoId);
    if (!mounted) return;
    setState(() => _upvotes = next);
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const SizedBox(
        width: 220,
        height: 180,
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (_hidden) {
      return Container(
        width: 220,
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.errorContainer,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.visibility_off_outlined),
            const SizedBox(height: 8),
            const Text(
              'Hidden by community flags',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              '"${widget.video.title}"',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      );
    }
    return Container(
      width: 220,
      margin: const EdgeInsets.only(right: 12),
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: _open,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AspectRatio(
                aspectRatio: 16 / 9,
                child: Image.network(
                  widget.video.thumbnailUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => Container(
                    color: Colors.grey.shade300,
                    child: const Icon(Icons.broken_image),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.video.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.video.channel,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: Colors.grey.shade700, fontSize: 12),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        IconButton(
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          visualDensity: VisualDensity.compact,
                          onPressed: _upvote,
                          icon: const Icon(Icons.thumb_up_outlined, size: 18),
                        ),
                        const SizedBox(width: 4),
                        Text('$_upvotes', style: const TextStyle(fontSize: 12)),
                        const Spacer(),
                        IconButton(
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          visualDensity: VisualDensity.compact,
                          onPressed: _flag,
                          icon: const Icon(Icons.flag_outlined, size: 18),
                        ),
                        const SizedBox(width: 4),
                        Text('$_flags', style: const TextStyle(fontSize: 12)),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
