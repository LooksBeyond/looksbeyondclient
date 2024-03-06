import 'package:cloud_firestore/cloud_firestore.dart';

enum Status {
  active,
  completed,
  refunded,
}

class UserBooking {
  String? id;
  final String title;
  final String userId;
  final int dateTime;
  final Status status;
  final String employee;
  final String brand;
  final bool isPaid;
  final String timeSlot;
  final String date;
  final double subtotal;
  final double total;
  final String service;
  String? review;
  double? taxes;
  String? paidThrough;
  String? empImage;

  UserBooking(
      {this.id,
      required this.userId,
      required this.isPaid,
      required this.timeSlot,
      required this.date,
      required this.subtotal,
      required this.total,
      required this.service,
      required this.title,
      required this.dateTime,
      required this.status,
      required this.employee,
      required this.brand,
      this.review,
      this.empImage,
      this.paidThrough,
      this.taxes});

  factory UserBooking.fromFireStore(DocumentSnapshot snapshot) {
    var data = snapshot.data()! as Map<String, dynamic>;
    print("Booking data::");
    print(data);

    var userBooking = UserBooking(
      id: snapshot.id,
      userId: data['userId'] ?? '',
      title: data['title'] ?? '',
      dateTime: data['dateTime'] ?? '',
      status: data['status'] == "active"
          ? Status.active
          : data['status'] == 'refunded'
              ? Status.refunded
              : Status.completed,
      employee: data['employee'] ?? '',
      brand: data['brand'] ?? '',
      isPaid: data['isPaid'] ?? false,
      timeSlot: data['timeSlot'] ?? '',
      date: data['date'] ?? '',
      subtotal: data['subtotal'] ?? 0.0,
      total: data['total'] ?? 0.0,
      service: data['service'] ?? '',
      review: data['review'] ?? '',
      empImage: data['empImage'] ?? '',
      paidThrough: data['paidThrough'] ?? '',
      taxes: data['taxes'] ?? 0,
    );

    return userBooking;
  }
}
