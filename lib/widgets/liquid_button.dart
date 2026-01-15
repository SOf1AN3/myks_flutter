import 'package:flutter/material.dart';
import '../config/theme.dart';

/// Liquid button with glass effect and animations
class LiquidButton extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final double size;
  final LiquidButtonType type;
  final bool isLoading;
  final String? semanticLabel;

  const LiquidButton({
    super.key,
    required this.child,
    this.onTap,
    this.size = 48,
    this.type = LiquidButtonType.control,
    this.isLoading = false,
    this.semanticLabel,
  });

  /// Factory for play button
  factory LiquidButton.play({
    required bool isPlaying,
    required bool isLoading,
    required VoidCallback onTap,
    String? semanticLabel,
  }) {
    final label =
        semanticLabel ??
        (isLoading
            ? 'Chargement en cours'
            : isPlaying
            ? 'Mettre en pause'
            : 'Lire la radio');

    return LiquidButton(
      size: 96,
      type: LiquidButtonType.play,
      onTap: onTap,
      isLoading: isLoading,
      semanticLabel: label,
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
    String? semanticLabel,
  }) {
    return LiquidButton(
      size: size,
      type: LiquidButtonType.control,
      onTap: onTap,
      semanticLabel: semanticLabel,
      child: Icon(icon, size: 24, color: Colors.white.withValues(alpha: 0.7)),
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
    return Semantics(
      button: true,
      label: widget.semanticLabel,
      enabled: widget.onTap != null,
      child: GestureDetector(
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
      ),
    );
  }

  Widget _buildPlayButton() {
    return RepaintBoundary(
      child: Container(
        width: widget.size,
        height: widget.size,
        decoration: BoxDecoration(
          // PERFORMANCE: Removed BackdropFilter, using static gradient
          gradient: AppColors.playButtonGradient,
          shape: BoxShape.circle,
          border: Border.all(
            color: const Color(0x4DFFFFFF), // rgba(255, 255, 255, 0.3)
            width: 1,
          ),
          boxShadow: GlassEffects.glowShadow,
        ),
        child: Center(child: widget.child),
      ),
    );
  }

  Widget _buildControlButton() {
    return RepaintBoundary(
      child: Container(
        width: widget.size,
        height: widget.size,
        decoration: BoxDecoration(
          // PERFORMANCE: Removed BackdropFilter, using static gradient
          gradient: const LinearGradient(
            colors: [
              Color(0x26FFFFFF), // rgba(255, 255, 255, 0.15)
              Color(0x0DFFFFFF), // rgba(255, 255, 255, 0.05)
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.glassControlBorder, width: 1),
          boxShadow: const [
            BoxShadow(
              color: Color(0x33000000),
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Center(child: widget.child),
      ),
    );
  }
}

enum LiquidButtonType { control, play }
