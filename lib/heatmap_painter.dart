import 'package:flutter/material.dart';

class HeatmapPainter extends CustomPainter {
  final List<Map<String, dynamic>> points;

  HeatmapPainter(this.points);

  @override
  void paint(Canvas canvas, Size size) {
    // Usamos un color con muy baja opacidad.
    // Al superponerse muchos círculos, el color se volverá más intenso (efecto mapa de calor).
    final paint = Paint()
      ..color = Colors.red.withOpacity(0.05) 
      ..style = PaintingStyle.fill;

    for (var point in points) {
      if (point['x'] != null && point['y'] != null) {
        double x = (point['x'] as num).toDouble();
        double y = (point['y'] as num).toDouble();
        
        // Dibujamos un círculo suave en cada posición registrada
        // Radio de 30.0 para cubrir un área razonable del dedo
        canvas.drawCircle(Offset(x, y), 30.0, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
