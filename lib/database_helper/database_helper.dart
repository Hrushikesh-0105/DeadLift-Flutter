import 'package:deadlift/debugFunctions/debugLog.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:io';
import 'package:path/path.dart';
// import 'package:path_provider/path_provider.dart';

class DatabaseHelper {
  static const _dbName = "myDatabase.db";
  static const _dbVersion = 1;
  static const _tableName = "myTable";
  static const columnId = "id";
  static const columnFullName = "fullName";
  static const columnPhoneNumber = "phoneNumber";
  static const columnEmailId = "emailId";
  static const columnMembership = "membership";
  static const columnPaidAmount = "paidAmount";
  static const columnDueAmount = "dueAmount";
  static const columnPaymentDate = "paymentDate";
  static const columnDueDate = "dueDate";
  static const columnPaymentMode = "paymentMode";
  static const columnStatus = "status";
  static const columnUpdatedBy = "updatedBy";
  static const columnTrainer = "trainer";

// making it singleton class
  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    //some code to create database in _database variable and return it
    _database = await _initiateDatabase();
    return _database!;
  }

  Future<Database> _initiateDatabase() async {
    Directory directory = await getApplicationDocumentsDirectory();
    String path = join(directory.path,
        _dbName); // joins directory path and db path and stores it in string
    debugLog("db path:$path");
    return await openDatabase(path,
        version: _dbVersion,
        onCreate: _onCreate); // initializes the database and opens it
  }

//changed the id from INTEGER to TEXT
  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
    CREATE TABLE $_tableName (
      $columnId TEXT PRIMARY KEY,
      $columnFullName TEXT NOT NULL,
      $columnPhoneNumber TEXT NOT NULL,
      $columnEmailId TEXT NOT NULL,
      $columnMembership INTEGER NOT NULL,
      $columnPaidAmount TEXT NOT NULL,
      $columnDueAmount TEXT NOT NULL,
      $columnPaymentDate TEXT NOT NULL,
      $columnDueDate TEXT NOT NULL,
      $columnPaymentMode TEXT NOT NULL,
      $columnStatus TEXT NOT NULL,
      $columnUpdatedBy TEXT NOT NULL,
      $columnTrainer TEXT NOT NULL
    )
  ''');
  }

//changed Id to string
  Future<int> insert(Map<String, dynamic> customer) async {
    Database db = await instance.database;
    try {
      return await db.insert(
        _tableName,
        customer,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      debugLog("Insert Error: $e");
      return -1; // Return -1 for error
    }
  }

  Future<int> insertMultipleRows(List<Map<String, dynamic>> customers) async {
    Database db = await instance.database;
    var batch = db.batch(); // Using a batch to insert multiple rows

    try {
      // Loop through the customers list and add each insert operation to the batch
      for (var customer in customers) {
        batch.insert(
          _tableName,
          customer,
          conflictAlgorithm: ConflictAlgorithm
              .replace, // Use ConflictAlgorithm.replace or ConflictAlgorithm.ignore based on your need
        );
      }

      // Execute the batch and return the number of rows affected
      final result = await batch.commit();
      return result.length; // Return the number of rows inserted
    } catch (e) {
      debugLog("Insert Multiple Rows Error: $e");
      return -1; // Return -1 for error
    }
  }

  Future<List<Map<String, dynamic>>> quearyAll() async {
    Database db = await instance.database;
    return await db.query(_tableName);
  }

  Future<int> update(Map<String, dynamic> row) async {
    Database db = await instance.database;
    String id = row[columnId]; //_cloumnId="id"
    return await db
        .update(_tableName, row, where: '$columnId = ?', whereArgs: [id]);
  }

  Future<int> delete(String id) async {
    Database db = await instance.database;
    return await db.delete(_tableName, where: '$columnId = ?', whereArgs: [id]);
  }

  Future<Map<String, dynamic>> getCustomerById(String id) async {
    Database db = await instance.database;
    List<Map<String, dynamic>> results =
        await db.query(_tableName, where: '$columnId = ?', whereArgs: [id]);

    if (results.isNotEmpty) {
      return results.first;
    } else {
      return {}; // Return an empty map if no customer is found
    }
  }

  Future<List<String>> getAllIds() async {
    Database db = await instance.database;
    //store the ids in a list in one more variable
    List<Map<String, dynamic>> results =
        await db.query(_tableName, columns: [columnId]);
    return results.map((row) => row[columnId] as String).toList();
  }

  Future<void> deleteAll() async {
    final db = await instance.database;
    try {
      await db.delete(_tableName); // Replace with your actual table name
      debugLog("All records deleted from the table.");
    } catch (e) {
      debugLog("Error deleting all records: $e");
      rethrow;
    }
  }
}

class CustomerStatus {
  static const String active = "Active";
  static const String expired = "Expired";
  static const String inactive = "Inactive";
  static const String due = "Due";
  static const String expiredToday = "ExpiredToday";
}

class CustomerFilter {
  static const String all = "All";
  static const String active = "Active";
  static const String expired = "Expired";
  static const String inactive = "Inactive";
  static const String due = "Due";
  static const String expiredToday = "ExpiredToday";
}

class CustomerId {
  static const String baseId = "DDLT";
}

class PaymentMode {
  static const String cash = "Cash";
  static const String card = "Card";
  static const String upi = "UPI";
  static const String gpay = "Gpay";
  static const String phonePe = "PhonePe";
}

class FirebaseDbCredentialKeys {
  static const String username = "username";
  static const String password = "password";
  static const String status = "status";
}

class loggedInStatus {
  static const String admin = "ADMIN";
  static const String employee = "EMPLOYEE";
}

class sharedPrefKeys {
  static const String loggedIn = "LoggedIn";
  static const String isAdmin = "isAdmin";
}

class CustomerDetails {
  String fullName;
  String fatherName;
  String mobileNumber;
  String email;
  String dob;
  String bloodGroup;
  String age;
  String height;
  String weight;
  String address;
  String illness;
  String remarks;
  String id;

  // Constructor
  CustomerDetails(
      {required this.fullName,
      required this.fatherName,
      required this.mobileNumber,
      required this.email,
      required this.dob,
      required this.bloodGroup,
      required this.age,
      required this.height,
      required this.weight,
      required this.address,
      required this.illness,
      this.remarks = '',
      this.id = ''});

  // Method to convert customer details to a map (for saving in a database)
  Map<String, String> toMap() {
    return {
      'id': id,
      'fullName': fullName,
      'fatherName': fatherName,
      'mobileNumber': mobileNumber,
      'email': email,
      'age': age,
      'height': height,
      'weight': weight,
      'dob': dob,
      'bloodGroup': bloodGroup,
      'address': address,
      'illness': illness,
      'remarks': remarks,
    };
  }

  // Method to create a CustomerDetails object from a map (for retrieving from a database)
  factory CustomerDetails.fromMap(Map<String, dynamic> map) {
    return CustomerDetails(
      fullName: map['fullName'] ?? '',
      fatherName: map['fatherName'] ?? '',
      mobileNumber: map['mobileNumber'] ?? '',
      email: map['email'] ?? '',
      dob: map['dob'] ?? '',
      bloodGroup: map['bloodGroup'] ?? '',
      age: map['age'] ?? '0',
      height: map['height'].toDouble() ?? '0',
      weight: map['weight'].toDouble() ?? '0',
      address: map['address'] ?? '',
      illness: map['illness'] ?? '',
      remarks: map['remarks'] ?? '',
      id: map['id'] ?? '',
    );
  }
}
