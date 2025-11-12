import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme/odoo_colors.dart';
import '../theme/odoo_typography.dart';

/// Odoo Layout Widget
///
/// Provides the main layout structure with:
/// - Left sidebar navigation (Odoo dark theme)
/// - Top bar with search, notifications, user menu
/// - Main content area with breadcrumbs
/// - Responsive design (collapses on mobile)
class OdooLayout extends StatefulWidget {
  const OdooLayout({
    required this.child,
    super.key,
  });

  final Widget child;

  @override
  State<OdooLayout> createState() => _OdooLayoutState();
}

class _OdooLayoutState extends State<OdooLayout> {
  bool _isSidebarCollapsed = false;

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;

    return Scaffold(
      body: Row(
        children: [
          // Sidebar
          _OdooSidebar(
            isCollapsed: _isSidebarCollapsed,
            currentLocation: location,
            onToggleCollapse: () {
              setState(() {
                _isSidebarCollapsed = !_isSidebarCollapsed;
              });
            },
          ),

          // Main content area
          Expanded(
            child: Column(
              children: [
                // Top bar
                _OdooTopBar(
                  onMenuPressed: () {
                    setState(() {
                      _isSidebarCollapsed = !_isSidebarCollapsed;
                    });
                  },
                ),

                // Content
                Expanded(
                  child: widget.child,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Odoo Sidebar
class _OdooSidebar extends StatelessWidget {
  const _OdooSidebar({
    required this.isCollapsed,
    required this.currentLocation,
    required this.onToggleCollapse,
  });

  final bool isCollapsed;
  final String currentLocation;
  final VoidCallback onToggleCollapse;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: isCollapsed ? 64 : OdooSpacing.sidebarWidth,
      decoration: const BoxDecoration(
        color: OdooColors.sidebarBackground,
        border: Border(
          right: BorderSide(
            color: Color(0xFF1F1F26),
            width: 1,
          ),
        ),
      ),
      child: Column(
        children: [
          // Header
          _buildHeader(),

          const SizedBox(height: OdooSpacing.lg),

          // Menu items
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _buildMenuItem(
                  context: context,
                  icon: Icons.dashboard_outlined,
                  selectedIcon: Icons.dashboard,
                  label: 'Dashboard',
                  route: '/',
                  isActive: currentLocation == '/',
                ),
                _buildMenuItem(
                  context: context,
                  icon: Icons.receipt_long_outlined,
                  selectedIcon: Icons.receipt_long,
                  label: 'Sales',
                  route: '/sales',
                  isActive: currentLocation == '/sales',
                ),
                _buildMenuItem(
                  context: context,
                  icon: Icons.inventory_2_outlined,
                  selectedIcon: Icons.inventory_2,
                  label: 'Products',
                  route: '/products',
                  isActive: currentLocation == '/products',
                ),
                _buildMenuItem(
                  context: context,
                  icon: Icons.restaurant_outlined,
                  selectedIcon: Icons.restaurant,
                  label: 'Restaurant',
                  route: '/restaurant',
                  isActive: currentLocation == '/restaurant',
                ),
                _buildMenuItem(
                  context: context,
                  icon: Icons.people_outline,
                  selectedIcon: Icons.people,
                  label: 'Staff',
                  route: '/staff',
                  isActive: currentLocation == '/staff',
                ),
                _buildMenuItem(
                  context: context,
                  icon: Icons.settings_outlined,
                  selectedIcon: Icons.settings,
                  label: 'Settings',
                  route: '/settings',
                  isActive: currentLocation.startsWith('/settings'),
                ),
                _buildMenuItem(
                  context: context,
                  icon: Icons.devices_outlined,
                  selectedIcon: Icons.devices,
                  label: 'Devices',
                  route: '/devices',
                  isActive: currentLocation == '/devices',
                ),
              ],
            ),
          ),

          // User section at bottom
          if (!isCollapsed) _buildUserSection(),

          // Collapse button
          _buildCollapseButton(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    if (isCollapsed) {
      return Container(
        height: OdooSpacing.topBarHeight,
        alignment: Alignment.center,
        child: const Icon(
          Icons.restaurant_menu,
          color: OdooColors.sidebarText,
          size: OdooIconSizes.xl,
        ),
      );
    }

    return Container(
      height: OdooSpacing.topBarHeight,
      padding: const EdgeInsets.symmetric(
        horizontal: OdooSpacing.lg,
      ),
      child: Row(
        children: [
          Icon(
            Icons.restaurant_menu,
            color: OdooColors.secondary,
            size: OdooIconSizes.xl,
          ),
          const SizedBox(width: OdooSpacing.md),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'SmartPOS',
                  style: OdooTypography.titleMedium.copyWith(
                    color: OdooColors.sidebarText,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  'Manager',
                  style: OdooTypography.bodySmall.copyWith(
                    color: OdooColors.sidebarText.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required BuildContext context,
    required IconData icon,
    required IconData selectedIcon,
    required String label,
    required String route,
    required bool isActive,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: isCollapsed ? OdooSpacing.sm : OdooSpacing.md,
        vertical: 2,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => context.go(route),
          borderRadius: BorderRadius.circular(OdooSpacing.radiusStandard),
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: isCollapsed ? OdooSpacing.sm : OdooSpacing.md,
              vertical: OdooSpacing.md,
            ),
            decoration: BoxDecoration(
              color: isActive ? OdooColors.sidebarActive : Colors.transparent,
              borderRadius: BorderRadius.circular(OdooSpacing.radiusStandard),
            ),
            child: Row(
              children: [
                Icon(
                  isActive ? selectedIcon : icon,
                  color: isActive
                      ? OdooColors.secondary
                      : OdooColors.sidebarText.withOpacity(0.8),
                  size: OdooIconSizes.lg,
                ),
                if (!isCollapsed) ...[
                  const SizedBox(width: OdooSpacing.md),
                  Expanded(
                    child: Text(
                      label,
                      style: OdooTypography.bodyMedium.copyWith(
                        color: isActive
                            ? OdooColors.sidebarText
                            : OdooColors.sidebarText.withOpacity(0.8),
                        fontWeight:
                            isActive ? FontWeight.w600 : FontWeight.w400,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildUserSection() {
    return Container(
      padding: const EdgeInsets.all(OdooSpacing.md),
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(
            color: Color(0xFF1F1F26),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: OdooColors.primary,
            radius: 18,
            child: Text(
              'M',
              style: OdooTypography.labelLarge.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: OdooSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Manager',
                  style: OdooTypography.bodySmall.copyWith(
                    color: OdooColors.sidebarText,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  'manager@smartpos.com',
                  style: OdooTypography.bodySmall.copyWith(
                    color: OdooColors.sidebarText.withOpacity(0.6),
                    fontSize: 11,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCollapseButton() {
    return Container(
      padding: const EdgeInsets.all(OdooSpacing.sm),
      child: IconButton(
        onPressed: onToggleCollapse,
        icon: Icon(
          isCollapsed ? Icons.chevron_right : Icons.chevron_left,
          color: OdooColors.sidebarText.withOpacity(0.6),
        ),
        tooltip: isCollapsed ? 'Expand sidebar' : 'Collapse sidebar',
      ),
    );
  }
}

/// Odoo Top Bar
class _OdooTopBar extends StatelessWidget {
  const _OdooTopBar({
    required this.onMenuPressed,
  });

  final VoidCallback onMenuPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: OdooSpacing.topBarHeight,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(
            color: OdooColors.border,
            width: 1,
          ),
        ),
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: OdooSpacing.lg,
      ),
      child: Row(
        children: [
          // Breadcrumbs or page title will go here
          Expanded(
            child: Text(
              _getPageTitle(context),
              style: OdooTypography.titleLarge.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          // Search
          IconButton(
            onPressed: () {
              // TODO: Implement search
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Search feature coming soon')),
              );
            },
            icon: const Icon(Icons.search),
            tooltip: 'Search',
          ),

          const SizedBox(width: OdooSpacing.sm),

          // Notifications
          IconButton(
            onPressed: () {
              // TODO: Implement notifications
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('Notifications feature coming soon')),
              );
            },
            icon: Badge(
              label: const Text('3'),
              child: const Icon(Icons.notifications_outlined),
            ),
            tooltip: 'Notifications',
          ),

          const SizedBox(width: OdooSpacing.sm),

          // User menu
          PopupMenuButton(
            icon: const CircleAvatar(
              backgroundColor: OdooColors.primary,
              radius: 16,
              child: Icon(
                Icons.person,
                color: Colors.white,
                size: OdooIconSizes.sm,
              ),
            ),
            tooltip: 'User menu',
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'profile',
                child: ListTile(
                  leading: Icon(Icons.person_outline),
                  title: Text('Profile'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const PopupMenuItem(
                value: 'settings',
                child: ListTile(
                  leading: Icon(Icons.settings_outlined),
                  title: Text('Settings'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const PopupMenuDivider(),
              const PopupMenuItem(
                value: 'logout',
                child: ListTile(
                  leading: Icon(Icons.logout),
                  title: Text('Logout'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ],
            onSelected: (value) {
              // TODO: Handle menu actions
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('$value action coming soon')),
              );
            },
          ),
        ],
      ),
    );
  }

  String _getPageTitle(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;

    switch (location) {
      case '/':
        return 'Dashboard';
      case '/sales':
        return 'Sales';
      case '/products':
        return 'Products';
      case '/restaurant':
        return 'Restaurant';
      case '/staff':
        return 'Staff';
      case '/devices':
        return 'Devices';
      default:
        if (location.startsWith('/settings')) {
          return 'Settings';
        }
        return 'Dashboard';
    }
  }
}
