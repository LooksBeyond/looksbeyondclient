import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:looksbeyondclient/models/brand.dart';
import 'package:looksbeyondclient/models/brand_booking.dart';
import 'package:looksbeyondclient/models/logged_in_brand.dart';
import 'package:looksbeyondclient/pages/AllBookings/AllBookings.dart';
import 'package:looksbeyondclient/pages/BrandProfileScreen/BrandProfileScreen.dart';
import 'package:looksbeyondclient/pages/Earnings/Earnings.dart';
import 'package:looksbeyondclient/pages/Employees/employees.dart';
import 'package:looksbeyondclient/provider/AuthProvider.dart';
import 'package:provider/provider.dart';

class BottomNavBarScreen extends StatefulWidget {
  static const String pageName = '/dashboard';

  const BottomNavBarScreen({super.key});

  @override
  State<BottomNavBarScreen> createState() => _BottomNavBarScreenState();
}

class _BottomNavBarScreenState extends State<BottomNavBarScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    Dashboard(),
    Employees(),
    Earnings(),
    BrandProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        showUnselectedLabels: true,
        fixedColor: Color(0xFFfbab66),
        unselectedItemColor: Colors.grey,
        unselectedLabelStyle: TextStyle(color: Colors.grey),
        currentIndex: _currentIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.space_dashboard_outlined),
            activeIcon: Icon(Icons.space_dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
              icon: Icon(Icons.supervised_user_circle_outlined),
              activeIcon: Icon(Icons.supervised_user_circle_sharp),
              label: 'Employees',
              tooltip: "List all employees"),
          BottomNavigationBarItem(
              icon: Icon(Icons.monetization_on_outlined),
              activeIcon: Icon(Icons.monetization_on),
              label: 'Earnings',
              tooltip: 'List all earnings'),
          BottomNavigationBarItem(
              icon: Icon(Icons.pages_outlined),
              activeIcon: Icon(Icons.pages_rounded),
              label: 'Brand',
              tooltip: "Brand Profile"),
        ],
      ),
    );
  }
}

class Dashboard extends StatefulWidget {
  const Dashboard({Key? key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  late AuthenticationProvider authenticationProvider;
  late LoggedInBrand loggedInBrand;
  List<Brand> ClientList = [];

  @override
  void initState() {
    super.initState();
    authenticationProvider =
        Provider.of<AuthenticationProvider>(context, listen: false);
    loggedInBrand = authenticationProvider.loggedInBrand!;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: SvgPicture.asset(
          'assets/img/login_logo_black.svg',
          fit: BoxFit.contain,
          width: 140,
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 20.0),
              Text(
                "Hello, ${loggedInBrand.brand}",
                style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    "Active Bookings",
                    style: TextStyle(fontSize: 20),
                  ),
                  TextButton(
                      onPressed: () {
                        Navigator.of(context).pushNamed(AllBookings.pageName);
                      },
                      child: Text(
                        "View All",
                        style: TextStyle(color: Colors.blueAccent),
                      ))
                ],
              ),
              SizedBox(height: 10.0),
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('bookings')
                    .where('brand', isEqualTo: loggedInBrand.uid)
                    .where('status', isEqualTo: 'active')
                    .orderBy('date')
                    .orderBy('timeSlot')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    print('Waiting for data...');
                    return CircularProgressIndicator();
                  }
                  if (snapshot.hasError) {
                    print('Error: ${snapshot.error}');
                    return Text('Error: ${snapshot.error}');
                  }

                  List<BrandBooking> bookingList = snapshot.data!.docs
                      .map((doc) => BrandBooking.fromFireStore(doc))
                      .toList();

                  if (snapshot.data!.docs.length == 0) {
                    return Center(
                      child: Text("No Active Bookings"),
                    );
                  }
                  return ListView.builder(
                    shrinkWrap: true,
                    itemCount: bookingList.length,
                    itemBuilder: (BuildContext context, int index) {
                      return Dismissible(
                        key: Key(bookingList[index]
                            .id!), // Use a unique key for each booking
                        direction: DismissDirection
                            .endToStart, // Swipe from right to left
                        background: Container(
                          alignment: Alignment.centerRight,
                          color: Colors.green,
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 20),
                            child: Icon(Icons.check_box, color: Colors.white),
                          ),
                        ),
                        onDismissed: (direction) async {
                          // Update the status of the booking to "completed"
                          bookingList[index].status = Status.completed;

                          // Update the document in Firestore
                          await FirebaseFirestore.instance
                              .collection('bookings')
                              .doc(bookingList[index].id)
                              .update({'status': 'completed'})
                              .then((value) =>
                                  print('Booking status updated successfully'))
                              .catchError((error) => print(
                                  'Failed to update booking status: $error'));

                          setState(() {
                            // Update the local list to reflect the change
                            bookingList.removeAt(index);
                          });
                        },
                        child: ListTile(
                          title: Text(bookingList[index]
                              .title), // Replace with relevant booking details
                          subtitle: Text(bookingList[index]
                              .status
                              .toString()), // Replace with relevant booking details
                        ),
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
