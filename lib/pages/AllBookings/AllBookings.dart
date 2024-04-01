import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:looksbeyondclient/models/brand_booking.dart';
import 'package:looksbeyondclient/models/logged_in_brand.dart';
import 'package:looksbeyondclient/pages/BookingDetails/BookingDetails.dart';
import 'package:looksbeyondclient/provider/AuthProvider.dart';
import 'package:provider/provider.dart';

class AllBookings extends StatefulWidget {
  static const String pageName = '/allbookings';
  const AllBookings({super.key});

  @override
  State<AllBookings> createState() => _AllBookingsState();
}

class _AllBookingsState extends State<AllBookings> {
  late AuthenticationProvider authenticationProvider;
  late LoggedInBrand loggedInBrand;

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
        title: Text(
          'All Bookings',
          style: TextStyle(
            fontSize: 24.0,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('bookings')
              .where('brand', isEqualTo: loggedInBrand.uid)
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
                child: Text("No Bookings yet"),
              );
            }
            return ListView.builder(
              shrinkWrap: true,
              itemCount: bookingList.length,
              itemBuilder: (BuildContext context, int index) {
                return ListTile(
                  title: Text(bookingList[index].title),
                  subtitle: Text(
                    bookingList[index].status.name.toUpperCase(),
                    style: TextStyle(
                        color: bookingList[index].status == Status.completed
                            ? Colors.blue
                            : Colors.green),
                  ),
                  trailing: IconButton(
                    onPressed: () {
                      Navigator.of(context).pushNamed(BookingDetails.pageName,
                          arguments: bookingList[index]);
                    },
                    icon: (Icon(CupertinoIcons.info)),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
