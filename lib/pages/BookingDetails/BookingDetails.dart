import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:looksbeyondclient/models/brand_booking.dart';

class BookingDetails extends StatefulWidget {
  static const String pageName = '/bookingDetails';
  const BookingDetails({super.key});

  @override
  State<BookingDetails> createState() => _BookingDetailsState();
}

class _BookingDetailsState extends State<BookingDetails> {
  @override
  Widget build(BuildContext context) {
    final brandBooking =
    ModalRoute.of(context)!.settings.arguments as BrandBooking;
    return Scaffold(
      appBar: AppBar(
        title: Text(brandBooking.title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Booking ID: ${brandBooking.id}',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            FutureBuilder<DocumentSnapshot>(
              future: FirebaseFirestore.instance
                  .collection('service')
                  .doc(brandBooking.service) // Assuming serviceId is the ID of the service
                  .get(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                } else if (snapshot.hasError || !snapshot.hasData) {
                  return Text('Error fetching service data');
                } else {
                  final serviceData = snapshot.data!;
                  final serviceName = serviceData['name']; // Replace 'name' with the field containing the service name
                  return Text(
                    'Service: $serviceName',
                    style: TextStyle(fontSize: 18),
                  );
                }
              },
            ),
            SizedBox(height: 10),
            Text(
              'Date & Time: ${brandBooking.dateTime}',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 10),
            FutureBuilder<DocumentSnapshot>(
              future: FirebaseFirestore.instance
                  .collection('employee')
                  .doc(brandBooking.employee) // Assuming employeeId is the ID of the employee
                  .get(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                } else if (snapshot.hasError || !snapshot.hasData) {
                  return Text('Error fetching employee data');
                } else {
                  final employeeData = snapshot.data!;
                  final employeeName =
                  employeeData['name']; // Replace 'name' with the field containing the employee name
                  return Text(
                    'Employee Name: $employeeName',
                    style: TextStyle(fontSize: 18),
                  );
                }
              },
            ),
            SizedBox(height: 10),
            Text(
              'Total Price: \$${brandBooking.subtotal}',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
