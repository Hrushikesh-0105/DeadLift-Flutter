// ignore_for_file: file_names

import 'dart:async';

import 'package:deadlift/database_helper/database_helper.dart';
import 'package:deadlift/database_helper/getxController.dart';
import 'package:deadlift/pages/base_app_layout.dart';
import 'package:deadlift/pages/login_page.dart';
import 'package:deadlift/style.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:get/get.dart';
// import 'package:get/get_core/src/get_main.dart';

void main() {
  runApp(MaterialApp(debugShowCheckedModeBanner: false, home: SplashScreen()));
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final DatabaseController dbController = Get.put(DatabaseController());
  @override
  void initState() {
    super.initState();
    navigateToNextScreen();
  }

  @override
  Widget build(BuildContext context) {
    double deviceHeight = MediaQuery.of(context).size.height;

    return Scaffold(
        backgroundColor: deadliftRedColor,
        body: Center(
          child: Image.asset(
            height: deviceHeight * 0.7,
            "assets/images/deadLiftLogo.png",
            color: Colors.white,
          ),
        ));
  }

  void navigateToNextScreen() {
    Timer(Duration(seconds: 2), () async {
      Widget nextScreen = await getNextScreen();
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => nextScreen));
    });
  }

  Future<Widget> getNextScreen() async {
    Widget nextScreen;
    bool isLoggedIn = await checkIfKeyExists();
    if (isLoggedIn) {
      nextScreen = MyApp();
      dbController.isAdmin.value = await getLoggedInStatus();
    } else {
      nextScreen = LoginPage();
    }
    return nextScreen;
  }

  Future<bool> checkIfKeyExists() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs
        .containsKey(sharedPrefKeys.loggedIn); // Returns true if the key exists
  }

  Future<bool> getLoggedInStatus() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(sharedPrefKeys.isAdmin)!;
  }
}
