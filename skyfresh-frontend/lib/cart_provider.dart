import 'package:flutter/material.dart';

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
}

class CartProvider extends ChangeNotifier {
  final List<CartItem> _items = [];

  List<CartItem> get items => _items;

  int get totalItems => _items.fold(0, (sum, item) => sum + item.quantity);

  int get totalPrice => _items.fold(0, (sum, item) => sum + item.total);

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
  }

  void increment(String name, String weight) {
    final item = _items.firstWhere((i) => i.name == name && i.weight == weight);
    item.quantity++;
    notifyListeners();
  }

  void decrement(String name, String weight) {
    final item = _items.firstWhere((i) => i.name == name && i.weight == weight);
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
