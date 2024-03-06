import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:looksbeyondclient/models/logged_in_user.dart';
import 'package:looksbeyondclient/pages/Login/loginPage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthenticationProvider with ChangeNotifier {
  late SharedPreferences _preferences;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  LoggedInUser? _loggedInUser; // Store the logged-in user

  // Getter to access the logged-in user
  LoggedInUser? get loggedInUser => _loggedInUser;

  User? get firebaseUser => FirebaseAuth.instance.currentUser;

  Future<void> signOut(BuildContext context) async {
    try {
      await _auth.signOut();
      SharedPreferences pref = await SharedPreferences.getInstance();
      pref.clear();
      Navigator.of(context).pushReplacementNamed(LoginPage.pageName);
    } catch (e) {
      print("Error signing out: $e");
    }
  }


  // Function to initialize the logged-in user
  Future<LoggedInUser?> initLoggedInUser(User? firebaseUser) async {
    _preferences = await SharedPreferences.getInstance();
    if (firebaseUser != null) {
      DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(firebaseUser.uid)
          .get();
      _loggedInUser = LoggedInUser.fromFireStore(snapshot);
      await setUserSharedPrefs(_preferences, _loggedInUser!);
    } else {
      _loggedInUser = null;
    }
    notifyListeners(); // Notify listeners of any changes
    return _loggedInUser;
  }

  setUserSharedPrefs(SharedPreferences prefs, LoggedInUser user) async {
    print("setting shared pref: " + user.address + user.address.toString() + user.phoneNumber + user.profileImage);
    if (user.address != "" &&
        user.age != 0 &&
        user.phoneNumber != "" &&
        user.profileImage != "") {
    print("setting shared pref: as true");
      await prefs.setBool("isProfileCompleted", true);
    }else{
    print("setting shared pref: as false");
      await prefs.setBool("isProfileCompleted", false);
    }
  }


  void updateLoggedInUser({
    String? phoneNumber,
    String? profileImage,
    String? address,
    int? age,
  }) {
    if (_loggedInUser != null) {
      // Update the user's parameters if they are not null
      _loggedInUser!.phoneNumber = phoneNumber ?? _loggedInUser!.phoneNumber;
      _loggedInUser!.profileImage = profileImage ?? _loggedInUser!.profileImage;
      _loggedInUser!.address = address ?? _loggedInUser!.address;
      _loggedInUser!.age = age ?? _loggedInUser!.age;

      // Notify listeners of the change
      notifyListeners();
    }
    print(_loggedInUser);
  }


}
