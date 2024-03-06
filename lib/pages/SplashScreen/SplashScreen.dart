import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:looksbeyondclient/models/logged_in_user.dart';
// import 'package:looksbeyondclient/pages/AdditonalInfo/AdditionalInfoScreen.dart';
// import 'package:looksbeyondclient/pages/Dashboard/dashboard.dart';
import 'package:looksbeyondclient/pages/Login/loginPage.dart';
import 'package:looksbeyondclient/provider/AuthProvider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  late SharedPreferences sharedPreferences;
  late AuthenticationProvider authenticationProvider;
  @override
  void initState() {
    super.initState();
    authenticationProvider =
        Provider.of<AuthenticationProvider>(context, listen: false);
    _checkAuthentication();
  }

  void _checkAuthentication() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    User? user = auth.currentUser;
    sharedPreferences = await SharedPreferences.getInstance();

    if (user != null) {
      await authenticationProvider.initLoggedInUser(user);
      bool? isProfileCompleted = sharedPreferences.getBool("isProfileCompleted");
      if (isProfileCompleted != null) {
        // User is already logged in, navigate to home page directly
        WidgetsBinding.instance?.addPostFrameCallback((_) {
          print("isProfileCompleted: ");
          print(isProfileCompleted);
          if (isProfileCompleted) {
            _navigateToHome();
          } else {
            _navigateToAdditionalDetails();
          }
        });
      }
    } else {
      // User is not logged in, navigate to login screen
      WidgetsBinding.instance?.addPostFrameCallback((_) {
        _navigateToLogin();
      });
    }
  }

  void _navigateToHome() {
    // Navigator.of(context).pushReplacementNamed(BottomNavBarScreen.pageName);
  }

  void _navigateToAdditionalDetails() {
    // Navigator.of(context).pushReplacementNamed(AdditionalInfoScreen.pageName);
  }

  void _navigateToLogin() {
    Navigator.of(context).pushReplacementNamed(LoginPage.pageName);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xff000000),
      body: Container(
        child: Center(
          child: SvgPicture.asset(
            'assets/img/login_logo.svg',
            height: MediaQuery.of(context).size.height > 800 ? 140.0 : 150,
            fit: BoxFit.fill,
          ),
        ),
      ),
    );
  }
}
