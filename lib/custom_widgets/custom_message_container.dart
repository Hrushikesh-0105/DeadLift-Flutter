import 'package:deadlift/custom_widgets/snack_bar.dart';
import 'package:deadlift/database_helper/database_helper.dart';
import 'package:deadlift/database_helper/getxController.dart';
import 'package:deadlift/debugFunctions/debugLog.dart';
import 'package:deadlift/message_Helper/message_helper.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
// import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class CustomMessageContainer extends StatefulWidget {
  final List<String> multiSelectedIds;
  const CustomMessageContainer({required this.multiSelectedIds, super.key});

  @override
  State<CustomMessageContainer> createState() => _CustomMessageContainerState();
}

class _CustomMessageContainerState extends State<CustomMessageContainer> {
  final DatabaseController dbController = Get.put(DatabaseController());
  final TextEditingController _messageController = TextEditingController();
  // final FocusNode _focusNode = FocusNode();
  @override
  void initState() {
    super.initState();
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
                    "Custom SMS",
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
                  Expanded(
                    child: Text(
                      "${widget.multiSelectedIds.length} Customers",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        fontFamily: "poppins",
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                "Type '@' to mention name of customer",
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  fontFamily: "poppins",
                ),
              ),
            ),
            // Message Input Area
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                children: [
                  TextField(
                    cursorColor: Colors.grey,
                    maxLines: null,
                    controller: _messageController,
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
                  const SizedBox(height: 24),

                  // Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
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
                            await sendCustomMultiSms(widget.multiSelectedIds);
                            Navigator.pop(context);
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

  Future<void> sendCustomMultiSms(List<String> multiSelectedIds) async {
    final String typedMessage = _messageController.text;
    bool messageSent = true;
    int count = 0;
    for (var id in multiSelectedIds) {
      Map<String, dynamic> customer = dbController.getCustomerById(id);
      String customerName = customer[
          DatabaseHelper.columnFullName]; // Replace 'name' with your key
      String phoneNumber = customer[
          DatabaseHelper.columnPhoneNumber]; // Replace 'phone' with your key

      // Replace '@' with the customer's name in the template message
      String personalizedMessage = typedMessage.replaceAll('@', customerName);

      // Send the personalized message
      messageSent =
          await SendMessage.smsMessage(phoneNumber, personalizedMessage);

      if (messageSent) {
        ++count;
        debugLog("Message sent to $customerName: $personalizedMessage");
      } else {
        debugLog("Failed to send message to $customerName.");
      }
    }
    if (count == multiSelectedIds.length) {
      CustomSnackbar.showSnackbar(
          type: SnackbarType.success, message: "All Custom SMS sent");
    } else {
      CustomSnackbar.showSnackbar(
          type: SnackbarType.failure,
          message: "Sms sent to $count/${multiSelectedIds.length} customers");
    }
  }
}
