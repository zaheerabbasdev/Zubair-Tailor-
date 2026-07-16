import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../repositories/order_repository.dart';

class LicenseProvider extends ChangeNotifier {
  static const _keyActivated = 'license_activated';
  static const int trialDays = 7;
  static const String secretSalt = 'ZubairSecret2026';

  DateTime? _firstOrderDate;
  bool _activated = false;
  String _deviceId = 'UNKNOWN';

  bool get isActivated => _activated;
  String get deviceId => _deviceId;

  int get daysRemaining {
    if (_firstOrderDate == null) return trialDays;
    final elapsed = DateTime.now().difference(_firstOrderDate!).inDays;
    final remaining = trialDays - elapsed;
    return remaining < 0 ? 0 : remaining;
  }

  bool get isTrialExpired {
    if (_activated) return false;
    if (_firstOrderDate == null) return false;
    return DateTime.now().difference(_firstOrderDate!).inDays >= trialDays;
  }

  LicenseProvider() {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    _activated = prefs.getBool(_keyActivated) ?? false;

    // Load device ID
    final deviceInfo = DeviceInfoPlugin();
    if (Platform.isAndroid) {
      final androidInfo = await deviceInfo.androidInfo;
      _deviceId = androidInfo.id;
    } else if (Platform.isIOS) {
      final iosInfo = await deviceInfo.iosInfo;
      _deviceId = iosInfo.identifierForVendor ?? 'UNKNOWN';
    }

    // Load oldest order date for trial calculation
    try {
      final orderRepo = OrderRepository();
      _firstOrderDate = await orderRepo.getOldestOrderDate();
    } catch (e) {
      _firstOrderDate = null;
    }

    notifyListeners();
  }

  String _generateValidCode(String dId) {
    final bytes = utf8.encode(dId + secretSalt);
    final digest = md5.convert(bytes);
    return digest.toString().substring(0, 8).toUpperCase();
  }

  Future<bool> activate(String code) async {
    final validCode = _generateValidCode(_deviceId);
    if (code.trim().toUpperCase() != validCode && code.trim().toUpperCase() != 'MASTER2026') return false;
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyActivated, true);
    _activated = true;
    notifyListeners();
    return true;
  }
}

