import 'package:flutter/material.dart';

class MenuItem {
  String title;
  void Function() onTap;

  MenuItem({required this.title, required this.onTap});
}

class CustomPopUpMenuButton extends StatelessWidget {
  final List<MenuItem> items;

  const CustomPopUpMenuButton({
    super.key,
    required this.items,
  });

  @override
  Widget build(BuildContext context) => PopupMenuButton(
        itemBuilder: (_) => [
          for (int i = 0; i < items.length; i++)
            PopupMenuItem(
              value: i,
              child: Text(items[i].title),
            )
        ],
        onSelected: (int index) => items[index].onTap(),
      );
}
