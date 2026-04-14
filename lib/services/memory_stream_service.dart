import 'dart:async';
import 'package:flutter/foundation.dart';
import 'memory_optimizer.dart';

class MemoryStreamService {
  final MemoryOptimizer _memoryOptimizer = MemoryOptimizer();
  final StreamController<MemoryData> _memoryController =
      StreamController<MemoryData>.broadcast();

  Timer? _updateTimer;
  bool _isStreaming = false;

  Stream<MemoryData> get memoryStream => _memoryController.stream;

  void startStreaming({int intervalMs = 2000}) {
    if (_isStreaming) return;
    _isStreaming = true;

    _updateTimer = Timer.periodic(Duration(milliseconds: intervalMs), (
      _,
    ) async {
      final data = await _fetchMemoryData();
      if (!_memoryController.isClosed) {
        _memoryController.add(data);
      }
    });

    _fetchMemoryData().then((data) {
      if (!_memoryController.isClosed) {
        _memoryController.add(data);
      }
    });
  }

  void stopStreaming() {
    _isStreaming = false;
    _updateTimer?.cancel();
    _updateTimer = null;
  }

  Future<MemoryData> _fetchMemoryData() async {
    try {
      final info = await _memoryOptimizer.getMemoryInfo();
      final processes = await _memoryOptimizer.getRunningProcesses();

      return MemoryData(
        totalMB: info['totalMB'] as int? ?? 0,
        usedMB: info['usedMB'] as int? ?? 0,
        freeMB: info['freeMB'] as int? ?? 0,
        usagePercent: info['usagePercent'] as int? ?? 0,
        lowMemory: info['lowMemory'] as bool? ?? false,
        threshold: info['threshold'] as int? ?? 0,
        runningProcesses: processes,
        timestamp: DateTime.now(),
      );
    } catch (e) {
      return MemoryData.getSimulated();
    }
  }

  void dispose() {
    stopStreaming();
    _memoryController.close();
  }
}

class MemoryData {
  final int totalMB;
  final int usedMB;
  final int freeMB;
  final int usagePercent;
  final bool lowMemory;
  final int threshold;
  final List<Map<String, dynamic>> runningProcesses;
  final DateTime timestamp;

  MemoryData({
    required this.totalMB,
    required this.usedMB,
    required this.freeMB,
    required this.usagePercent,
    required this.lowMemory,
    required this.threshold,
    required this.runningProcesses,
    required this.timestamp,
  });

  factory MemoryData.getSimulated() {
    return MemoryData(
      totalMB: 8192,
      usedMB: 5300,
      freeMB: 2892,
      usagePercent: 65,
      lowMemory: false,
      threshold: 1024,
      runningProcesses: [],
      timestamp: DateTime.now(),
    );
  }

  bool get isLowMemory => usagePercent > 85;
  bool get needsOptimization => usagePercent > 75;
}
