import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scada_app/core/theme/app_colors.dart';
import 'package:scada_app/data/modbus/modbus_tcp_client.dart';
import 'package:scada_app/data/providers/data_provider.dart';
import 'package:scada_app/data/providers/fake_data_provider.dart';
import 'package:scada_app/data/providers/real_data_provider.dart';
import 'package:scada_app/state/settings_state.dart';
import 'package:scada_app/state/user_state.dart';
import 'package:scada_app/ui/screen/dashboard/dashboard_screen.dart';

import 'data/repositories/alert_repository.dart';
import 'data/repositories/energy_data_repository.dart';
import 'data/repositories/user_repository.dart';
import 'services/alert_service.dart';
import 'services/control_service.dart';
import 'state/alerts_state.dart';
import 'state/control_state.dart';
import 'state/energy_data_state.dart';


 bool useRealData = bool.fromEnvironment('USE_REAL_DATA');

void main() {

  final DataProvider provider = RealDataProvider(
    modbusClient: ModbusTcpClient(
      host: '192.168.56.100',
      port: 502,
      unitId: 1, 
      )
  );

  runApp(AbuSmartEnergyApp(dataProvider: provider));
}

/// Widget racine public — injecte n'importe quel DataProvider (Fake
/// aujourd'hui, ScadaBR à l'étape 5, ou un Fake de test à l'étape 4).
/// Exposé publiquement pour être réutilisable dans widget_test.dart sans
/// dupliquer tout le câblage MultiProvider.
class AbuSmartEnergyApp extends StatelessWidget {
  const AbuSmartEnergyApp({super.key, required this.dataProvider});

  final DataProvider dataProvider;

  @override
  Widget build(BuildContext context) {
    final energyDataRepository = EnergyDataRepository(dataProvider);
    final alertRepository = AlertRepository(dataProvider);
    final userRepository = UserRepository();

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => EnergyDataState(energyDataRepository),
        ),
        ChangeNotifierProvider(
          create: (_) => AlertsState(AlertService(alertRepository)),
        ),
        ChangeNotifierProvider(
          create: (_) => ControlState(ControlService(energyDataRepository)),
        ),
        ChangeNotifierProvider(create: (_) => UsersState(userRepository)),
        ChangeNotifierProvider(create: (_) => SettingsState()),
      ],
      child: MaterialApp(
        title: 'ABU Smart Energy',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorSchemeSeed: AppColors.primary,
          scaffoldBackgroundColor: AppColors.background,
        ),
        home: const DashboardScreen(),
      ),
    );
  }
}
