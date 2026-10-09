// import 'package:scada_app/data/modbus/modbus_tcp_client.dart';
// import 'package:scada_app/data/providers/real_data_provider.dart';

// Future<void> main() async{

//   final client = ModbusTcpClient(
//   host: '192.168.56.100',
//   port: 502,
//   unitId: 1,
// );

// final provider = RealDataProvider(
//   modbusClient: client,
// );
//   print('3. RealDataProvider créé');

// provider.watchReadings().listen((reading) {
//   print(
//     'Equipment=${reading.equipmentId} '
//     'V=${reading.voltage} '
//     'I=${reading.current} '
//     'P=${reading.activePower} '
//     'Q=${reading.reactivePower} '
//     'PF=${reading.powerFactor}',
//   );
// },
// onError: (error) {
//   print('Error occurred while watching readings: $error');
// },
// );

//  await Future.delayed(const Duration(seconds: 3));
//    print('6. Test terminé');
// }
import 'package:modbus_client/modbus_client.dart';
import 'package:scada_app/data/modbus/modbus_tcp_client.dart';

// Les 5 registres d'un circuit : V, I, P, Q, PF
List<ModbusUint16Register> circuit(String label, int base) {
  ModbusUint16Register reg(String name, int offset, double multiplier) {
    return ModbusUint16Register(
      name: '$label-$name',
      address: base + offset,
      type: ModbusElementType.holdingRegister,
      multiplier: multiplier,
    );
  }

  return [
    reg('V', 0, 0.1),
    reg('I', 1, 0.01),
    reg('P', 2, 0.001),
    reg('Q', 3, 0.001),
    reg('PF', 4, 0.001),
  ];
}

Future<void> main() async {
  final client = ModbusTcpClient(host: '192.168.56.100', port: 502, unitId: 1);

  // 4 circuits éloignés les uns des autres : 0, 40, 80 et 130
  final circuits = {
    'ac_office': circuit('ac_office', 0),
    'AC Library': circuit('ac_lib', 5),
    'Fan Laboratory': circuit('fan_lab', 40),
    'Lighting Office': circuit('light_office', 80),
    'Socket Laboratory': circuit('socket_lab', 130),
  };

  final all = circuits.values.expand((regs) => regs).toList();

  Future<void> readAll(String title) async {
    final code = await client.readRegisters(all);
    print('\n--- $title : ${code.name}');
    if (code != ModbusResponseCode.requestSucceed) return;

    circuits.forEach((label, regs) {
      print(
        '${label.padRight(13)} '
        'V=${regs[0].value?.toStringAsFixed(1)} V | '
        'I=${regs[1].value?.toStringAsFixed(2)} A | '
        'P=${regs[2].value?.toStringAsFixed(3)} kW | '
        'Q=${regs[3].value?.toStringAsFixed(3)} kvar | '
        'PF=${regs[4].value?.toStringAsFixed(3)}',
      );
    });
  }

  try {
    await readAll('1) lecture des 4 circuits');
    await Future.delayed(const Duration(seconds: 2));
    await readAll('2) deuxième lecture (les valeurs doivent bouger)');

    final cut = await client.writeCoil(0, true);
    print('\nwriteCoil(0, true) : ${cut.name}');
    await Future.delayed(const Duration(milliseconds: 1500));
    await readAll('3) après coupure du coil 0');

    final restore = await client.writeCoil(0, false);
    print('\nwriteCoil(0, false) : ${restore.name}');
    await Future.delayed(const Duration(milliseconds: 1500));
    await readAll('4) après reconnexion');
  } finally {
    await client.disconnect();
  }
}

