import 'dart:async';
import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import '../utils/constants.dart';
import '../widgets/cyber_card.dart';
import '../services/device_info_service.dart';
import '../services/smart_config_service.dart';

class ConfigTab extends StatefulWidget {
  const ConfigTab({super.key});

  @override
  State<ConfigTab> createState() => _ConfigTabState();
}

class _ConfigTabState extends State<ConfigTab> {
  final DeviceInfoService _deviceInfoService = DeviceInfoService();
  final SmartConfigService _smartConfigService = SmartConfigService();

  DeviceInfo? _deviceInfo;
  DisplayInfo? _displayInfo;
  RefreshRateInfo? _refreshRateInfo;
  SmartConfigSettings? _savedSettings;
  bool _isLoading = true;
  bool _isCalculating = false;

  @override
  void initState() {
    super.initState();
    _loadAllData();
  }

  Future<void> _loadAllData() async {
    setState(() {
      _isLoading = true;
    });

    final results = await Future.wait([
      _deviceInfoService.getDeviceInfo(),
      _deviceInfoService.getDisplayInfo(),
      _deviceInfoService.getRefreshRate(),
    ]);

    final savedSettings = await _smartConfigService.loadSavedSettings();

    if (mounted) {
      setState(() {
        _deviceInfo = results[0] as DeviceInfo;
        _displayInfo = results[1] as DisplayInfo;
        _refreshRateInfo = results[2] as RefreshRateInfo;
        _savedSettings = savedSettings;
        _isLoading = false;
      });
    }
  }

  Future<void> _runSmartConfig() async {
    if (_deviceInfo == null) return;

    setState(() {
      _isCalculating = true;
    });

    await Future.delayed(const Duration(milliseconds: 1500));

    final settings = await _smartConfigService.calculateSettings(
      totalRAMGB: _deviceInfo!.totalRAMGB,
      chipset: _deviceInfo!.chipset,
      refreshRate: _displayInfo?.refreshRate ?? 60.0,
    );

    if (mounted) {
      setState(() {
        _savedSettings = settings;
        _isCalculating = false;
      });

      _showApplyGuide(settings);
    }
  }

