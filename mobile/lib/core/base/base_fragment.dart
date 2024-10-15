import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux/redux.dart';
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
      _userId = store.state.user?.id;
      afterInitState();
    });
    customInitState();
    super.initState();
  }

  void customInitState() {}

  void afterInitState() {}

  String? get userId => _userId;

  Store<ApplicationState> get store => StoreProvider.of<ApplicationState>(context);
}
