import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import '../utils/constants.dart';
import '../widgets/cyber_card.dart';

class ToolsTab extends StatefulWidget {
  const ToolsTab({super.key});

  @override
  State<ToolsTab> createState() => _ToolsTabState();
}

class _ToolsTabState extends State<ToolsTab> {
  bool _overlayEnabled = false;
  bool _crosshairLocked = false;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const SizedBox(height: 20),
          _buildOverlayToggle(),
          const SizedBox(height: 24),
          _buildCrosshairSection(),
          const SizedBox(height: 24),
          _buildJoystickSection(),
          const SizedBox(height: 24),
          _buildAimLockSection(),
        ],
      ),
    );
  }

  Widget _buildOverlayToggle() {
    return CyberCard(
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.electricBlue.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Ionicons.layers,
              color: AppColors.electricBlue,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'OVERLAY',
                  style: TextStyle(
                    color: AppColors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Enable floating game overlay',
                  style: TextStyle(color: AppColors.gray, fontSize: 12),
                ),
              ],
            ),
          ),
          Switch(
            value: _overlayEnabled,
            onChanged: (value) {
              setState(() {
                _overlayEnabled = value;
              });
            },
            activeTrackColor: AppColors.electricBlue,
            thumbColor: WidgetStateProperty.all(AppColors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildCrosshairSection() {
    return CyberCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Ionicons.shield, color: AppColors.neonPurple, size: 20),
              SizedBox(width: 8),
              Text(
                'CROSSHAIR',
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
          Center(
            child: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color:
                      _crosshairLocked
                          ? AppColors.neonPink
                          : AppColors.neonPurple,
                  width: 3,
                ),
              ),
              child: const Icon(Ionicons.add, color: AppColors.white, size: 24),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                setState(() {
                  _crosshairLocked = !_crosshairLocked;
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    _crosshairLocked ? AppColors.neonPink : AppColors.darkGray2,
              ),
              child: Text(
                _crosshairLocked ? 'LOCKED TO FIRE' : 'LOCK TO FIRE BTN',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildJoystickSection() {
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
                'JOYSTICK',
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
          const Text(
            'Virtual joystick for camera control',
            style: TextStyle(color: AppColors.gray),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _buildJoystickPosition('LEFT', Icons.arrow_back)),
              const SizedBox(width: 12),
              Expanded(
                child: _buildJoystickPosition('RIGHT', Icons.arrow_forward),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildJoystickPosition(String label, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.darkGray2,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: AppColors.gray),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(color: AppColors.gray, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildAimLockSection() {
    return CyberCard(
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.neonPurple.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Ionicons.navigate,
              color: AppColors.neonPurple,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'AIM LOCK',
                  style: TextStyle(
                    color: AppColors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Auto aim assist toggle',
                  style: TextStyle(color: AppColors.gray, fontSize: 12),
                ),
              ],
            ),
          ),
          Switch(
            value: false,
            onChanged: (value) {},
            activeTrackColor: AppColors.neonPurple,
            thumbColor: WidgetStateProperty.all(AppColors.white),
          ),
        ],
      ),
    );
  }
}
