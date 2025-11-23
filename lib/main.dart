import 'package:flutter/material.dart';
import 'touch_tracker.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final tracker = TouchTracker();
  await tracker.init();
  runApp(MyApp(tracker: tracker));
}

class MyApp extends StatelessWidget {
  final TouchTracker tracker;
  const MyApp({required this.tracker, super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomePage(tracker: tracker),
    );
  }
}

class HomePage extends StatefulWidget {
  final TouchTracker tracker;
  const HomePage({required this.tracker, super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Map<String, dynamic>> _touches = [];

  @override
  void initState() {
    super.initState();
    widget.tracker.startListening();
    _load();
  }

  Future<void> _load() async {
    final data = await widget.tracker.getLatestTouches(50);
    setState(() => _touches = data);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Heatmap Tracker')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              onPressed: () async {
                await widget.tracker.openAccessibilitySettings();
              },
              child: const Text('Abrir ajustes de accesibilidad'),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              onPressed: _load,
              child: const Text('Refrescar datos'),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _touches.length,
              itemBuilder: (ctx, i) {
                final t = _touches[i];
                return ListTile(
                  title: Text('x:${t['x']}  y:${t['y']}'),
                  subtitle: Text('${t['package']}  ${t['timestamp']}'),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
