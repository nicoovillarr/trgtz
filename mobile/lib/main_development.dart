import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

import 'package:firebase_core/firebase_core.dart';
import 'package:trgtz/main_common.dart';

void main() {
  mainCommon(
    flavor: 'development',
    options: DevelopmentFirebaseOptions.currentPlatform,
  );
}

class DevelopmentFirebaseOptions {
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
    apiKey: 'AIzaSyCczsWo1oI65KXMTzz371EMFoJR2QkbLd8',
    appId: '1:1031931311990:android:6e794cb3a30823dd012c57',
    messagingSenderId: '1031931311990',
    projectId: 'marppa-trgtz-dev',
    storageBucket: 'marppa-trgtz-dev.appspot.com',
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
