

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/cart.dart';

class CartItem extends StatelessWidget {
  const CartItem(
    this.id,
    this.productId,
    this.price,
    this.quantity,
    this.title, {
    super.key,
  });

  final String id;
  final String productId;
  final double price;
  final int quantity;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      confirmDismiss: (direction) {
       return showDialog(
          context: context, 
          builder: (ctx) {
            return AlertDialog(
              title: const Text('Are you sure?'),
              content: const Text('Do you want to remove the item from the cart?'),
              actions: [
                TextButton(
                  onPressed: (){
                    Navigator.of(ctx).pop(false);
                  }, 
                  child: const Text('No'),
                  ),
                  TextButton(
                  onPressed: (){
                    Navigator.of(ctx).pop(true);

                  }, 
                  child: const Text('Yes'),
                  ),
              ],
            );
          },);
      },
      direction: DismissDirection.endToStart,
      onDismissed: (direction) {
        Provider.of<Cart>(context,listen: false).removeItem(productId);
      },
      key: ValueKey(id),
      background: Container(color: Theme.of(context).colorScheme.error,
      alignment: Alignment.centerRight,
      margin: const EdgeInsets.symmetric(
          horizontal: 15,
          vertical: 4,
        ),
      padding: const EdgeInsets.only(right: 20),
      child:  const Icon(Icons.delete,
      color: Colors.white,
      size: 40,),
      ),
      child: Card(
        margin: const EdgeInsets.symmetric(
          horizontal: 15,
          vertical: 4,
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Theme.of(context).colorScheme.primary,
              child: Padding(
                padding: const EdgeInsets.all(4.0),
                child: FittedBox(
                  child: Text(
                    '\$$price',
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ),
            title: Text(title),
            subtitle: Text('Total: \$${(price * quantity).toStringAsFixed(2)}'),
            trailing: Text('$quantity x'),
          ),
        ),
      ),
    );
  }
}
