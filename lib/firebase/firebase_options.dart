import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

    
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
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

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyBG3jihSvrwaCok89ozLuPDJxma329-YBQ',
    appId: '1:1013674080696:web:ea08613a4d4c38699eb74d',
    messagingSenderId: '1013674080696',
    projectId: 'vote2u-6d272',
    authDomain: 'vote2u-6d272.firebaseapp.com',
    storageBucket: 'vote2u-6d272.appspot.com',
    measurementId: 'G-Q5R36CFD5N',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDws0vdCwHZD2Bv1-4Tmk9-pHgybSVM5o0',
    appId: '1:1013674080696:android:99c6bd8d938534bc9eb74d',
    messagingSenderId: '1013674080696',
    projectId: 'vote2u-6d272',
    storageBucket: 'vote2u-6d272.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAUMlxNXwPhneJi3hejh8n5hqhWJh4BWvk',
    appId: '1:1013674080696:ios:d9dd03910b78a3d79eb74d',
    messagingSenderId: '1013674080696',
    projectId: 'vote2u-6d272',
    storageBucket: 'vote2u-6d272.appspot.com',
    iosBundleId: 'com.example.vote2u',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyAUMlxNXwPhneJi3hejh8n5hqhWJh4BWvk',
    appId: '1:1013674080696:ios:644558234377004b9eb74d',
    messagingSenderId: '1013674080696',
    projectId: 'vote2u-6d272',
    storageBucket: 'vote2u-6d272.appspot.com',
    iosBundleId: 'com.example.vote2u.RunnerTests',
  );
}
