import 'package:scada_app/data/modbus/modbus_tcp_client.dart';
import 'package:scada_app/data/providers/real_data_provider.dart';

Future<void> main() async{

  final client = ModbusTcpClient(
  host: '192.168.56.100',
  port: 502,
  unitId: 1,
);

final provider = RealDataProvider(
  modbusClient: client,
);
  print('3. RealDataProvider créé');

provider.watchReadings().listen((reading) {
  print(
    'Equipment=${reading.equipmentId} '
    'V=${reading.voltage} '
    'I=${reading.current} '
    'P=${reading.activePower} '
    'Q=${reading.reactivePower} '
    'PF=${reading.powerFactor}',
  );
},
onError: (error) {
  print('Error occurred while watching readings: $error');
},
);

 await Future.delayed(const Duration(seconds: 3));
   print('6. Test terminé');
}

