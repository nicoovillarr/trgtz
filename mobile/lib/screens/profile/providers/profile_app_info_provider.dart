import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:redux/redux.dart';
import 'package:trgtz/store/index.dart';

class ProfileAppInfoModel {
  final String appName;
  final String packageName;
  final String version;
  final String buildNumber;
  final String? firebaseToken;

  ProfileAppInfoModel({
    required this.appName,
    required this.packageName,
    required this.version,
    required this.buildNumber,
    this.firebaseToken,
  });

  ProfileAppInfoModel copyWith({
    String? appName,
    String? packageName,
    String? version,
    String? buildNumber,
    String? firebaseToken,
  }) {
    return ProfileAppInfoModel(
      appName: appName ?? this.appName,
      packageName: packageName ?? this.packageName,
      version: version ?? this.version,
      buildNumber: buildNumber ?? this.buildNumber,
      firebaseToken: firebaseToken ?? this.firebaseToken,
    );
  }
}

class ProfileAppInfoProvider extends ChangeNotifier {
  ProfileAppInfoModel? _appInfo;

  BuildContext context;

  ProfileAppInfoProvider({required this.context});

  factory ProfileAppInfoProvider.of(BuildContext context) {
    return ProfileAppInfoProvider(context: context);
  }

  ProfileAppInfoModel? get appInfo => _appInfo;

  Future<void> populate() async {
    Store<ApplicationState> store = StoreProvider.of<ApplicationState>(context);
    String? firebaseToken = store.state.firebaseToken;

    final packageInfo = await PackageInfo.fromPlatform();
    _appInfo = ProfileAppInfoModel(
      appName: packageInfo.appName,
      packageName: packageInfo.packageName,
      version: packageInfo.version,
      buildNumber: packageInfo.buildNumber,
      firebaseToken: firebaseToken,
    );
  }
}
