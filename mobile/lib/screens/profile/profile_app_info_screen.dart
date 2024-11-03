import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:trgtz/core/base/index.dart';

import 'package:trgtz/screens/profile/providers/index.dart';

class ProfileAppInfoScreen extends StatefulWidget {
  const ProfileAppInfoScreen({super.key});

  @override
  State<ProfileAppInfoScreen> createState() => _ProfileAppInfoScreenState();
}

class _ProfileAppInfoScreenState extends BaseScreen<ProfileAppInfoScreen> {
  late final ProfileAppInfoProvider viewModel;

  @override
  void customInitState() {
    viewModel = context.read<ProfileAppInfoProvider>();
  }

  @override
  Future loader() async {
    await viewModel.populate();
  }

  @override
  Widget body(BuildContext context) =>
      Selector<ProfileAppInfoProvider, ProfileAppInfoModel?>(
        selector: (_, provider) => provider.appInfo,
        builder: (_, appInfo, __) => SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildInfoItem('App Name', appInfo!.appName),
              _buildInfoItem('Package Name', appInfo.packageName),
              _buildInfoItem('Version', appInfo.version),
              _buildInfoItem('Build Number', appInfo.buildNumber),
              _buildInfoItem('Firebase Token', appInfo.firebaseToken ?? 'N/A'),
            ],
          ),
        ),
      );

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
            SizedBox(
              width: double.infinity,
              child: InkWell(
                onTap: () => _copyToClipboard(value),
                borderRadius: BorderRadius.circular(4.0),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8.0,
                    vertical: 4.0,
                  ),
                  child: Text(
                    value,
                    style: const TextStyle(
                      fontSize: 14.0,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      );

  @override
  String get title => 'Application';
  
  void _copyToClipboard(String value) {
    Clipboard.setData(ClipboardData(text: value));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Copied to clipboard'),
      ),
    );
  }
}
