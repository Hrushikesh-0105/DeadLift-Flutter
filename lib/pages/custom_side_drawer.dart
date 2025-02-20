import 'package:deadlift/database_helper/database_helper.dart';
import 'package:deadlift/pages/login_page.dart';
// import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CustomSideDrawer extends StatefulWidget {
  const CustomSideDrawer({super.key});

  @override
  State<CustomSideDrawer> createState() => _CustomSideDrawerState();
}

class _CustomSideDrawerState extends State<CustomSideDrawer> {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.grey[900],
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            decoration: BoxDecoration(
              color: Colors.grey[900],
              border: Border.all(width: 0, color: Colors.transparent),
            ),
            currentAccountPictureSize: Size(80, 80),
            accountName: const Text(
              "Admin",
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontFamily: 'poppins'),
            ),
            accountEmail: null,
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.transparent,
              child: Image.asset("assets/images/deadLiftLogo.png"),
            ),
          ),

          Expanded(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(
                    Icons.message,
                    color: Colors.white,
                  ),
                  title: const Text(
                    'Custom Messages',
                    style: TextStyle(color: Colors.white),
                  ),
                  onTap: () {},
                ),
              ],
            ),
          ),

          // Bottom Actions
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.grey[900],
            ),
            child: ListTile(
              leading: const Icon(
                Icons.logout,
                color: Colors.white,
              ),
              title: const Text(
                'Logout',
                style: TextStyle(color: Colors.white),
              ),
              onTap: () async {
                await removeUser();
                navigateToLoginPage();
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> removeUser() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(sharedPrefKeys.loggedIn);
    await prefs.setBool(sharedPrefKeys.isAdmin, false);
  }

  void navigateToLoginPage() {
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => const LoginPage()));
  }
}
