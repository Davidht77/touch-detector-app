import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:gal/gal.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
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
  final GlobalKey _globalKey = GlobalKey();
  List<Map<String, dynamic>> _points = [];
  Size _nativeResolution = Size.zero;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<File?> _generateImageFile() async {
    try {
      RenderRepaintBoundary boundary = _globalKey.currentContext!
          .findRenderObject() as RenderRepaintBoundary;
      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      final bytes = byteData!.buffer.asUint8List();

      final directory = await getTemporaryDirectory();
      final path = '${directory.path}/heatmap_${DateTime.now().millisecondsSinceEpoch}.png';
      final file = File(path);
      await file.writeAsBytes(bytes);
      return file;
    } catch (e) {
      debugPrint('Error generating image: $e');
      return null;
    }
  }

  Future<void> _saveImage() async {
    try {
      final file = await _generateImageFile();
      if (file != null) {
        await Gal.putImage(file.path);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Imagen guardada en la galería')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al guardar la imagen: $e')),
        );
      }
    }
  }

  Future<void> _shareImage() async {
    try {
      final file = await _generateImageFile();
      if (file != null) {
        await Share.shareXFiles([XFile(file.path)], text: 'Mira mi mapa de calor de toques!');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al compartir la imagen: $e')),
        );
      }
    }
  }

  Future<void> _loadData() async {
    final points = await widget.tracker.getAllTouches(package: widget.package);
    final resolution = await widget.tracker.getScreenResolution();
    
    if (mounted) {
      setState(() {
        _points = points;
        _nativeResolution = resolution;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Usamos extendBodyBehindAppBar para que el mapa ocupe toda la pantalla
      // y las coordenadas (0,0) coincidan mejor con la esquina superior.
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(widget.package ?? 'Todas las apps'),
        backgroundColor: Colors.black.withOpacity(0.3),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: _shareImage,
          ),
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: _saveImage,
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _points.isEmpty
              ? const Center(child: Text('No hay datos para mostrar.'))
              : LayoutBuilder(
                  builder: (context, constraints) {
                    return RepaintBoundary(
                      key: _globalKey,
                      child: Container(
                        width: double.infinity,
                        height: double.infinity,
                        color: Colors.white,
                        child: CustomPaint(
                          painter: HeatmapPainter(
                            _points,
                            nativeResolution: _nativeResolution,
                          ),
                          size: Size.infinite,
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
