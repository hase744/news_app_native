import 'package:shared_preferences/shared_preferences.dart';
class History{
  SharedPreferences? _preferences;

  // Initialize SharedPreferences
  Future<void> initialize() async {
    _preferences = await SharedPreferences.getInstance();
  }

  // Getter for a specific value in SharedPreferences
   getStoredValue(String key)  {
    print(_preferences?.getString(key));
    return _preferences?.getString(key);
  }

  // Setter to store a value in SharedPreferences
  Future<void> setStoredValue(String key, String value) async {
    await _preferences?.setString(key, value);
  }
}