import 'package:deadlift/debugFunctions/debugLog.dart';
import 'package:flutter_native_sms/flutter_native_sms.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';

class SendMessage {
  static Future<bool> smsMessage(String phoneNumber, String message) async {
    FlutterNativeSms sms = FlutterNativeSms();
    bool smsSent = false;
    var status = await Permission.sms.status;
    if (status.isDenied || status.isRestricted || status.isPermanentlyDenied) {
      status = await Permission.sms.request();
    }
    if (await Permission.phone.status.isDenied) {
      await Permission.phone.request();
    }
    status = await Permission.sms.status;
    if (status.isGranted && await Permission.phone.status.isGranted) {
      try {
        smsSent =
            await sms.send(phone: phoneNumber, smsBody: message, sim: "0");
        debugLog("Sms sent");
        smsSent = true;
      } catch (e) {
        debugLog("Failed to send sms: $e");
        smsSent = false;
      }
    } else {
      debugLog("Sms or phone permissions not granted");
    }
    return smsSent;
  }

  static Future<bool> whatsappMessage(
      String phoneNumber, String message) async {
    bool messageSent = true;
    final Uri whatsappUri = Uri.parse(
        "whatsapp://send?phone=+91$phoneNumber&text=${Uri.encodeComponent(message)}");
    try {
      messageSent =
          await launchUrl(whatsappUri, mode: LaunchMode.externalApplication);
    } catch (e) {
      messageSent = false;
    }
    return messageSent;
  }
}
