import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

import 'package:firebase_core/firebase_core.dart';
import 'package:trgtz/main_common.dart';

void main() async {
  mainCommon(
    flavor: 'staging',
    options: StagingFirebaseOptions.currentPlatform,
  );
}

class StagingFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError(
        'DefaultFirebaseOptions have not been configured for web - '
        'you can reconfigure this by running the FlutterFire CLI again.',
      );
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDlpdgnY577cMCh0xAAjnVE-zeJzx3mteE',
    appId: '1:974339063072:android:f4c1b21a83fea78f9fab45',
    messagingSenderId: '974339063072',
    projectId: 'marppa-trgtz-stg',
    storageBucket: 'marppa-trgtz-stg.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDuTlcuErPfbACY5mQsleA3QF-kHTkmpD0',
    appId: '1:872940828539:ios:6b789ddc1ed0b78323afde',
    messagingSenderId: '872940828539',
    projectId: 'marppa-trgtz',
    storageBucket: 'marppa-trgtz.appspot.com',
    iosBundleId: 'com.marppa.trgtz',
  );
}
