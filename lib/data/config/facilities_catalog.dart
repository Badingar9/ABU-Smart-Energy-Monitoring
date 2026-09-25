import 'package:scada_app/models/equipment.dart';

class FacilitiesSpec {
  final String id;
  final String title;
  final String buildingSpecId;
  final Zone zone;
  final List<Equipment> equipments;

  const FacilitiesSpec({required this.id, required this.title, required this.buildingSpecId, required this.zone,  required this.equipments, });

  String get name => zone.name;
}
