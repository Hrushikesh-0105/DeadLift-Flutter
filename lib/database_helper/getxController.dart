import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:deadlift/config/secrets.dart';
import 'package:deadlift/debugFunctions/debugLog.dart';
import 'package:deadlift/firebase_helper/custom_firebase_Api.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get/get.dart';
import 'database_helper.dart';
import 'package:http/http.dart' as http;

class DatabaseController extends GetxController {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
  StreamSubscription<QuerySnapshot>? _firestoreSubscription;
  bool _localDbfetchedOnce = false;
  bool _firebaseSynced = false;
  // Reactive list of customers
  RxList<Map<String, dynamic>> customers = <Map<String, dynamic>>[].obs;
  RxString filter = "All".obs;
  RxString searchText = "".obs;
  RxBool isAdmin = false.obs;
  RxBool isTablet = false.obs;
  RxInt members = 0.obs;
  RxInt inactive = 0.obs;
  RxInt active = 0.obs;
  RxInt expired = 0.obs;
  RxInt currentMonthEarnings = 0.obs;

  //firebase related
  RxBool isLoading = false.obs;
  RxBool isOnlineMode = false.obs;

  // Load customers when the controller initializes
  @override
  void onInit() async {
    super.onInit();
    bool isDeviceOnline = await isOnline();
    if (isDeviceOnline) {
      await initializeOnlineDb();
    } else {
      debugLog("No internet fetching local db");
      fetchCustomers();
      _localDbfetchedOnce = true;
    }
    startConnectivityListener();
  }

  @override
  void onClose() {
    _connectivitySubscription?.cancel();
    _firestoreSubscription?.cancel();
    super.onClose();
  }

  //!firebase trial 3
  Future<void> initializeOnlineDb() async {
    try {
      // await Firebase.initializeApp();
      //removing caching of data
      FirebaseFirestore.instance.settings = const Settings(
        persistenceEnabled: false,
      );
      _dbHelper.deleteAll();
      customers.clear();
      startFirestoreListener();
      _firebaseSynced = true;
      _localDbfetchedOnce = true;
    } catch (e) {
      _firebaseSynced = false;
      _localDbfetchedOnce = false;
      debugLog("Error in initailize firebase getx: $e");
    }

    if (!_firebaseSynced && !_localDbfetchedOnce) {
      debugLog("No internet fetching local db");
      fetchCustomers();
    }
  }

  void startFirestoreListener() {
    // Cancel any previous subscription
    _firestoreSubscription?.cancel();
    debugLog("Starting firebase listener");
    // Set up a new Firestore listener
    _firestoreSubscription = FirebaseFirestore.instance
        .collection(Secrets.customersDb)
        .snapshots()
        .listen((snapshot) async {
      // Handle real-time updates
      for (var change in snapshot.docChanges) {
        debugLog("change detected");
        if (change.type == DocumentChangeType.added &&
            change.doc.data() != null) {
          debugLog("new doc added in firebase");
          await addCustomer(change.doc.data()!);
        } else if (change.type == DocumentChangeType.modified &&
            change.doc.data() != null) {
          debugLog("new doc changed in firebase");

          await updateCustomer(change.doc.data()!);
        } else if (change.type == DocumentChangeType.removed &&
            change.doc.data() != null) {
          debugLog("new doc deleted in firebase");

          await deleteCustomer(change.doc.data()![DatabaseHelper.columnId]);
        }
      }
      await UpdateDisplayData();
      print("Real-time updates synced.");
    }, onError: (error) {
      print("Error in Firestore listener: $error");
    });
  }

  void startConnectivityListener() {
    // Cancel any existing connectivity subscription
    _connectivitySubscription?.cancel();
    debugLog("Starting connectivity listener");
    // Listen for connectivity changes
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen(
        (List<ConnectivityResult> result) async {
      bool isDeviceOnline = await isOnline();
      if (isDeviceOnline) {
        if (!_firebaseSynced) {
          debugLog("in connectivity listener and re initializing online db");
          initializeOnlineDb();
        }
      } else {
        debugLog("Device went offline");
        _firebaseSynced = false;
        _firestoreSubscription?.cancel();
      }
    }, onError: (e) {
      debugLog("Error in connectivity listener: $e");
    });
  }

