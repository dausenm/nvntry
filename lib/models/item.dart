import 'package:hive/hive.dart';

part 'item.g.dart'; // generated file

@HiveType(typeId: 0)
class Item extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  String category;

  @HiveField(3)
  int quantity;

  Item({
    required this.id,
    required this.name,
    required this.category,
    required this.quantity,
  });
}
