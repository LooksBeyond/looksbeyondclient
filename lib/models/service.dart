import 'package:cloud_firestore/cloud_firestore.dart';

class Service {
  final String id;
  final String name;
  final int time;

  Service({required this.id, required this.name, required this.time});

  factory Service.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Service(id: doc.id, name: data['name'], time: data['time']);
  }
}