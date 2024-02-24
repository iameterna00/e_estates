import 'package:hive/hive.dart';

class UserDataServide {
  static const String _boxName = 'userBox';

  static Future<void> SaveUserData(String key, dynamic value) async {
    final Box box = await Hive.openBox(_boxName);
    await box.put(key, value);
    await box.close();
  }

  static Future<dynamic> getUserData(String key) async {
    final Box box = await Hive.openBox(_boxName);
    final value = box.get(key);
    await box.close();
    return value;
  }
}
