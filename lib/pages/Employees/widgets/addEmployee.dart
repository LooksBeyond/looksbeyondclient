import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:looksbeyondclient/models/logged_in_brand.dart';
import 'package:looksbeyondclient/provider/AuthProvider.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';
import 'package:provider/provider.dart';

class AddEmployee extends StatefulWidget {
  static const String pageName = '/addemployees';

  const AddEmployee({Key? key}) : super(key: key);

  @override
  State<AddEmployee> createState() => _AddEmployeeState();
}

class _AddEmployeeState extends State<AddEmployee> {
  final _formKey = GlobalKey<FormState>();

  TextEditingController _nameController = TextEditingController();
  TextEditingController _ageController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  File? _image;

  List<String> _selectedServices = [];

  Map<String, String> _serviceIds = {};
  Map<String, double> _servicePrices = {};
  List<String> _services = []; // Change type to List<String>
  late AuthenticationProvider authenticationProvider;
  late LoggedInBrand loggedInBrand;

  @override
  void initState() {
    super.initState();
    _getServices();
    authenticationProvider = Provider.of<AuthenticationProvider>(context, listen: false);
    loggedInBrand = authenticationProvider.loggedInBrand!;
  }

  Future<void> _getServices() async {
    final QuerySnapshot snapshot =
        await FirebaseFirestore.instance.collection('service').get();
    setState(() {
      _services = snapshot.docs
          .map((doc) {
        final serviceName = doc['name'] as String;
        final serviceId = doc.id;
        _serviceIds[serviceName] = serviceId; // Store service name and ID in the map
        return serviceName;
      })
          .toList();
    });
  }

  Future<void> _getImageFromGallery() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      }
    });
  }

  Future<void> _uploadImageAndAddEmployee() async {
    if (_image == null) return;

    // Show a confirmation dialog
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirmation'),
        content: Text('Do you want to add this employee?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(false); // User canceled
            },
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              String imageName =
                  DateTime.now().millisecondsSinceEpoch.toString();
              firebase_storage.Reference ref = firebase_storage
                  .FirebaseStorage.instance
                  .ref()
                  .child('employee_images')
                  .child('$imageName.jpg');

              await ref.putFile(_image!);

              // Get image URL
              String imageUrl = await ref.getDownloadURL();

              Map<String, double> servicePricesWithIds = {};
              for (String serviceName in _selectedServices) {
                final serviceId = _serviceIds[serviceName];
                if (serviceId != null) {
                  servicePricesWithIds[serviceId] = _servicePrices[serviceName] ?? 0.0;
                }
              }

              // Add employee details to Firestore
              DocumentReference employeeRef = await FirebaseFirestore.instance.collection('employee').add({
                'name': _nameController.text,
                'age': int.parse(_ageController.text),
                'email': _emailController.text,
                'img': imageUrl,
                'services': servicePricesWithIds,
                'avgRating': 0,
                'numberOfRatings': 0,
              });

              loggedInBrand.employees.add(employeeRef.id);
              print('brand id ${loggedInBrand.uid}');
              await FirebaseFirestore.instance.collection('brands').doc(loggedInBrand.uid).set({
                'employees': FieldValue.arrayUnion([employeeRef.id]),
              }, SetOptions(merge: true));


              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Employee added successfully')),
              );

              // Clear form and image
              _formKey.currentState?.reset();
              setState(() {
                _image = null;
              });
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: Text('Confirm'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Add Employee',
          style: TextStyle(
            fontSize: 24.0,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: _getImageFromGallery,
                child: CircleAvatar(
                  radius: 50,
                  backgroundImage: _image != null ? FileImage(_image!) : null,
                  child: _image == null
                      ? Icon(
                    Icons.add_a_photo,
                    size: 50,
                  )
                      : null,
                ),
              ),
              SizedBox(height: 16.0),
              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(labelText: 'Name'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a name';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: _ageController,
                      decoration: InputDecoration(labelText: 'Age'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter an age';
                        }
                        // You can add additional age validation if needed
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: _emailController,
                      decoration: InputDecoration(labelText: 'Email'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter an email';
                        }
                        // Add email validation if needed
                        return null;
                      },
                    ),
                    SizedBox(height: 16.0),
                    MultiSelectDialogField(
                      searchHint: "Type service name",
                      searchable: true,
                      buttonText: Text("Select Services"),
                      separateSelectedItems: true,
                      title: Text('Select Services'),
                      items: _services
                          .map((service) => MultiSelectItem(service, service))
                          .toList(),
                      initialValue: _selectedServices,
                      listType: MultiSelectListType.CHIP,
                      onConfirm: (values) {
                        setState(() {
                          _selectedServices = values.map<String>((value) => value as String).toList();
                        });
                      },
                      chipDisplay: MultiSelectChipDisplay(
                        onTap: (value) {
                          setState(() {
                            _selectedServices.remove(value);
                          });
                        },
                      ),
                    ),
                    SizedBox(height: 16.0),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: _selectedServices.length,
                      itemBuilder: (context, index) {
                        final service = _selectedServices[index];
                        return Row(
                          children: [
                            Expanded(child: Text(service)),
                            SizedBox(width: 10),
                            Expanded(
                              child: TextFormField(
                                keyboardType: TextInputType.numberWithOptions(decimal: true),
                                decoration: InputDecoration(labelText: 'Price'),
                                onChanged: (value) {
                                  setState(() {
                                    _servicePrices[service] = double.tryParse(value) ?? 0.0;
                                  });
                                },
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: _uploadImageAndAddEmployee,
                child: Text('Add Employee'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
