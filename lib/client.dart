import 'package:modbus_client/modbus_client.dart';
import 'package:modbus_client_tcp/modbus_client_tcp.dart';

Future<void> main() async {
  // 1. Connexion au client OpenPLC
  final client = ModbusClientTcp('192.168.56.100', serverPort: 502, unitId: 1);
  await client.connect();

  // Noms des 5 métriques et leurs multiplicateurs respectifs
  final metrics = ['V', 'I', 'P', 'Q', 'PF'];
  final multipliers = [0.1, 0.01, 1.0, 1.0, 0.001];

  // 2. Cartographie des adresses de base (%QW) pour chaque équipement
  final equipments = {
    'AC Office': 0,         // %QW0 à %QW4
    // 'AC Library': 5,        // %QW5 à %QW9
    'Fan Laboratory': 40,   // %QW40 à %QW44
    'Fan Library': 45,      // %QW45 à %QW49
    'Light Office': 80,     // %QW80 à %QW84
    'Light Library': 85,    // %QW85 à %QW89
    'Light Laboratory': 90, // %QW90 à %QW94
    'Socket Office': 120,   // %QW120 à %QW124
    'Socket Library': 125,  // %QW125 à %QW129
    'Socket Laboratory': 130,// %QW130 à %QW134
  };

  // 3. Lecture des 5 registres pour TOUS les équipements
  for (var entry in equipments.entries) {
    final name = entry.key;
    final baseAddress = entry.value;

    print('\n=== $name (Adresses: $baseAddress à ${baseAddress + 4}) ===');

    for (var i = 0; i < 5; i++) {
      final currentAddress = baseAddress + i;

      final reg = ModbusUint16Register(
        name: '${name}_${metrics[i]}',
        address: currentAddress,
        type: ModbusElementType.holdingRegister,
        multiplier: multipliers[i],
      );

      try {
        await client.send(reg.getReadRequest());
        // Affiche le résultat formaté (ex: V : 229.5)
        print('${metrics[i]} : ${reg.value}');
      } catch (e) {
        print('Erreur lors de la lecture de ${metrics[i]} à l\'adresse $currentAddress : $e');
      }
    }
  }

  // 4. Déconnexion du serveur
  await client.disconnect();
}
