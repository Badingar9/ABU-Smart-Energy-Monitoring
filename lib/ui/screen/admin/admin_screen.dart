import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scada_app/core/constants/app_route.dart';
import 'package:scada_app/core/theme/app_colors.dart';
import 'package:scada_app/core/theme/app_spacing.dart';
import 'package:scada_app/core/theme/app_typography.dart';
import 'package:scada_app/models/role.dart';
import 'package:scada_app/state/control_state.dart';
import 'package:scada_app/state/energy_data_state.dart';
import 'package:scada_app/state/user_state.dart';
import 'package:scada_app/ui/widgets/admin/user_tab.dart';

import '../../widgets/admin/action_log_tab.dart';
import '../../widgets/admin/admin_thresholds_tab.dart';
import '../../widgets/admin/buildings_tab.dart';
import '../../widgets/admin/data_source_tab.dart';
import '../../widgets/shared/app_shell.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController = TabController(
    length: 5,
    vsync: this,
  );

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppShell(
      selectedRoute: AppRoute.admin,
      body: Consumer3<EnergyDataState, UsersState, ControlState>(
        builder: (context, energy, users, controlState, _) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.containerPadding,
                  AppSpacing.containerPadding,
                  AppSpacing.containerPadding,
                  0,
                ),
                child: Text('Administration', style: AppTypography.headlineLg),
              ),
              TabBar(
                controller: _tabController,
                isScrollable: true,
                labelColor: AppColors.primary,
                unselectedLabelColor: AppColors.onSurfaceVariant,
                indicatorColor: AppColors.primary,
                tabAlignment: TabAlignment.start,
                tabs: const [
                  Tab(text: 'Users'),
                  Tab(text: 'Buildings'),
                  Tab(text: 'Thresholds'),
                  Tab(text: 'Data Source'),
                  Tab(text: 'Action Log'),
                ],
              ),
              const Divider(height: 1, color: AppColors.outlineVariant),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    UsersTab(
                      users: users.users,
                      onCreateUser: (name, email, role) => users.createUser(
                        fullName: name,
                        email: email,
                        roleType: role as RoleType,
                      ),
                      onSetStatus: users.setStatus,
                    ),
                    AdminBuildingsTab(energy: energy),
                    AdminThresholdsTab(energy: energy),
                    const DataSourceTab(),
                    ActionLogTab(
                      actions: controlState.controlActions,
                      energy: energy,
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
