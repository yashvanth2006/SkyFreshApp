import 'package:flutter/material.dart';

class CartItem {
  final String name;
  final String price;
  final String emoji;
  final String unit;
  int quantity;

  CartItem({
    required this.name,
    required this.price,
    required this.emoji,
    required this.unit,
    this.quantity = 1,
  });

  int get priceInt => int.parse(price.replaceAll('₹', ''));
  int get total => priceInt * quantity;
}

class CartProvider extends ChangeNotifier {
  final List<CartItem> _items = [];

  List<CartItem> get items => _items;

  int get totalItems => _items.fold(0, (sum, item) => sum + item.quantity);

  int get totalPrice => _items.fold(0, (sum, item) => sum + item.total);

  void addItem(Map<String, dynamic> product) {
    final existing = _items.where((i) => i.name == product['name']);
    if (existing.isNotEmpty) {
      existing.first.quantity++;
    } else {
      _items.add(CartItem(
        name:  product['name'],
        price: product['price'],
        emoji: product['emoji'],
        unit:  product['unit'],
      ));
    }
    notifyListeners();
  }

  void removeItem(String name) {
    _items.removeWhere((i) => i.name == name);
    notifyListeners();
  }

  void increment(String name) {
    final item = _items.firstWhere((i) => i.name == name);
    item.quantity++;
    notifyListeners();
  }

  void decrement(String name) {
    final item = _items.firstWhere((i) => i.name == name);
    if (item.quantity > 1) {
      item.quantity--;
    } else {
      _items.remove(item);
    }
    notifyListeners();
  }

  void clear() {
    _items.clear();
    notifyListeners();
  }
}