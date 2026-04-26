import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../data/plant_repository.dart';
import '../models/plant.dart';
import 'history_screen.dart';
import 'plant_detail_screen.dart';
import 'result_screen.dart';

/// Main landing page — lets the user snap a photo, pick one from the gallery,
/// or browse the offline seed library.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _picker = ImagePicker();
  bool _busy = false;

  Future<void> _pickAndIdentify(ImageSource source) async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      final picked = await _picker.pickImage(
        source: source,
        maxWidth: 1600,
        imageQuality: 85,
      );
      if (picked == null) return;
      if (!mounted) return;
      await Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => ResultScreen(image: File(picked.path)),
        ),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('African Doctor'),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            tooltip: 'Scan history',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const HistoryScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                color: theme.colorScheme.primaryContainer,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline,
                          color: theme.colorScheme.onPrimaryContainer),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Point your camera at a single leaf on a plain '
                          'background for the best identification results.',
                          style: TextStyle(
                            color: theme.colorScheme.onPrimaryContainer,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: _busy
                    ? null
                    : () => _pickAndIdentify(ImageSource.camera),
                icon: const Icon(Icons.camera_alt_outlined, size: 28),
                label: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Text('Capture a leaf or tree',
                      style: TextStyle(fontSize: 16)),
                ),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: _busy
                    ? null
                    : () => _pickAndIdentify(ImageSource.gallery),
                icon: const Icon(Icons.photo_library_outlined),
                label: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 14),
                  child: Text('Choose from gallery'),
                ),
              ),
              const SizedBox(height: 24),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Offline library',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Expanded(child: _OfflineLibraryList()),
            ],
          ),
        ),
      ),
    );
  }
}

class _OfflineLibraryList extends StatefulWidget {
  @override
  State<_OfflineLibraryList> createState() => _OfflineLibraryListState();
}

class _OfflineLibraryListState extends State<_OfflineLibraryList> {
  // Cache the future so parent rebuilds (e.g. toggling _busy on the Home
  // screen) don't restart the load and flash a spinner.
  late final Future<List<Plant>> _plants = PlantRepository.instance.loadAll();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Plant>>(
      future: _plants,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final plants = snapshot.data!;
        return ListView.separated(
          itemCount: plants.length,
          separatorBuilder: (_, _) => const Divider(height: 1),
          itemBuilder: (context, index) {
            final p = plants[index];
            return ListTile(
              leading: const CircleAvatar(child: Icon(Icons.eco_outlined)),
              title: Text(p.displayName),
              subtitle: Text(
                p.scientificName,
                style: const TextStyle(fontStyle: FontStyle.italic),
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => PlantDetailScreen(plant: p),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}
