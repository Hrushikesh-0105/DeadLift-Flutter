// ignore_for_file: file_names, camel_case_types, non_constant_identifier_names
import 'package:deadlift/database_helper/getxController.dart';
import 'package:deadlift/debugFunctions/debugLog.dart';
import 'package:flutter/material.dart';
import 'package:deadlift/style.dart';
import 'package:get/get.dart';

class myHome extends StatefulWidget {
  const myHome({super.key});

  @override
  State<myHome> createState() => _myHomeState();
}

class _myHomeState extends State<myHome> {
  final DatabaseController dbController = Get.put(DatabaseController());
  List<Map<String, dynamic>> customerDataList = [];
  // int? members;
  // int? active;
  // int? expired;
  // int? inactive;
  // int? currentMonthEarnings;
  String userStatus = "User";
  int currentPage = 0;
  @override
  void initState() {
    // UpdateDisplayData();
    userStatus = dbController.isAdmin.value ? "Admin" : "User";
    // CustomFirebaseApi().loadFirebaseData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var maxwidth = MediaQuery.of(context).size.width;
    var maxheight = MediaQuery.of(context).size.height;
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 20, 20, 8),
      // height: 84 * maxheight / 100,//for sized box
      child: Obx(() {
        debugLog("In Obx Home page");
        return Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            AdminOrUserWidget(userStatus: userStatus),
            Container(
              constraints: const BoxConstraints(maxWidth: 450),
              child: Column(
                children: [
                  SizedBox(
                      height: maxheight / 3,
                      child: Image.asset("assets/images/deadLiftLogo.png")),
                  const SizedBox(
                    height: 10,
                  ),
                  Container(
                    padding: const EdgeInsets.all(10),
                    constraints:
                        const BoxConstraints(maxWidth: 450, maxHeight: 120),
                    width: dbController.isTablet.value
                        ? maxwidth / 2
                        : double.infinity,
                    height: maxheight / 10,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: const Color(0xff242424)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          "${dbController.members.value}",
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 40,
                              fontWeight: FontWeight.w900),
                        ),
                        const SizedBox(
                          width: 5,
                        ),
                        const Text(
                          "Members",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 30,
                              fontWeight: FontWeight.w900),
                        )
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Row(
                    mainAxisAlignment: dbController.isAdmin.value
                        ? MainAxisAlignment.spaceBetween
                        : MainAxisAlignment.center,
                    children: [
                      if (dbController.isAdmin.value)
                        typeOfCustomersWidget(maxheight, maxwidth, "Active",
                            dbController.active.value),
                      typeOfCustomersWidget(maxheight, maxwidth, "Expired",
                          dbController.expired.value),
                      if (dbController.isAdmin.value)
                        typeOfCustomersWidget(maxheight, maxwidth, "Inactive",
                            dbController.inactive.value)
                    ],
                  ),
                ],
              ),
            ),
          ],
        );
      }),
    );
  }

  Column typeOfCustomersWidget(
      double maxheight, double maxwidth, String status, int numCustomers) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          constraints: const BoxConstraints(maxWidth: 150, maxHeight: 120),
          height: dbController.isTablet.value ? maxheight / 5 : maxheight / 8,
          width: dbController.isTablet.value ? maxwidth / 10 : maxwidth * 0.28,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: const Color(0xff242424)),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                status,
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
              ),
              Text("$numCustomers",
                  style: const TextStyle(
                      fontSize: 25, fontWeight: FontWeight.w900))
            ],
          ),
        ),
      ],
    );
  }
}

class AdminOrUserWidget extends StatelessWidget {
  const AdminOrUserWidget({
    super.key,
    required this.userStatus,
  });

  final String userStatus;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(
          Icons.verified_user,
          color: Colors.white,
          size: 20,
        ),
        const SizedBox(
          width: 1,
        ),
        Text(
          userStatus,
          style: style1().copyWith(fontSize: 16),
        )
      ],
    );
  }
}
