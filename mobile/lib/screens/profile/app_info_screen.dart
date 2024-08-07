import 'dart:async';

import 'package:flutter/material.dart';
import 'package:trgtz/core/base/index.dart';

import 'package:package_info_plus/package_info_plus.dart';

class ProfileAppInfoScreen extends StatefulWidget {
  const ProfileAppInfoScreen({super.key});

  @override
  State<ProfileAppInfoScreen> createState() => _ProfileAppInfoScreenState();
}

class _ProfileAppInfoScreenState extends BaseScreen<ProfileAppInfoScreen> {
  late Stream<Map<String, dynamic>> stream;
  late StreamController<Map<String, dynamic>> streamController;

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      setIsLoading(true);
      streamController = StreamController<Map<String, dynamic>>();
      stream = streamController.stream.asBroadcastStream();

      final packageInfo = await PackageInfo.fromPlatform();
      streamController.add({
        'appName': packageInfo.appName,
        'packageName': packageInfo.packageName,
        'version': packageInfo.version,
        'buildNumber': packageInfo.buildNumber,
      });

      setIsLoading(false);
    });
    super.initState();
  }

  @override
  Widget body(BuildContext context) {
    return SingleChildScrollView(
      child: StreamBuilder(
        stream: stream,
        builder: (context, snapshot) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: snapshot.connectionState == ConnectionState.waiting
              ? []
              : [
                  _buildInfoItem('App Name', snapshot.data!['appName']),
                  _buildInfoItem('Package Name', snapshot.data!['packageName']),
                  _buildInfoItem('Version', snapshot.data!['version']),
                  _buildInfoItem('Build Number', snapshot.data!['buildNumber']),
                ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(String title, String value) => Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              value,
              style: const TextStyle(
                fontSize: 14.0,
              ),
            ),
          ],
        ),
      );

  @override
  String get title => 'Application';
}
