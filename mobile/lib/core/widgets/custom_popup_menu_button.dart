import 'package:flutter/material.dart';

class MenuItem {
  String title;
  void Function() onTap;
  bool enabled;

  MenuItem({
    required this.title,
    required this.onTap,
    this.enabled = true,
  });
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
              enabled: items[i].enabled,
              child: Text(items[i].title),
            )
        ],
        onSelected: (int index) => items[index].onTap(),
      );
}
