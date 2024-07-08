import 'package:flutter/material.dart';

abstract class BaseFragment extends StatefulWidget {
  final void Function(String name) enimtAction;
  const BaseFragment({
    super.key,
    required this.enimtAction,
  });
}

abstract class BaseFragmentState<T extends BaseFragment> extends State<T> {}
