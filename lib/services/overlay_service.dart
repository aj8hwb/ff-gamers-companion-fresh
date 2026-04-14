import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OverlayService {
  static const MethodChannel _channel = MethodChannel('ff_gamers/overlay');
  static const String _prefsKey = 'overlay_settings';

  static OverlayService? _instance;
  static OverlayService get instance => _instance ??= OverlayService._();

  OverlayService._();

  bool _isActive = false;
  bool get isActive => _isActive;

  final _stateController = StreamController<bool>.broadcast();
  Stream<bool> get stateStream => _stateController.stream;

  OverlaySettings _settings = OverlaySettings.defaults();

  Future<bool> checkOverlayPermission() async {
    try {
      final result = await _channel.invokeMethod('checkOverlayPermission');
      return result as bool? ?? false;
    } catch (e) {
      return false;
    }
  }

  Future<bool> requestOverlayPermission() async {
    try {
      final result = await _channel.invokeMethod('requestOverlayPermission');
      return result as bool? ?? false;
    } catch (e) {
      return false;
    }
  }

  Future<void> startOverlay() async {
    try {
      await _channel.invokeMethod('startOverlay', {
        'x': _settings.positionX,
        'y': _settings.positionY,
        'size': _settings.size,
        'color': _settings.colorValue,
        'isLocked': _settings.isLocked,
      });
      _isActive = true;
      _stateController.add(true);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> stopOverlay() async {
    try {
      await _channel.invokeMethod('stopOverlay');
      _isActive = false;
      _stateController.add(false);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updatePosition(double x, double y) async {
    _settings.positionX = x;
    _settings.positionY = y;
    await _saveSettings();
    try {
      await _channel.invokeMethod('updatePosition', {'x': x, 'y': y});
    } catch (e) {}
  }

  Future<void> updateSize(double size) async {
    _settings.size = size;
    await _saveSettings();
    try {
      await _channel.invokeMethod('updateSize', {'size': size});
    } catch (e) {}
  }

  Future<void> updateColor(int colorValue) async {
    _settings.colorValue = colorValue;
    await _saveSettings();
    try {
      await _channel.invokeMethod('updateColor', {'color': colorValue});
    } catch (e) {}
  }

  Future<void> toggleLock() async {
    _settings.isLocked = !_settings.isLocked;
    await _saveSettings();
    try {
      await _channel.invokeMethod('toggleLock', {'locked': _settings.isLocked});
    } catch (e) {}
  }

  Future<void> loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final x = prefs.getDouble('${_prefsKey}_x');
      final y = prefs.getDouble('${_prefsKey}_y');
      final size = prefs.getDouble('${_prefsKey}_size');
      final color = prefs.getInt('${_prefsKey}_color');
      final locked = prefs.getBool('${_prefsKey}_locked');

      if (x != null && y != null) {
        _settings.positionX = x;
        _settings.positionY = y;
      }
      if (size != null) _settings.size = size;
      if (color != null) _settings.colorValue = color;
      if (locked != null) _settings.isLocked = locked;
    } catch (e) {}
  }

  Future<void> _saveSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble('${_prefsKey}_x', _settings.positionX);
      await prefs.setDouble('${_prefsKey}_y', _settings.positionY);
      await prefs.setDouble('${_prefsKey}_size', _settings.size);
      await prefs.setInt('${_prefsKey}_color', _settings.colorValue);
      await prefs.setBool('${_prefsKey}_locked', _settings.isLocked);
    } catch (e) {}
  }

  OverlaySettings get settings => _settings;

  void dispose() {
    _stateController.close();
  }
}

class OverlaySettings {
  double positionX;
  double positionY;
  double size;
  int colorValue;
  bool isLocked;

  OverlaySettings({
    required this.positionX,
    required this.positionY,
    required this.size,
    required this.colorValue,
    required this.isLocked,
  });

  factory OverlaySettings.defaults() {
    return OverlaySettings(
      positionX: 0.5,
      positionY: 0.5,
      size: 50.0,
      colorValue: 0xFF00FF88,
      isLocked: false,
    );
  }

  double get sizePercent => size / 100.0;

  double getScaledSize(double baseGameButtonSize) {
    return baseGameButtonSize * 1.01;
  }
}
