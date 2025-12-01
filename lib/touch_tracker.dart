import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class TouchTracker {
  static const _methodChannel = MethodChannel('com.heatmap.tracker/methods');
  static const _eventChannel  = EventChannel('com.heatmap.tracker/events');

  Database? _db;

  Future<void> init() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'touches.db');

    _db = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE touches(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            x INTEGER,
            y INTEGER,
            width INTEGER,
            height INTEGER,
            left_pos INTEGER,
            top_pos INTEGER,
            package TEXT,
            component TEXT,
            view_id TEXT,
            timestamp INTEGER
          );
        ''');
      },
    );
  }

  Future<void> openAccessibilitySettings() async {
    await _methodChannel.invokeMethod('openAccessibilitySettings');
  }

  Future<bool> isAccessibilityEnabled() async {
    try {
      final bool result = await _methodChannel.invokeMethod('isAccessibilityEnabled');
      return result;
    } on PlatformException {
      return false;
    }
  }

  Future<Size> getScreenResolution() async {
    try {
      final Map result = await _methodChannel.invokeMethod('getScreenResolution');
      return Size(
        (result['width'] as int).toDouble(),
        (result['height'] as int).toDouble(),
      );
    } catch (e) {
      return Size.zero;
    }
  }

  Future<void> startListening() async {
    _eventChannel.receiveBroadcastStream().listen((event) async {
      final data = Map<String, dynamic>.from(event as Map);
      await _saveTouch(data);
    }, onError: (e) {
      // manejar errores
      debugPrint("Error receiving touch event: $e");
    });
  }

  Future<void> _saveTouch(Map<String, dynamic> data) async {
    await _db?.insert('touches', {
      'x': data['x'],
      'y': data['y'],
      'width': data['element_width'],
      'height': data['element_height'],
      'left_pos': data['element_left'],
      'top_pos': data['element_top'],
      'package': data['package'],
      'component': data['component_type'],
      'view_id': data['view_id'],
      'timestamp': data['timestamp'],
    });
  }

  Future<List<Map<String, dynamic>>> getLatestTouches(int limit) async {
    return await _db?.query(
          'touches',
          orderBy: 'timestamp DESC',
          limit: limit,
        ) ??
        [];
  }

  Future<List<Map<String, dynamic>>> getAllTouches({String? package}) async {
    if (package != null && package.isNotEmpty) {
      return await _db?.query(
            'touches',
            where: 'package = ?',
            whereArgs: [package],
          ) ??
          [];
    }
    return await _db?.query('touches') ?? [];
  }

  Future<List<String>> getUniquePackages() async {
    final result = await _db?.rawQuery('SELECT DISTINCT package FROM touches');
    return result?.map((e) => e['package'] as String).toList() ?? [];
  }
}

