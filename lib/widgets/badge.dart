import 'package:flutter/material.dart';


class BadgeWidget extends StatelessWidget {
  const BadgeWidget(
    this.color, {
    super.key,
    required this.child,
    required this.value,
  });

  final Widget child;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        child,
        Positioned(
          right: 10,
          top: 10,
          child: Container(
            padding: const EdgeInsets.all(2.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10.0),
              // ignore: prefer_if_null_operators, unnecessary_null_comparison
              color: color != null
                  ? color
                  : Theme.of(context).colorScheme.secondary,
            ),
            constraints: const BoxConstraints(
              minWidth: 16,
              minHeight: 16,
            ),
            child: Text(
              value,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 10,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
