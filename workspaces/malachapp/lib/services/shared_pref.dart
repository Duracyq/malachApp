import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesService {
   late SharedPreferences _preferences;

   Future<SharedPreferences> get preferences async {
    _preferences ??= await SharedPreferences.getInstance();
    return _preferences;
  }
  
}