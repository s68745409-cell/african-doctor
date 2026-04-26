import 'package:flutter/material.dart';

import '../data/plant_repository.dart';
import '../services/cache_service.dart';
import 'plant_detail_screen.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  late Future<List<String>> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<List<String>> _load() async {
    final cache = await CacheService.instance();
    return cache.readHistory();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scan history')),
      body: FutureBuilder<List<String>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'Could not load scan history.',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final items = snapshot.data!;
          if (items.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'No scans yet. Identify a plant to build up your history.',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }
          return ListView.separated(
            itemCount: items.length,
            separatorBuilder: (_, _) => const Divider(height: 1),
            itemBuilder: (context, i) {
              final name = items[i];
              return ListTile(
                leading: const Icon(Icons.history),
                title: Text(
                  name,
                  style: const TextStyle(fontStyle: FontStyle.italic),
                ),
                onTap: () async {
                  final match =
                      await PlantRepository.instance.lookup(name);
                  if (!context.mounted) return;
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      // Pass `name` as fallbackName so the detail screen
                      // still shows the original label (and loads community
                      // videos) for plants we don't have seed entries for.
                      builder: (_) => PlantDetailScreen(
                        plant: match.plant,
                        fallbackName: name,
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
