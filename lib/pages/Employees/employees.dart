import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:looksbeyondclient/models/logged_in_brand.dart';
import 'package:looksbeyondclient/pages/Employees/widgets/addEmployee.dart';
import 'package:looksbeyondclient/provider/AuthProvider.dart';
import 'package:provider/provider.dart';

class Employees extends StatefulWidget {
  static const String pageName = '/employees';
  const Employees({super.key});

  @override
  State<Employees> createState() => _EmployeesState();
}

class _EmployeesState extends State<Employees> {
  late AuthenticationProvider authenticationProvider;
  late LoggedInBrand loggedInBrand;
  late List employeeDocId;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    authenticationProvider = Provider.of<AuthenticationProvider>(context, listen: false);
    loggedInBrand = authenticationProvider.loggedInBrand!;
    employeeDocId = loggedInBrand.employees;
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(
            'Employees',
            style: TextStyle(
              fontSize: 24.0,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          actions: [
            IconButton(
              onPressed: () {
                Navigator.of(context).pushNamed(AddEmployee.pageName);
              },
              icon: Icon(Icons.add),
              tooltip: "Add Employee",
            )
          ],
        ),
        body: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('employee')
              .where(FieldPath.documentId, whereIn: employeeDocId)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              final List<DocumentSnapshot> documents = snapshot.data!.docs;
              // Use documents list to display employee data
              return ListView.builder(
                itemCount: documents.length,
                itemBuilder: (context, index) {
                  final employee = documents[index];
                  // Use employee data to build UI
                  return ListTile(
                    title: Text(employee['name']),
                    subtitle: Text(employee['email']),
                    // Add more fields as needed
                  );
                },
              );
            } else if (snapshot.hasError) {
              return Center(
                child: Text('Error: ${snapshot.error}'),
              );
            } else {
              return Center(
                child: CircularProgressIndicator(),
              );
            }
          },
        ),
    );
  }
}
