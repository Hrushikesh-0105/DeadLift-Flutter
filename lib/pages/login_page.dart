import 'package:deadlift/custom_widgets/snack_bar.dart';
import 'package:deadlift/database_helper/getxController.dart';
import 'package:deadlift/debugFunctions/debugLog.dart';
import 'package:deadlift/pages/base_app_layout.dart';
import 'package:get/get.dart';
// import 'package:get/get_core/src/get_main.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:deadlift/database_helper/database_helper.dart';
import 'package:deadlift/firebase_helper/custom_firebase_Api.dart';
import 'package:deadlift/style.dart';
import 'package:flutter/material.dart';

// void main() {
//   runApp(MaterialApp(
//     home: LoginPage(),
//     debugShowCheckedModeBanner: false,
//   ));
// }

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool isLoading = false;
  final _formKey = GlobalKey<FormState>();
  TextEditingController _usernameController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  final DatabaseController dbController = Get.put(DatabaseController());

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: Text("hello"),
      // ),
      // backgroundColor: Colors.red,
      body: LayoutBuilder(
        builder: (context, constraints) {
          // Check if the width is greater than 600 (tablet)
          if (constraints.maxWidth > 600) {
            return _buildTabletLayout(context);
          } else {
            return _buildMobileLayout(context);
          }
        },
      ),
    );
  }

  Widget _buildTabletLayout(BuildContext context) {
    double deviceHeight = MediaQuery.of(context).size.height;
    double deviceWidth = MediaQuery.of(context).size.width;
    return Stack(children: [
      const FullScreenImage(imagePath: "assets/images/background_tab2.png"),
      const DiagonalGradientOverlay(),
      Row(
        children: [
          // Left half - Image
          Expanded(
            child: Image.asset(
              'assets/images/deadLiftLogo.png', // Replace with your image
              height: deviceHeight * 0.65,

              fit: BoxFit.contain,
            ),
          ),
          // Right half - Login form
          Expanded(
            child: Center(
                child: Container(
                    constraints: BoxConstraints(
                        maxWidth: deviceWidth * 0.4, maxHeight: 400),
                    decoration: BoxDecoration(
                        color: const Color(0xff242424),
                        borderRadius: BorderRadius.circular(20)),
                    child: _buildLoginForm(context))),
          ),
        ],
      ),
    ]);
  }

  Widget _buildMobileLayout(BuildContext context) {
    double deviceHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          const FullScreenImage(
              imagePath: "assets/images/background_mobile2.png"),
          const DiagonalGradientOverlay(),

          // Main Content
          SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: deviceHeight,
              ),
              child: IntrinsicHeight(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Top Logo Section with AnimatedContainer
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: double.infinity,
                      height: MediaQuery.of(context).viewInsets.bottom > 0
                          ? deviceHeight * 0.3
                          : deviceHeight * 0.6,
                      child: Image.asset(
                        'assets/images/deadLiftLogo.png',
                        fit: BoxFit.contain,
                      ),
                    ),

                    // Login Form Container
                    Container(
                      padding: const EdgeInsets.only(top: 8),
                      decoration: const BoxDecoration(
                        color: Color(0xff242424),
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(30),
                          topRight: Radius.circular(30),
                        ),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildLoginForm(context),
                          // Add padding at bottom for keyboard
                          SizedBox(
                              height: MediaQuery.of(context).viewInsets.bottom),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoginForm(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32.0),
      // color: Colors.white,
      // color: Colors.white,
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Login',
              // style: Theme.of(context).textTheme.headlineMedium,

              style: TextStyle(
                color: Colors.white,
                fontFamily: "poppins",
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            TextFormField(
              controller: _usernameController,
              cursorColor: Colors.grey,
              style: TextStyle(
                color: Colors.grey.shade200,
              ),
              validator: validateField,
              decoration: loginTextFieldStyle(
                  Icons.person_outline_outlined, "Username"),
              // onChanged: (value) {
              //   validateField(value);
              // },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _passwordController,
              validator: validateField,
              obscureText: true,
              style: TextStyle(
                color: Colors.grey.shade200,
              ),
              cursorColor: Colors.grey,
              decoration: loginTextFieldStyle(Icons.lock_outline, "Password"),
              // onChanged: (value) {
              //   validateField(value);
              // },
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: (!isLoading) ? _handleLogin : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: deadliftRedColor,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: (!isLoading)
                    ? Text(
                        'Log In',
                        style: loginButtonStyle(),
                      )
                    : const CircularProgressIndicator(
                        color: Colors.white,
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String? validateField(String? value) {
    if (value == null || value.isEmpty) {
      return 'Field cannot be empty';
    }
    return null;
  }

  void _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      isLoading = true;
      setState(() {});
      String typedUsername = _usernameController.text.toString().trim();
      String typedPassword = _passwordController.text.toString();
      bool loggedIn = await checkLoginDetails(typedPassword, typedUsername);
      if (!loggedIn) {
        CustomSnackbar.showSnackbar(
            type: SnackbarType.failure, message: "Failed to login");
        setState(() {});
      } else {
        CustomSnackbar.showSnackbar(
            type: SnackbarType.success, message: "Logged in successfully");
        navigateToMainPage();
      }
      isLoading = false;
    }
  }

  Future<bool> checkLoginDetails(
      String typedPassword, String typedUsername) async {
    bool loggedIn = false;
    List<Map<String, dynamic>>? CREDENTIALSLIST =
        await CustomFirebaseApi().getUsernameAndPasswords();
    if (CREDENTIALSLIST == null) {
      CustomSnackbar.showSnackbar(
          type: SnackbarType.networkError,
          message: "Check your internet connection");
    } else {
      for (Map<String, dynamic> map in CREDENTIALSLIST) {
        if (map[FirebaseDbCredentialKeys.username] == typedUsername) {
          if (map[FirebaseDbCredentialKeys.password] == typedPassword) {
            loggedIn = true;
            bool isAdmin =
                (map[FirebaseDbCredentialKeys.status] == loggedInStatus.admin);
            await saveBoolToSharedPrefs(sharedPrefKeys.loggedIn, true);
            await saveBoolToSharedPrefs(sharedPrefKeys.isAdmin, isAdmin);
            dbController.isAdmin.value = isAdmin;
          }
        }
      }
    }
    debugLog("Loggedin:$loggedIn");
    return loggedIn;
  }

  Future<void> saveBoolToSharedPrefs(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }

  void navigateToMainPage() {
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => const MyApp()));
  }
}

class FullScreenImage extends StatelessWidget {
  final String imagePath;

  const FullScreenImage({Key? key, required this.imagePath}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      imagePath,
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      fit: BoxFit.cover,
    );
  }
}

class DiagonalGradientOverlay extends StatelessWidget {
  const DiagonalGradientOverlay({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomRight,
          end: Alignment.topLeft,
          colors: [
            Colors.black.withOpacity(1.0),
            Colors.black.withOpacity(0.7), // Full opacity black at bottom right
            Colors.black.withOpacity(0.0), // Fully transparent at top left
          ],
        ),
      ),
    );
  }
}

class PercentageSizeImage extends StatelessWidget {
  final String imagePath;
  final double widthPercent;
  final double heightPercent;

  const PercentageSizeImage({
    Key? key,
    required this.imagePath,
    this.widthPercent = 0.5, // 50% of screen width by default
    this.heightPercent = 0.3, // 30% of screen height by default
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Image.asset(
      imagePath,
      width: screenSize.width * widthPercent,
      height: screenSize.height * heightPercent,
      fit: BoxFit.cover,
    );
  }
}
