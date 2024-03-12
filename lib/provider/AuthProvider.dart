import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:looksbeyondclient/models/brand_booking.dart';
import 'package:looksbeyondclient/models/logged_in_brand.dart';
import 'package:looksbeyondclient/pages/Login/loginPage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthenticationProvider with ChangeNotifier {
  late SharedPreferences _preferences;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  LoggedInBrand? _loggedInBrand; // Store the logged-in brand

  // Getter to access the logged-in user
  LoggedInBrand? get loggedInBrand => _loggedInBrand;

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
  Future<LoggedInBrand?> initLoggedInUser(User? firebaseUser) async {
    _preferences = await SharedPreferences.getInstance();
    if (firebaseUser != null) {
      DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection('brands')
          .doc(firebaseUser.uid)
          .get();
      _loggedInBrand = LoggedInBrand.fromFireStore(snapshot);
      await setUserSharedPrefs(_preferences, _loggedInBrand!);
    } else {
      _loggedInBrand = null;
    }
    notifyListeners(); // Notify listeners of any changes
    return _loggedInBrand;
  }

  setUserSharedPrefs(SharedPreferences prefs, LoggedInBrand user) async {
    print("setting shared pref: " +
        user.address +
        user.address.toString() +
        user.phoneNumber +
        user.brandLogo);
    if (user.address != "" &&
        user.owner != "" &&
        user.phoneNumber != "" &&
        user.brandLogo != "") {
      print("setting shared pref: as true");
      await prefs.setBool("isProfileCompleted", true);
    } else {
      print("setting shared pref: as false");
      await prefs.setBool("isProfileCompleted", false);
    }
  }

  void updateLoggedInUser({
    String? phoneNumber,
    String? brandlogo,
    String? address,
    String? owner,
  }) {
    if (_loggedInBrand != null) {
      // Update the user's parameters if they are not null
      _loggedInBrand!.phoneNumber = phoneNumber ?? _loggedInBrand!.phoneNumber;
      _loggedInBrand!.brandLogo = brandlogo ?? _loggedInBrand!.brandLogo;
      _loggedInBrand!.address = address ?? _loggedInBrand!.address;
      _loggedInBrand!.owner = owner ?? _loggedInBrand!.owner;

      // Notify listeners of the change
      notifyListeners();
    }
    print(_loggedInBrand);
  }

  Stream<List<BrandBooking>> get brandBookingsStream {
    return FirebaseFirestore.instance
        .collection('bookings')
        .where('brand', isEqualTo: _loggedInBrand!.uid)
        .where('status', isEqualTo: 'completed')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => BrandBooking.fromFireStore(doc))
            .toList());
  }

  Future<DocumentSnapshot?> getEmployeeData(String employeeId) async {
    try {
      DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection('employee')
          .doc(employeeId)
          .get();
      if (snapshot.exists) {
        return snapshot;
      }
    } catch (e) {
      print('Error fetching employee name: $e');
    }
    return null;
  }
}
