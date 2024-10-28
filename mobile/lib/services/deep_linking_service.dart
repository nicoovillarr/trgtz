import 'dart:async';
import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:trgtz/app.dart';
import 'package:trgtz/screens/profile/single_profile_view.dart';
import 'package:trgtz/store/index.dart';
import 'package:trgtz/utils.dart';

class DeepLinkingService {
  DeepLinkingService._();

  static final DeepLinkingService _instance = DeepLinkingService._();

  static DeepLinkingService get instance => _instance;

  late AppLinks _appLinks;

  void init() {
    _appLinks = AppLinks();
    _initDeepLinks();
  }

  Future<void> _initDeepLinks() async {
    _appLinks.uriLinkStream.listen((Uri? uri) {
      if (uri != null) {
        _handleDeepLink(uri);
      }
    });
  }

  void _handleDeepLink(Uri uri) {
    final action = uri.pathSegments.first;
    print(action);
    switch (action) {
      case 'friends':
        final userId = uri.pathSegments.length > 1 ? uri.pathSegments[1] : null;
        if (userId == null) {
          return;
        }

        final context = navigatorKey.currentState!.overlay!.context;
        final store = StoreProvider.of<ApplicationState>(context);

        if (store.state.user == null || store.state.user!.id == userId) {
          return;
        }

        Utils.simpleBottomSheet(
          child: SingleProfileView(
            userId: userId,
            me: store.state.user!.id,
          ),
          height: MediaQuery.of(context).size.height * 0.75,
        );
        break;
      default:
        break;
    }
  }
}
