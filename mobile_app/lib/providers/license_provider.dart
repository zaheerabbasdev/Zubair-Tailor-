import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LicenseProvider extends ChangeNotifier {
  static const _keyFirstLaunch = 'license_first_launch';
  static const _keyActivated = 'license_activated';

  static const int trialDays = 7;

  // Shared unlock code given to shop owners once they pay. Change it here
  // (and tell shop owners the new code) if it needs to be rotated.
  static const String unlockCode = 'ZAHEERTECH2026';

  DateTime? _firstLaunch;
  bool _activated = false;

  bool get isActivated => _activated;

  int get daysRemaining {
    if (_firstLaunch == null) return trialDays;
    final elapsed = DateTime.now().difference(_firstLaunch!).inDays;
    final remaining = trialDays - elapsed;
    return remaining < 0 ? 0 : remaining;
  }

  bool get isTrialExpired {
    if (_activated) return false;
    if (_firstLaunch == null) return false;
    return DateTime.now().difference(_firstLaunch!).inDays >= trialDays;
  }

  LicenseProvider() {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    _activated = prefs.getBool(_keyActivated) ?? false;

    final stored = prefs.getString(_keyFirstLaunch);
    if (stored != null) {
      _firstLaunch = DateTime.tryParse(stored);
    } else {
      _firstLaunch = DateTime.now();
      await prefs.setString(_keyFirstLaunch, _firstLaunch!.toIso8601String());
    }
    notifyListeners();
  }

  Future<bool> activate(String code) async {
    if (code.trim().toUpperCase() != unlockCode) return false;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyActivated, true);
    _activated = true;
    notifyListeners();
    return true;
  }
}
