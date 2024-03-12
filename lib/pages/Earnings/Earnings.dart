import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:looksbeyondclient/models/brand_booking.dart';
import 'package:looksbeyondclient/models/logged_in_brand.dart';
import 'package:looksbeyondclient/provider/AuthProvider.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:math';
class Earnings extends StatefulWidget {
  static const String pageName = '/earnings';
  const Earnings({Key? key});

  @override
  State<Earnings> createState() => _EarningsState();
}

class _EarningsState extends State<Earnings> {
  late AuthenticationProvider authenticationProvider;
  late LoggedInBrand loggedInBrand;
  Map<String, String> employeeImages = {};

  @override
  void initState() {
    super.initState();
    authenticationProvider =
        Provider.of<AuthenticationProvider>(context, listen: false);
    loggedInBrand = authenticationProvider.loggedInBrand!;
  }

  Map<String, double> earningsData = {};
  late double totalEarnings;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Earnings',
          style: TextStyle(
            fontSize: 24.0,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ),
      body: SafeArea(
        child: StreamBuilder<List<BrandBooking>>(
          stream: authenticationProvider.brandBookingsStream,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else {
              List<BrandBooking>? bookings = snapshot.data;
              if (bookings != null && bookings.isNotEmpty) {
                return FutureBuilder<void>(
                  future: _updateEarningsData(bookings),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    } else {
                      return Center(
                        child: Column(
                          children: [
                            Expanded(
                              flex: 1,
                              child: PieChart(
                                PieChartData(
                                  sections: _generatePieChartSections(),
                                  borderData: FlBorderData(show: false),
                                  sectionsSpace: 0,
                                  centerSpaceRadius: 40,
                                ),
                                swapAnimationDuration:
                                Duration(milliseconds: 150), // Optional
                                swapAnimationCurve: Curves.easeIn,
                              ),
                            ),
                            Container(
                              height: 20,
                              margin: EdgeInsets.only(bottom: 20),
                              decoration: BoxDecoration(
                                border: Border(
                                    bottom: BorderSide(color: Colors.grey)),
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Total Earnings: \$${totalEarnings.toStringAsFixed(2)}',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: 10),
                                  ..._buildIndicators(),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    }
                  },
                );
              } else {
                return Center(child: Text('No bookings available'));
              }
            }
          },
        ),
      ),
    );
  }


  Future<void> _updateEarningsData(List<BrandBooking> bookings) async {
    totalEarnings = 0;
    for (var booking in bookings) {
      Map<String, dynamic> employee = await _getEmployeeData(booking.employee);
      String employeeName = employee['name'];
      String imgURL = employee['img']; // Get employee image URL
      if (earningsData.containsKey(employeeName)) {
        earningsData[employeeName] =
            (earningsData[employeeName] ?? 0) + booking.subtotal;
      } else {
        earningsData[employeeName] = booking.subtotal;
      }
      totalEarnings += booking.subtotal;
      employeeImages[employeeName] = imgURL; // Store image URL
    }
  }


  List<PieChartSectionData> _generatePieChartSections() {
    List<PieChartSectionData> sections = [];
    earningsData.forEach((key, value) {
      sections.add(
        PieChartSectionData(
          value: value,
          color: _getRandomColor(),
          title: key,
          showTitle: true,
          radius: 50,
          badgeWidget: _Badge(employeeImages[key]!, borderColor: Colors.white, size: 30,),
          badgePositionPercentageOffset: 1,
        ),
      );
    });
    return sections;
  }

  List<Color> usedColors = [];

  Color _getRandomColor() {
    Random random = Random();
    Color color;
    do {
      color = Color.fromRGBO(
        random.nextInt(256),
        random.nextInt(256),
        random.nextInt(256),
        1,
      );
    } while (usedColors.contains(color));
    usedColors.add(color);
    return color;
  }

  Future<Map<String, dynamic>> _getEmployeeData(String employeeId) async {
    DocumentSnapshot? snap =
    await authenticationProvider.getEmployeeData(employeeId);
    String? name = snap!.get("name");
    String? img = snap.get("img");
    Map<String, dynamic> nameImg = {"name": name, "img": img};
    return nameImg;
  }

  List<Widget> _buildIndicators() {
    List<Widget> indicators = [];
    int index = 0;
    earningsData.forEach((key, value) {
      indicators.add(
        Indicator(
          color: usedColors.length > index
              ? usedColors[index]
              : _getRandomColor(),
          text: key,
          earning: value.toString(),
        ),
      );
      indicators.add(SizedBox(height: 4));
      index++;
    });
    return indicators;
  }
}

class Indicator extends StatelessWidget {
  const Indicator({
    Key? key,
    required this.color,
    required this.text,
    required this.earning,
    this.size = 16,
    this.textColor,
  }) : super(key: key);

  final Color color;
  final String text;
  final String earning;
  final double size;
  final Color? textColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 2,
            blurRadius: 3,
            offset: Offset(0, 2), // changes position of shadow
          ),
        ],
      ),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        trailing: Text(
          "\$$earning",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
        title: Text(
          text,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
      ),
    );
  }
}


class _Badge extends StatelessWidget {
  const _Badge(
      this.imgURL, {
        required this.size,
        required this.borderColor,
      });
  final String imgURL;
  final double size;
  final Color borderColor;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: PieChart.defaultDuration,
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        border: Border.all(
          color: borderColor,
          width: 2,
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withOpacity(.5),
            offset: const Offset(3, 3),
            blurRadius: 3,
          ),
        ],
      ),
      padding: EdgeInsets.all(size * .15),
      child: Center(
        child: Image.network(
          imgURL,
        ),
      ),
    );
  }
}
