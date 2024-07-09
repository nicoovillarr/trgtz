import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:trgtz/store/index.dart';

abstract class BaseFragment extends StatefulWidget {
  final void Function(String name, {dynamic data}) enimtAction;
  const BaseFragment({
    super.key,
    required this.enimtAction,
  });
}

abstract class BaseFragmentState<T extends BaseFragment> extends State<T> {
  String? _userId;

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _userId = StoreProvider.of<AppState>(context).state.user?.id;
    });
    customInitState();
    super.initState();
  }

  void customInitState() {}

  String? get userId => _userId;
}
