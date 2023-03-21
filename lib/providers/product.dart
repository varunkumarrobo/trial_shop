import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Product with ChangeNotifier {
  final String? id;
  final String title;
  final String description;
  final double price;
  final String imageUrl;
  bool isFavorite;

  Product({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.imageUrl,
    this.isFavorite = false,
  });

  void _setFavValue(bool newValue) {
    isFavorite = newValue;
    notifyListeners();
  }

  Future<void> toggleFavoriteStatus(String token, String userId) async {
    log(isFavorite.toString());
    final oldStauts = isFavorite;
    isFavorite = !isFavorite;
    notifyListeners();
    final sendFavorite = json.encode(isFavorite);
    final url = Uri.parse(
      'https://trial-shop-54709-default-rtdb.asia-southeast1.firebasedatabase.app/userFavorites/$userId/$id.json?auth=$token',
    );
    try {
      final response = await http.put(
        url,
        body: sendFavorite,
      );
      if (response.statusCode >= 400) {
        _setFavValue(oldStauts);
      }
    } catch (e) {
      _setFavValue(oldStauts);
    }
  }
}
