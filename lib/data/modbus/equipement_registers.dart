
import 'package:modbus_client/modbus_client.dart';

class EquipementRegisters {
  EquipementRegisters(this.label, int baseAddress
  ): voltage = ModbusUint16Register(
    name : '$label-Voltage',
    address: baseAddress,
    type: ModbusElementType.inputRegister,
    multiplier: 0.1,
    uom: "V",

  ),
  current = ModbusUint16Register(
    name: '$label-Current', 
    address: baseAddress + 1, 
    type: ModbusElementType.inputRegister,
    multiplier: 0.01,
    uom: "A"
    ),
    activePower = ModbusUint16Register(
      name: '$label-ActivePower', 
      address: baseAddress + 2, 
      type: ModbusElementType.inputRegister,
      multiplier: 0.001,
      uom: 'KW'
    ),
    reactivePower = ModbusUint16Register(
      name: '$label-ReactivePower', 
      address: baseAddress + 3, 
      type: ModbusElementType.inputRegister,
      multiplier: 0.001,
      uom: 'KWAR'
      ),
    powerFactor = ModbusUint16Register(
      name: '$label-PowerFactor', 
      address: baseAddress + 4, 
      type: ModbusElementType.inputRegister,
      multiplier: 0.001,
      uom: ''
      );
  

final String label;
final ModbusUint16Register voltage;
final ModbusUint16Register current;
final ModbusUint16Register activePower;
final ModbusUint16Register reactivePower;
final ModbusUint16Register powerFactor;

List<ModbusElement> get allRegisters => [
  voltage,
  current,
  activePower,
  reactivePower,
  powerFactor
];
}