// import 'package:flutter/cupertino.dart';
// ignore_for_file: use_build_context_synchronously, unused_local_variable
//!update this getcustomer function, not working

// import 'dart:math';
import 'package:deadlift/config/secrets.dart';
import 'package:deadlift/custom_widgets/customCircularProgressIndicator.dart';
import 'package:deadlift/custom_widgets/paymentModeSelector.dart';
// import 'package:deadlift/custom_widgets/payment_mode_radio_button.dart';
import 'package:deadlift/database_helper/getxController.dart';
import 'package:deadlift/debugFunctions/debugLog.dart';
import 'package:deadlift/firebase_helper/custom_firebase_Api.dart';
import 'package:deadlift/google_sheet_helper/google_sheet_helper.dart';
import 'package:deadlift/message_Helper/message_helper.dart';
import 'package:flutter/material.dart';
import 'package:deadlift/custom_widgets/snack_bar.dart';
// import 'package:flutter/widgets.dart';
// import 'package:deadlift/customer_records.dart';
import 'package:deadlift/database_helper/database_helper.dart';

import 'package:deadlift/style.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
// import 'package:get/get_core/src/get_main.dart';

class EditCustomerPage extends StatefulWidget {
  final bool editCustomer;
  final String editCustomerid;
  const EditCustomerPage(
      {super.key, required this.editCustomer, required this.editCustomerid});

  @override
  State<EditCustomerPage> createState() => _EditCustomerPageState();
}

class _EditCustomerPageState extends State<EditCustomerPage> {
  int? membership;
  TextEditingController fullName = TextEditingController();
  TextEditingController phoneNumber = TextEditingController();
  TextEditingController emailId = TextEditingController();
  TextEditingController paidAmount = TextEditingController();
  TextEditingController dueAmount = TextEditingController();
  TextEditingController paymentDateDisplay = TextEditingController();
  DateTime? paymentDate;
  TextEditingController dueDateDisplay = TextEditingController();
  DateTime? dueDate;
  String paymentMode = PaymentMode.cash;
  String? selectedTrainer;
  List<String> trainersList = [
    "Prasad",
    "Bhanu",
    "Mustaq",
    "Ali",
    "Gopi",
    "Pintu",
    "Nitesh",
    "Prasad",
    "Prashanth",
    "Maniya Chauhan"
  ];
  String? selectedUpdatedBy;
  List<String> updatedByList = ["Shiva", "Krishna", "Santosh"];

  // textfield outline colors
  Color fullNameColor = lightGrey;
  Color phoneNumberColor = lightGrey;
  Color paidAmountColor = lightGrey;
  Color dueAmountColor = lightGrey;
  Color membershipColor = lightGrey;
  Color paymentDateColor = lightGrey;
  Color dueDateColor = lightGrey;
  Color updatedByTextFieldColor = lightGrey;
  Color trainerTextFieldColor = lightGrey;
  bool isLoading = false;
  //Database getx controller
  final DatabaseController dbController = Get.put(DatabaseController());

  @override
  void initState() {
    if (widget.editCustomer) {
      getCustomerInfo();
    }
    super.initState();
  }

