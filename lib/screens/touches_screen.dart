import 'package:flutter/material.dart';
import '../touch_tracker.dart';

class TouchesScreen extends StatefulWidget {
  final TouchTracker tracker;
  const TouchesScreen({required this.tracker, super.key});

  @override
  State<TouchesScreen> createState() => _TouchesScreenState();
}

class _TouchesScreenState extends State<TouchesScreen> {
  List<Map<String, dynamic>> _touches = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final data = await widget.tracker.getLatestTouches(50);
    if (mounted) setState(() => _touches = data);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Registro de Toques')),
      floatingActionButton: FloatingActionButton(
        onPressed: _load,
        child: const Icon(Icons.refresh),
      ),
      body: _touches.isEmpty
          ? const Center(child: Text('No hay toques registrados aún.'))
          : ListView.builder(
              itemCount: _touches.length,
              itemBuilder: (ctx, i) {
                final t = _touches[i];
                return ListTile(
                  leading: const Icon(Icons.fingerprint),
                  title: Text('App: ${t['package']}'),
                  subtitle: Text('X: ${t['x']}, Y: ${t['y']}\n${DateTime.fromMillisecondsSinceEpoch(t['timestamp'])}'),
                  isThreeLine: true,
                );
              },
            ),
    );
  }
}
