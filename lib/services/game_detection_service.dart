import 'package:flutter/services.dart';

class GameDetectionService {
  static const MethodChannel _channel = MethodChannel('ff_gamers/memory');

  Future<List<GameInfo>> getInstalledGames() async {
    try {
      final result = await _channel.invokeMethod('getInstalledGames');
      final List<dynamic> games = result as List<dynamic>;

      return games
          .map(
            (game) => GameInfo(
              name: game['name'] as String,
              package: game['package'] as String,
              installed: game['installed'] as bool? ?? true,
            ),
          )
          .toList();
    } catch (e) {
      return _getSimulatedGames();
    }
  }

  Future<List<AppUsage>> getAppUsageStats() async {
    try {
      final result = await _channel.invokeMethod('getAppUsageStats');
      final List<dynamic> stats = result as List<dynamic>;

      return stats
          .map(
            (stat) => AppUsage(
              package: stat['package'] as String,
              name: stat['name'] as String,
              usageTimeMinutes: stat['usageTime'] as int? ?? 0,
              lastUsed: DateTime.fromMillisecondsSinceEpoch(
                stat['lastUsed'] as int? ?? 0,
              ),
            ),
          )
          .toList();
    } catch (e) {
      return [];
    }
  }

  List<GameInfo> _getSimulatedGames() {
    return [
      GameInfo(
        name: 'Free Fire',
        package: 'com.garena.game.codm',
        installed: true,
      ),
      GameInfo(name: 'PUBG Mobile', package: 'com.tencent.ig', installed: true),
      GameInfo(
        name: 'Call of Duty',
        package: 'com.activision.callofduty.warzone',
        installed: false,
      ),
      GameInfo(
        name: 'Genshin Impact',
        package: 'com.miHoYo.GenshinImpact',
        installed: false,
      ),
    ];
  }

  Future<bool> launchGame(String package) async {
    try {
      final result = await _channel.invokeMethod('launchGame', {
        'package': package,
      });
      return result as bool? ?? false;
    } catch (e) {
      return false;
    }
  }
}

class GameInfo {
  final String name;
  final String package;
  final bool installed;

  GameInfo({
    required this.name,
    required this.package,
    required this.installed,
  });
}

class AppUsage {
  final String package;
  final String name;
  final int usageTimeMinutes;
  final DateTime lastUsed;

  AppUsage({
    required this.package,
    required this.name,
    required this.usageTimeMinutes,
    required this.lastUsed,
  });

  String get formattedUsage {
    if (usageTimeMinutes < 60) {
      return '${usageTimeMinutes}m';
    }
    final hours = usageTimeMinutes ~/ 60;
    final mins = usageTimeMinutes % 60;
    return '${hours}h ${mins}m';
  }
}
