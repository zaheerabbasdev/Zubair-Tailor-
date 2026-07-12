import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppLockProvider extends ChangeNotifier {
  static const _pinKey = 'app_lock_pin';
  final _secureStorage = const FlutterSecureStorage();

  bool _isEnabled = false;

  bool get isEnabled => _isEnabled;

  AppLockProvider() {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    _isEnabled = prefs.getBool('lock_enabled') ?? false;
    notifyListeners();
  }

  Future<void> setPin(String pin) async {
    await _secureStorage.write(key: _pinKey, value: pin);
    _isEnabled = true;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('lock_enabled', true);
    notifyListeners();
  }

  Future<void> disable() async {
    await _secureStorage.delete(key: _pinKey);
    _isEnabled = false;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('lock_enabled', false);
    notifyListeners();
  }

  Future<bool> verifyPin(String pin) async {
    final stored = await _secureStorage.read(key: _pinKey);
    return stored != null && stored == pin;
  }
}
