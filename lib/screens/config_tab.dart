import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:device_info_plus/device_info_plus.dart';
import '../utils/constants.dart';
import '../widgets/cyber_card.dart';

class ConfigTab extends StatefulWidget {
  const ConfigTab({super.key});

  @override
  State<ConfigTab> createState() => _ConfigTabState();
}

class _ConfigTabState extends State<ConfigTab> {
  String _deviceBrand = 'Unknown';
  String _deviceModel = 'Unknown';
  int _recommendedDpi = 460;
  double _sensitivity = 1.0;
  final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();

  @override
  void initState() {
    super.initState();
    _loadDeviceInfo();
  }

  Future<void> _loadDeviceInfo() async {
    try {
      final androidInfo = await _deviceInfo.androidInfo;
      setState(() {
        _deviceBrand = androidInfo.manufacturer.toLowerCase();
        _deviceModel = androidInfo.model;
        _recommendedDpi = _getDpiForBrand(_deviceBrand);
      });
    } catch (e) {
      setState(() {
        _deviceBrand = 'samsung';
        _deviceModel = 'Simulator';
        _recommendedDpi = 460;
      });
    }
  }

  int _getDpiForBrand(String brand) {
    final dpiMap = {
      'xiaomi': 490,
      'redmi': 490,
      'poco': 490,
      'samsung': 460,
      'vivo': 450,
      'realme': 400,
      'oppo': 390,
      'oneplus': 480,
      'asus': 480,
    };
    for (final entry in dpiMap.entries) {
      if (brand.contains(entry.key)) {
        return entry.value;
      }
    }
    return 460;
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const SizedBox(height: 20),
          _buildDeviceInfoCard(),
          const SizedBox(height: 24),
          _buildDpiSlider(),
          const SizedBox(height: 24),
          _buildSensitivitySlider(),
          const SizedBox(height: 24),
          _buildSmartConfigButton(),
        ],
      ),
    );
  }

  Widget _buildDeviceInfoCard() {
    return CyberCard(
      child: Column(
        children: [
          const Row(
            children: [
              Icon(
                Ionicons.phone_portrait,
                color: AppColors.electricBlue,
                size: 20,
              ),
              SizedBox(width: 8),
              Text(
                'DEVICE INFO',
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
          _buildInfoRow('Brand', _deviceBrand.toUpperCase()),
          _buildInfoRow('Model', _deviceModel),
          _buildInfoRow('Recommended DPI', '$_recommendedDpi'),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(color: AppColors.gray, fontSize: 14),
          ),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.white,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDpiSlider() {
    return CyberCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Ionicons.resize, color: AppColors.neonPurple, size: 20),
              SizedBox(width: 8),
              Text(
                'DPI SETTINGS',
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('300', style: TextStyle(color: AppColors.gray)),
              Text(
                '${_recommendedDpi.toInt()} DPI',
                style: const TextStyle(
                  color: AppColors.electricBlue,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Text('600', style: TextStyle(color: AppColors.gray)),
            ],
          ),
          Slider(
            value: _recommendedDpi.toDouble(),
            min: 300,
            max: 600,
            divisions: 60,
            activeColor: AppColors.neonPurple,
            inactiveColor: AppColors.darkGray2,
            onChanged: (value) {
              setState(() {
                _recommendedDpi = value.toInt();
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSensitivitySlider() {
    return CyberCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Ionicons.speedometer, color: AppColors.neonPink, size: 20),
              SizedBox(width: 8),
              Text(
                'SENSITIVITY',
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Low', style: TextStyle(color: AppColors.gray)),
              Text(
                '${_sensitivity.toStringAsFixed(1)}x',
                style: const TextStyle(
                  color: AppColors.neonPink,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Text('High', style: TextStyle(color: AppColors.gray)),
            ],
          ),
          Slider(
            value: _sensitivity,
            min: 0.5,
            max: 2.0,
            divisions: 15,
            activeColor: AppColors.neonPink,
            inactiveColor: AppColors.darkGray2,
            onChanged: (value) {
              setState(() {
                _sensitivity = value;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSmartConfigButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: () {
          _showDpiGuide();
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.neonPurple,
          foregroundColor: AppColors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Ionicons.settings, size: 24),
            SizedBox(width: 12),
            Text(
              'SMART CONFIG',
              style: TextStyle(
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

  void _showDpiGuide() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.darkGray,
        title: const Text(
          'DPI Settings Guide',
          style: TextStyle(color: AppColors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'To change DPI in Free Fire:',
              style: TextStyle(
                color: AppColors.electricBlue,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 12),
            Text(
              '1. Open Free Fire Settings',
              style: TextStyle(color: AppColors.white),
            ),
            Text('2. Go to Graphics', style: TextStyle(color: AppColors.white)),
            Text(
              '3. Find DPI option',
              style: TextStyle(color: AppColors.white),
            ),
            Text(
              '4. Set recommended: $_recommendedDpi',
              style: TextStyle(color: AppColors.white),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Got it',
              style: TextStyle(color: AppColors.electricBlue),
            ),
          ),
        ],
      ),
    );
  }
}
