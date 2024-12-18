import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:trgtz/constants.dart';
import 'package:trgtz/models/index.dart';
import 'package:trgtz/services/index.dart';
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

final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();

abstract class BaseScreen<T extends StatefulWidget> extends State<T>
    with RouteAware {
  ScreenState _state = ScreenState.loading;
  User? _user;
  late Store<ApplicationState> _store;
  final Map<String, String> channelsSubscribed = {};

  final Map<String, StreamSubscription> _subscriptions = {};

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final ModalRoute? modalRoute = ModalRoute.of(context);
    if (modalRoute is PageRoute) {
      routeObserver.subscribe(this, modalRoute);
    }
  }

  @override
  void initState() {
    super.initState();
    customInitState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _store = StoreProvider.of<ApplicationState>(context);
      _user = _store.state.user;

      setIsLoading(true);
      loader().then((_) {
        setIsLoading(false);
        afterFirstBuild(context).then((_) {
          initSubscriptions();
          setState(() => _state = ScreenState.ready);
        });
      });
    });
  }

  @override
  void dispose() {
    _disposeSubscriptions();
    _disposeChannelsSubscriptions();
    super.dispose();
  }

  void initSubscriptions() {}

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    Widget? body = _state == ScreenState.loading
        ? const Center(
            child: CircularProgressIndicator(),
          )
        : this.body(context);
    if (body != null && onRefresh != null) {
      body = RefreshIndicator(
        onRefresh: onRefresh!,
        child: body,
      );
    }
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
                elevation: 0,
                actions: actions,
                backgroundColor: Colors.white,
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
                child: body ?? const SizedBox.shrink(),
              ),
          ],
        ),
      ),
    ]);
  }

  Widget? body(BuildContext context) => null;

  void customInitState() {}

  void subscribeToChannel(String channelType, String documentId,
      Function(WebSocketMessage) onMessage) {
    channelsSubscribed[channelType] = documentId;
    WebSocketService.getInstance()
        .subscribe(channelType, documentId, onMessage);
  }

  void unsuscribeToChannel(String channelType, String id) {
    if (channelsSubscribed.containsKey(channelType)) {
      WebSocketService.getInstance()
          .unsubscribe(channelType, channelsSubscribed[channelType]!);
    }
  }

  Future loader() async {}

  Future afterFirstBuild(BuildContext context) async {}

  void simpleBottomSheet({
    Widget? child,
    Widget Function(BuildContext, Widget?)? builder,
    String? title,
    double height = 350,
    Color backgroundColor = const Color(0xFFFFFFFF),
  }) {
    assert(child != null || builder != null,
        'child or builder should be provided');
    builder ??= (context, child) => SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (title != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: Text(title),
                ),
              child!,
            ],
          ),
        );
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      enableDrag: true,
      backgroundColor: Colors.white,
      useRootNavigator: false,
      elevation: 20,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16.0),
          topRight: Radius.circular(16.0),
        ),
      ),
      builder: (BuildContext context) {
        final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
        final screenHeight = MediaQuery.of(context).size.height;
        final maxHeight = (screenHeight * 0.875) - keyboardHeight;
        return Container(
          margin: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          height: height > 0 ? min(height, maxHeight) : null,
          color: backgroundColor,
          width: MediaQuery.of(context).size.width,
          child: builder!(context, child),
        );
      },
    );
  }

  void simpleBottomSheetOptions({
    required List<BottomModalOption> options,
    String? title,
  }) {
    simpleBottomSheet(
      title: title,
      child: Material(
        child: Column(
          children: options
              .map(
                (option) => Container(
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: mainColor.withOpacity(0.25),
                      ),
                    ),
                  ),
                  child: ListTile(
                    title: Text(
                      option.title,
                      textAlign: TextAlign.center,
                    ),
                    tileColor: mainColor.withOpacity(0.025),
                    onTap: () {
                      Navigator.of(context).pop();
                      option.onTap();
                    },
                  ),
                ),
              )
              .toList(),
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

  void showSnackBar(
    String message, {
    SnackBarAction? action,
    BuildContext? context,
  }) {
    ScaffoldMessenger.of(context ?? this.context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
        action: action,
      ),
    );
  }

  void dismissKeyboard() => FocusScope.of(context).unfocus();

  Color get backgroundColor => const Color(0xFFF5F5F5);

  Store<ApplicationState> get store => _store;

  bool get useAppBar => true;

  bool get addBackButton => true;

  String? get title => appName;

  User? get user => _user;

  List<Widget> get actions => [];

  FloatingActionButton? get fab => null;

  BottomNavigationBar? get bottomNavigationBar => null;

  RefreshCallback? get onRefresh => null;

  Size get size => MediaQuery.of(context).size;

  void addSubscription(String name, StreamSubscription subscription) {
    _subscriptions[name] = subscription;
  }

  void _disposeSubscriptions() {
    _subscriptions.forEach((key, value) {
      value.cancel();
    });
  }

  void _disposeChannelsSubscriptions() {
    channelsSubscribed.forEach((key, value) {
      WebSocketService.getInstance().unsubscribe(key, value);
    });
  }
}
