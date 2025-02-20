import 'package:deadlift/custom_widgets/snack_bar.dart';
import 'package:deadlift/database_helper/getxController.dart';
import 'package:deadlift/debugFunctions/debugLog.dart';
import 'package:deadlift/firebase_helper/custom_firebase_Api.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DeleteConfirmationDialog extends StatelessWidget {
  final DatabaseController dbController = Get.put(DatabaseController());
  final bool multiCardSelect;
  final List<String>? multiSelectedIds;
  final String? deleteName;
  final String? deleteId;

  DeleteConfirmationDialog({
    super.key,
    required this.multiCardSelect,
    this.multiSelectedIds,
    this.deleteName,
    this.deleteId,
  });

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
                    Icons.warning_rounded,
                    color: Colors.amber,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    "Delete Confirmation",
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
            ),

            // Content
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    multiCardSelect
                        ? "Delete ${multiSelectedIds!.length} record${multiSelectedIds!.length > 1 ? 's' : ''}?"
                        : "Delete ${deleteName}'s record?",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "This action cannot be undone.",
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Buttons
                  Obx(() => Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: dbController.isLoading.value
                                  ? null
                                  : () => Navigator.of(context).pop(false),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.grey[700],
                                foregroundColor: Colors.white,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: const Text(
                                "Cancel",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: dbController.isLoading.value
                                  ? null
                                  : () async {
                                      if (multiCardSelect) {
                                        bool deleted =
                                            await deleteMultipleCustomers(
                                                multiSelectedIds!, context);
                                        Navigator.of(context).pop(deleted);
                                      } else {
                                        bool deleted =
                                            await deleteMultipleCustomers(
                                                [deleteId!], context);
                                        Navigator.of(context).pop(deleted);
                                      }
                                    },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFFF5A5F),
                                foregroundColor: Colors.white,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  if (dbController.isLoading.value)
                                    const SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                                Colors.white),
                                      ),
                                    ),
                                  if (dbController.isLoading.value)
                                    const SizedBox(width: 8),
                                  Text(
                                    dbController.isLoading.value
                                        ? "Deleting..."
                                        : "Delete",
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      )),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Your existing methods remain the same
  Future<bool> deleteDataFromDb(String selectedId) async {
    // bool isDeleted = false;
    bool deletedFromOnlinDb = false;
    deletedFromOnlinDb = await CustomFirebaseApi().deleteData(selectedId);
    // if (deletedFromOnlinDb) {
    //   try {
    //     await dbController.deleteCustomer(selectedId);
    //     isDeleted = true;
    //   } catch (e) {
    //     debugLog("Error in deleting data from offline db: $e");
    //   }
    // }
    return deletedFromOnlinDb;
  }

  Future<bool> deleteMultipleCustomers(
      List<String> multiSelectedIdList, BuildContext context) async {
    int totalNumberOfRowsEffected = 0;
    bool deleted = true;
    dbController.isLoading.value = true;
    int numberOfIds = multiSelectedIdList.length;

    for (int i = 0; i < numberOfIds && deleted; i++) {
      try {
        deleted = await deleteDataFromDb(multiSelectedIdList[i]);
        if (deleted) {
          ++totalNumberOfRowsEffected;
        }
      } catch (e) {
        debugLog("$e");
        deleted = false;
      }
    }

    if (kDebugMode) {
      debugLog(
          "total redcords deleted: $totalNumberOfRowsEffected out of $numberOfIds");
    }

    if (deleted) {
      CustomSnackbar.showSnackbar(
          type: SnackbarType.success,
          message: "$totalNumberOfRowsEffected Customer(s) deleted");
    } else {
      CustomSnackbar.showSnackbar(
          type: SnackbarType.failure, message: "Failed to delete");
    }
    dbController.isLoading.value = false;
    return deleted;
  }
}