  //!firebase trial 3
  // Fetch all customers from the database
  Future<void> fetchCustomers() async {
    isLoading.value = true;
    debugLog("Fetching Local data");
    final List<Map<String, dynamic>> data = await _dbHelper.quearyAll();
    customers.assignAll(data);
    await UpdateDisplayData();
    isLoading.value = false;
  }

  // Add a new customer
  Future<void> addCustomer(Map<String, dynamic> customer) async {
    debugLog("In getx save function");
    isLoading.value = true;
    debugLog("loading value set to true");
    await _dbHelper.insert(customer);
    customers.add(customer);
    isLoading.value = false;
    // await fetchCustomers(); // Refresh the list
    // await UpdateDisplayData();
  }

  // Update an existing customer
  Future<void> updateCustomer(Map<String, dynamic> updatedCustomer) async {
    debugLog("In getx update function");
    isLoading.value = true;
    debugLog("updating customer");
    await _dbHelper.update(updatedCustomer);
    int dbLength = members.value;
    bool updatedInGetx = false;
    for (int i = 0; i < dbLength && !updatedInGetx; i++) {
      if (customers[i][DatabaseHelper.columnId] ==
          updatedCustomer[DatabaseHelper.columnId]) {
        customers[i] = updatedCustomer;
        updatedInGetx = true;
      }
    }
    isLoading.value = false;
    // await fetchCustomers(); // Refresh the list
    // await UpdateDisplayData(); // this updates the members or total customers value too
  }

  // Delete a customer
  Future<void> deleteCustomer(String id) async {
    debugLog("In getx Delete function");
    isLoading.value = true;
    debugLog("deleting customer from local db and getx");
    await _dbHelper.delete(id);
    int dbLength = members.value;
    bool deletedInGetx = false;
    for (int i = 0; i < dbLength && !deletedInGetx; i++) {
      if (customers[i][DatabaseHelper.columnId] == id) {
        customers.removeAt(i);
        deletedInGetx = true;
      }
    }
    isLoading.value = false;
    // await fetchCustomers(); // Refresh the list
    // await UpdateDisplayData();
  }

  // Get a specific customer by ID
  Map<String, dynamic> getCustomerById(String id) {
    Map<String, dynamic> customerMap = {};
    bool found = false;
    for (int i = 0; i < members.value && !found; i++) {
      if (customers[i][DatabaseHelper.columnId] == id) {
        customerMap = customers[i];
        found = true;
      }
    }
    return customerMap;
  }

  List<String> getAllIds() {
    return customers
        .map((customer) => customer[DatabaseHelper.columnId] as String)
        .toList();
  }

  List<Map<String, dynamic>> FilteredCustomers() {
    List<Map<String, dynamic>> filteredList = [];
    for (Map<String, dynamic> customer in customers) {
      if (_filterCustomer(
              filter.value,
              customer[DatabaseHelper.columnStatus],
              customer[DatabaseHelper.columnDueAmount],
              customer[DatabaseHelper.columnDueDate]) &&
          searchCustomer(customer[DatabaseHelper.columnFullName],
              customer[DatabaseHelper.columnPhoneNumber])) {
        filteredList.add(customer);
      }
    }
    return filteredList;
  }

  bool searchCustomer(String fullName, String phoneNumber) {
    fullName = fullName.toLowerCase();
    if (searchText.value.trim().isEmpty) {
      return true;
    } else {
      if (fullName.contains(searchText.value.toLowerCase().trim()) ||
          phoneNumber.contains(searchText.value.trim())) {
        return true;
      } else {
        return false;
      }
    }
  }

  bool _filterCustomer(
      String filter, String customerStatus, String dueAmount, String dueDate) {
    bool filterBool;
    if (filter == "All") {
      filterBool = true;
    } else if (filter == CustomerFilter.due) {
      if (int.parse(dueAmount) > 0) {
        filterBool = true;
      } else {
        filterBool = false;
      }
    } else if (filter == customerStatus) {
      filterBool = true;
    } else if (filter == CustomerFilter.expiredToday) {
      filterBool = isExpiredToday(dueDate);
    } else {
      filterBool = false;
    }

    return filterBool;
  }

  bool isExpiredToday(String dateString) {
    bool expiredToday = false;
    try {
      DateTime inputDate = DateTime.parse(dateString);
      DateTime today = DateTime.now();
      DateTime todayOnly = DateTime(today.year, today.month, today.day);
      DateTime inputDateOnly =
          DateTime(inputDate.year, inputDate.month, inputDate.day);
      expiredToday = (inputDateOnly == todayOnly);
    } catch (e) {
      debugLog('Error parsing date: $e');
    }
    return expiredToday;
  }

