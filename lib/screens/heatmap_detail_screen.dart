import 'package:flutter/material.dart';
import '../touch_tracker.dart';
import '../heatmap_painter.dart';

class HeatmapDetailScreen extends StatefulWidget {
  final TouchTracker tracker;
  final String? package;

  const HeatmapDetailScreen({
    required this.tracker,
    this.package,
    super.key,
  });

  @override
  State<HeatmapDetailScreen> createState() => _HeatmapDetailScreenState();
}

class _HeatmapDetailScreenState extends State<HeatmapDetailScreen> {
  List<Map<String, dynamic>> _points = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadPoints();
  }

  Future<void> _loadPoints() async {
    final points = await widget.tracker.getAllTouches(package: widget.package);
    if (mounted) {
      setState(() {
        _points = points;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _points.isEmpty
              ? const Center(child: Text('No hay datos para mostrar.'))
              : LayoutBuilder(
                  builder: (context, constraints) {
                    return Container(
                      width: double.infinity,
                      height: double.infinity,
                      color: Colors.white,
                      child: CustomPaint(
                        painter: HeatmapPainter(_points),
                        size: Size.infinite,
                      ),
                    );
                  },
                ),
    );
  }
}
