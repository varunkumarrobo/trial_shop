import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/orders.dart' show Orders;
import '../widgets/app_drawer.dart';
import '../widgets/order_item.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  static const routeName = '/orders';

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  
  Future _orderFuture = Future(() {});

  Future _obtainOrdersFuture(){
    return Provider.of<Orders>(context, listen: false).fetchAndSetOrders();
  }


  @override
  void initState() {
    _orderFuture = _obtainOrdersFuture(); 
    super.initState();
  }



  @override
  Widget build(BuildContext context) {
    // final ordersData = Provider.of<Orders>(context);
    log('building orders');
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Orders'),
      ),
      drawer:   AppDrawer(),
      body: FutureBuilder(
        future: _orderFuture,
        builder: (ctx, snapshotData) {
          if (snapshotData.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } 
          // else if (snapshotData.hasError) {
          //   return const Center(
          //     child: Text("Please Make an Orders to View Order's"),
          //   );
          // }
           else {
            return Consumer<Orders>(builder: (context, ordersData, _) {
              return ListView.builder(
                itemCount: ordersData.orders.length,
                itemBuilder: (context, i) => OrderItem(
                  ordersData.orders[i],
                ),
              );
            });
          }
        },
      ),
    );
  }
}
