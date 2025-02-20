import 'package:deadlift/database_helper/database_helper.dart';
// import 'package:deadlift/firebase_helper/custom_firebase_Api.dart';
import 'package:deadlift/pages/edit_customer.dart';
import 'package:deadlift/style.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:deadlift/database_helper/getxController.dart';

class ViewCustomerWindow extends StatefulWidget {
  final String customerId;
  final VoidCallback closeWindow;
  const ViewCustomerWindow(
      {required this.customerId, required this.closeWindow, super.key});

  @override
  State<ViewCustomerWindow> createState() => _ViewCustomerWindowState();
}

class _ViewCustomerWindowState extends State<ViewCustomerWindow> {
  final DatabaseController dbController = Get.put(DatabaseController());

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      Map<String, dynamic> customerMap =
          dbController.getCustomerById(widget.customerId);
      return LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          // double parentWidth = constraints.maxWidth;
          // double parentHeight = constraints.maxHeight;

          return Container(
            // color: Colors.blue,
            padding: const EdgeInsets.all(12),
            margin: const EdgeInsets.only(right: 10),
            decoration: const BoxDecoration(
                color: Color(0xff1c1c1c),
                borderRadius: BorderRadius.only(
                    topRight: Radius.circular(40),
                    bottomRight: Radius.circular(40))),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 210),
                      child: Text(
                        overflow: TextOverflow.ellipsis,
                        customerMap[DatabaseHelper.columnFullName],
                        style: headlineLarge(),
                      ),
                    ),
                    CloseButton(
                      onPressed: () => widget.closeWindow(),
                      color: Colors.white,
                      style: const ButtonStyle(
                          iconSize: WidgetStatePropertyAll(26)),
                    )
                  ],
                ),
                Row(
                  children: [
                    const Icon(
                      Icons.phone,
                      color: Colors.white70,
                      size: 20,
                    ),
                    const SizedBox(
                      width: 5,
                    ),
                    Text(
                      customerMap[DatabaseHelper.columnPhoneNumber],
                      style: style5().copyWith(color: Colors.white70),
                    )
                  ],
                ),
                if (customerMap[DatabaseHelper.columnEmailId] != "")
                  Row(
                    children: [
                      const Icon(
                        Icons.email_outlined,
                        color: Colors.white70,
                        size: 20,
                      ),
                      const SizedBox(
                        width: 5,
                      ),
                      Text(
                        customerMap[DatabaseHelper.columnEmailId],
                        style: style5().copyWith(color: Colors.white70),
                      )
                    ],
                  ),
                const Divider(
                  color: Colors.grey,
                ),
                Text(
                  "Membership",
                  style: bodyMeduim(),
                ),
                Row(
                  children: [
                    Container(
                      width: 10,
                      height: 18,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(50),
                        color: colorOfCustomerStatus(
                            customerMap[DatabaseHelper.columnStatus]),
                      ),
                    ),
                    const SizedBox(
                      width: 5,
                    ),
                    Row(
                      children: [
                        Text(
                          customerMap[DatabaseHelper.columnStatus],
                          style: style5(),
                        ),
                        const SizedBox(
                          width: 5,
                        ),
                        daysLeftOrExpiredSinceTextWidget(
                          customerMap[DatabaseHelper.columnStatus],
                          customerMap[DatabaseHelper.columnDueDate],
                        )
                      ],
                    ),
                  ],
                ),
                InfoText(
                    label: "Payment Date",
                    value: displayDateString(
                        customerMap[DatabaseHelper.columnPaymentDate])),
                InfoText(
                    label: "Due Date",
                    value: displayDateString(
                        customerMap[DatabaseHelper.columnDueDate])),
                InfoText(
                    label: "Paid Amount",
                    value: "₹${customerMap[DatabaseHelper.columnPaidAmount]}"),
                InfoText(
                    label: "Due Amount",
                    value: "₹${customerMap[DatabaseHelper.columnDueAmount]}"),
                InfoText(
                    label: "Mode",
                    value: "${customerMap[DatabaseHelper.columnPaymentMode]}"),
                InfoText(
                    label: "Trainer",
                    value: "${customerMap[DatabaseHelper.columnTrainer]}"),
                InfoText(
                    label: "Collected By",
                    value: "${customerMap[DatabaseHelper.columnUpdatedBy]}"),
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      widget.closeWindow();
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => EditCustomerPage(
                                  editCustomer: true,
                                  editCustomerid:
                                      customerMap[DatabaseHelper.columnId])));
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          const Color(0xFF424242), // Light gray option
                      // OR
                      // backgroundColor: const Color(0xFF333333), // Slightly lighter than background
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(40),
                      ),
                      elevation: 2,
                      shadowColor: Colors.black.withOpacity(0.3),
                    ),
                    child: const Text(
                      'Renew',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5, // Better text readability
                      ),
                    ),
                  ),
                )
              ],
            ),
          );
        },
      );
    });
  }

  Color colorOfCustomerStatus(String status) {
    Color statusColor;
    if (status == CustomerStatus.active) {
      statusColor = activeCustomerColor;
    } else if (status == CustomerStatus.expired) {
      statusColor = expiredCustomerColor;
    } else {
      statusColor = inactiveCustomerColor;
    }
    return statusColor;
  }

  String displayDateString(String date) {
    DateTime parsedDate = DateTime.parse(date);
    return "${parsedDate.day.toString().padLeft(2, '0')}/${parsedDate.month.toString().padLeft(2, '0')}/${parsedDate.year}";
  }

  Text daysLeftOrExpiredSinceTextWidget(String status, String dueDateString) {
    String returnString;
    DateTime dueDate = DateTime.parse(dueDateString);
    if (status == CustomerStatus.active) {
      returnString =
          "(${(dueDate.difference(DateTime.now()).inHours / 24.0).ceil()} days left)";
    } else {
      returnString =
          "(Since ${(DateTime.now().difference(dueDate).inHours / 24.0).ceil()} days)";
    }
    return Text(
      returnString,
      style: style5(),
    );
  }
}

class InfoText extends StatelessWidget {
  final String label;
  final String value;

  const InfoText({
    required this.label,
    required this.value,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: label + ": ",
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 16,
              fontWeight: FontWeight.w400,
            ),
          ),
          TextSpan(
            text: value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
