import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class SmartConfigService {
  static const String _prefsKey = 'smart_config_settings';

  Future<SmartConfigSettings> calculateSettings({
    required int totalRAMGB,
    required String chipset,
    required double refreshRate,
  }) async {
    SmartConfigSettings settings;

    if (totalRAMGB <= 4) {
      settings = _calculateLowEnd(totalRAMGB, refreshRate);
    } else if (totalRAMGB <= 8) {
      settings = _calculateMidEnd(totalRAMGB, refreshRate, chipset);
    } else {
      settings = _calculateHighEnd(totalRAMGB, refreshRate, chipset);
    }

    await _saveSettings(settings);
    return settings;
  }

  SmartConfigSettings _calculateLowEnd(int ramGB, double refreshRate) {
    final baseSensitivity = 97;

    return SmartConfigSettings(
      deviceTier: 'Low-End',
      recommendedGraphics: 'Smooth',
      generalSensitivity: baseSensitivity,
      redDotSensitivity: baseSensitivity + 2,
      x2ScopeSensitivity: baseSensitivity - 3,
      x4ScopeSensitivity: baseSensitivity - 5,
      graphicQuality: 'Low',
      fpsLimit: refreshRate >= 90 ? '90' : '60',
      hdResolution: false,
      antiAliasing: false,
      effectsQuality: 'Off',
    );
  }

  SmartConfigSettings _calculateMidEnd(
    int ramGB,
    double refreshRate,
    String chipset,
  ) {
    int baseSensitivity;
    String graphics;

    if (chipset.contains('Snapdragon') && refreshRate >= 90) {
      baseSensitivity = 88;
      graphics = 'Standard';
    } else {
      baseSensitivity = 90;
      graphics = 'Balanced';
    }

    return SmartConfigSettings(
      deviceTier: 'Mid-End',
      recommendedGraphics: graphics,
      generalSensitivity: baseSensitivity,
      redDotSensitivity: baseSensitivity + 3,
      x2ScopeSensitivity: baseSensitivity - 2,
      x4ScopeSensitivity: baseSensitivity - 4,
      graphicQuality: 'Medium',
      fpsLimit: refreshRate >= 120 ? '120' : (refreshRate >= 90 ? '90' : '60'),
      hdResolution: false,
      antiAliasing: true,
      effectsQuality: 'Low',
    );
  }

  SmartConfigSettings _calculateHighEnd(
    int ramGB,
    double refreshRate,
    String chipset,
  ) {
    int baseSensitivity;
    String graphics;

    if (chipset.contains('Snapdragon 8') || chipset.contains('Exynos 2')) {
      baseSensitivity = 78;
      graphics = 'Ultra';
    } else {
      baseSensitivity = 82;
      graphics = 'High';
    }

    return SmartConfigSettings(
      deviceTier: 'High-End',
      recommendedGraphics: graphics,
      generalSensitivity: baseSensitivity,
      redDotSensitivity: baseSensitivity + 4,
      x2ScopeSensitivity: baseSensitivity - 1,
      x4ScopeSensitivity: baseSensitivity - 3,
      graphicQuality: 'High',
      fpsLimit: '120',
      hdResolution: true,
      antiAliasing: true,
      effectsQuality: 'Medium',
    );
  }

  Future<void> _saveSettings(SmartConfigSettings settings) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefsKey, jsonEncode(settings.toJson()));
    } catch (e) {}
  }

  Future<SmartConfigSettings?> loadSavedSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final json = prefs.getString(_prefsKey);
      if (json != null) {
        return SmartConfigSettings.fromJson(jsonDecode(json));
      }
    } catch (e) {}
    return null;
  }

  Future<void> clearSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_prefsKey);
    } catch (e) {}
  }

  List<ProTip> getProTips(String deviceTier) {
    return [
      ProTip(
        icon: '📡',
        title: 'Reduce Network Lag',
        description:
            'Turn off auto-sync and close background apps while gaming for lower ping.',
      ),
      ProTip(
        icon: '🔋',
        title: 'Battery Optimization',
        description:
            'Enable battery saver mode before gaming to prevent thermal throttling.',
      ),
      ProTip(
        icon: '🌡️',
        title: 'Temperature Control',
        description:
            deviceTier == 'Low-End'
                ? 'Avoid extended gaming sessions to prevent lag spikes.'
                : 'Use a cooling fan for sustained performance in long matches.',
      ),
      ProTip(
        icon: '📱',
        title: 'DPI Sync',
        description:
            'Match your in-game DPI with system DPI for consistent aim accuracy.',
      ),
      ProTip(
        icon: '🎯',
        title: 'Crosshair Positioning',
        description:
            'Enable the overlay and position it 1% larger than game buttons for perfect alignment.',
      ),
    ];
  }
}

