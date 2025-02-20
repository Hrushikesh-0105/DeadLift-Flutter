import 'dart:ui';

import 'package:deadlift/database_helper/database_helper.dart';
import 'package:deadlift/orientation/orientationHelper.dart';
// import 'package:deadlift/pages/custom_side_drawer.dart';
import 'package:deadlift/pages/customer_details_enroll_page.dart';
import 'package:deadlift/pages/customer_records.dart';
// import 'package:deadlift/pages/membership_details_enroll_page_slidable.dart';
import 'package:deadlift/pages/home.dart';
import 'package:deadlift/pages/login_page.dart';
import 'package:deadlift/style.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:get/get.dart';
import 'package:deadlift/database_helper/getxController.dart';

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  List<Map<String, dynamic>> customerDataList = [];
  final DatabaseController dbController = Get.put(DatabaseController());

  // int? members;
  // int? active;
  // int? expired;

  PageController _pageController = PageController(initialPage: 1);
  int _currentPageIndex = 1;
  @override
  void initState() {
    // checkExpiredCustomers();
    super.initState();
    _pageController.addListener(() {
      if (_pageController.page!.toInt() != _currentPageIndex) {
        // _onPageChange(_pageController.page!.toInt());
        _currentPageIndex = _pageController.page!.toInt();
        // setState(() {});
      }
    });
  }

//grey color 60,60,60
  @override
  Widget build(BuildContext context) {
    // ignore: unused_local_variable
    OrientationManager.setOrientation(context);
    // var maxwidth = MediaQuery.of(context).size.width;
    // var maxheight = MediaQuery.of(context).size.height;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: black,
      appBar: AppBar(
        backgroundColor: black,
        title: Container(
          // color: Colors.black,
          margin: const EdgeInsets.fromLTRB(0, 10, 0, 0),
          child: Text("DEADLIFT FITNESS STUDIO",
              style: dbController.isTablet.value
                  ? headlineLarge()
                  : headlineMedium()),
        ),
        centerTitle: true,
        actions: [
          if (_currentPageIndex == 1)
            IconButton(
                onPressed: () async {
                  await removeUser();
                  navigateToLoginPage();
                },
                icon: const Icon(
                  Icons.logout,
                  color: Colors.white,
                ))
        ],
      ),
      //learn more about page view
      // drawer: Drawer(
      //   backgroundColor: Colors.grey[900],
      //   child: CustomSideDrawer(),
      // ),
      body: PageView(
        controller: _pageController,
        children: [
          CustomerDetailsEnrollPage(
            pageController: _pageController,
          ),
          myHome(),
          CustomerRecords(),
        ],
        onPageChanged: (value) {
          _currentPageIndex = value;
          setState(() {});
        },
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          // color: const Color(0xff1c1c1c),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: 16, vertical: 2), // reduced vertical padding
            child: ClipRRect(
              borderRadius: BorderRadius.circular(30),
              child: Container(
                height: 64, // explicit height
                padding: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 0), // reduced padding
                decoration: BoxDecoration(
                  color: const Color(0xff1c1c1c), // same as parent background
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.1),
                    width: 1,
                  ),
                ),
                child: BottomNavigationBar(
                  elevation: 0,
                  backgroundColor: Colors.transparent,
                  selectedItemColor: const Color(0xfff40752),
                  unselectedItemColor: Colors.grey.shade600,
                  selectedFontSize: 14,
                  unselectedFontSize: 12,
                  type: BottomNavigationBarType.fixed,
                  currentIndex: _currentPageIndex,
                  onTap: (index) {
                    _pageController.animateToPage(
                      index,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  },
                  items: [
                    BottomNavigationBarItem(
                      icon: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.all(2), // reduced padding
                        decoration: BoxDecoration(
                          color: _currentPageIndex == 0
                              ? const Color(0xfff40752).withOpacity(0.1)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.note_add_outlined),
                      ),
                      label: 'Enroll',
                    ),
                    BottomNavigationBarItem(
                      icon: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.all(2), // reduced padding
                        decoration: BoxDecoration(
                          color: _currentPageIndex == 1
                              ? const Color(0xfff40752).withOpacity(0.1)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.home),
                      ),
                      label: 'Home',
                    ),
                    BottomNavigationBarItem(
                      icon: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.all(2), // reduced padding
                        decoration: BoxDecoration(
                          color: _currentPageIndex == 2
                              ? const Color(0xfff40752).withOpacity(0.1)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.group),
                      ),
                      label: 'Customers',
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
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

/*
bottomNavigationBar: Container(
          padding: const EdgeInsets.all(8),
          margin: const EdgeInsets.fromLTRB(20, 10, 20, 10),
          height: 6.25 * maxheight / 100,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(50),
              color: const Color.fromARGB(255, 60, 60, 60)),
          child: Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: () {
                    if (_currentPageIndex != 0) {
                      setState(() {
                        _currentPageIndex = 0;
                        _pageController.animateToPage(_currentPageIndex,
                            duration: const Duration(milliseconds: 120),
                            curve: Curves.linear);
                      });
                    }
                  },
                  child: Container(
                      height: maxheight / 16,
                      decoration: _currentPageIndex == 0
                          ? bottomNavBarSelected()
                          : bottomNavBarNotSelected(),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.home,
                            color: Colors.white,
                            size: 28,
                          ),
                          Text(
                            "Home",
                            style: style1().copyWith(
                                fontSize: 20, fontWeight: FontWeight.bold),
                          )
                        ],
                      )),
                ),
              ),
              Expanded(
                child: InkWell(
                  onTap: () {
                    if (_currentPageIndex != 1) {
                      setState(() {
                        _currentPageIndex = 1;
                        _pageController.animateToPage(_currentPageIndex,
                            duration: const Duration(milliseconds: 120),
                            curve: Curves.linear);
                      });
                    }
                  },
                  child: Container(
                      height: maxheight / 16,
                      decoration: _currentPageIndex == 1
                          ? bottomNavBarSelected()
                          : bottomNavBarNotSelected(),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.person,
                            color: Colors.white,
                            size: 28,
                          ),
                          Text(
                            "Search",
                            style: style1().copyWith(
                                fontSize: 20, fontWeight: FontWeight.bold),
                          )
                        ],
                      )),
                ),
              ),
              Expanded(
                child: InkWell(
                  onTap: () {
                    if (_currentPageIndex != 2) {
                      setState(() {
                        _currentPageIndex = 2;
                        _pageController.animateToPage(_currentPageIndex,
                            duration: const Duration(milliseconds: 120),
                            curve: Curves.linear);
                      });
                    }
                  },
                  child: Container(
                      height: maxheight / 16,
                      decoration: _currentPageIndex == 2
                          ? bottomNavBarSelected()
                          : bottomNavBarNotSelected(),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.note_add_outlined,
                            color: Colors.white,
                            size: 28,
                          ),
                          Text(
                            "Enroll",
                            style: style1().copyWith(
                                fontSize: 20, fontWeight: FontWeight.bold),
                          )
                        ],
                      )),
                ),
              )
            ],
          ),
        )
*/