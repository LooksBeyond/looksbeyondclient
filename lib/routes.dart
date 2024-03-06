import 'package:flutter/material.dart';
import 'package:looksbeyondclient/pages/Login/loginPage.dart';


import 'package:looksbeyondclient/pages/SplashScreen/SplashScreen.dart';

Map<String, WidgetBuilder> appRoutes = {
  '/': (context) => const SplashScreen(),
  LoginPage.pageName: (context) => const LoginPage(),
//   BottomNavBarScreen.pageName: (context) => const BottomNavBarScreen(),
//   BookingDetails.pageName: (context) => BookingDetails(),
//   FeedbackPage.pageName: (context) => const FeedbackPage(),
//   SearchScreen.pageName: (context) => SearchScreen(),
//   AdditionalInfoScreen.pageName: (context) => const AdditionalInfoScreen(),
//   ServicesList.pageName: (context) => const ServicesList(),
//   ServiceEmployees.pageName: (context) => const ServiceEmployees(),
//   CreateBooking.pageName: (context) => const CreateBooking(),
//   PaymentScreen.pageName: (context) => const PaymentScreen(),
//   EmployeeInfoScreen.pageName: (context) => const EmployeeInfoScreen(),
//   BrandDisplayScreen.pageName: (context) => BrandDisplayScreen(),
};
