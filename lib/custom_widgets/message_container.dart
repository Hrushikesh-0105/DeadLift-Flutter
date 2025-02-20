import 'package:deadlift/custom_widgets/snack_bar.dart';
import 'package:deadlift/database_helper/database_helper.dart';
import 'package:deadlift/database_helper/getxController.dart';
import 'package:deadlift/debugFunctions/debugLog.dart';
import 'package:deadlift/message_Helper/message_helper.dart';
import 'package:deadlift/style.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
// import 'package:flutter_native_sms/flutter_native_sms.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'package:url_launcher/url_launcher.dart';

class MessageContainer extends StatefulWidget {
  final bool multiCardSelect;
  final List<String>? multiSelectedIds;
  final String? messageName;
  final String? messageNumber;
  final String? dueDate;
  final String? dueAmount;
  const MessageContainer({
    super.key,
    required this.multiCardSelect,
    this.multiSelectedIds,
    this.messageName,
    this.messageNumber,
    this.dueDate,
    this.dueAmount,
  });
  @override
  State<MessageContainer> createState() => _MessageContainerState();
}

class _MessageContainerState extends State<MessageContainer> {
  final DatabaseController dbController = Get.put(DatabaseController());

  TextEditingController messageController = TextEditingController();
  bool messageCheckBox = true;
  bool whatsappCheckBox = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if (!widget.multiCardSelect) {
      messageController.text =
          cookMessage(widget.messageName!, widget.dueAmount!, widget.dueDate!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        decoration: BoxDecoration(
          color: const Color(0xFF2A2A2A),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Color(0xFF3A3A3A),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.message_rounded,
                    color: Colors.blue,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    "Message",
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontFamily: "poppins",
                        ),
                  ),
                ],
              ),
            ),
            // Recipient Info
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: Color(0xFF404040),
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                children: [
                  const Text(
                    "TO: ",
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      fontFamily: "poppins",
                    ),
                  ),
                  if (!widget.multiCardSelect)
                    Expanded(
                      child: Text(
                        "${widget.messageName}(${widget.messageNumber})",
                        maxLines: 2,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          fontFamily: "poppins",
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  if (widget.multiCardSelect)
                    Expanded(
                      child: Text(
                        "${widget.multiSelectedIds!.length} Customers",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          fontFamily: "poppins",
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    )
                ],
              ),
            ),

            // Message Input

            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  if (!widget.multiCardSelect)
                    TextField(
                      enabled: false,
                      controller: messageController,
                      maxLines: null,
                      style: const TextStyle(
                          color: Colors.white, fontFamily: "poppins"),
                      decoration: InputDecoration(
                        hintText: "Type your message here...",
                        hintStyle: TextStyle(color: Colors.grey[400]),
                        filled: true,
                        fillColor: const Color(0xFF353535),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.all(16),
                      ),
                    ),
                  if (widget.multiCardSelect)
                    Container(
                      height: 100,
                      decoration: BoxDecoration(
                          color: const Color(0xFF353535),
                          borderRadius: BorderRadius.circular(8)),
                      padding: const EdgeInsets.all(8),
                      child: ListView.builder(
                          itemCount: widget.multiSelectedIds!.length,
                          itemBuilder: (context, index) {
                            List<Map<String, dynamic>> customerList =
                                getCustomesFromIds(widget.multiSelectedIds!);
                            return Text(
                              "${customerList[index][DatabaseHelper.columnFullName]} (${customerList[index][DatabaseHelper.columnPhoneNumber]})",
                              style: style3(),
                            );
                          }),
                    ),
                  const SizedBox(height: 12),
                  if (!widget.multiCardSelect)
                    Row(
                      children: [
                        Row(
                          children: [
                            Checkbox(
                              value: messageCheckBox,
                              onChanged: (value) {
                                messageCheckBox = !messageCheckBox;
                                setState(() {});
                              },
                              side: BorderSide(
                                  color: Colors.grey.shade400, width: 2),
                              activeColor: Colors.blue,
                              checkColor: Colors.white,
                            ),
                            Icon(
                              Icons.sms_outlined,
                              size: 30,
                              color: Colors.blue[600],
                            )
                          ],
                        ),
                        Row(
                          children: [
                            Checkbox(
                              value: whatsappCheckBox,
                              onChanged: (value) {
                                whatsappCheckBox = !whatsappCheckBox;
                                setState(() {});
                              },
                              side: BorderSide(
                                  color: Colors.grey.shade400, width: 2),
                              activeColor: Colors.blue,
                              checkColor: Colors.white,
                            ),
                            const FaIcon(
                              FontAwesomeIcons.whatsapp,
                              size: 30,
                              color: Colors.green,
                            ),
                          ],
                        )
                      ],
                    ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => Navigator.of(context).pop(false),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey[700],
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            "Cancel",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              fontFamily: "poppins",
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () async {
                            // Handle send message
                            if (widget.multiCardSelect) {
                              //send multiple messages
                              await sendMultipleMessages(
                                  widget.multiSelectedIds!);
                            } else {
                              //send single message;
                              await sendMessage(messageController.text,
                                  widget.messageNumber!);
                            }

                            Navigator.of(context)
                                .pop(); //true means message sent
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            "Send",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              fontFamily: "poppins",
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> sendMessage(String typedMessage, String phoneNumber) async {
    bool smsSent = false; //TODO change this not for both message and whatsapp
    if (kDebugMode) {
      debugLog("${typedMessage.length}");
    }
    if (messageCheckBox) {
      smsSent = await SendMessage.smsMessage(phoneNumber, typedMessage);
      if (smsSent) {
        CustomSnackbar.showSnackbar(
            type: SnackbarType.success, message: "Sms sent");
      } else {
        CustomSnackbar.showSnackbar(
            type: SnackbarType.failure, message: "Failed to send Sms");
      }
    }
    if (whatsappCheckBox) {
      //send whatsapp message
      bool whatsappMessageSent =
          await SendMessage.whatsappMessage(phoneNumber, typedMessage);
      if (whatsappMessageSent) {
        CustomSnackbar.showSnackbar(
            type: SnackbarType.success, message: "Notified on whatsapp");
      } else {
        CustomSnackbar.showSnackbar(
            type: SnackbarType.failure, message: "Failed to open Whatsapp");
      }
      whatsappCheckBox = false;
    }
  }

  String cookMessage(String currentName, String dueAmount, String currentDate) {
    String cookedMessage =
        "Hello $currentName,\nYour gym membership has expired on $currentDate. Due: Rs.$dueAmount\nKindly renew.\nDeadlift Fitness Studio";

    return cookedMessage;
  }

  List<Map<String, dynamic>> getCustomesFromIds(List<String> ids) {
    List<Map<String, dynamic>> listOFCustomersSelected = [];

    // !without getx
    for (String id in ids) {
      for (var customer in dbController.customers) {
        if (customer[DatabaseHelper.columnId] == id) {
          listOFCustomersSelected.add({
            DatabaseHelper.columnPhoneNumber:
                customer[DatabaseHelper.columnPhoneNumber],
            DatabaseHelper.columnFullName:
                customer[DatabaseHelper.columnFullName],
            DatabaseHelper.columnDueDate:
                customer[DatabaseHelper.columnDueDate],
            DatabaseHelper.columnDueAmount:
                customer[DatabaseHelper.columnDueAmount]
          });
        }
      }
    }
    return listOFCustomersSelected;
  }

  Future<void> sendMultipleMessages(List<String> multiSelectedIds) async {
    List<Map<String, dynamic>> customersSelected =
        getCustomesFromIds(multiSelectedIds);
    bool messagesSent = false;
    for (Map<String, dynamic> customer in customersSelected) {
      DateTime custDueDate =
          DateTime.parse(customer[DatabaseHelper.columnDueDate]);
      String custDueDateString =
          "${custDueDate.day}/${custDueDate.month}/${custDueDate.year}";
      String customMessage = cookMessage(
          customer[DatabaseHelper.columnFullName],
          customer[DatabaseHelper.columnDueAmount],
          custDueDateString);
      messagesSent = await SendMessage.smsMessage(
          customer[DatabaseHelper.columnPhoneNumber], customMessage);
      if (kDebugMode) {
        debugLog("Message sent: $messagesSent");
      }
    }
    if (messagesSent) {
      CustomSnackbar.showSnackbar(
          type: SnackbarType.success, message: "Message(s) sent");
    } else {
      CustomSnackbar.showSnackbar(
          type: SnackbarType.failure, message: "Failed to send sms");
    }
  }
}
