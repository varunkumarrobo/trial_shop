import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/products_provider.dart';
import '../widgets/app_drawer.dart';
import '../widgets/user_products_item.dart';
import 'edit_product.dart';

class UserProductsScreen extends StatelessWidget {
  const UserProductsScreen({super.key});

  static const routeName = '/user-products';

  Future<void> _refershProducts(BuildContext context) async {
    await Provider.of<Products>(context, listen: false)
        .fetchAndSetProducts(true);
  }

  @override
  Widget build(BuildContext context) {
    // final productsData = Provider.of<Products>(context);
    log('re-Building....');
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Products'),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).pushNamed(EditProductScreen.routeName);
            },
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      drawer:   AppDrawer(),
      body: FutureBuilder(
        future: _refershProducts(context),
        builder: (ctx, snapshot) =>
            snapshot.connectionState == ConnectionState.waiting
                ? const Center(
                    child: CircularProgressIndicator(),
                  )
                : RefreshIndicator(
                    onRefresh: () => _refershProducts(context),
                    child: Consumer<Products>(
                      builder: (
                        ctx,
                        productsData,
                        _,
                      ) =>
                          Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ListView.builder(
                          itemCount: productsData.items.length,
                          itemBuilder: (_, i) => Column(
                            children: [
                              UserProdutcsItem(
                                id: productsData.items[i].id.toString(),
                                title: productsData.items[i].title,
                                imageUrl: productsData.items[i].imageUrl,
                              ),
                              const Divider(),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
      ),
    );
  }
}
