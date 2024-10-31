import 'package:hive_flutter/hive_flutter.dart';
import 'package:recoface/models/user.dart';

class HiveBoxes {
  static const userDetails = "user_details";
  static const listUserDetails = "list_user_details";

  static Box userDetailsBox() => Hive.box(userDetails);
  static Box listUserDetailsBox() => Hive.box(listUserDetails);

  static closeUserDetailsBox() => HiveBoxes.userDetailsBox().close();
  static closeListUserDetailsBox() => HiveBoxes.listUserDetailsBox().close();

  static initialize() async {
    await Hive.openBox(userDetails);
    await Hive.openBox(listUserDetails);
  }

  static clearAllBox() async {
    await HiveBoxes.userDetailsBox().clear();
    await HiveBoxes.listUserDetailsBox().clear();
  }
}

class LocalDb {
  //
  static void saveUser(User user) => HiveBoxes.listUserDetailsBox().add(user.toJson());

  static List<User> getUsers() => HiveBoxes.listUserDetailsBox().values.map((i) => User.fromJson(i)).toList();

  static User foundUser(List array) => HiveBoxes.listUserDetailsBox()
      .values
      .where((w) => User.fromJson(w).array == array)
      .map((i) => User.fromJson(i))
      .first;

  static void deleteUser(int element) => HiveBoxes.listUserDetailsBox().deleteAt(element);
  
  //
  static User getUser() => User.fromJson(HiveBoxes.userDetailsBox().toMap());

  static String getUserName() => HiveBoxes.userDetailsBox().toMap()[User.nameKey];

  static String getUserArray() => HiveBoxes.userDetailsBox().toMap()[User.arrayKey];

  static setUserDetails(User user) => HiveBoxes.userDetailsBox().putAll(user.toJson());
}
