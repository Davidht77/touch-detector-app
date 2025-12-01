import 'package:flutter/material.dart';

class HeatmapPainter extends CustomPainter {
  final List<Map<String, dynamic>> points;
  final Size nativeResolution;

  HeatmapPainter(this.points, {required this.nativeResolution});

  @override
  void paint(Canvas canvas, Size size) {
    // Si no tenemos resolución nativa válida, no dibujamos para evitar errores
    if (nativeResolution.width == 0 || nativeResolution.height == 0) return;

    // Calculamos el factor de escala
    // Ejemplo: Android 1080px -> Flutter 360dp => scaleX = 360 / 1080 = 0.33
    final double scaleX = size.width / nativeResolution.width;
    final double scaleY = size.height / nativeResolution.height;

    for (var point in points) {
      if (point['x'] != null && point['y'] != null) {
        // Coordenadas originales (píxeles físicos de Android)
        double rawX = (point['x'] as num).toDouble();
        double rawY = (point['y'] as num).toDouble();
        
        // Coordenadas escaladas al tamaño actual del Canvas
        double x = rawX * scaleX;
        double y = rawY * scaleY;
        
        // Generar color basado en el nombre del paquete
        final String pkg = point['package'] ?? '';
        final Color color = _getColorForPackage(pkg);

        final paint = Paint()
          ..color = color.withOpacity(0.1) 
          ..style = PaintingStyle.fill;

        canvas.drawCircle(Offset(x, y), 30.0, paint);
      }
    }
  }

  Color _getColorForPackage(String package) {
    if (package.isEmpty) return Colors.red;
    
    // Usamos el hash del string para generar un color consistente
    final int hash = package.hashCode;
    
    // Generamos componentes RGB asegurando que sean colores vibrantes
    // Usamos operaciones de bits para extraer valores del hash
    final int r = (hash & 0xFF0000) >> 16;
    final int g = (hash & 0x00FF00) >> 8;
    final int b = (hash & 0x0000FF);
    
    return Color.fromARGB(255, r, g, b);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
