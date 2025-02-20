import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:deadlift/debugFunctions/debugLog.dart';
import 'package:deadlift/config/secrets.dart';
import 'package:http/http.dart' as http;

// import 'package:deadlift/database_helper/database_helper.dart';

class CustomFirebaseApi {
  // ignore: constant_identifier_names
  static const String _DBNAMENAME = Secrets.customersDb;
  // ignore: constant_identifier_names
  static const String _CREDENTIALSDBNAME = Secrets.credentialsDb;
  CollectionReference<Map<String, dynamic>>? firebaseDb;

  CollectionReference<Map<String, dynamic>>? credentialsDb;

  CustomFirebaseApi() {
    try {
      firebaseDb = FirebaseFirestore.instance.collection(_DBNAMENAME);
      debugLog("Got customers firebase instance");
    } catch (e) {
      debugLog("Error getting firebase customers instance: $e");
      firebaseDb = null;
    }
    try {
      credentialsDb = FirebaseFirestore.instance.collection(_CREDENTIALSDBNAME);
      debugLog("Got credentials firebase instance");
    } catch (e) {
      debugLog("Error getting firebase credential instance: $e");
      credentialsDb = null;
    }
  }

  Future<List<Map<String, dynamic>>?> loadFirebaseData() async {
    List<Map<String, dynamic>>? fetchedDataList;
    try {
      debugLog("trying to fetch data");
      final snapshot = await firebaseDb!.get();
      fetchedDataList = snapshot.docs.map((doc) => doc.data()).toList();
      debugLog("Data fetched successfully from firebase");
    } catch (e) {
      debugLog("Error in fetching data: $e");
    }
    return fetchedDataList;
  }

  Future<bool> createDocument(Map<String, dynamic> data) async {
    debugLog("In firebase create function");
    bool documentCreated = false;
    if (await isOnline() && firebaseDb != null) {
      try {
        await firebaseDb!.add(data);
        documentCreated = true;
        debugLog("Document created successfully in firebase.");
      } catch (e) {
        debugLog("Error creating document in firebase: $e");
      }
    } else {
      debugLog("No internet connection.(tried to save in firebase)");
    }
    return documentCreated;
  }

  Future<bool> updateData(
      String customerId, Map<String, dynamic> updatedData) async {
    bool dataUpdated = false;
    if (await isOnline() && firebaseDb != null) {
      try {
        await firebaseDb!
            .where('id', isEqualTo: customerId)
            .get()
            .then((querySnapshot) {
          if (querySnapshot.docs.isNotEmpty) {
            String documentId =
                querySnapshot.docs.first.id; // Getting document ID
            firebaseDb!.doc(documentId).update(updatedData);
            dataUpdated = true;
            debugLog("data updated In firebase:$dataUpdated");
          } else {
            debugLog("No document found in firebase with id: $customerId");
          }
        });
      } catch (e) {
        dataUpdated = false;
        debugLog("Error updating document in firebse : $e");
      }
    } else {
      debugLog("No internet connection.(tried to update in firebase)");
    }

    return dataUpdated;
  }

  Future<bool> deleteData(String customerId) async {
    bool dataDeleted = false;
    if (await isOnline() && firebaseDb != null) {
      try {
        await firebaseDb!
            .where('id', isEqualTo: customerId)
            .get()
            .then((querySnapshot) {
          if (querySnapshot.docs.isNotEmpty) {
            String documentId =
                querySnapshot.docs.first.id; // Getting document ID
            firebaseDb!.doc(documentId).delete();
            dataDeleted = true;
            debugLog("Document deleted successfully in firebase: $dataDeleted");
          } else {
            debugLog("No document found in firebase with id: $customerId");
          }
        });
      } catch (e) {
        debugLog("Error deleting document in firebase: $e");
      }
    } else {
      debugLog("No internet connection.(tried to delete in firebase)");
    }

    return dataDeleted;
  }

  Future<List<Map<String, dynamic>>?> getUsernameAndPasswords() async {
    List<Map<String, dynamic>>? usernameAndPasswordList;
    if (await isOnline() && credentialsDb != null) {
      final snapshot = await credentialsDb!.get();
      usernameAndPasswordList = snapshot.docs.map((doc) => doc.data()).toList();
    } else {
      debugLog("Failed to get login details from firebase");
    }
    return usernameAndPasswordList;
  }
}

Future<bool> isOnline() async {
  try {
    bool isOnline = false;
    // final result = await InternetAddress.lookup('google.com');
    // return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    final response = await http
        .get(Uri.parse('https://firebase.google.com'))
        .timeout(
          const Duration(seconds: 10), // Set a timeout to avoid long wait times
        );
    isOnline = (response.statusCode == 200);
    debugLog("Firebase connected: $isOnline");
    return isOnline;
  } catch (_) {
    return false;
  }
}
