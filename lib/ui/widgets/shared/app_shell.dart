import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scada_app/core/constants/app_route.dart';
import 'package:scada_app/core/theme/app_colors.dart';
import 'package:scada_app/models/role.dart';
import 'package:scada_app/state/alerts_state.dart';
import 'package:scada_app/state/user_state.dart';
import 'package:scada_app/ui/screen/alerts/alerts_screen.dart';
import 'package:scada_app/ui/screen/buildings/buildings_screen.dart';
import 'package:scada_app/ui/screen/dashboard/dashboard_screen.dart';
import 'package:scada_app/ui/screen/settings/settings_screen.dart';

import 'app_side_nav.dart';
import 'app_top_bar.dart';

/// Coquille commune (sidebar + topbar) — centralise aussi la navigation.
/// Chaque écran ne fournit que son contenu (body), plus besoin de
/// redéclarer sidebar/topbar/logique de routage à chaque fois.
class AppShell extends StatelessWidget {
  final AppRoute selectedRoute;
  final Widget body;

  const AppShell({super.key, required this.selectedRoute, required this.body});

  static AppShell? maybeOf(BuildContext context) {
    return context.findAncestorWidgetOfExactType<AppShell>();
  }

  void navigate(BuildContext context, AppRoute route) {
    if (route == selectedRoute) return;

    final Widget? screen = switch (route) {
      AppRoute.dashboard => const DashboardScreen(),
      AppRoute.buildings => const BuildingsScreen(),
      AppRoute.alerts => const AlertsScreen(),
      AppRoute.settings => const SettingsScreen(), // handled by SettingsScreen
      _ => null,
    };

    if (screen == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Screen not yet implemented')),
      );
      return;
    }

    Navigator.of(
      context,
    ).pushReplacement(MaterialPageRoute(builder: (_) => screen));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Row(
        children: [
          Consumer<AlertsState>(
            builder: (context, alerts, _) => AppSideNav(
              selectedRoute: selectedRoute,
              alertBadgeCount: alerts.activeAlerts.length,
              onSelectRoute: (route) => navigate(context, route),
            ),
          ),
          Expanded(
            child: Column(
              children: [
                Consumer<UsersState>(
                  builder: (context, users, _) {
                    final admin = users.users
                        .where((u) => u.role.type == RoleType.admin)
                        .firstOrNull;
                    return AppTopBar(
                      dataSourceLabel: 'Simulated',
                      currentUser: admin,
                    );
                  },
                ),
                Expanded(child: body),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
