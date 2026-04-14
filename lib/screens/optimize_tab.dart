import 'dart:async';
import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import '../utils/constants.dart';
import '../widgets/cyber_card.dart';
import '../services/memory_optimizer.dart';
import '../services/memory_stream_service.dart';
import '../services/game_detection_service.dart';

class OptimizeTab extends StatefulWidget {
  const OptimizeTab({super.key});

  @override
  State<OptimizeTab> createState() => _OptimizeTabState();
}

class _OptimizeTabState extends State<OptimizeTab>
    with TickerProviderStateMixin {
  final MemoryStreamService _memoryStreamService = MemoryStreamService();
  final MemoryOptimizer _memoryOptimizer = MemoryOptimizer();
  final GameDetectionService _gameDetectionService = GameDetectionService();

  StreamSubscription<MemoryData>? _memorySubscription;
  MemoryData? _currentMemoryData;
  List<GameInfo> _installedGames = [];

  bool _isOptimizing = false;
  bool _isBoosted = false;
  bool _showRocketAnimation = false;
  int _freedMemory = 0;
  String _optimizationStatus = 'Ready to Boost';

  late AnimationController _rocketController;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _initServices();

    _rocketController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _pulseController.repeat(reverse: true);
  }

  void _initServices() {
    _memoryStreamService.startStreaming(intervalMs: 2000);
    _memorySubscription = _memoryStreamService.memoryStream.listen((data) {
      if (mounted) {
        setState(() {
          _currentMemoryData = data;
        });
      }
    });

    _loadInstalledGames();
  }

  Future<void> _loadInstalledGames() async {
    final games = await _gameDetectionService.getInstalledGames();
    if (mounted) {
      setState(() {
        _installedGames = games.where((g) => g.installed).toList();
      });
    }
  }

  Widget _buildBoostAnimation() {
    return AnimatedBuilder(
      animation: _rocketController,
      builder: (context, child) {
        return Transform.scale(
          scale: 0.8 + (_rocketController.value * 0.4),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 80,
                height: 120,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.electricBlue, AppColors.neonPurple],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  borderRadius: BorderRadius.circular(40),
                ),
              ),
              Positioned(
                bottom: -30,
                child: Container(
                  width: 40,
                  height: 50 + (_rocketController.value * 30),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.neonPink,
                        Colors.orange,
                        Colors.transparent,
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _triggerBoost() async {
    if (_isOptimizing || _isBoosted) return;

    setState(() {
      _isOptimizing = true;
      _optimizationStatus = 'Initializing Boost...';
      _showRocketAnimation = true;
    });

    _rocketController.forward();

    await Future.delayed(const Duration(milliseconds: 500));

    if (mounted) {
      setState(() {
        _optimizationStatus = 'Cleaning Memory...';
      });
    }

    final freed = await _memoryOptimizer.optimizeMemory();

    await Future.delayed(const Duration(milliseconds: 800));

    if (mounted) {
      setState(() {
        _isOptimizing = false;
        _isBoosted = true;
        _showRocketAnimation = false;
        _freedMemory = freed;
        _optimizationStatus = 'System Optimized!';
      });

      _rocketController.reset();
    }

    await Future.delayed(const Duration(seconds: 8));
    if (mounted) {
      setState(() {
        _isBoosted = false;
        _optimizationStatus = 'Ready to Boost';
      });
    }
  }

  @override
  void dispose() {
    _memorySubscription?.cancel();
    _memoryStreamService.dispose();
    _rocketController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const SizedBox(height: 20),
          _buildRocketBoostSection(),
          const SizedBox(height: 24),
          _buildRealTimeMemoryGauge(),
          const SizedBox(height: 24),
          _buildLiveProcessList(),
          const SizedBox(height: 24),
          _buildGameDashboard(),
        ],
      ),
    );
  }

  Widget _buildRocketBoostSection() {
    return CyberCard(
      child: Column(
        children: [
          const Text(
            '🚀 ROCKET BOOST',
            style: TextStyle(
              color: AppColors.neonPink,
              fontSize: 14,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 20),
          GestureDetector(
            onTap: _triggerBoost,
            child: AnimatedBuilder(
              animation: _pulseAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _isBoosted ? 1.0 : _pulseAnimation.value,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      if (_showRocketAnimation)
                        SizedBox(
                          width: 150,
                          height: 150,
                          child: _buildBoostAnimation(),
                        ),
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors:
                                _isBoosted
                                    ? [AppColors.neonPink, AppColors.neonPurple]
                                    : [
                                      AppColors.electricBlue,
                                      AppColors.neonPurple,
                                    ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: (_isBoosted
                                      ? AppColors.neonPink
                                      : AppColors.electricBlue)
                                  .withValues(alpha: 0.5),
                              blurRadius: 20,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                        child: Icon(
                          _isBoosted
                              ? Ionicons.checkmark
                              : _isOptimizing
                              ? Ionicons.sync
                              : Ionicons.rocket,
                          color: AppColors.white,
                          size: 48,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          Text(
            _optimizationStatus,
            style: TextStyle(
              color: _isBoosted ? AppColors.neonPink : AppColors.gray,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (_freedMemory > 0) ...[
            const SizedBox(height: 8),
            Text(
              'Freed $_freedMemory MB',
              style: const TextStyle(color: AppColors.neonGreen, fontSize: 14),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildRealTimeMemoryGauge() {
    final usage = _currentMemoryData?.usagePercent ?? 65;
    final used = _currentMemoryData?.usedMB ?? 5300;
    final total = _currentMemoryData?.totalMB ?? 8192;
    final free = _currentMemoryData?.freeMB ?? 2892;

    Color gaugeColor;
    if (usage > 85) {
      gaugeColor = AppColors.neonRed;
    } else if (usage > 70) {
      gaugeColor = AppColors.neonPink;
    } else {
      gaugeColor = AppColors.electricBlue;
    }

    return CyberCard(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '📊 REAL-TIME RAM',
                style: TextStyle(
                  color: AppColors.electricBlue,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: gaugeColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${usage}%',
                  style: TextStyle(
                    color: gaugeColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 180,
                height: 180,
                child: CircularProgressIndicator(
                  value: usage / 100,
                  strokeWidth: 14,
                  backgroundColor: AppColors.darkGray2,
                  valueColor: AlwaysStoppedAnimation<Color>(gaugeColor),
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Ionicons.trending_up,
                    color: AppColors.electricBlue,
                    size: 28,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${used}MB',
                    style: const TextStyle(
                      color: AppColors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'of ${total}MB',
                    style: const TextStyle(color: AppColors.gray, fontSize: 12),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildMemoryStatItem('Used', '${used}MB', AppColors.neonPink),
              _buildMemoryStatItem('Free', '${free}MB', AppColors.neonGreen),
              _buildMemoryStatItem(
                'Total',
                '${total}MB',
                AppColors.electricBlue,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMemoryStatItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(color: AppColors.gray, fontSize: 12),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildLiveProcessList() {
    final processes = _currentMemoryData?.runningProcesses ?? [];

    return CyberCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Ionicons.pulse, color: AppColors.neonPurple, size: 20),
              SizedBox(width: 8),
              Text(
                '⚡ LIVE PROCESSES',
                style: TextStyle(
                  color: AppColors.neonPurple,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (processes.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Text(
                  'Scanning processes...',
                  style: TextStyle(color: AppColors.gray),
                ),
              ),
            )
          else
            ...processes
                .take(6)
                .map(
                  (process) => _buildLiveProcessItem(
                    process['name']?.toString() ?? 'Unknown',
                    process['memoryMB'] as int? ?? 0,
                  ),
                ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.darkGray2,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.neonGreen,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${processes.length} processes active',
                  style: const TextStyle(color: AppColors.gray, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLiveProcessItem(String name, int memoryMB) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 24,
            decoration: BoxDecoration(
              color:
                  memoryMB > 400
                      ? AppColors.neonRed
                      : memoryMB > 200
                      ? AppColors.neonPink
                      : AppColors.neonGreen,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              name,
              style: const TextStyle(color: AppColors.white, fontSize: 14),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.darkGray2,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '${memoryMB}MB',
              style: const TextStyle(color: AppColors.gray, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGameDashboard() {
    return CyberCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Ionicons.game_controller,
                color: AppColors.neonPink,
                size: 20,
              ),
              SizedBox(width: 8),
              Text(
                '🎮 GAME LAUNCHER',
                style: TextStyle(
                  color: AppColors.neonPink,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (_installedGames.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Column(
                  children: [
                    Icon(Ionicons.football, color: AppColors.gray, size: 40),
                    SizedBox(height: 8),
                    Text(
                      'No games detected',
                      style: TextStyle(color: AppColors.gray),
                    ),
                  ],
                ),
              ),
            )
          else
            ..._installedGames.take(4).map((game) => _buildGameItem(game)),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _loadInstalledGames,
              icon: const Icon(Ionicons.refresh, size: 18),
              label: const Text('Refresh Games'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.darkGray2,
                foregroundColor: AppColors.gray,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGameItem(GameInfo game) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.neonPurple.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Ionicons.game_controller,
              color: AppColors.neonPurple,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  game.name,
                  style: const TextStyle(
                    color: AppColors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  game.package,
                  style: const TextStyle(color: AppColors.gray, fontSize: 10),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(
              Ionicons.play_circle,
              color: AppColors.neonGreen,
              size: 28,
            ),
          ),
        ],
      ),
    );
  }
}
