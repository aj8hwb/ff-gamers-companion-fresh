import 'dart:async';
import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import '../utils/constants.dart';
import '../widgets/cyber_card.dart';
import '../services/overlay_service.dart';

class ToolsTab extends StatefulWidget {
  const ToolsTab({super.key});

  @override
  State<ToolsTab> createState() => _ToolsTabState();
}

class _ToolsTabState extends State<ToolsTab>
    with SingleTickerProviderStateMixin {
  final OverlayService _overlayService = OverlayService.instance;
  bool _overlayEnabled = false;
  bool _crosshairLocked = false;
  bool _isLoading = false;
  StreamSubscription<bool>? _overlaySubscription;

  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _checkOverlayState();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  Future<void> _checkOverlayState() async {
    await _overlayService.loadSettings();
    _overlaySubscription = _overlayService.stateStream.listen((isActive) {
      if (mounted) {
        setState(() {
          _overlayEnabled = isActive;
        });
        if (isActive) {
          _pulseController.repeat(reverse: true);
        } else {
          _pulseController.stop();
          _pulseController.reset();
        }
      }
    });
  }

  Future<void> _toggleOverlay() async {
    setState(() {
      _isLoading = true;
    });

    try {
      if (_overlayEnabled) {
        await _overlayService.stopOverlay();
      } else {
        final hasPermission = await _overlayService.checkOverlayPermission();
        if (!hasPermission) {
          await _overlayService.requestOverlayPermission();
          setState(() {
            _isLoading = false;
          });
          return;
        }

        await _overlayService.startOverlay();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: AppColors.neonRed,
          ),
        );
      }
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    _overlaySubscription?.cancel();
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
          _buildOverlayActivationCard(),
          const SizedBox(height: 24),
          _buildOverlaySettingsCard(),
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

  Widget _buildOverlayActivationCard() {
    return CyberCard(
      child: Column(
        children: [
          Row(
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
                      'GAMING OVERLAY',
                      style: TextStyle(
                        color: AppColors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Floating crosshair while gaming',
                      style: TextStyle(color: AppColors.gray, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          GestureDetector(
            onTap: _isLoading ? null : _toggleOverlay,
            child: AnimatedBuilder(
              animation: _pulseAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _overlayEnabled ? _pulseAnimation.value : 1.0,
                  child: Container(
                    width: double.infinity,
                    height: 56,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors:
                            _overlayEnabled
                                ? [AppColors.neonPink, AppColors.neonRed]
                                : [
                                  AppColors.electricBlue,
                                  AppColors.neonPurple,
                                ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: (_overlayEnabled
                                  ? AppColors.neonPink
                                  : AppColors.electricBlue)
                              .withValues(alpha: _overlayEnabled ? 0.6 : 0.4),
                          blurRadius: _overlayEnabled ? 20 : 10,
                          spreadRadius: _overlayEnabled ? 3 : 0,
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (_isLoading)
                          const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                AppColors.white,
                              ),
                            ),
                          )
                        else ...[
                          Icon(
                            _overlayEnabled
                                ? Ionicons.close_circle
                                : Ionicons.add_circle,
                            color: AppColors.white,
                            size: 24,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            _overlayEnabled
                                ? 'DEACTIVATE OVERLAY'
                                : 'ACTIVATE GAMING OVERLAY',
                            style: const TextStyle(
                              color: AppColors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          if (_overlayEnabled) ...[
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
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
                const Text(
                  'Overlay is running - Drag the crosshair to position',
                  style: TextStyle(color: AppColors.neonGreen, fontSize: 11),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildOverlaySettingsCard() {
    if (!_overlayEnabled) return const SizedBox.shrink();

    return CyberCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Ionicons.settings, color: AppColors.electricBlue, size: 20),
              SizedBox(width: 8),
              Text(
                'OVERLAY SETTINGS',
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
          _buildSizeSlider(),
          const SizedBox(height: 16),
          _buildColorPicker(),
          const SizedBox(height: 16),
          _buildLockToggle(),
        ],
      ),
    );
  }

  Widget _buildSizeSlider() {
    final currentSize = _overlayService.settings.size;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Crosshair Size',
              style: TextStyle(color: AppColors.white, fontSize: 14),
            ),
            Text(
              '${currentSize.toInt()}px (${_getScaledSize(currentSize).toStringAsFixed(1)}px scaled)',
              style: const TextStyle(color: AppColors.gray, fontSize: 12),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: AppColors.electricBlue,
            inactiveTrackColor: AppColors.darkGray2,
            thumbColor: AppColors.electricBlue,
          ),
          child: Slider(
            value: currentSize,
            min: 20,
            max: 150,
            onChanged: (value) {
              _overlayService.updateSize(value);
            },
          ),
        ),
        const Text(
          '1% larger than game button for perfect alignment',
          style: TextStyle(
            color: AppColors.gray,
            fontSize: 10,
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    );
  }

  double _getScaledSize(double baseSize) {
    return baseSize * 1.01;
  }

  Widget _buildColorPicker() {
    final colors = [
      AppColors.neonGreen,
      AppColors.electricBlue,
      AppColors.neonPurple,
      AppColors.neonPink,
      AppColors.neonRed,
      AppColors.white,
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Crosshair Color',
          style: TextStyle(color: AppColors.white, fontSize: 14),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children:
              colors.map((color) {
                final isSelected =
                    _overlayService.settings.colorValue == color.toARGB32();
                return GestureDetector(
                  onTap: () {
                    _overlayService.updateColor(color.toARGB32());
                  },
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color:
                            isSelected ? AppColors.white : Colors.transparent,
                        width: 3,
                      ),
                      boxShadow:
                          isSelected
                              ? [
                                BoxShadow(
                                  color: color.withValues(alpha: 0.5),
                                  blurRadius: 10,
                                  spreadRadius: 2,
                                ),
                              ]
                              : null,
                    ),
                  ),
                );
              }).toList(),
        ),
      ],
    );
  }

  Widget _buildLockToggle() {
    final isLocked = _overlayService.settings.isLocked;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Row(
          children: [
            Icon(Ionicons.lock_closed, color: AppColors.neonPurple, size: 20),
            SizedBox(width: 8),
            Text(
              'Lock Position',
              style: TextStyle(color: AppColors.white, fontSize: 14),
            ),
          ],
        ),
        Switch(
          value: isLocked,
          onChanged: (value) {
            _overlayService.toggleLock();
          },
          activeTrackColor: AppColors.neonPurple,
          thumbColor: WidgetStateProperty.all(AppColors.white),
        ),
      ],
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

extension on Color {
  int toARGB32() {
    return ((a * 255.0).round().clamp(0, 255) << 24) |
        ((r * 255.0).round().clamp(0, 255) << 16) |
        ((g * 255.0).round().clamp(0, 255) << 8) |
        (b * 255.0).round().clamp(0, 255);
  }
}
