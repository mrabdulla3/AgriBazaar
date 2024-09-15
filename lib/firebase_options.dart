// File generated by FlutterFire CLI.
// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
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
        return windows;
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
    apiKey: 'AIzaSyDmaJC8-5BrvLsf4QhMmdVKmoE4T1BLlDE',
    appId: '1:445090650606:web:8c30e2001fad4b708716ff',
    messagingSenderId: '445090650606',
    projectId: 'agribazar-4ad4b',
    authDomain: 'agribazar-4ad4b.firebaseapp.com',
    storageBucket: 'agribazar-4ad4b.appspot.com',
    measurementId: 'G-L51DXNHJ6B',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDz2UdhOSU_dNQLbkP_RIi-ue2y0dBzw78',
    appId: '1:445090650606:android:b54741a6d27a807a8716ff',
    messagingSenderId: '445090650606',
    projectId: 'agribazar-4ad4b',
    storageBucket: 'agribazar-4ad4b.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDNdTbWnoD-VtvKWAcDrLS1YQ-BNhn_9Vc',
    appId: '1:445090650606:ios:2fc13e1d7b9270208716ff',
    messagingSenderId: '445090650606',
    projectId: 'agribazar-4ad4b',
    storageBucket: 'agribazar-4ad4b.appspot.com',
    iosBundleId: 'com.example.agribazar',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyDNdTbWnoD-VtvKWAcDrLS1YQ-BNhn_9Vc',
    appId: '1:445090650606:ios:2fc13e1d7b9270208716ff',
    messagingSenderId: '445090650606',
    projectId: 'agribazar-4ad4b',
    storageBucket: 'agribazar-4ad4b.appspot.com',
    iosBundleId: 'com.example.agribazar',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyDmaJC8-5BrvLsf4QhMmdVKmoE4T1BLlDE',
    appId: '1:445090650606:web:e007b4dd1bbc30ba8716ff',
    messagingSenderId: '445090650606',
    projectId: 'agribazar-4ad4b',
    authDomain: 'agribazar-4ad4b.firebaseapp.com',
    storageBucket: 'agribazar-4ad4b.appspot.com',
    measurementId: 'G-JLS46S1RZY',
  );
}