  @override
  void dispose() {
    fullName.dispose();
    phoneNumber.dispose();
    emailId.dispose();
    paidAmount.dispose();
    dueAmount.dispose();
    paymentDateDisplay.dispose();
    dueDateDisplay.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenheight = MediaQuery.of(context).size.height;
    return Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_new,
              color: Colors.white,
              size: 32,
            ),
            onPressed: (!isLoading) ? () => {Navigator.pop(context)} : null,
          ),
          title: Container(
            // color: Colors.black,
            margin: const EdgeInsets.fromLTRB(0, 10, 0, 0),
            child: Text(
              "DEADLIFT FITNESS STUDIO",
              style: dbController.isTablet.value
                  ? headlineLarge()
                  : headlineMedium(),
            ),
          ),
        ),
        body: Container(
            margin: const EdgeInsets.fromLTRB(20, 20, 20, 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Update Customer",
                    style: style1()
                        .copyWith(fontSize: 26, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                Expanded(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 650),
                    child: SingleChildScrollView(
                      child: Container(
                        margin: const EdgeInsets.all(5),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            TextField(
                              controller: fullName,
                              inputFormatters: [
                                LengthLimitingTextInputFormatter(20)
                              ],
                              decoration: textfieldstyle1(Icons.person_outlined,
                                  "Full Name", fullNameColor),
                              style: style3(),
                              cursorColor:
                                  const Color.fromARGB(255, 15, 154, 173),
                              onChanged: (value) {
                                fullNameColor =
                                    (value.isEmpty) ? Colors.red : lightGrey;
                                setState(() {});
                              },
                            ),
                            const SizedBox(
                              height: 15,
                            ),
                            TextField(
                              controller: phoneNumber,
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                                LengthLimitingTextInputFormatter(10)
                              ], // this restricts keypad to enter only digits

                              decoration: textfieldstyle1(Icons.call_outlined,
                                  "Mobile Number", phoneNumberColor),
                              style: style3(),
                              cursorColor:
                                  const Color.fromARGB(255, 15, 154, 173),
                              onChanged: (value) {
                                phoneNumberColor = (checkPhoneNumberLength())
                                    ? lightGrey
                                    : Colors.red;
                                setState(() {});
                              },
                            ),
                            const SizedBox(
                              height: 15,
                            ),
                            TextField(
                              controller: emailId,
                              keyboardType: TextInputType.emailAddress,
                              decoration: textfieldstyle1(
                                  Icons.email_outlined, "Email Id", lightGrey),
                              style: style3(),
                              cursorColor:
                                  const Color.fromARGB(255, 15, 154, 173),
                            ),
                            const SizedBox(
                              height: 15,
                            ),
                            DropdownButtonFormField(
                              value: membership,
                              items: [1, 3, 6, 12].map((int month) {
                                return DropdownMenuItem<int>(
                                    value: month,
                                    child: Row(
                                      children: [
                                        Text(
                                          "$month Month",
                                          style: style3(),
                                        ),
                                        Text(
                                          " | ${month * 30} Days",
                                          style: style3()
                                              .copyWith(color: Colors.grey),
                                        )
                                      ],
                                    ));
                              }).toList(),
                              //map() function passes each element of the list to another function which returns a widget, each widget makes up a new list
                              onChanged: (months) {
                                membership = months!;
                                membershipColor = (membership == null)
                                    ? Colors.red
                                    : lightGrey;
                                setState(() {});
                              },
                              decoration: textfieldstyle1(
                                  Icons.dehaze, "", membershipColor),
                              dropdownColor: Colors.grey[800],
                              hint: Text("Membership", style: style2()),
                              icon: const Icon(
                                Icons.arrow_drop_down,
                                size: 40,
                              ),
                            ),
                            const SizedBox(
                              height: 15,
                            ),
                            Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: paidAmount,
                                    keyboardType: TextInputType.number,
                                    inputFormatters: [
                                      FilteringTextInputFormatter.digitsOnly
                                    ],
                                    decoration: textfieldstyle1(
                                        Icons.currency_rupee_outlined,
                                        "Paid Amount",
                                        paidAmountColor),
                                    style: style3(),
                                    cursorColor:
                                        const Color.fromARGB(255, 15, 154, 173),
                                    onChanged: (value) {
                                      paidAmountColor = (value.isEmpty)
                                          ? Colors.red
                                          : lightGrey;
                                      setState(() {});
                                    },
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: TextField(
                                    controller: dueAmount,
                                    keyboardType: TextInputType.number,
                                    inputFormatters: [
                                      FilteringTextInputFormatter.digitsOnly
                                    ],
                                    decoration: textfieldstyle1(
                                        Icons.currency_rupee_outlined,
                                        "Due Amount",
                                        dueAmountColor),
                                    style: style3(),
                                    cursorColor:
                                        const Color.fromARGB(255, 15, 154, 173),
                                    onChanged: (value) {
                                      dueAmountColor = (value.isEmpty)
                                          ? Colors.red
                                          : lightGrey;
                                      setState(() {});
                                    },
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(
                              height: 15,
                            ),
                            // do date setting and other things from here
                            TextField(
                              controller: paymentDateDisplay,
                              readOnly: true,
                              onTap: () async {
                                DateTime? pickedDate = await showDatePicker(
                                    context: context,
                                    initialDate: DateTime.now(),
                                    firstDate: DateTime(2019),
                                    lastDate: DateTime(2030));
                                if (pickedDate != null) {
                                  paymentDateDisplay.text =
                                      "${pickedDate.day}/${pickedDate.month}/${pickedDate.year}";
                                  paymentDate = pickedDate;
                                  if (membership != null) {
                                    setDueDate(pickedDate, membership!);
                                  }
                                }
                                paymentDateColor = (paymentDate == null)
                                    ? Colors.red
                                    : lightGrey;
                                setState(() {});
                              },
                              decoration: textfieldstyle1(
                                  Icons.edit_calendar_rounded,
                                  "Payment Date",
                                  paymentDateColor),
                              style: style3(),
                            ),
                            const SizedBox(
                              height: 15,
                            ),
                            TextField(
                              controller: dueDateDisplay,
                              readOnly: true,
                              onTap: () async {
                                DateTime? pickedDate = await showDatePicker(
                                    context: context,
                                    initialDate: DateTime.now(),
                                    firstDate: DateTime(2019),
                                    lastDate: DateTime(2030));
                                if (pickedDate != null) {
                                  dueDateDisplay.text =
                                      "${pickedDate.day}/${pickedDate.month}/${pickedDate.year}";
                                  dueDate = pickedDate;
                                }
                                dueDateColor =
                                    (dueDate == null) ? Colors.red : lightGrey;
                                setState(() {});
                              },
                              decoration: textfieldstyle1(
                                  Icons.free_cancellation_outlined,
                                  "Due Date",
                                  dueDateColor),
                              style: style3(),
                            ),
                            const SizedBox(
                              height: 15,
                            ),
                            DropdownButtonFormField<String>(
                                value: selectedTrainer,
                                items: trainersList.map((trainer) {
                                  return DropdownMenuItem<String>(
                                    value: trainer,
                                    child: Text(trainer),
                                  );
                                }).toList(),
                                onChanged: (value) {
                                  setState(() {
                                    selectedTrainer = value;
                                  });
                                },
                                decoration: textfieldstyle1(
                                    Icons.sports_gymnastics,
                                    "Trainer",
                                    trainerTextFieldColor),
                                dropdownColor: Colors.grey[800],
                                hint: Text("", style: style2()),
                                icon: const Icon(
                                  Icons.arrow_drop_down,
                                  size: 40,
                                ),
                                style: const TextStyle(
                                  color: Colors.white,
                                )),
                            const SizedBox(
                              height: 15,
                            ),
                            DropdownButtonFormField<String>(
                                value: selectedUpdatedBy,
                                items: updatedByList.map((updatedBy) {
                                  return DropdownMenuItem<String>(
                                    value: updatedBy,
                                    child: Text(updatedBy),
                                  );
                                }).toList(),
                                onChanged: (value) {
                                  setState(() {
                                    selectedUpdatedBy = value;
                                  });
                                },
                                decoration: textfieldstyle1(
                                    Icons.person_pin_outlined,
                                    "Collected By",
                                    updatedByTextFieldColor),
                                dropdownColor: Colors.grey[800],
                                hint: Text("", style: style2()),
                                icon: const Icon(
                                  Icons.arrow_drop_down,
                                  size: 40,
                                ),
                                style: const TextStyle(
                                  color: Colors.white,
                                )),

                            PaymentModeSelector(
                              onModeSelected: (value) {
                                paymentMode = value;
                                setState(() {});
                              },
                              initialMode: paymentMode,
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    InkWell(
                      onTap: (!isLoading)
                          ? () {
                              clearEntry();
                              setState(() {});
                            }
                          : null,
                      child: Container(
                        constraints: const BoxConstraints(maxWidth: 140),
                        height: 36,
                        width: screenWidth * 0.5,
                        // decoration: BoxDecoration(
                        //     //color: Colors.red[600],
                        //     color: const Color.fromARGB(255, 60, 60, 60),
                        //     borderRadius: BorderRadius.circular(8)),
                        child: Center(
                          child: Text(
                            "Clear",
                            style: style4().copyWith(
                                fontSize: 18, color: Colors.grey.shade600),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    InkWell(
                      onTap: (!isLoading)
                          ? () async {
                              if (checkAllTextFields()) {
                                setState(() {
                                  isLoading = true;
                                });
                                bool updated = await update();
                                if (updated) {
                                  CustomSnackbar.showSnackbar(
                                      type: SnackbarType.success,
                                      message: "Customer details updated");
                                  Navigator.pop(context);
                                } else {
                                  CustomSnackbar.showSnackbar(
                                      type: SnackbarType.failure,
                                      message: "Failed to update customer");
                                  setState(() {
                                    isLoading = false;
                                  });
                                }
                              } else {
                                CustomSnackbar.showSnackbar(
                                    type: SnackbarType.failure,
                                    message: "Fill the required fields");
                              }
                            }
                          : null,
                      child: Container(
                        constraints: const BoxConstraints(maxWidth: 140),
                        height: 36,
                        width: screenWidth * 0.5,
                        // decoration: saveButtonStyle(),
                        child: Center(
                          child: (!isLoading)
                              ? Text(
                                  "Update",
                                  style: style4().copyWith(
                                      fontSize: 18, color: Color(0xff1A936F)),
                                )
                              : const Customcircularprogressindicator(),
                        ),
                      ),
                    ),
                  ],
                ),
                // const SizedBox(
                //   height: 40,
                // ),
              ],
            )));
  }

  bool checkAllTextFields() {
    fullNameColor = (fullName.text.isEmpty) ? Colors.red : lightGrey;
    phoneNumberColor = (phoneNumber.text.length != 10) ? Colors.red : lightGrey;
    membershipColor = (membership == null) ? Colors.red : lightGrey;
    paidAmountColor = (paidAmount.text.isEmpty) ? Colors.red : lightGrey;
    // dueAmountColor = (dueAmount.text.isEmpty) ? Colors.red : lightGrey;
    paymentDateColor = (paymentDate == null) ? Colors.red : lightGrey;
    dueDateColor = (dueDate == null) ? Colors.red : lightGrey;
    updatedByTextFieldColor =
        (selectedUpdatedBy == null) ? Colors.red : lightGrey;
    trainerTextFieldColor = (selectedTrainer == null) ? Colors.red : lightGrey;
    if (dueAmount.text.isEmpty) {
      dueAmount.text = "0";
    }

    setState(() {});
    if (fullName.text.isEmpty ||
        phoneNumber.text.length != 10 ||
        membership == null ||
        paidAmount.text.isEmpty ||
        dueAmount.text.isEmpty ||
        paymentDate == null ||
        dueDate == null ||
        selectedTrainer == null ||
        selectedUpdatedBy == null) {
      return false;
    }
    return true;
  }

  void clearEntry() {
    fullName.clear();
    phoneNumber.clear();
    emailId.clear();
    membership = null;
    paidAmount.clear();
    dueAmount.clear();
    paymentDateDisplay.clear();
    dueDateDisplay.clear();
    paymentDate = null;
    dueDate = null;
    paymentMode = PaymentMode.cash;
    selectedTrainer = null;
    selectedUpdatedBy = null;
  }

  // Future<bool> save() async {
  //   bool saved = false;
  //   bool storedInOnlineDb = false;
  //   String currentStatus = setStatus();
  //   //rowId is not same as the customer id
  //   String newCustomerId = await generateRandomId();
  //   Map<String, dynamic> currentData = {
  //     DatabaseHelper.columnId: newCustomerId,
  //     DatabaseHelper.columnFullName: fullName.text,
  //     DatabaseHelper.columnPhoneNumber: phoneNumber.text,
  //     DatabaseHelper.columnEmailId: emailId.text,
  //     DatabaseHelper.columnMembership: membership,
  //     DatabaseHelper.columnPaidAmount: paidAmount.text,
  //     DatabaseHelper.columnDueAmount: dueAmount.text,
  //     DatabaseHelper.columnPaymentDate: paymentDate.toString(),
  //     DatabaseHelper.columnDueDate: dueDate.toString(),
  //     DatabaseHelper.columnPaymentMode: paymentMode,
  //     DatabaseHelper.columnStatus: currentStatus,
  //   };
  //   storedInOnlineDb = await CustomFirebaseApi().createDocument(currentData);
  //   await GoogleSheetHelper().appendRow(currentData);

  //   if (storedInOnlineDb) {
  //     debugLog("stored In online db");
  //     try {
  //       //! db related
  //       await dbController.addCustomer(currentData);
  //       saved = true;
  //       debugLog("stored in offline db");
  //       debugLog("${dbController.customers}");
  //     } catch (e) {
  //       debugLog("Error: $e");
  //     }
  //   }
  //   return saved;
  // }

  Future<void> getCustomerInfo() async {
    //! db related complete this function
    Map<String, dynamic> result =
        dbController.getCustomerById(widget.editCustomerid);
    debugLog("$result");
    if (result.isNotEmpty) {
      fullName.text = result[DatabaseHelper.columnFullName];
      phoneNumber.text = result[DatabaseHelper.columnPhoneNumber];
      emailId.text = result[DatabaseHelper.columnEmailId];
      membership = result[DatabaseHelper.columnMembership];
      paidAmount.text = "${result[DatabaseHelper.columnPaidAmount]}";
      dueAmount.text = "${result[DatabaseHelper.columnDueAmount]}";
      paymentDate = DateTime.parse(result[DatabaseHelper.columnPaymentDate]);
      if (paymentDate != null) {
        paymentDateDisplay.text =
            "${paymentDate!.day}/${paymentDate!.month}/${paymentDate!.year}";
      }
      dueDate = DateTime.parse(result[DatabaseHelper.columnDueDate]);
      if (dueDate != null) {
        dueDateDisplay.text =
            "${dueDate!.day}/${dueDate!.month}/${dueDate!.year}";
      }
      paymentMode = result[DatabaseHelper.columnPaymentMode];
      selectedTrainer = result[DatabaseHelper.columnTrainer];
      selectedUpdatedBy = result[DatabaseHelper.columnUpdatedBy];
      setState(() {});
    }
  }

  Future<bool> update() async {
    bool dataUpdated = false;
    bool dataUpdatedInOnlineDb = false;
    bool storedInGoogleSheet = false;
    String currentStatus = setStatus();
    Map<String, dynamic> updatedData = {
      DatabaseHelper.columnId: widget.editCustomerid,
      DatabaseHelper.columnFullName: fullName.text.trim(),
      DatabaseHelper.columnPhoneNumber: phoneNumber.text.trim(),
      DatabaseHelper.columnEmailId: emailId.text.trim(),
      DatabaseHelper.columnMembership: membership,
      DatabaseHelper.columnPaidAmount: paidAmount.text,
      DatabaseHelper.columnDueAmount: dueAmount.text,
      DatabaseHelper.columnPaymentDate: paymentDate.toString(),
      DatabaseHelper.columnDueDate: dueDate.toString(),
      DatabaseHelper.columnPaymentMode: paymentMode,
      DatabaseHelper.columnStatus: currentStatus,
      //added below
      DatabaseHelper.columnUpdatedBy: selectedUpdatedBy,
      DatabaseHelper.columnTrainer: selectedTrainer,
    };
    // !db related
    dataUpdatedInOnlineDb = await CustomFirebaseApi()
        .updateData(widget.editCustomerid, updatedData);
    if (dataUpdatedInOnlineDb) {
      storedInGoogleSheet =
          await storeMemberShipDetailsInGoogleSheet(updatedData);
    }

    if (!storedInGoogleSheet) {
      debugLog("Failed to store in google sheet");
      CustomSnackbar.showSnackbar(
          type: SnackbarType.failure,
          message: "Failed to store in google sheet");
      //show snakbar that failed to save in google sheet
    }
    if (dataUpdatedInOnlineDb) {
      sendMessage(updatedData);
    }
    return dataUpdatedInOnlineDb;
  }

  Future<bool> storeMemberShipDetailsInGoogleSheet(
      Map<String, dynamic> membershipData) async {
    debugLog("Entering google sheet member function");
    bool storedInGoogleSheet = false;
    String paymentDateString = DateFormat('dd/MM/yyyy')
        .format(
            DateTime.parse(membershipData[DatabaseHelper.columnPaymentDate]))
        .toString();
    String dueDateString = DateFormat('dd/MM/yyyy')
        .format(DateTime.parse(membershipData[DatabaseHelper.columnDueDate]))
        .toString();
    Map<String, String> rowMap = {
      "Id": membershipData[DatabaseHelper.columnId],
      "FullName": membershipData[DatabaseHelper.columnFullName],
      "MobileNumber": membershipData[DatabaseHelper.columnPhoneNumber],
      "MembershipPlan":
          "${membershipData[DatabaseHelper.columnMembership]} month",
      "PaidAmount": membershipData[DatabaseHelper.columnPaidAmount],
      "DueAmount": membershipData[DatabaseHelper.columnDueAmount],
      "PaymentDate": paymentDateString,
      "DueDate": dueDateString,
      "PaymentMode": membershipData[DatabaseHelper.columnPaymentMode],
      "CollectedBy": membershipData[DatabaseHelper.columnUpdatedBy],
      "TrainerName": membershipData[DatabaseHelper.columnTrainer]
    };
    storedInGoogleSheet = await GoogleSheetHelper()
        .appendRow(rowMap, Secrets.paymentdetailsGoogleSheet);
    return storedInGoogleSheet;
  }

  void setDueDate(DateTime pickedDate, int membership) {
    Map<int, int> daysCalander = {
      1: 31,
      2: 28,
      3: 31,
      4: 30,
      5: 31,
      6: 30,
      7: 31,
      8: 31,
      9: 30,
      10: 31,
      11: 30,
      12: 31
    };
    int noOfDaysLeft = membership * 30;

    int dueDay = pickedDate.day;
    int dueMonth = pickedDate.month;
    int dueYear = pickedDate.year;

    while (noOfDaysLeft != 0) {
      if ((dueYear % 4 == 0 && dueYear % 100 != 0) || dueYear % 400 == 0) {
        daysCalander[2] = 29;
      } else {
        daysCalander[2] = 28;
      }
      dueDay = dueDay + noOfDaysLeft;
      if (dueDay > daysCalander[dueMonth]!) {
        noOfDaysLeft = dueDay - daysCalander[dueMonth]!;
        dueDay = 0;
        ++dueMonth;
        if (dueMonth > 12) {
          dueMonth = 1;
          ++dueYear;
        }
      } else {
        noOfDaysLeft = 0;
      }
    }
    // debugLog("$dueDay/$dueMonth/$dueYear");
    dueDate = DateTime(dueYear, dueMonth, dueDay);
    dueDateDisplay.text = "${dueDate!.day}/${dueDate!.month}/${dueDate!.year}";
  }

  String setStatus() {
    DateTime currentDate = DateTime.now();
    String currentStatus;
    if (currentDate.difference(dueDate!).inDays >= 90) {
      currentStatus = CustomerStatus.inactive;
    } else if (dueDate!.isBefore(currentDate)) {
      currentStatus = CustomerStatus.expired;
    } else {
      currentStatus = CustomerStatus.active;
    }
    return currentStatus;
  }

  bool checkPhoneNumberLength() {
    if (phoneNumber.text.length == 10) {
      return true;
    } else {
      // ScaffoldMessenger.of(context)
      //     .showSnackBar(customSnackBar("Enter 10 digit phone number"));
      return false;
    }
  }

  Future<void> sendMessage(Map<String, dynamic> customerMap) async {
    String phoneNumber = customerMap[DatabaseHelper.columnPhoneNumber];
    String message = createMessage(customerMap);
    bool smsSent = false;
    debugLog("${message.length}");
    smsSent = await SendMessage.smsMessage(phoneNumber, message);
    if (smsSent) {
      CustomSnackbar.showSnackbar(
          type: SnackbarType.success, message: "Sms sent");
    } else {
      CustomSnackbar.showSnackbar(
          type: SnackbarType.failure, message: "Failed to send Sms");
    }
    //send whatsapp message
    bool whatsappMessageSent =
        await SendMessage.whatsappMessage(phoneNumber, message);
    if (whatsappMessageSent) {
      CustomSnackbar.showSnackbar(
          type: SnackbarType.success, message: "Notified on whatsapp");
    } else {
      CustomSnackbar.showSnackbar(
          type: SnackbarType.failure, message: "Failed to open Whatsapp");
    }
  }

  String createMessage(Map<String, dynamic> customerMap) {
    String name = customerMap[DatabaseHelper.columnFullName];
    String amount = customerMap[DatabaseHelper.columnPaidAmount];
    String paymentDateString = DateFormat('dd/MM/yyyy')
        .format(DateTime.parse(customerMap[DatabaseHelper.columnPaymentDate]))
        .toString();
    String dueDateString = DateFormat('dd/MM/yyyy')
        .format(DateTime.parse(customerMap[DatabaseHelper.columnDueDate]))
        .toString();
    debugLog("${customerMap[DatabaseHelper.columnPaymentDate]}");
    debugLog("${customerMap[DatabaseHelper.columnDueDate]}");
    String message =
        "Hello $name, we have received your payment of Rs.$amount on $paymentDateString.\nYour membership is now active till $dueDateString.\nDeadlift Fitness Studio";
    debugLog("Message length: ${message.length}");
    debugLog("Message: $message");
    return message;
  }

  // Future<String> generateRandomId() async {
  //   //get ids from offline first
  //   List<String> existingIds = dbController.getAllIds();
  //   // debugLog("Existing ids:${existingIds}");
  //   String newId;
  //   final random = Random();
  //   do {
  //     int id = random.nextInt(10000); // Generate a random 4-digit integer
  //     newId =
  //         "${CustomerId.baseId}${id.toString().padLeft(4, '0')}"; // Concatenate "DDLT" with 4-digit ID
  //   } while (existingIds.contains(newId));
  //   return newId; // Concatenate "DDLT" with 4-digit ID
  // }
}
