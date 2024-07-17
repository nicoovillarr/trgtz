import 'package:flutter/material.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:trgtz/services/firebase_helper.service.dart';

class DeviceInformationService {
  final BuildContext context;

  const DeviceInformationService({
    required this.context,
  });

  factory DeviceInformationService.of(BuildContext context) {
    return DeviceInformationService(context: context);
  }

  Future getDeviceInfo() async {
    final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
    if (Theme.of(context).platform == TargetPlatform.android) {
      return _readAndroidBuildData(await deviceInfoPlugin.androidInfo);
    } else if (Theme.of(context).platform == TargetPlatform.iOS) {
      return _readIosDeviceInfo(await deviceInfoPlugin.iosInfo);
    }
  }

  Future<Map<String, dynamic>> _readAndroidBuildData(
      AndroidDeviceInfo build) async {
    return <String, dynamic>{
      'firebaseToken': await FirebaseHelperService.token,
      'type': 'Android',
      'version': build.version.release,
      'manufacturer': build.manufacturer,
      'model': build.model,
      'isVirtual': build.isPhysicalDevice,
      'serialNumber': build.serialNumber,
    };
  }

  Future<Map<String, dynamic>> _readIosDeviceInfo(IosDeviceInfo data) async {
    return <String, dynamic>{
      'firebaseToken': await FirebaseHelperService.token,
      'type': 'iOS',
      'version': data.systemVersion,
      'manufacturer': 'Apple',
      'model': data.utsname.machine,
      'isVirtual': !data.isPhysicalDevice,
      'serialNumber': data.identifierForVendor,
    };
  }
}
