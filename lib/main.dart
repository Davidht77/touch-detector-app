import 'package:flutter/material.dart';
import 'touch_tracker.dart';
import 'screens/main_screen.dart';

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
      title: 'Touch Heatmap',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: MainScreen(tracker: tracker),
    );
  }
}
