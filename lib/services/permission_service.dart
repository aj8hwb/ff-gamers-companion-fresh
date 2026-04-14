import 'package:flutter/services.dart';

class PermissionService {
  static const MethodChannel _channel = MethodChannel('ff_gamers/permissions');

  Future<bool> checkUsageStatsPermission() async {
    try {
      final result = await _channel.invokeMethod('checkUsageStatsPermission');
      return result as bool? ?? false;
    } catch (e) {
      return false;
    }
  }

  Future<bool> checkOverlayPermission() async {
    try {
      final result = await _channel.invokeMethod('checkOverlayPermission');
      return result as bool? ?? false;
    } catch (e) {
      return false;
    }
  }

  Future<bool> checkRootAccess() async {
    try {
      final result = await _channel.invokeMethod('checkRootAccess');
      return result as bool? ?? false;
    } catch (e) {
      return false;
    }
  }

  Future<bool> requestUsageStatsPermission() async {
    try {
      final result = await _channel.invokeMethod('requestUsageStatsPermission');
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
}
