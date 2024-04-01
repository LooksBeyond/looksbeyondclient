import 'package:flutter/material.dart';
import 'package:looksbeyondclient/pages/AdditionalInfo/AdditionalInfoScreen.dart';
import 'package:looksbeyondclient/pages/AllBookings/AllBookings.dart';
import 'package:looksbeyondclient/pages/BookingDetails/BookingDetails.dart';
import 'package:looksbeyondclient/pages/Dashboard/dashboard.dart';
import 'package:looksbeyondclient/pages/Earnings/Earnings.dart';
import 'package:looksbeyondclient/pages/EmployeeProfile/EmployeeProfile.dart';
import 'package:looksbeyondclient/pages/Employees/employees.dart';
import 'package:looksbeyondclient/pages/Employees/widgets/addEmployee.dart';
import 'package:looksbeyondclient/pages/Feedback/feedbackScreen.dart';
import 'package:looksbeyondclient/pages/Login/loginPage.dart';

import 'package:looksbeyondclient/pages/SplashScreen/SplashScreen.dart';

Map<String, WidgetBuilder> appRoutes = {
  '/': (context) => const SplashScreen(),
  LoginPage.pageName: (context) => const LoginPage(),
  BottomNavBarScreen.pageName: (context) => const BottomNavBarScreen(),
  Earnings.pageName: (context) => Earnings(),
  FeedbackPage.pageName: (context) => const FeedbackPage(),
  Employees.pageName: (context) => Employees(),
  AdditionalInfoScreen.pageName: (context) => const AdditionalInfoScreen(),
  AddEmployee.pageName: (context) => const AddEmployee(),
  AllBookings.pageName: (context) => const AllBookings(),
  EmployeeProfile.pageName: (context) => const EmployeeProfile(),
  BookingDetails.pageName: (context) => const BookingDetails(),
};
