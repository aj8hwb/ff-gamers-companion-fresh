import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import '../utils/constants.dart';
import '../widgets/cyber_card.dart';
import '../services/memory_optimizer.dart';

class OptimizeTab extends StatefulWidget {
  const OptimizeTab({super.key});

  @override
  State<OptimizeTab> createState() => _OptimizeTabState();
}

class _OptimizeTabState extends State<OptimizeTab> {
  final MemoryOptimizer _memoryOptimizer = MemoryOptimizer();
  bool _isOptimizing = false;
  String _memoryStatus = 'Tap to analyze';

  @override
  void initState() {
    super.initState();
    _loadMemoryInfo();
  }

  Future<void> _loadMemoryInfo() async {
    final memInfo = await _memoryOptimizer.getMemoryInfo();
    if (mounted) {
      setState(() {
        _memoryStatus = '${memInfo['usedMB']}MB / ${memInfo['totalMB']}MB Used';
      });
    }
  }

  Future<void> _optimizeMemory() async {
    if (_isOptimizing) return;

    setState(() {
      _isOptimizing = true;
      _memoryStatus = 'Optimizing...';
    });

    final result = await _memoryOptimizer.optimizeMemory();

    if (mounted) {
      setState(() {
        _isOptimizing = false;
        _memoryStatus = '${result}MB Freed!';
      });
    }

    await Future.delayed(const Duration(seconds: 2));
    await _loadMemoryInfo();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const SizedBox(height: 20),
          _buildRamGauge(),
          const SizedBox(height: 32),
          _buildOptimizeButton(),
          const SizedBox(height: 32),
          _buildProcessList(),
        ],
      ),
    );
  }

  Widget _buildRamGauge() {
    return CyberCard(
      child: Column(
        children: [
          const Text(
            'RAM USAGE',
            style: TextStyle(
              color: AppColors.electricBlue,
              fontSize: 14,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 20),
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 180,
                height: 180,
                child: CircularProgressIndicator(
                  value: 0.65,
                  strokeWidth: 12,
                  backgroundColor: AppColors.darkGray2,
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    AppColors.neonPurple,
                  ),
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Ionicons.flash, color: AppColors.electricBlue, size: 40),
                  const SizedBox(height: 8),
                  Text(
                    _memoryStatus,
                    style: const TextStyle(
                      color: AppColors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOptimizeButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _isOptimizing ? null : _optimizeMemory,
        style: ElevatedButton.styleFrom(
          backgroundColor: _isOptimizing
              ? AppColors.darkGray2
              : AppColors.electricBlue,
          foregroundColor: _isOptimizing
              ? AppColors.gray
              : AppColors.pitchBlack,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(_isOptimizing ? Ionicons.sync : Ionicons.rocket, size: 24),
            const SizedBox(width: 12),
            Text(
              _isOptimizing ? 'OPTIMIZING...' : 'BOOST NOW',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProcessList() {
    return CyberCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Ionicons.list, color: AppColors.electricBlue, size: 20),
              SizedBox(width: 8),
              Text(
                'RUNNING PROCESSES',
                style: TextStyle(
                  color: AppColors.electricBlue,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildProcessItem('App Processes', '12 Running'),
          _buildProcessItem('Background Services', '3 Active'),
          _buildProcessItem('Cached Apps', '8 Cached'),
        ],
      ),
    );
  }

  Widget _buildProcessItem(String name, String status) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            name,
            style: const TextStyle(color: AppColors.white, fontSize: 14),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.darkGray2,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              status,
              style: const TextStyle(color: AppColors.gray, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}
