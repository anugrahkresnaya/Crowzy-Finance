import 'package:flutter/material.dart';

class IconMapper {
  IconMapper._();

  static const Map<String, IconData> _icons = {
    'work': Icons.work,
    'store': Icons.store,
    'card_giftcard': Icons.card_giftcard,
    'attach_money': Icons.attach_money,
    'restaurant': Icons.restaurant,
    'directions_car': Icons.directions_car,
    'shopping_bag': Icons.shopping_bag,
    'receipt_long': Icons.receipt_long,
    'movie': Icons.movie,
    'local_hospital': Icons.local_hospital,
    'school': Icons.school,
    'category': Icons.category,
    'savings': Icons.savings,
    'home': Icons.home,
    'flight': Icons.flight,
    'pets': Icons.pets,
    'fitness_center': Icons.fitness_center,
    'sports_esports': Icons.sports_esports,
  };

  static IconData iconFor(String key) => _icons[key] ?? Icons.category;

  static List<String> get keys => _icons.keys.toList(growable: false);
}
