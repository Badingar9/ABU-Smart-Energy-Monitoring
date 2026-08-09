import 'package:flutter/material.dart';
import 'package:scada_app/core/constants/app_route.dart';
import 'package:scada_app/core/theme/app_colors.dart';
import 'package:scada_app/core/theme/app_spacing.dart';
import 'package:scada_app/core/theme/app_typography.dart';

class AppSideNav extends StatelessWidget {
  final AppRoute selectedRoute;
  final ValueChanged<AppRoute> onSelectRoute;
  final int alertBadgeCount;

  const AppSideNav({
    super.key,
    required this.selectedRoute,
    required this.onSelectRoute,
    required this.alertBadgeCount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: AppSpacing.sidebarWidth,
      color: AppColors.surfaceContainer,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.containerPadding),
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(color: AppColors.outlineVariant),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                  ),
                  child: const Icon(
                    Icons.electric_bolt,
                    color: AppColors.onPrimary,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'ABU Energy',
                        style: AppTypography.headlineMd.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                      Text(
                        'Powering Efficiency',
                        style: AppTypography.labelData.copyWith(fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
              children: [
                _NavItem(
                  route: AppRoute.dashboard,
                  label: 'Dashboard',
                  icon: Icons.dashboard,
                  selected: selectedRoute,
                  onTap: onSelectRoute,
                ),
                _NavItem(
                  route: AppRoute.buildings,
                  label: 'Buildings',
                  icon: Icons.domain,
                  selected: selectedRoute,
                  onTap: onSelectRoute,
                ),
                _NavItem(
                  route: AppRoute.alerts,
                  label: 'Alerts',
                  icon: Icons.notifications_active,
                  selected: selectedRoute,
                  onTap: onSelectRoute,
                  badgeCount: alertBadgeCount,
                ),
                _NavItem(
                  route: AppRoute.history,
                  label: 'History',
                  icon: Icons.history,
                  selected: selectedRoute,
                  onTap: onSelectRoute,
                ),
                _NavItem(
                  route: AppRoute.admin,
                  label: 'Admin',
                  icon: Icons.admin_panel_settings,
                  selected: selectedRoute,
                  onTap: onSelectRoute,
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: AppColors.outlineVariant)),
            ),
            child: _NavItem(
              route: AppRoute.settings,
              label: 'Settings',
              icon: Icons.settings,
              selected: selectedRoute,
              onTap: onSelectRoute,
            ),
          ),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final AppRoute route;
  final String label;
  final IconData icon;
  final AppRoute selected;
  final ValueChanged<AppRoute> onTap;
  final int? badgeCount;

  const _NavItem({
    required this.route,
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
    this.badgeCount,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = route == selected;
    return InkWell(
      onTap: () => onTap(route),
      borderRadius: BorderRadius.circular(AppRadius.lg),
      child: Container(
        margin: const EdgeInsets.only(bottom: 4),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.secondaryContainer.withValues(alpha: 0.2)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: isSelected
              ? const Border(
                  right: BorderSide(color: AppColors.primary, width: 4),
                )
              : null,
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected
                  ? AppColors.primary
                  : AppColors.onSurfaceVariant,
              size: 22,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: AppTypography.bodyMd.copyWith(
                  color: isSelected
                      ? AppColors.primary
                      : AppColors.onSurfaceVariant,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
                ),
              ),
            ),
            if (badgeCount != null && badgeCount! > 0)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.statusCritical,
                  borderRadius: BorderRadius.circular(AppRadius.full),
                ),
                child: Text(
                  '$badgeCount',
                  style: AppTypography.labelData.copyWith(
                    color: AppColors.onError,
                    fontSize: 12,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
