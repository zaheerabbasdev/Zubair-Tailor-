import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ShopProfileProvider extends ChangeNotifier {
  static const _defaultName = 'Tailor Management';

  String _shopName = _defaultName;
  String? _shopPhone;
  String? _shopAddress;

  String get shopName => _shopName;
  String? get shopPhone => _shopPhone;
  String? get shopAddress => _shopAddress;

  ShopProfileProvider() {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    _shopName = prefs.getString('shop_name') ?? _defaultName;
    _shopPhone = prefs.getString('shop_phone');
    _shopAddress = prefs.getString('shop_address');
    notifyListeners();
  }

  Future<void> updateProfile({required String shopName, String? shopPhone, String? shopAddress}) async {
    _shopName = shopName.isEmpty ? _defaultName : shopName;
    _shopPhone = shopPhone;
    _shopAddress = shopAddress;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('shop_name', _shopName);
    if (shopPhone != null && shopPhone.isNotEmpty) {
      await prefs.setString('shop_phone', shopPhone);
    } else {
      await prefs.remove('shop_phone');
    }
    if (shopAddress != null && shopAddress.isNotEmpty) {
      await prefs.setString('shop_address', shopAddress);
    } else {
      await prefs.remove('shop_address');
    }
    notifyListeners();
  }
}