class SmartConfigSettings {
  final String deviceTier;
  final String recommendedGraphics;
  final int generalSensitivity;
  final int redDotSensitivity;
  final int x2ScopeSensitivity;
  final int x4ScopeSensitivity;
  final String graphicQuality;
  final String fpsLimit;
  final bool hdResolution;
  final bool antiAliasing;
  final String effectsQuality;

  SmartConfigSettings({
    required this.deviceTier,
    required this.recommendedGraphics,
    required this.generalSensitivity,
    required this.redDotSensitivity,
    required this.x2ScopeSensitivity,
    required this.x4ScopeSensitivity,
    required this.graphicQuality,
    required this.fpsLimit,
    required this.hdResolution,
    required this.antiAliasing,
    required this.effectsQuality,
  });

  Map<String, dynamic> toJson() => {
    'deviceTier': deviceTier,
    'recommendedGraphics': recommendedGraphics,
    'generalSensitivity': generalSensitivity,
    'redDotSensitivity': redDotSensitivity,
    'x2ScopeSensitivity': x2ScopeSensitivity,
    'x4ScopeSensitivity': x4ScopeSensitivity,
    'graphicQuality': graphicQuality,
    'fpsLimit': fpsLimit,
    'hdResolution': hdResolution,
    'antiAliasing': antiAliasing,
    'effectsQuality': effectsQuality,
  };

  factory SmartConfigSettings.fromJson(Map<String, dynamic> json) {
    return SmartConfigSettings(
      deviceTier: json['deviceTier'] as String? ?? 'Unknown',
      recommendedGraphics: json['recommendedGraphics'] as String? ?? 'Standard',
      generalSensitivity: json['generalSensitivity'] as int? ?? 85,
      redDotSensitivity: json['redDotSensitivity'] as int? ?? 88,
      x2ScopeSensitivity: json['x2ScopeSensitivity'] as int? ?? 82,
      x4ScopeSensitivity: json['x4ScopeSensitivity'] as int? ?? 80,
      graphicQuality: json['graphicQuality'] as String? ?? 'Medium',
      fpsLimit: json['fpsLimit'] as String? ?? '60',
      hdResolution: json['hdResolution'] as bool? ?? false,
      antiAliasing: json['antiAliasing'] as bool? ?? false,
      effectsQuality: json['effectsQuality'] as String? ?? 'Low',
    );
  }

  List<ApplyGuideItem> getApplyGuideItems() {
    return [
      ApplyGuideItem(
        step: 1,
        title: 'Graphics Settings',
        settings: [
          '${graphicQuality} Graphics',
          '${effectsQuality} Effects',
          if (antiAliasing) 'Anti-Aliasing: ON' else 'Anti-Aliasing: OFF',
          if (hdResolution) 'HD Resolution: ON' else 'HD Resolution: OFF',
        ],
      ),
      ApplyGuideItem(
        step: 2,
        title: 'FPS Limit',
        settings: ['Set FPS to: $fpsLimit'],
      ),
      ApplyGuideItem(
        step: 3,
        title: 'Sensitivity Settings',
        settings: [
          'General: $generalSensitivity',
          'Red Dot: $redDotSensitivity',
          '2x Scope: $x2ScopeSensitivity',
          '4x Scope: $x4ScopeSensitivity',
        ],
      ),
    ];
  }
}

class ApplyGuideItem {
  final int step;
  final String title;
  final List<String> settings;

  ApplyGuideItem({
    required this.step,
    required this.title,
    required this.settings,
  });
}

class ProTip {
  final String icon;
  final String title;
  final String description;

  ProTip({required this.icon, required this.title, required this.description});
}
