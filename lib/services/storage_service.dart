import 'package:hive_flutter/hive_flutter.dart';

class StorageService {
  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  StorageService._internal();

  late Box _settingsBox;
  late Box _dataBox;

  Future<void> init() async {
    await Hive.initFlutter();
    _settingsBox = await Hive.openBox('settings');
    _dataBox = await Hive.openBox('data');
  }

  // Settings
  Future<void> setCrosshairPosition(double x, double y) async {
    await _settingsBox.put('crosshair_x', x);
    await _settingsBox.put('crosshair_y', y);
  }

  double getCrosshairX() =>
      _settingsBox.get('crosshair_x', defaultValue: 200.0);
  double getCrosshairY() =>
      _settingsBox.get('crosshair_y', defaultValue: 400.0);

  Future<void> setCrosshairLocked(bool locked) async {
    await _settingsBox.put('crosshair_locked', locked);
  }

  bool isCrosshairLocked() =>
      _settingsBox.get('crosshair_locked', defaultValue: false);

  Future<void> setDeviceDpi(int dpi) async {
    await _settingsBox.put('device_dpi', dpi);
  }

  int getDeviceDpi() => _settingsBox.get('device_dpi', defaultValue: 460);

  Future<void> setSensitivity(double sensitivity) async {
    await _settingsBox.put('sensitivity', sensitivity);
  }

  double getSensitivity() => _settingsBox.get('sensitivity', defaultValue: 1.0);

  Future<void> setOverlayEnabled(bool enabled) async {
    await _settingsBox.put('overlay_enabled', enabled);
  }

  bool isOverlayEnabled() =>
      _settingsBox.get('overlay_enabled', defaultValue: false);

  // Data storage
  Future<void> addNicknameToHistory(String nickname) async {
    List<String> history = getNicknameHistory();
    if (!history.contains(nickname)) {
      history.insert(0, nickname);
      if (history.length > 20) {
        history = history.sublist(0, 20);
      }
      await _dataBox.put('nickname_history', history);
    }
  }

  List<String> getNicknameHistory() {
    return List<String>.from(
      _dataBox.get('nickname_history', defaultValue: <String>[]),
    );
  }

  // Clear all data
  Future<void> clearAll() async {
    await _settingsBox.clear();
    await _dataBox.clear();
  }
}
