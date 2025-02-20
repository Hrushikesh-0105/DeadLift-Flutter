// import 'package:flutter/cupertino.dart';
import 'dart:ui';

import 'package:deadlift/database_helper/getxController.dart';
import 'package:deadlift/orientation/orientationHelper.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:deadlift/pages/splashScreen.dart';
import 'package:get/get.dart';

// import 'package:get/get_core/src/get_main.dart';
//using GetMaterialApp instead of Material app to show snakbar

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };

  // await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await Get.putAsync(() async => DatabaseController());
  runApp(GetMaterialApp(
      builder: (context, child) {
        // Set orientation globally based on device type
        OrientationManager.setOrientation(context);
        return child!;
      },
      // scaffoldMessengerKey: GlobalSnackbarState().scaffoldMessengerKey,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
          textTheme: const TextTheme(
        headlineLarge: TextStyle(
          color: Colors.white,
          fontFamily: "poppins",
          fontSize: 40,
        ),
        bodyMedium: TextStyle(
          color: Colors.white,
          fontFamily: "poppins",
          fontSize: 32,
        ),
      )),
      home: const SplashScreen()));
}
