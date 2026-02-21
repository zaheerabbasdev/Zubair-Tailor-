import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleProvider extends ChangeNotifier {
  Locale _locale = const Locale('en');

  Locale get locale => _locale;

  LocaleProvider() {
    _loadLocale();
  }

  Future<void> _loadLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final languageCode = prefs.getString('language_code') ?? 'en';
    _locale = Locale(languageCode);
    notifyListeners();
  }

  void setLocale(Locale locale) async {
    _locale = locale;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language_code', _locale.languageCode);
    notifyListeners();
  }

  void toggleLocale() async {
    _locale = _locale.languageCode == 'en' ? const Locale('ur') : const Locale('en');
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language_code', _locale.languageCode);
    notifyListeners();
  }
}
