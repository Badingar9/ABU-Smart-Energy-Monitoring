
import 'package:scada_app/models/building.dart';

class BuildingSpec{
  const BuildingSpec(this.id, this.name, this.type);

  final String id;
  final String name;
  final BuildingType type;
}

const kBuildingCatalog = [
  BuildingSpec('b-cpe', 'Dept. Computer Engineering', BuildingType.department),
  BuildingSpec('b-elect', 'Dept. Electrical', BuildingType.department)
];
