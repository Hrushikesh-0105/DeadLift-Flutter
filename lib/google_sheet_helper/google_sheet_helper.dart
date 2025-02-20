import 'package:deadlift/debugFunctions/debugLog.dart';
import 'package:gsheets/gsheets.dart';
import 'package:deadlift/config/secrets.dart';
import 'package:http/http.dart' as http;

//create lib/config/secrets.dart file and store all credentials there

class GoogleSheetHelper {
  final _spreadsheetId = Secrets.spreadsheetId;
  final credentials = Secrets.googleSheetCredentials;

  /// Function to append a row to the specified sheet
  Future<bool> appendRow(Map<String, dynamic> rowData, int sheetId) async {
    bool storedInGoogleSheet = false;
    debugLog("In google sheet function");

    // Create a GSheets instance
    if (await isGoogleSheetsAccessible(_spreadsheetId)) {
      try {
        final gsheets = GSheets(credentials);

        // Access the spreadsheet by ID
        final spreadsheet = await gsheets.spreadsheet(_spreadsheetId);

        // Select the specified worksheet by ID
        final sheet = spreadsheet.worksheetById(sheetId);

        if (sheet == null) {
          debugLog("Worksheet with ID $sheetId not found.");
          return false;
        }

        // Convert Map<String, dynamic> to a List<String>
        List<String> values =
            rowData.values.map((value) => value.toString()).toList();

        // Append the row data
        storedInGoogleSheet = await sheet.values.appendRow(values);
        debugLog("Stored in gsheet");
      } catch (e) {
        debugLog("Error in g sheet: $e");
      }
    } else {
      debugLog("No internet while storing in google sheets");
    }

    return storedInGoogleSheet;
  }
}

Future<bool> isGoogleSheetsAccessible(String sheetId) async {
  try {
    final response = await http
        .get(
          Uri.parse('https://www.google.com'),
        )
        .timeout(
          const Duration(seconds: 3),
        );
    return response.statusCode == 200;
  } catch (e) {
    return false;
  }
}
