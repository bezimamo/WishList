import 'package:hive/hive.dart';

part 'friend.g.dart'; // This will be generated automatically

@HiveType(typeId: 0)
class Friend {
  @HiveField(0)
  String name;

  @HiveField(1)
  String image;

  @HiveField(2)
  String wish;

  Friend({required this.name, required this.image, required this.wish});
}
