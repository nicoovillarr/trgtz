import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:trgtz/constants.dart';
import 'package:trgtz/store/index.dart';
import 'package:redux/redux.dart';

enum ScreenState { loading, ready, leaving }

class BottomModalOption {
  final String title;
  final String? tooltip;
  final Function() onTap;

  BottomModalOption({
    required this.title,
    required this.onTap,
    this.tooltip,
  });
}

abstract class BaseScreen<T extends StatefulWidget> extends State<T> {
  bool _isLoading = false;
  ScreenState _state = ScreenState.loading;
  OverlayEntry? _overlayEntry;
  String _userId = '';

  final Map<String, StreamSubscription> _subscriptions = {};

  @override
  void initState() {
    super.initState();
    customInitState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      initSubscriptions();
      _userId = StoreProvider.of<AppState>(context).state.user!.id;
      afterFirstBuild(context).then((_) {
        setState(() => _state = ScreenState.ready);
      });
    });
  }

  @override
  void dispose() {
    _disposeSubscriptions();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Stack(children: [
      Scaffold(
        appBar: useAppBar && _state != ScreenState.loading
            ? AppBar(
                leading: addBackButton
                    ? IconButton(
                        icon: const Icon(Icons.arrow_back),
                        onPressed: () => Navigator.of(context).pop(),
                      )
                    : null,
                title: title != null ? Text(title!) : null,
                elevation: 1,
                actions: actions,
              )
            : null,
        floatingActionButton: _state != ScreenState.loading ? fab : null,
        backgroundColor: backgroundColor,
        bottomNavigationBar: bottomNavigationBar,
        body: Stack(
          children: [
            if (_state != ScreenState.loading)
              SizedBox(
                height: size.height,
                width: size.width,
                child: body(context) ?? const SizedBox.shrink(),
              ),
          ],
        ),
      ),
    ]);
  }

  Widget? body(BuildContext context) => null;

  void customInitState() {}

  void initSubscriptions() {
    addSubscription(
      'isLoading',
      store.onChange
          .map((event) => event.isLoading ?? false)
          .listen((isLoading) {
        if (isLoading != _isLoading) {
          setState(() => _isLoading = isLoading);
        }
      }),
    );
  }

  Future afterFirstBuild(BuildContext context) async {}

  void simpleBottomSheet({
    required Widget child,
    String? title,
    double height = 350,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      enableDrag: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16.0),
          topRight: Radius.circular(16.0),
        ),
      ),
      builder: (_) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (title != null) Text(title),
            SingleChildScrollView(
              child: child,
            ),
          ],
        ),
      ),
    );
  }

  void simpleBottomSheetOptions({
    required List<BottomModalOption> options,
    String? title,
    int height = 350,
  }) {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      enableDrag: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16.0),
          topRight: Radius.circular(16.0),
        ),
      ),
      builder: (_) => ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: height.toDouble(),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (title != null) Text(title),
            ...options
                .map(
                  (option) => ListTile(
                    title: Text(option.title),
                    onTap: option.onTap,
                    subtitle:
                        option.tooltip != null ? Text(option.tooltip!) : null,
                  ),
                )
                .toList(),
          ],
        ),
      ),
    );
  }

  void draggableBottomSheet(
      {required Widget child, String? title, double initialHeight = 0.5}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => Navigator.of(context).pop(),
        child: DraggableScrollableSheet(
          minChildSize: 0.25,
          maxChildSize: 0.9,
          builder: (_, controller) => Container(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(16.0),
              ),
            ),
            child: ListView(
              controller: controller,
              children: [
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 8.0),
                  width: 40.0,
                  height: 6.0,
                  decoration: BoxDecoration(
                    color: Colors.grey[800],
                    borderRadius: BorderRadius.circular(4.0),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void setIsLoading(bool isLoading) {
    if (isLoading) {
      _overlayEntry = _createOverlayEntry();
      Overlay.of(context).insert(_overlayEntry!);
    } else {
      _overlayEntry?.remove();
      _overlayEntry = null;
    }
    store.dispatch(SetIsLoadingAction(isLoading: isLoading));
  }

  void showMessage(
    String title,
    String description, {
    String positiveText = 'Ok',
    Function()? onPositiveTap,
    String? negativeText,
    Function()? onNegativeTap,
  }) =>
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(title),
          content: Text(description),
          actions: [
            if (negativeText != null)
              TextButton(
                onPressed: () => onNegativeTap != null
                    ? onNegativeTap()
                    : Navigator.of(context).pop(),
                child: Text(negativeText),
              ),
            TextButton(
              onPressed: () => onPositiveTap != null
                  ? onPositiveTap()
                  : Navigator.of(context).pop(),
              child: Text(positiveText),
            ),
          ],
        ),
      );

  void showSnackBar(String message, {SnackBarAction? action}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
        action: action,
      ),
    );
  }

  void dismissKeyboard() => FocusScope.of(context).unfocus();

  Color get backgroundColor => Colors.white;

  Store<AppState> get store => StoreProvider.of<AppState>(context);

  bool get useAppBar => true;

  bool get addBackButton => true;

  String? get title => appName;

  String get userId => _userId;

  List<Widget> get actions => [];

  FloatingActionButton? get fab => null;

  BottomNavigationBar? get bottomNavigationBar => null;

  void addSubscription(String name, StreamSubscription subscription) {
    _subscriptions[name] = subscription;
  }

  void _disposeSubscriptions() {
    _subscriptions.forEach((key, value) {
      value.cancel();
    });
  }

  OverlayEntry _createOverlayEntry() {
    return OverlayEntry(
      builder: (context) => Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              color: Colors.black.withOpacity(0.6),
              child: const Center(
                child: CircularProgressIndicator(
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
