import 'package:modbus_client/modbus_client.dart';
import 'package:modbus_client_tcp/modbus_client_tcp.dart';

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

  // Un bloc de lecture ne doit pas dépasser 125 registres (limite du package).
  // On reste prudent avec 100.
  static const int _maxBlockSize = 100;

  // Si deux registres sont séparés par plus de 8 adresses, on démarre un
  // nouveau bloc au lieu de lire inutilement les adresses vides entre eux.
  static const int _maxGap = 8;

  late final ModbusClientTcp _client = ModbusClientTcp(
    host,
    serverPort: port,
    unitId: unitId,
    connectionTimeout: connectionTimeout,
    responseTimeout: responseTimeout,
  );

  Future<bool> connect() => _client.connect();

  Future<void> disconnect() async {
    await _client.disconnect();
    print('Disconnected from Modbus TCP server at $host:$port');
  }

  /// Lit tous les registres demandés, en plusieurs requêtes si nécessaire.
  /// Retourne requestSucceed si TOUS les blocs ont été lus, sinon le
  /// premier code d'erreur rencontré.
  Future<ModbusResponseCode> readRegisters(
    List<ModbusElement> registers,
  ) async {
    if (registers.isEmpty) return ModbusResponseCode.requestSucceed;

    final groups = _buildGroups(registers);

    for (final group in groups) {
      final code = await _client.send(group.getReadRequest());
      if (code != ModbusResponseCode.requestSucceed) {
        return code;
      }
    }
    return ModbusResponseCode.requestSucceed;
  }

  /// Écrit un coil (true = 1 = circuit coupé, false = 0 = circuit normal).
  Future<ModbusResponseCode> writeCoil(int address, bool value) async {
    final coil = ModbusCoil(name: 'coil-$address', address: address);
    return await _client.send(coil.getWriteRequest(value));
  }

  /// Trie les registres par adresse et les découpe en blocs contigus.
  List<ModbusElementsGroup> _buildGroups(List<ModbusElement> registers) {
    final sorted = [...registers]..sort((a, b) => a.address - b.address);

    final groups = <ModbusElementsGroup>[];
    var current = <ModbusElement>[];

    for (final register in sorted) {
      if (current.isNotEmpty) {
        final gap = register.address - current.last.address;
        final span = register.address - current.first.address + 1;

        if (gap > _maxGap || span > _maxBlockSize) {
          groups.add(ModbusElementsGroup(current));
          current = <ModbusElement>[];
        }
      }
      current.add(register);
    }
    groups.add(ModbusElementsGroup(current));

    return groups;
  }
}