  // Check internet connectivity
  Future<bool> isOnline() async {
    try {
      final response =
          await http.get(Uri.parse('https://firebase.google.com')).timeout(
                const Duration(seconds: 10),
              );
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  Future<void> UpdateDisplayData() async {
    int currentIncome = 0;
    int currentExpired = 0;
    int currentActive = 0;
    debugLog("In update display function");
    DateTime currentDate = DateTime.now();
    //!getx accessed here
    List<Map<String, dynamic>> localCustomerDataList = customers;
    debugLog("local customer list created");
    // debugLog(dbController.customers);
    debugLog("db length is:${localCustomerDataList.length}");
    int noOfCustomers = localCustomerDataList.length;
    for (int i = 0; i < noOfCustomers; i++) {
      Map<String, dynamic> currentCustomerMap = localCustomerDataList[
          i]; // this is immutable, cant make changes to it, only we can read
      Map<String, dynamic> mutableCustomerMap = Map.from(currentCustomerMap);
      DateTime currentPaymentDate =
          DateTime.parse(currentCustomerMap[DatabaseHelper.columnPaymentDate]);
      DateTime currentDueDate =
          DateTime.parse(currentCustomerMap[DatabaseHelper.columnDueDate]);
      if (currentDueDate.isBefore(currentDate) &&
          currentCustomerMap[DatabaseHelper.columnStatus] ==
              CustomerStatus.active) {
        // debugLog("${currentCustomerMap[DatabaseHelper.columnFullName]} Expired");
        mutableCustomerMap[DatabaseHelper.columnStatus] =
            CustomerStatus.expired;
        //!update the data in online db too
        await updateCustomerInOfflineAndOnlineDb(mutableCustomerMap);
      }
      if (isDifferenceGreaterThan90Days(currentDueDate, currentDate) &&
          currentCustomerMap[DatabaseHelper.columnStatus] !=
              CustomerStatus.inactive) {
        mutableCustomerMap[DatabaseHelper.columnStatus] =
            CustomerStatus.inactive;
        //!update the data in online db too
        await updateCustomerInOfflineAndOnlineDb(mutableCustomerMap);
      }
      if (mutableCustomerMap[DatabaseHelper.columnStatus] ==
          CustomerStatus.expired) {
        currentExpired = currentExpired + 1;
      }
      if (mutableCustomerMap[DatabaseHelper.columnStatus] ==
          CustomerStatus.active) {
        currentActive = currentActive + 1;
      }
      if (currentPaymentDate.month == currentDate.month) {
        debugLog(
            "Current Customer: ${currentCustomerMap[DatabaseHelper.columnFullName]}, amount: ${currentCustomerMap[DatabaseHelper.columnPaidAmount]}");
        currentIncome = currentIncome +
            int.parse(currentCustomerMap[DatabaseHelper.columnPaidAmount]);
      }
      //! here update the status in getx and firebse also
    }
    if (noOfCustomers != members.value) {
      members.value = noOfCustomers;
    }
    if (active.value != currentActive) {
      active.value = currentActive;
    }
    if (expired.value != currentExpired) {
      expired.value = currentExpired;
    }
    if (currentMonthEarnings.value != currentIncome) {
      currentMonthEarnings.value = currentIncome;
    }
    if (inactive.value != members.value - active.value - expired.value) {
      inactive.value = members.value - active.value - expired.value;
    }
  }

  //!update data in the online db too
  Future<void> updateCustomerInOfflineAndOnlineDb(
      Map<String, dynamic> updatedDataMap) async {
    // bool dataUpdated = false;
    bool dataUpdatedInOnlineDb = await CustomFirebaseApi()
        .updateData(updatedDataMap[DatabaseHelper.columnId], updatedDataMap);
    if (dataUpdatedInOnlineDb) {
      debugLog("Customer status changed in online db");
    } else {
      debugLog("Error in updating data to online db in home page");
    }
  }

  bool isDifferenceGreaterThan90Days(DateTime startDate, DateTime endDate) {
    int differenceInDays = endDate.difference(startDate).inDays;
    return differenceInDays >= 90;
  }
}
