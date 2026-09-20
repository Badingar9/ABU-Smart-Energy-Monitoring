import 'package:modbus_client/modbus_client.dart';
import 'package:modbus_client_tcp/modbus_client_tcp.dart';

const String openPlcHost = '192.168.1.100';
const int openPlcPort = 502;
const int unitId = 1;

class ModbusTcpClient {
  ModbusTcpClient({
    required this.host,
    this.port = 502,
    this.unitId = 1,
    this.connectionTimeout = const Duration(seconds: 5),
    this.responseTimeout = const Duration(seconds: 5),
  });

  final String host;
  final int port;
  final int unitId;

  final Duration connectionTimeout;
  final Duration responseTimeout;

  late final ModbusClientTcp _client = ModbusClientTcp(
    host,
    serverPort: port,
    unitId: unitId,
    connectionTimeout: connectionTimeout,
    responseTimeout: responseTimeout
  );

  Future<void> disconnect() async {
    await _client.disconnect();
    print("Disconnected from Modbus TCP server at $host:$port");
  }

  Future<ModbusResponseCode> readRegisters(
    List<ModbusElement> registers
  ) async{
    final group = ModbusElementsGroup(registers);

    final request = group.getReadRequest();
    
    return await _client.send(request);
  }
}