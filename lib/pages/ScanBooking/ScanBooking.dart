import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class ScanBooking extends StatefulWidget {
  static const String pageName = '/scan_booking';

  const ScanBooking({super.key});

  @override
  State<ScanBooking> createState() => _ScanBookingState();
}

class _ScanBookingState extends State<ScanBooking> {
  MobileScannerController cameraController = MobileScannerController();
  @override
  Widget build(BuildContext context) {
    return Placeholder();
    // return Scaffold(
    //   appBar: AppBar(title: Text('Scan Booking'), actions: [
    //     IconButton(
    //       color: Colors.white,
    //       icon: ValueListenableBuilder(
    //         valueListenable: cameraController.torchState,
    //         builder: (context, state, child) {
    //           switch (state as TorchState) {
    //             case TorchState.off:
    //               return const Icon(Icons.flash_off, color: Colors.grey);
    //             case TorchState.on:
    //               return const Icon(Icons.flash_on, color: Colors.yellow);
    //           }
    //         },
    //       ),
    //       iconSize: 32.0,
    //       onPressed: () => cameraController.toggleTorch(),
    //     ),
    //   ],),
    //   body: MobileScanner(
    //     controller: MobileScannerController(
    //       detectionSpeed: DetectionSpeed.normal,
    //       facing: CameraFacing.back,
    //     ),
    //     onDetect: (data) {
    //       print("Scan data");
    //       print(data);
    //       Navigator.of(context)
    //           .pop(data); // Return scanned data to previous screen
    //     },
    //   ),
    // );
  }
}