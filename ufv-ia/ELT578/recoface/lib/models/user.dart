import 'package:hive/hive.dart';

@HiveType(typeId: 0)
class User extends HiveObject {
  static const String nameKey = "user_name";
  static const String arrayKey = "user_array";

  @HiveField(0)
  String? name;

  @HiveField(1)
  List? array;

  User({
    this.name,
    this.array,
  });

  factory User.fromJson(Map<dynamic, dynamic> map) => User(
        name: map[nameKey],
        array: map[arrayKey],
      );

  Map<String, dynamic> toJson() => {
        nameKey: name,
        arrayKey: array,
      };
}
