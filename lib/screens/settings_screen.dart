import 'package:flutter/material.dart';
import '../touch_tracker.dart';

class SettingsScreen extends StatefulWidget {
  final TouchTracker tracker;
  const SettingsScreen({required this.tracker, super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> with WidgetsBindingObserver {
  bool _isServiceEnabled = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkStatus();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkStatus();
    }
  }

  Future<void> _checkStatus() async {
    final enabled = await widget.tracker.isAccessibilityEnabled();
    if (mounted) setState(() => _isServiceEnabled = enabled);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ajustes')),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          Card(
            color: _isServiceEnabled ? Colors.green.shade100 : Colors.red.shade100,
            child: ListTile(
              leading: Icon(
                _isServiceEnabled ? Icons.check_circle : Icons.error,
                color: _isServiceEnabled ? Colors.green : Colors.red,
              ),
              title: const Text('Servicio de Accesibilidad'),
              subtitle: Text(_isServiceEnabled 
                ? 'El servicio está activo y registrando toques.' 
                : 'El servicio está inactivo. La app no puede registrar toques.'),
            ),
          ),
          const SizedBox(height: 20),
          if (!_isServiceEnabled)
            ElevatedButton.icon(
              onPressed: () async {
                await widget.tracker.openAccessibilitySettings();
              },
              icon: const Icon(Icons.settings_accessibility),
              label: const Text('Activar Permisos en Ajustes'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(16),
                backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              ),
            ),
          const SizedBox(height: 20),
          const Divider(),
          const ListTile(
            title: Text('Acerca de'),
            subtitle: Text('Touch Heatmap Tracker v1.0'),
          ),
        ],
      ),
    );
  }
}
