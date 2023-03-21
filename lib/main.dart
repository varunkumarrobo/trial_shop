import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; 

import 'providers/auth.dart';
import 'providers/cart.dart';
import 'providers/orders.dart';
import 'providers/products_provider.dart';
import 'screens/auth_screen.dart';
import 'screens/cart_screen.dart';
import 'screens/edit_product.dart';
import 'screens/orders_screen.dart';
import 'screens/product_detail_screen.dart';
import 'screens/products_overview_screen.dart';
import 'screens/splash_screen.dart';
import 'screens/user_products_screen.dart';

void main() {
  runApp(
    const MyApp(),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => Auth(),
        ),
        ChangeNotifierProxyProvider<Auth, Products>(
          update: (ctx, authValue, previousProducts) => Products(
            authValue.token.toString(),
            previousProducts == null ? [] : previousProducts.items,
            authValue.userId,
          ),
          create: (ctx) => Products(
            '',
            [],
            '',
          ),
        ),
        ChangeNotifierProvider(
          create: (ctx) => Cart(),
        ),
        ChangeNotifierProxyProvider<Auth, Orders>(
          update: (ctx, authValue, previousOrders) => Orders(
            authValue.token.toString(),
            previousOrders == null ? [] : previousOrders.orders,
            authValue.userId,
          ),
          create: (ctx) => Orders(
            '',
            [],
            '',
          ),
        ),
      ],
      child: Consumer<Auth>(
        builder: (ctx, authData, _) => MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Flutter Demo',
          theme: ThemeData(
            colorScheme: ColorScheme.fromSwatch().copyWith(
              primary: Colors.orange,
              secondary: Colors.greenAccent, // Your accent color
            ),
          ),
          home: authData.isAuth
              ? const ProductsOverviewScreen()
              : FutureBuilder(
                  future: authData.tryAutoLogin(),
                  builder: (ctx, authResultSnapshot) =>
                      authResultSnapshot.connectionState ==
                              ConnectionState.waiting
                          ? const SplashScreen()
                          : const AuthScreen(),
                ),
          routes: {
            ProductDetailScreen.routeName: (ctx) => const ProductDetailScreen(),
            CartScreen.routeName: (ctx) => const CartScreen(),
            OrdersScreen.routeName: (ctx) => const OrdersScreen(),
            EditProductScreen.routeName: (ctx) => const EditProductScreen(),
            UserProductsScreen.routeName: (ctx) => const UserProductsScreen(),
          },
        ),
      ),
    );
  }
}
