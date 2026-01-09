import 'dart:ui';
import 'package:flutter/material.dart';
import '../config/theme.dart';

/// Liquid button with glass effect and animations
class LiquidButton extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final double size;
  final LiquidButtonType type;
  final bool isLoading;

  const LiquidButton({
    super.key,
    required this.child,
    this.onTap,
    this.size = 48,
    this.type = LiquidButtonType.control,
    this.isLoading = false,
  });

  /// Factory for play button
  factory LiquidButton.play({
    required bool isPlaying,
    required bool isLoading,
    required VoidCallback onTap,
  }) {
    return LiquidButton(
      size: 96,
      type: LiquidButtonType.play,
      onTap: onTap,
      isLoading: isLoading,
      child: isLoading
          ? const SizedBox(
              width: 40,
              height: 40,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                color: Colors.white,
              ),
            )
          : Icon(
              isPlaying ? Icons.pause : Icons.play_arrow,
              size: 48,
              color: Colors.white,
            ),
    );
  }

  /// Factory for control buttons (prev/next)
  factory LiquidButton.control({
    required IconData icon,
    required VoidCallback onTap,
    double size = 48,
  }) {
    return LiquidButton(
      size: size,
      type: LiquidButtonType.control,
      onTap: onTap,
      child: Icon(icon, size: 24, color: Colors.white.withOpacity(0.7)),
    );
  }

  @override
  State<LiquidButton> createState() => _LiquidButtonState();
}

class _LiquidButtonState extends State<LiquidButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    _scaleController.forward();
  }

  void _onTapUp(TapUpDetails details) {
    _scaleController.reverse();
  }

  void _onTapCancel() {
    _scaleController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: widget.onTap != null ? _onTapDown : null,
      onTapUp: widget.onTap != null ? _onTapUp : null,
      onTapCancel: widget.onTap != null ? _onTapCancel : null,
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(scale: _scaleAnimation.value, child: child);
        },
        child: widget.type == LiquidButtonType.play
            ? _buildPlayButton()
            : _buildControlButton(),
      ),
    );
  }

  Widget _buildPlayButton() {
    return Container(
      width: widget.size,
      height: widget.size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: GlassEffects.glowShadow,
      ),
      child: ClipOval(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            decoration: BoxDecoration(
              gradient: AppColors.playButtonGradient,
              border: Border.all(
                color: const Color(0x4DFFFFFF), // rgba(255, 255, 255, 0.3)
                width: 1,
              ),
              shape: BoxShape.circle,
            ),
            child: Center(child: widget.child),
          ),
        ),
      ),
    );
  }

  Widget _buildControlButton() {
    return Container(
      width: widget.size,
      height: widget.size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: const [
          BoxShadow(
            color: Color(0x33000000),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: ClipOval(
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: GlassEffects.blurIntensityControl,
            sigmaY: GlassEffects.blurIntensityControl,
          ),
          child: Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  Color(0x26FFFFFF), // rgba(255, 255, 255, 0.15)
                  Color(0x0DFFFFFF), // rgba(255, 255, 255, 0.05)
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              border: Border.all(color: AppColors.glassControlBorder, width: 1),
              shape: BoxShape.circle,
            ),
            child: Center(child: widget.child),
          ),
        ),
      ),
    );
  }
}

enum LiquidButtonType { control, play }
