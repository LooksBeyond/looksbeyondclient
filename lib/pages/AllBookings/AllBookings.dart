import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:looksbeyondclient/models/brand_booking.dart';
import 'package:looksbeyondclient/models/logged_in_brand.dart';
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

      ),
    );
  }
}
