import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class CartItem {
  final String name;
  final String price;
  final String emoji;
  final String unit;
  final String weight;
  int quantity;

  CartItem({
    required this.name,
    required this.price,
    required this.emoji,
    required this.unit,
    required this.weight,
    this.quantity = 1,
  });

  int get priceInt => int.parse(price.replaceAll('₹', ''));
  int get total => priceInt * quantity;

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'price': price,
      'emoji': emoji,
      'unit': unit,
      'weight': weight,
      'quantity': quantity,
    };
  }

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      name: json['name'],
      price: json['price'],
      emoji: json['emoji'],
      unit: json['unit'],
      weight: json['weight'],
      quantity: json['quantity'] ?? 1,
    );
  }
}

class CartProvider extends ChangeNotifier {
  final List<CartItem> _items = [];
  static const String _cartKey = 'skyfresh_cart';

  List<CartItem> get items => _items;

  int get totalItems => _items.fold(0, (sum, item) => sum + item.quantity);

  int get totalPrice => _items.fold(0, (sum, item) => sum + item.total);

  CartProvider() {
    _loadCart();
  }

  Future<void> _loadCart() async {
    final prefs = await SharedPreferences.getInstance();
    final cartJson = prefs.getString(_cartKey);
    if (cartJson != null) {
      try {
        final List<dynamic> decoded = jsonDecode(cartJson);
        _items.clear();
        _items.addAll(decoded.map((item) => CartItem.fromJson(item)));
        notifyListeners();
      } catch (e) {
        print('Error loading cart: $e');
      }
    }
  }

  Future<void> _saveCart() async {
    final prefs = await SharedPreferences.getInstance();
    final cartJson = jsonEncode(_items.map((item) => item.toJson()).toList());
    await prefs.setString(_cartKey, cartJson);
  }

  void addItem(Map<String, dynamic> product, {String? weight}) {
    final selectedWeight = weight ?? (product['category'] == 'Fruits' ? '250g' : product['unit'].toString());
    final baseWeight = _gramsIn(product['unit'].toString());
    final requestedWeight = _gramsIn(selectedWeight);
    final basePrice = int.parse(product['price'].toString().replaceAll(RegExp(r'[^0-9]'), ''));
    final selectedPrice = baseWeight > 0 && requestedWeight > 0
        ? (basePrice * requestedWeight / baseWeight).round()
        : basePrice;
    final existing = _items.where((i) => i.name == product['name'] && i.weight == selectedWeight);
    if (existing.isNotEmpty) {
      existing.first.quantity++;
    } else {
      _items.add(CartItem(
        name:  product['name'],
        price: '₹$selectedPrice',
        emoji: product['emoji'],
        unit:  product['unit'],
        weight: selectedWeight,
      ));
    }
    notifyListeners();
    _saveCart();
  }

  int _gramsIn(String value) {
    final match = RegExp(r'(\d+)\s*g', caseSensitive: false).firstMatch(value);
    if (match != null) return int.parse(match.group(1)!);
    final kg = RegExp(r'(\d+)\s*kg', caseSensitive: false).firstMatch(value);
    return kg == null ? 0 : int.parse(kg.group(1)!) * 1000;
  }

  void removeItem(String name, String weight) {
    _items.removeWhere((i) => i.name == name && i.weight == weight);
    notifyListeners();
    _saveCart();
  }

  void increment(String name, String weight) {
    final item = _items.firstWhere((i) => i.name == name && i.weight == weight);
    item.quantity++;
    notifyListeners();
    _saveCart();
  }

  void decrement(String name, String weight) {
    final item = _items.firstWhere((i) => i.name == name && i.weight == weight);
    if (item.quantity > 1) {
      item.quantity--;
    } else {
      _items.remove(item);
    }
    notifyListeners();
    _saveCart();
  }

  void clear() {
    _items.clear();
    notifyListeners();
    _saveCart();
  }
}
