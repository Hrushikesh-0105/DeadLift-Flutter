import 'package:deadlift/database_helper/database_helper.dart';
import 'package:deadlift/pages/edit_customer.dart';
import 'package:deadlift/style.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:deadlift/database_helper/getxController.dart';

class ViewCustomerDialog extends StatefulWidget {
  final String customerId;
  const ViewCustomerDialog({required this.customerId, super.key});

  @override
  State<ViewCustomerDialog> createState() => _ViewCustomerDialogState();
}

class _ViewCustomerDialogState extends State<ViewCustomerDialog> {
  final DatabaseController dbController = Get.put(DatabaseController());

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      Map<String, dynamic> customerMap =
          dbController.getCustomerById(widget.customerId);
      return Dialog(
        backgroundColor: const Color(0xff1c1c1c),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          width: MediaQuery.of(context).size.width * 0.4,
          padding: const EdgeInsets.all(20),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        customerMap[DatabaseHelper.columnFullName],
                        style: headlineLarge(),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () => Navigator.of(context).pop(),
                    )
                  ],
                ),
                const SizedBox(height: 15),
                Row(
                  children: [
                    const Icon(
                      Icons.phone,
                      color: Colors.white70,
                      size: 20,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      customerMap[DatabaseHelper.columnPhoneNumber],
                      style: style5().copyWith(color: Colors.white70),
                    )
                  ],
                ),
                if (customerMap[DatabaseHelper.columnEmailId].isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(
                        Icons.email_outlined,
                        color: Colors.white70,
                        size: 20,
                      ),
                      const SizedBox(width: 5),
                      Expanded(
                        child: Text(
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          customerMap[DatabaseHelper.columnEmailId],
                          style: style5().copyWith(color: Colors.white70),
                        ),
                      )
                    ],
                  ),
                ],
                const Divider(color: Colors.grey, height: 30),
                Text("Membership", style: bodyMeduim()),
                const SizedBox(height: 10),
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
                    const SizedBox(width: 5),
                    Row(
                      children: [
                        Text(
                          customerMap[DatabaseHelper.columnStatus],
                          style: style5(),
                        ),
                        const SizedBox(width: 5),
                        daysLeftOrExpiredSinceTextWidget(
                          customerMap[DatabaseHelper.columnStatus],
                          customerMap[DatabaseHelper.columnDueDate],
                        )
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 15),
                InfoText(
                    label: "Payment Date",
                    value: displayDateString(
                        customerMap[DatabaseHelper.columnPaymentDate])),
                const SizedBox(height: 8),
                InfoText(
                    label: "Due Date",
                    value: displayDateString(
                        customerMap[DatabaseHelper.columnDueDate])),
                const SizedBox(height: 8),
                InfoText(
                    label: "Paid Amount",
                    value: "₹${customerMap[DatabaseHelper.columnPaidAmount]}"),
                const SizedBox(height: 8),
                InfoText(
                    label: "Due Amount",
                    value: "₹${customerMap[DatabaseHelper.columnDueAmount]}"),
                const SizedBox(height: 8),
                InfoText(
                    label: "Mode",
                    value: "${customerMap[DatabaseHelper.columnPaymentMode]}"),
                const SizedBox(height: 8),
                InfoText(
                    label: "Trainer",
                    value: "${customerMap[DatabaseHelper.columnTrainer]}"),
                const SizedBox(height: 8),
                InfoText(
                    label: "Collected By",
                    value: "${customerMap[DatabaseHelper.columnUpdatedBy]}"),
                const SizedBox(height: 20),
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => EditCustomerPage(
                                  editCustomer: true,
                                  editCustomerid:
                                      customerMap[DatabaseHelper.columnId])));
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF424242),
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
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        ),
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

// InfoText widget remains the same
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
            text: "$label: ",
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
