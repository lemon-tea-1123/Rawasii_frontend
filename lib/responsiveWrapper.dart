import 'package:flutter/material.dart';

class Breakpoints {
  static const double tablet = 600;
  static const double desktop = 1024;
}

enum LayoutType { mobile, tablet, desktop }

class AdaptiveLayout extends StatelessWidget {
  final Widget mainContent;
  final Widget sidebar;
  final Widget? rightPanel;
  final Widget? bottomNav; // ← now shown on ALL sizes
  final PreferredSizeWidget? appBar;
  final Widget? drawer;

  const AdaptiveLayout({
    super.key,
    required this.mainContent,
    required this.sidebar,
    this.rightPanel,
    this.bottomNav,
    this.appBar,
    this.drawer,
  });

  static LayoutType layoutOf(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width >= Breakpoints.desktop) return LayoutType.desktop;
    if (width >= Breakpoints.tablet) return LayoutType.tablet;
    return LayoutType.mobile;
  }

  @override
  Widget build(BuildContext context) {
    final layout = layoutOf(context);

    return switch (layout) {
      LayoutType.mobile => _MobileLayout(
        appBar: appBar,
        bottomNav: bottomNav,
        drawer: drawer,
        child: mainContent,
      ),
      LayoutType.tablet => _TabletLayout(
        sidebar: sidebar,
        bottomNav: bottomNav, // ← pass it here too
        drawer: drawer,
        child: mainContent,
      ),
      LayoutType.desktop => _DesktopLayout(
        sidebar: sidebar,
        rightPanel: rightPanel,
        bottomNav: bottomNav, // ← and here
        drawer: drawer,
        child: mainContent,
      ),
    };
  }
}

// ─── Mobile ───────────────────────────────────────────────────────────────────
class _MobileLayout extends StatelessWidget {
  final Widget child;
  final PreferredSizeWidget? appBar;
  final Widget? bottomNav;
  final Widget? drawer;

  const _MobileLayout({
    required this.child,
    this.appBar,
    this.bottomNav,
    this.drawer,
  });

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: appBar,
    drawer: drawer,
    body: child,
    bottomNavigationBar: bottomNav, // bottom of screen
  );
}

// ─── Tablet ───────────────────────────────────────────────────────────────────
class _TabletLayout extends StatelessWidget {
  final Widget sidebar;
  final Widget child;
  final Widget? bottomNav;
  final Widget? drawer;

  const _TabletLayout({
    required this.sidebar,
    required this.child,
    this.bottomNav,
    this.drawer,
  });

  @override
  Widget build(BuildContext context) => Scaffold(
    drawer: drawer,
    body: Row(
      children: [
        // ── Sidebar (no navbar) ─────────────────────────────────────────
        SizedBox(width: 120, child: sidebar),
        const VerticalDivider(width: 1, thickness: 1),

        // ── Middle column: content + navbar stacked ─────────────────────
        Expanded(
          child: Column(
            // ← Column only wraps the middle
            children: [
              Expanded(child: child),
              if (bottomNav != null) ...[
                const Divider(height: 1, thickness: 1),
                bottomNav!, // navbar only under middle
              ],
            ],
          ),
        ),
      ],
    ),
  );
}

// ─── Desktop ──────────────────────────────────────────────────────────────────
class _DesktopLayout extends StatelessWidget {
  final Widget sidebar;
  final Widget child;
  final Widget? rightPanel;
  final Widget? bottomNav;
  final Widget? drawer;

  const _DesktopLayout({
    required this.sidebar,
    required this.child,
    this.rightPanel,
    this.bottomNav,
    this.drawer,
  });

  @override
  Widget build(BuildContext context) => Scaffold(
    drawer: drawer,
    body: Row(
      // ← back to Row, no Column
      children: [
        // SIDE BAR
        SizedBox(width: 320, child: sidebar),
        const VerticalDivider(width: 1, thickness: 1),

        Expanded(
          flex: 2,
          child: Column(
            children: [
              Expanded(child: child), // main content takes all space
              if (bottomNav != null) ...[
                const Divider(height: 1, thickness: 1),
                bottomNav!, // navbar only under middle
              ],
            ],
          ),
        ),

        if (rightPanel != null) ...[
          const VerticalDivider(width: 1, thickness: 1),
          SizedBox(width: 320, child: rightPanel!),
        ],
      ],
    ),
  );
}
