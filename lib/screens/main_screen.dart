import 'package:flutter/material.dart';
import '../touch_tracker.dart';
import 'touches_screen.dart';
import 'heatmap_screen.dart';
import 'settings_screen.dart';

class MainScreen extends StatefulWidget {
  final TouchTracker tracker;
  const MainScreen({required this.tracker, super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with WidgetsBindingObserver {
  int _currentIndex = 0;
  late List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _screens = [
      TouchesScreen(tracker: widget.tracker),
      HeatmapScreen(tracker: widget.tracker),
      SettingsScreen(tracker: widget.tracker),
    ];
    _checkPermission();
    widget.tracker.startListening();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkPermission();
    }
  }

  Future<void> _checkPermission() async {
    final enabled = await widget.tracker.isAccessibilityEnabled();
    if (!enabled) {
      if (_currentIndex != 2) {
        setState(() {
          _currentIndex = 2;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Se requieren permisos de accesibilidad.'),
              duration: Duration(seconds: 3),
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() => _currentIndex = index);
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.touch_app),
            label: 'Toques',
          ),
          NavigationDestination(
            icon: Icon(Icons.map),
            label: 'Mapa de Calor',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings),
            label: 'Ajustes',
          ),
        ],
      ),
    );
  }
}