  void _showApplyGuide(SmartConfigSettings settings) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _buildApplyGuideSheet(settings),
    );
  }

  Widget _buildApplyGuideSheet(SmartConfigSettings settings) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: const BoxDecoration(
        color: AppColors.darkGray,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.gray,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.neonPurple.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Ionicons.list,
                    color: AppColors.neonPurple,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                const Expanded(
                  child: Text(
                    'APPLY GUIDE',
                    style: TextStyle(
                      color: AppColors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Ionicons.close, color: AppColors.gray),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children:
                  settings.getApplyGuideItems().map((item) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.darkGray2,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 28,
                                height: 28,
                                decoration: BoxDecoration(
                                  color: AppColors.electricBlue,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Center(
                                  child: Text(
                                    '${item.step}',
                                    style: const TextStyle(
                                      color: AppColors.pitchBlack,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                item.title,
                                style: const TextStyle(
                                  color: AppColors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          ...item.settings.map(
                            (s) => Padding(
                              padding: const EdgeInsets.only(
                                left: 40,
                                bottom: 6,
                              ),
                              child: Text(
                                '• $s',
                                style: const TextStyle(
                                  color: AppColors.gray,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.electricBlue),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const SizedBox(height: 20),
          _buildDeviceIdentityCard(),
          const SizedBox(height: 24),
          _buildSmartConfigCard(),
          const SizedBox(height: 24),
          _buildProTipsCard(),
          const SizedBox(height: 24),
          _buildDpiSyncCard(),
        ],
      ),
    );
  }

  Widget _buildDeviceIdentityCard() {
    return CyberCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.electricBlue.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Ionicons.phone_portrait,
                  color: AppColors.electricBlue,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'DEVICE IDENTITY',
                style: TextStyle(
                  color: AppColors.electricBlue,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildInfoRow('Model', _deviceInfo?.model ?? 'Unknown'),
          _buildInfoRow('Brand', _deviceInfo?.brand ?? 'Unknown'),
          _buildInfoRow('Chipset', _deviceInfo?.chipset ?? 'Unknown'),
          _buildInfoRow('RAM', '${_deviceInfo?.totalRAMGB ?? 4}GB'),
          _buildInfoRow(
            'Android',
            '${_deviceInfo?.androidVersion ?? '11'} (SDK ${_deviceInfo?.sdkVersion ?? 30})',
          ),
          const Divider(color: AppColors.darkGray2, height: 24),
          Row(
            children: [
              const Icon(Ionicons.globe, color: AppColors.neonPurple, size: 18),
              const SizedBox(width: 8),
              const Text(
                'DISPLAY',
                style: TextStyle(
                  color: AppColors.neonPurple,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildInfoRow(
            'Resolution',
            '${_displayInfo?.widthPx ?? 1080}x${_displayInfo?.heightPx ?? 2400}',
          ),
          _buildInfoRow('DPI (Real)', '${_displayInfo?.densityDpi ?? 480} DPI'),
          _buildInfoRow(
            'Refresh Rate',
            _displayInfo?.refreshRateLabel ?? '60Hz',
          ),
          _buildInfoRow('Tier', _deviceInfo?.tierName ?? 'Unknown'),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(color: AppColors.gray, fontSize: 13),
          ),
          Flexible(
            child: Text(
              value,
              style: const TextStyle(
                color: AppColors.white,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.right,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSmartConfigCard() {
    return CyberCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.neonPink.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Ionicons.analytics,
                  color: AppColors.neonPink,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'SMART CONFIG',
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
          if (_savedSettings != null) ...[
            _buildSavedSettingsView(),
          ] else ...[
            const Text(
              'AI-powered settings optimized for your device.',
              style: TextStyle(color: AppColors.gray, fontSize: 13),
            ),
          ],
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _isCalculating ? null : _runSmartConfig,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.neonPink,
                foregroundColor: AppColors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child:
                  _isCalculating
                      ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            AppColors.white,
                          ),
                        ),
                      )
                      : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Ionicons.rocket, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            _savedSettings != null
                                ? 'RECALCULATE'
                                : 'CALCULATE NOW',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1,
                            ),
                          ),
                        ],
                      ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSavedSettingsView() {
    final settings = _savedSettings!;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.darkGray2,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getTierColor(
                    settings.deviceTier,
                  ).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  settings.deviceTier,
                  style: TextStyle(
                    color: _getTierColor(settings.deviceTier),
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Text(
                '${settings.graphicQuality} Graphics • ${settings.fpsLimit} FPS',
                style: const TextStyle(color: AppColors.gray, fontSize: 11),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'Sensitivity Settings',
            style: TextStyle(
              color: AppColors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildSensitivityChip('General', settings.generalSensitivity),
              _buildSensitivityChip('Red Dot', settings.redDotSensitivity),
              _buildSensitivityChip('2x', settings.x2ScopeSensitivity),
              _buildSensitivityChip('4x', settings.x4ScopeSensitivity),
            ],
          ),
          const SizedBox(height: 12),
          TextButton.icon(
            onPressed: () => _showApplyGuide(settings),
            icon: const Icon(Ionicons.list, size: 16),
            label: const Text('View Apply Guide'),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.electricBlue,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSensitivityChip(String label, int value) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(color: AppColors.gray, fontSize: 10),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.neonGreen.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            '$value',
            style: const TextStyle(
              color: AppColors.neonGreen,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }

  Color _getTierColor(String tier) {
    switch (tier) {
      case 'High-End':
        return AppColors.neonGreen;
      case 'Mid-End':
        return AppColors.electricBlue;
      default:
        return AppColors.neonPink;
    }
  }

  Widget _buildProTipsCard() {
    final tips = _smartConfigService.getProTips(
      _deviceInfo?.tierName ?? 'Low-End',
    );

    return CyberCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.neonGreen.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Ionicons.bulb,
                  color: AppColors.neonGreen,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'PRO TIPS',
                style: TextStyle(
                  color: AppColors.neonGreen,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...tips
              .take(3)
              .map(
                (tip) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(tip.icon, style: const TextStyle(fontSize: 18)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              tip.title,
                              style: const TextStyle(
                                color: AppColors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              tip.description,
                              style: const TextStyle(
                                color: AppColors.gray,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
        ],
      ),
    );
  }

  Widget _buildDpiSyncCard() {
    return CyberCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.neonPurple.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Ionicons.sync,
                  color: AppColors.neonPurple,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'DPI SYNC',
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
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.darkGray2,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Ionicons.information_circle,
                      color: AppColors.electricBlue,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Current System DPI',
                      style: TextStyle(color: AppColors.gray, fontSize: 12),
                    ),
                    const Spacer(),
                    Text(
                      '${_displayInfo?.densityDpi ?? 480} DPI',
                      style: const TextStyle(
                        color: AppColors.electricBlue,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Text(
                  'To change DPI in Developer Options:',
                  style: TextStyle(color: AppColors.white, fontSize: 13),
                ),
                const SizedBox(height: 8),
                const Text(
                  '1. Settings → Developer Options → Display size\n'
                  '2. Or use "Smallest width" setting\n'
                  '3. Match this value for consistent aim',
                  style: TextStyle(color: AppColors.gray, fontSize: 11),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
