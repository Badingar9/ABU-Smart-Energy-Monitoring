import 'package:modbus_client/modbus_client.dart';
import 'package:scada_app/data/modbus/equipement_registers.dart';
import 'package:scada_app/data/modbus/modbus_tcp_client.dart';

Future<void> main() async{
final equipments = [
EquipementRegisters('AC Office 3', 0),
EquipementRegisters('Fans Room 12', 5),
EquipementRegisters('Socket Office 7', 10),
EquipementRegisters('Lighting Ground Floor', 15),
];

final listOfAllRegister = equipments.expand((equipment)=> equipment.allRegisters).toList();

final client = ModbusTcpClient(host: '192.168.56.100', port: 502, unitId: 1);

try {
  print('Connection to OpenPLC...');
  final responseCode = await client.readRegisters(listOfAllRegister);

  if(responseCode != ModbusResponseCode.requestSucceed){
    print('Error reading registers : ${responseCode.name}');

    return;
  }
  print('========Registers read successfully=======');

  for(final equipment in equipments){
    print(
      '${equipment.label} | '
      'V=${equipment.voltage.value?.toStringAsFixed(1) ?? '?'} V |'
         'I=${equipment.current.value?.toStringAsFixed(2) ?? '?'} A | '
        'P=${equipment.activePower.value?.toStringAsFixed(3) ?? '?'} kW | '
        'Q=${equipment.reactivePower.value?.toStringAsFixed(3) ?? '?'} kVAR | '
        'PF=${equipment.powerFactor.value?.toStringAsFixed(3) ?? '?'}',
    );
  }
} catch (e) {
  print('Error occured while reading registers: $e');
}
finally{
  await client.disconnect();
}

}