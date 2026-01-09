import 'package:flutter/material.dart';

/// Custom app bar with consistent styling
class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showBackButton;
  final List<Widget>? actions;
  final Widget? leading;
  final bool centerTitle;
  final Color? backgroundColor;
  final double elevation;
  final Widget? titleWidget;

  const CustomAppBar({
    super.key,
    this.title = '',
    this.showBackButton = false,
    this.actions,
    this.leading,
    this.centerTitle = true,
    this.backgroundColor,
    this.elevation = 0,
    this.titleWidget,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title:
          titleWidget ??
          (title.isNotEmpty
              ? Text(title, style: const TextStyle(fontWeight: FontWeight.w600))
              : null),
      centerTitle: centerTitle,
      backgroundColor: backgroundColor ?? Colors.transparent,
      elevation: elevation,
      scrolledUnderElevation: elevation,
      leading:
          leading ??
          (showBackButton
              ? IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => Navigator.pop(context),
                )
              : null),
      actions: [if (actions != null) ...actions!, const SizedBox(width: 8)],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

/// Sliver app bar variant for scrollable screens
class CustomSliverAppBar extends StatelessWidget {
  final String title;
  final List<Widget>? actions;
  final Widget? flexibleSpace;
  final double expandedHeight;
  final bool pinned;
  final bool floating;

  const CustomSliverAppBar({
    super.key,
    this.title = '',
    this.actions,
    this.flexibleSpace,
    this.expandedHeight = 120,
    this.pinned = true,
    this.floating = false,
  });

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      title: title.isNotEmpty
          ? Text(title, style: const TextStyle(fontWeight: FontWeight.w600))
          : null,
      centerTitle: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      pinned: pinned,
      floating: floating,
      expandedHeight: flexibleSpace != null ? expandedHeight : null,
      flexibleSpace: flexibleSpace,
      actions: [if (actions != null) ...actions!, const SizedBox(width: 8)],
    );
  }
}
