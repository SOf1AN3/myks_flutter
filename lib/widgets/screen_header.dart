import 'package:flutter/material.dart';
import 'liquid_glass_container.dart';

/// Reusable screen header with Liquid Glass design
/// Provides consistent header styling across all screens
class ScreenHeader extends StatelessWidget {
  final String? subtitle;
  final String title;
  final Widget? leading;
  final Widget? trailing;
  final bool centerTitle;

  const ScreenHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
    this.trailing,
    this.centerTitle = true,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Leading button (back, menu, etc.)
          leading ?? const SizedBox(width: 40, height: 40),

          // Title and subtitle
          if (centerTitle)
            Expanded(child: Center(child: _buildTitleColumn()))
          else
            Expanded(child: _buildTitleColumn()),

          // Trailing button (menu, search, etc.)
          trailing ?? const SizedBox(width: 40, height: 40),
        ],
      ),
    );
  }

  Widget _buildTitleColumn() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: centerTitle
          ? CrossAxisAlignment.center
          : CrossAxisAlignment.start,
      children: [
        if (subtitle != null) ...[
          Text(
            subtitle!,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
              color: Colors.white.withValues(alpha: 0.4),
            ),
          ),
          const SizedBox(height: 4),
        ],
        Text(
          title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.white.withValues(alpha: 0.9),
          ),
        ),
      ],
    );
  }

  /// Factory constructor for back button header
  factory ScreenHeader.withBack({
    required BuildContext context,
    required String title,
    String? subtitle,
    Widget? trailing,
    VoidCallback? onBack,
  }) {
    return ScreenHeader(
      title: title,
      subtitle: subtitle,
      leading: LiquidControlContainer(
        size: 40,
        onTap: onBack ?? () => Navigator.of(context).pop(),
        child: const Icon(Icons.arrow_back, size: 24, color: Colors.white),
      ),
      trailing: trailing,
    );
  }

  /// Factory constructor for menu header
  factory ScreenHeader.withMenu({
    required BuildContext context,
    required String title,
    String? subtitle,
    Widget? leading,
    required VoidCallback onMenuTap,
  }) {
    return ScreenHeader(
      title: title,
      subtitle: subtitle,
      leading: leading,
      trailing: LiquidControlContainer(
        size: 40,
        onTap: onMenuTap,
        child: const Icon(Icons.more_horiz, size: 24, color: Colors.white),
      ),
    );
  }
}
