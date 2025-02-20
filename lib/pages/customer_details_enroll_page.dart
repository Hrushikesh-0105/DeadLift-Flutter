import 'package:deadlift/custom_widgets/snack_bar.dart';
import 'package:deadlift/database_helper/database_helper.dart';
// import 'package:deadlift/debugFunctions/debugLog.dart';
import 'package:deadlift/pages/membership_details_enroll_page_slidable.dart';
import 'package:deadlift/style.dart';
// import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class CustomerDetailsEnrollPage extends StatefulWidget {
  final PageController pageController;
  const CustomerDetailsEnrollPage({required this.pageController, super.key});

  @override
  State<CustomerDetailsEnrollPage> createState() =>
      _CustomerDetailsEnrollPageState();
}

class _CustomerDetailsEnrollPageState extends State<CustomerDetailsEnrollPage> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _fatherNameController = TextEditingController();
  final _mobileNumberController = TextEditingController();
  final _emailController = TextEditingController();
  final _dobController = TextEditingController();
  final _ageController = TextEditingController();
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();
  final _addressController = TextEditingController();
  final _illnessController = TextEditingController();
  final _remarksController = TextEditingController();

  final List<String> bloodGroups = [
    'A+',
    'A-',
    'B+',
    'B-',
    'O+',
    'O-',
    'AB+',
    'AB-'
  ];
  String? selectedBloodGroup;

  DateTime todaysDate = DateTime.now();
  final _formPageController = PageController();

  @override
  void dispose() {
    _fullNameController.dispose();
    _fatherNameController.dispose();
    _mobileNumberController.dispose();
    _emailController.dispose();
    _dobController.dispose();
    _addressController.dispose();
    _illnessController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    //disposing the current page controller
    _formPageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    // double screenheight = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: Colors.black,
      body: Container(
        color: Colors.black,
        margin: const EdgeInsets.fromLTRB(28, 20, 28, 0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Customer details",
                style: style1()
                    .copyWith(fontSize: 26, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(
              height: 5,
            ),
            Expanded(
                child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 650),
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Container(
                    margin: const EdgeInsets.all(5),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        TextFormField(
                            controller: _fullNameController,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "Full name is required";
                              }
                              return null;
                            },
                            keyboardType: TextInputType.name,
                            decoration: CustomerTextFieldStyle(
                                Icons.person_outlined, 'Full Name'),
                            style: const TextStyle(
                              color: Colors.white,
                            )),
                        const SizedBox(height: 10),

                        // Father's Name
                        TextFormField(
                            controller: _fatherNameController,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "Father's name is required";
                              }
                              return null;
                            },
                            keyboardType: TextInputType.name,
                            decoration: CustomerTextFieldStyle(
                                Icons.group_outlined, "Father's Name"),
                            style: const TextStyle(
                              color: Colors.white,
                            )),
                        const SizedBox(height: 10),

                        // Mobile Number
                        TextFormField(
                            controller: _mobileNumberController,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "Mobile number is required";
                              } else if (!RegExp(r'^[0-9]{10}$')
                                  .hasMatch(value)) {
                                return "Enter a valid 10-digit mobile number";
                              }
                              return null;
                            },
                            keyboardType: TextInputType.phone, //.number
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(10)
                            ],
                            decoration: CustomerTextFieldStyle(
                                Icons.local_phone_outlined, 'Mobile Number'),
                            style: const TextStyle(
                              color: Colors.white,
                            )),
                        const SizedBox(height: 10),

                        // Email
                        TextFormField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            decoration: CustomerTextFieldStyle(
                                Icons.email_outlined, 'Email'),
                            style: const TextStyle(
                              color: Colors.white,
                            )),
                        const SizedBox(height: 10),

                        // Date of Birth & Blood Group in a Row
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                  readOnly: true,
                                  controller: _dobController,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return "Date of birth is required";
                                    }
                                    return null;
                                  },
                                  onTap: () async {
                                    DateTime? pickedDate = await showDatePicker(
                                        context: context,
                                        initialDate: todaysDate,
                                        firstDate: DateTime(1960),
                                        lastDate: DateTime(todaysDate.year + 50,
                                            todaysDate.month, todaysDate.day));
                                    if (pickedDate != null) {
                                      _dobController.text =
                                          DateFormat('dd/MM/yyyy')
                                              .format(pickedDate);
                                      _ageController.text =
                                          "${((todaysDate.difference(pickedDate).inDays) / 365).floor()}";
                                    }
                                    setState(() {});
                                  },
                                  keyboardType: TextInputType.datetime,
                                  decoration: CustomerTextFieldStyle(
                                      Icons.date_range, 'Date of Birth'),
                                  style: const TextStyle(
                                    color: Colors.white,
                                  )),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: DropdownButtonFormField<String>(
                                  value: selectedBloodGroup,
                                  items: bloodGroups.map((group) {
                                    return DropdownMenuItem<String>(
                                      value: group,
                                      child: Text(group),
                                    );
                                  }).toList(),
                                  onChanged: (value) {
                                    setState(() {
                                      selectedBloodGroup = value;
                                    });
                                  },
                                  decoration: CustomerTextFieldStyle(
                                      Icons.bloodtype_outlined, 'Blood Group'),
                                  validator: (value) {
                                    if (value == null) {
                                      return "Blood group is required";
                                    }
                                    return null;
                                  },
                                  dropdownColor: Colors.grey[800],
                                  hint: Text("", style: style2()),
                                  icon: const Icon(
                                    Icons.arrow_drop_down,
                                    size: 40,
                                  ),
                                  style: const TextStyle(
                                    color: Colors.white,
                                  )),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),

                        // Age, Height, Weight in a Row
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                  enabled: false,
                                  controller: _ageController,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return "Age is required";
                                    }
                                    return null;
                                  },
                                  keyboardType: TextInputType.number,
                                  decoration: CustomerTextFieldStyle(
                                      Icons.onetwothree_outlined, 'Age'),
                                  style: const TextStyle(
                                    color: Colors.white,
                                  )),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: TextFormField(
                                  controller: _heightController,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                    LengthLimitingTextInputFormatter(10)
                                  ],
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return "Height is required";
                                    }
                                    return null;
                                  },
                                  keyboardType: TextInputType.number,
                                  decoration: CustomerTextFieldStyle(
                                      Icons.height_outlined, 'Height (cm)'),
                                  style: const TextStyle(
                                    color: Colors.white,
                                  )),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: TextFormField(
                                  controller: _weightController,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                    LengthLimitingTextInputFormatter(10)
                                  ],
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return "Weight is required";
                                    }
                                    return null;
                                  },
                                  keyboardType: TextInputType.number,
                                  decoration: CustomerTextFieldStyle(
                                      Icons.monitor_weight_outlined,
                                      'Weight (kg)'),
                                  style: const TextStyle(
                                    color: Colors.white,
                                  )),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),

                        // Address
                        TextFormField(
                            controller: _addressController,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "Address is required";
                              }
                              return null;
                            },
                            keyboardType: TextInputType.streetAddress,
                            decoration: CustomerTextFieldStyle(
                                Icons.location_city, 'Address'),
                            style: const TextStyle(
                              color: Colors.white,
                            )),
                        const SizedBox(height: 10),

                        // Illness
                        TextFormField(
                            controller: _illnessController,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "Illness is required";
                              }
                              return null;
                            },
                            keyboardType: TextInputType.text,
                            decoration: CustomerTextFieldStyle(
                                Icons.medical_services_outlined, 'Illness'),
                            style: const TextStyle(
                              color: Colors.white,
                            )),
                        const SizedBox(height: 10),

                        // Remarks (No validation)
                        TextFormField(
                            controller: _remarksController,
                            keyboardType: TextInputType.text,
                            decoration: CustomerTextFieldStyle(
                                Icons.notes_rounded, 'Remarks'),
                            style: const TextStyle(
                              color: Colors.white,
                            )),
                      ],
                    ),
                  ),
                ),
              ),
            )),
            const SizedBox(
              height: 20,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  constraints: const BoxConstraints(maxWidth: 140),
                  height: 36,
                  width: screenWidth * 0.5,
                  child: TextButton(
                      onPressed: () {
                        clearForm();
                      },
                      child: Text("Clear",
                          style: style4().copyWith(
                              fontSize: 18, color: Colors.grey.shade600))),
                ),
                const SizedBox(
                  width: 10,
                ),
                Container(
                  constraints: const BoxConstraints(maxWidth: 140),
                  height: 36,
                  width: screenWidth * 0.5,
                  child: TextButton(
                      onPressed: () => _nextButtonFunction(),
                      child: Text("Next",
                          style: style4().copyWith(
                              fontSize: 18, color: const Color(0xff1A936F)))),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  void _nextButtonFunction() {
    if (_formKey.currentState!.validate()) {
      _moveToNextPage();
    } else {
      CustomSnackbar.showSnackbar(
          type: SnackbarType.failure, message: "Fill the required Text Fields");
    }
  }

  void _moveToNextPage() async {
    CustomerDetails customerDetailsObj = CustomerDetails(
        fullName: _fullNameController.text.trim(),
        fatherName: _fatherNameController.text.trim(),
        mobileNumber: _mobileNumberController.text.trim(),
        email: _emailController.text.trim(),
        dob: _dobController.text,
        bloodGroup: selectedBloodGroup ?? 'Unknown',
        age: _ageController.text,
        height: _heightController.text.trim(),
        weight: _weightController.text.trim(),
        address: _addressController.text.trim(),
        illness: _illnessController.text.trim(),
        remarks: _remarksController.text.trim(),
        id: '');
    bool created = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => MembershipEnrollPage(
                customerDetailsObj: customerDetailsObj,
                pageController: widget.pageController)));
    if (created) {
      clearForm();
      setState(() {});
      widget.pageController.animateToPage(
        1, // Navigate to Page 1(Home page)
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void clearForm() {
    _fullNameController.clear();
    _fatherNameController.clear();
    _mobileNumberController.clear();
    _emailController.clear();
    _dobController.clear();
    _addressController.clear();
    _illnessController.clear();
    _heightController.clear();
    _weightController.clear();
    _remarksController.clear();
    selectedBloodGroup = null;
    setState(() {});
  }
}
