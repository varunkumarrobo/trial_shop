import 'dart:convert';
import 'dart:developer'; 

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../models/http_exception.dart';
import 'product.dart';

class Products with ChangeNotifier {
  List<Product> _items = [
    // Product(
    //     id: 'p1',
    //     title: 'Red Shirt',
    //     description: 'A red shirt - it is pretty red!',
    //     price: 29.99,
    //     imageUrl:
    //         'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSQqw8cOtcl69aeonuM75vXsEgDf3YhK8c7sw&usqp=CAU'),
    // Product(
    //     id: 'p2',
    //     title: 'Trousers',
    //     description: 'A nice pair of Trousers',
    //     price: 59.99,
    //     imageUrl:
    //         'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQS5HC_MDKbTSv0PCEl8z2J5qvaB8jL4hlkE8S6a5AeXGtGcBXMkSRFYz1XggYOpKcC0uU&usqp=CAU'),
    // Product(
    //     id: 'p3',
    //     title: 'Yellow Scarf',
    //     description: 'Warm and cozy - excatly what you need for the winter.',
    //     price: 19.99,
    //     imageUrl:
    //         'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSbLVyhfWIPo4IpLSkR2k8_EradhuYeQQltYw&usqp=CAU'),
    // Product(
    //     id: 'p4',
    //     title: 'A Pan',
    //     description: 'Prepare any meal you want',
    //     price: 49.99,
    //     imageUrl:
    //         'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRakoVLXLU1RMXAZ3kXp5cWgVFT7RjLZgkFsw&usqp=CAU',
    //         ),
  ];

  // var _showFavoritesOnly = false;

  final String authToken;
  final String userId;

  Products(this.authToken, this._items, this.userId);

  List<Product> get items {
    // if(_showFavoritesOnly){
    //   return _items.where((prodItem) => prodItem.isFavorite).toList();
    // }
    return [..._items];
  }

  List<Product> get favoriteItems {
    return _items.where((prodItem) => prodItem.isFavorite).toList();
  }

  Product findById(String id) {
    return _items.firstWhere(
      (prod) => prod.id == id,
    );
  }

  // void showFavoritesOnly(){
  //   _showFavoritesOnly = true;
  //   notifyListeners();
  // }

  // void showAll(){
  //   _showFavoritesOnly = false;
  //   notifyListeners();
  // }

  Future<void> fetchAndSetProducts([bool filterByUser = false]) async {
    final filterString = filterByUser ? 'orderBy="creatorId"&equalTo="$userId"' : '' ;
    var url = Uri.parse(
        'https://trial-shop-54709-default-rtdb.asia-southeast1.firebasedatabase.app/products.json?auth=$authToken&$filterString',);
    try {
      final response = await http.get(url);
      final extractedData = json.decode(response.body) as Map<String, dynamic>;
      if (extractedData == null) {
        return;
      }
        url = Uri.parse(
        'https://trial-shop-54709-default-rtdb.asia-southeast1.firebasedatabase.app/userFavorites/$userId.json?auth=$authToken',
      );
      final favoriteResponse = await http.get(url);
      final favoriteData = json.decode(favoriteResponse.body);
      final List<Product> loadedProducts = [];
      extractedData.forEach(
        (prodId, prodData) {
          loadedProducts.add(
            Product(
              id: prodId,
              title: prodData['title'],
              description: prodData['description'],
              price: prodData['price'],
              imageUrl: prodData['imageUrl'],
              isFavorite:
               favoriteData == null 
               ? false 
               : favoriteData[prodId] 
               ?? false, 
               // for favorite with this will get error inthe ,middle of the course just delete the favorite field in 
               //firebase storage then firebase itself will recreate favorite field's 
            ),
          );
        },
      );
      _items = loadedProducts;
      notifyListeners();
      log(json.decode(response.body).toString());
      log("no products ${json.decode(response.body).toString()}");
    } catch (error) {
      rethrow;
    }
  }

  Future<void> addProduct(Product product) async {
    final url = Uri.parse(
        'https://trial-shop-54709-default-rtdb.asia-southeast1.firebasedatabase.app/products.json?auth=$authToken');
    try {
      final response = await http.post(
        url,
        body: json.encode({
          'title': product.title,
          'description': product.description,
          'imageUrl': product.imageUrl,
          'price': product.price,
          'creatorId': userId,
        }),
      );
      final newProduct = Product(
        title: product.title,
        description: product.description,
        imageUrl: product.imageUrl,
        price: product.price,
        id: json.decode(response.body)['name'],
      );
      _items.add(newProduct);
      // log(newProduct.toString(),);
      // _items.insert(0,newProduct); //at the start of the list..
      notifyListeners();
    } catch (error) {
      print(error);
      rethrow;
    }
  }

  Future<void> updateProduct(String id, Product newProduct) async {
    final prodIndex = _items.indexWhere((prod) => prod.id == id);
    if (prodIndex >= 0) {
      final url = Uri.parse(
          'https://trial-shop-54709-default-rtdb.asia-southeast1.firebasedatabase.app/products/$id.json?auth=$authToken');
      final response = await http.patch(
        url,
        body: json.encode({
          'title': newProduct.title,
          'description': newProduct.description,
          'imageUrl': newProduct.imageUrl,
          'price': newProduct.price,
        }),
      );
      _items[prodIndex] = newProduct;
      notifyListeners();
    } else {
      log('.....');
    }
  }

  Future<void> deleteProduct(String id) async {
    final url = Uri.parse(
      'https://trial-shop-54709-default-rtdb.asia-southeast1.firebasedatabase.app/products/$id.json?auth=$authToken',
    );
    final exisitingProductIndex = _items.indexWhere((prod) => prod.id == id);
    Product? existingProduct = _items[exisitingProductIndex];
    _items.removeAt(exisitingProductIndex);
    notifyListeners();
    final response = await http.delete(url);
    if (response.statusCode >= 400) {
      _items.insert(exisitingProductIndex, existingProduct);
      notifyListeners();
      throw HTTPException('Could not delete product.');
    }
    existingProduct = null;
  }
}
