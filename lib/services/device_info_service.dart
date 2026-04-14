import 'package:flutter/services.dart';

class DeviceInfoService {
  static const MethodChannel _channel = MethodChannel('ff_gamers/memory');

  Future<DeviceInfo> getDeviceInfo() async {
    try {
      final result = await _channel.invokeMethod('getDeviceInfo');
      return DeviceInfo.fromMap(Map<String, dynamic>.from(result));
    } catch (e) {
      return DeviceInfo.getDefault();
    }
  }

  Future<DisplayInfo> getDisplayInfo() async {
    try {
      final result = await _channel.invokeMethod('getDisplayInfo');
      return DisplayInfo.fromMap(Map<String, dynamic>.from(result));
    } catch (e) {
      return DisplayInfo.getDefault();
    }
  }

  Future<RefreshRateInfo> getRefreshRate() async {
    try {
      final result = await _channel.invokeMethod('getRefreshRate');
      return RefreshRateInfo.fromMap(Map<String, dynamic>.from(result));
    } catch (e) {
      return RefreshRateInfo.getDefault();
    }
  }

  Future<MemoryInfo> getMemoryInfo() async {
    try {
      final result = await _channel.invokeMethod('getMemoryInfo');
      return MemoryInfo.fromMap(Map<String, dynamic>.from(result));
    } catch (e) {
      return MemoryInfo.getDefault();
    }
  }
}

class DeviceInfo {
  final String model;
  final String brand;
  final String device;
  final String hardware;
  final String processor;
  final String chipset;
  final int totalRAMGB;
  final double availableRAMGB;
  final String androidVersion;
  final int sdkVersion;

  DeviceInfo({
    required this.model,
    required this.brand,
    required this.device,
    required this.hardware,
    required this.processor,
    required this.chipset,
    required this.totalRAMGB,
    required this.availableRAMGB,
    required this.androidVersion,
    required this.sdkVersion,
  });

  factory DeviceInfo.fromMap(Map<String, dynamic> map) {
    return DeviceInfo(
      model: map['model'] as String? ?? 'Unknown',
      brand: map['brand'] as String? ?? 'Unknown',
      device: map['device'] as String? ?? 'Unknown',
      hardware: map['hardware'] as String? ?? 'Unknown',
      processor: map['processor'] as String? ?? 'Unknown',
      chipset: map['chipset'] as String? ?? 'Unknown',
      totalRAMGB: map['totalRAMGB'] as int? ?? 4,
      availableRAMGB: (map['availableRAMGB'] as num?)?.toDouble() ?? 2.0,
      androidVersion: map['androidVersion'] as String? ?? '11',
      sdkVersion: map['sdkVersion'] as int? ?? 30,
    );
  }

  factory DeviceInfo.getDefault() {
    return DeviceInfo(
      model: 'Unknown Device',
      brand: 'Unknown',
      device: 'Unknown',
      hardware: 'Unknown',
      processor: 'Unknown',
      chipset: 'Unknown',
      totalRAMGB: 4,
      availableRAMGB: 2.0,
      androidVersion: '11',
      sdkVersion: 30,
    );
  }

  String get tierName {
    if (totalRAMGB <= 4) return 'Low-End';
    if (totalRAMGB <= 8) return 'Mid-End';
    return 'High-End';
  }
}

class DisplayInfo {
  final int widthPx;
  final int heightPx;
  final int densityDpi;
  final double density;
  final double xdpi;
  final double ydpi;
  final double refreshRate;

  DisplayInfo({
    required this.widthPx,
    required this.heightPx,
    required this.densityDpi,
    required this.density,
    required this.xdpi,
    required this.ydpi,
    required this.refreshRate,
  });

  factory DisplayInfo.fromMap(Map<String, dynamic> map) {
    return DisplayInfo(
      widthPx: map['widthPx'] as int? ?? 1080,
      heightPx: map['heightPx'] as int? ?? 2400,
      densityDpi: map['densityDpi'] as int? ?? 480,
      density: (map['density'] as num?)?.toDouble() ?? 2.0,
      xdpi: (map['xdpi'] as num?)?.toDouble() ?? 480.0,
      ydpi: (map['ydpi'] as num?)?.toDouble() ?? 480.0,
      refreshRate: (map['refreshRate'] as num?)?.toDouble() ?? 60.0,
    );
  }

  factory DisplayInfo.getDefault() {
    return DisplayInfo(
      widthPx: 1080,
      heightPx: 2400,
      densityDpi: 480,
      density: 2.0,
      xdpi: 480.0,
      ydpi: 480.0,
      refreshRate: 60.0,
    );
  }

  String get refreshRateLabel {
    if (refreshRate >= 120) return '120Hz';
    if (refreshRate >= 90) return '90Hz';
    if (refreshRate >= 60) return '60Hz';
    return '${refreshRate.toInt()}Hz';
  }
}

class RefreshRateInfo {
  final double currentRefreshRate;
  final List<RefreshRateMode> supportedModes;

  RefreshRateInfo({
    required this.currentRefreshRate,
    required this.supportedModes,
  });

  factory RefreshRateInfo.fromMap(Map<String, dynamic> map) {
    final modesList = map['supportedModes'] as List<dynamic>? ?? [];
    return RefreshRateInfo(
      currentRefreshRate:
          (map['currentRefreshRate'] as num?)?.toDouble() ?? 60.0,
      supportedModes:
          modesList
              .map((m) => RefreshRateMode.fromMap(Map<String, dynamic>.from(m)))
              .toList(),
    );
  }

  factory RefreshRateInfo.getDefault() {
    return RefreshRateInfo(
      currentRefreshRate: 60.0,
      supportedModes: [
        RefreshRateMode(width: 1080, height: 2400, refreshRate: 60.0),
      ],
    );
  }
}

class RefreshRateMode {
  final int width;
  final int height;
  final double refreshRate;

  RefreshRateMode({
    required this.width,
    required this.height,
    required this.refreshRate,
  });

  factory RefreshRateMode.fromMap(Map<String, dynamic> map) {
    return RefreshRateMode(
      width: map['width'] as int? ?? 1080,
      height: map['height'] as int? ?? 2400,
      refreshRate: (map['refreshRate'] as num?)?.toDouble() ?? 60.0,
    );
  }
}

class MemoryInfo {
  final int totalMB;
  final int usedMB;
  final int freeMB;
  final int usagePercent;

  MemoryInfo({
    required this.totalMB,
    required this.usedMB,
    required this.freeMB,
    required this.usagePercent,
  });

  factory MemoryInfo.fromMap(Map<String, dynamic> map) {
    return MemoryInfo(
      totalMB: map['totalMB'] as int? ?? 4096,
      usedMB: map['usedMB'] as int? ?? 2048,
      freeMB: map['freeMB'] as int? ?? 2048,
      usagePercent: map['usagePercent'] as int? ?? 50,
    );
  }

  factory MemoryInfo.getDefault() {
    return MemoryInfo(
      totalMB: 4096,
      usedMB: 2048,
      freeMB: 2048,
      usagePercent: 50,
    );
  }
}
