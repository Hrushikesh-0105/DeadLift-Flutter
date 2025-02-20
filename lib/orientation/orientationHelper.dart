import 'package:deadlift/database_helper/getxController.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
// import 'package:get/get_core/src/get_main.dart';

class OrientationManager {
  static void setOrientation(BuildContext context) {
    final DatabaseController dbController = Get.put(DatabaseController());
    // Check the size of the device
    final size = MediaQuery.of(context).size;

    // Determine if the device is a tablet
    bool isTablet =
        (size.shortestSide >= 600); // A common threshold for tablets

    // Set the preferred orientation
    if (isTablet) {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
      dbController.isTablet.value = true;
    } else {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);
    }
  }
}
