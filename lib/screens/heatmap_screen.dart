import 'package:flutter/material.dart';
import '../touch_tracker.dart';
import 'heatmap_detail_screen.dart';

class HeatmapScreen extends StatefulWidget {
  final TouchTracker tracker;
  const HeatmapScreen({required this.tracker, super.key});

  @override
  State<HeatmapScreen> createState() => _HeatmapScreenState();
}

class _HeatmapScreenState extends State<HeatmapScreen> {
  List<String> _packages = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadPackages();
  }

  Future<void> _loadPackages() async {
    setState(() => _loading = true);
    final packages = await widget.tracker.getUniquePackages();
    if (mounted) {
      setState(() {
        _packages = packages;
        _loading = false;
      });
    }
  }

  void _openHeatmap(BuildContext context, String? package) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => HeatmapDetailScreen(
          tracker: widget.tracker,
          package: package,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Seleccionar App'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadPackages,
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              children: [
                ListTile(
                  leading: const Icon(Icons.layers),
                  title: const Text('Todas las aplicaciones'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _openHeatmap(context, null),
                ),
                const Divider(),
                if (_packages.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text('No hay aplicaciones registradas aún.'),
                  ),
                ..._packages.map((pkg) => ListTile(
                      leading: const Icon(Icons.android),
                      title: Text(pkg),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => _openHeatmap(context, pkg),
                    )),
              ],
            ),
    );
  }
}
