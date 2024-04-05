import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class ScanBooking extends StatefulWidget {
  static const String pageName = '/scan_booking';

  const ScanBooking({Key? key}) : super(key: key);

  @override
  _ScanBookingState createState() => _ScanBookingState();
}

class _ScanBookingState extends State<ScanBooking> with WidgetsBindingObserver {
  late MobileScannerController cameraController;
  bool barcodeDetected = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    cameraController = MobileScannerController();
    initCameraController();
  }

  Future<void> initCameraController() async {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    super.dispose();
    WidgetsBinding.instance.removeObserver(this);
    cameraController.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (cameraController == null) {
      return;
    }
    if (state == AppLifecycleState.inactive) {
      cameraController.dispose();
    } else if (state == AppLifecycleState.resumed) {
      if (cameraController != null) {
        initCameraController();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Scan Booking'),
        actions: [
          IconButton(
            color: Colors.white,
            icon: ValueListenableBuilder(
              valueListenable: cameraController.torchState,
              builder: (context, state, child) {
                switch (state as TorchState) {
                  case TorchState.off:
                    return const Icon(Icons.flash_off, color: Colors.grey);
                  case TorchState.on:
                    return const Icon(Icons.flash_on, color: Colors.yellow);
                }
              },
            ),
            iconSize: 32.0,
            onPressed: () => cameraController.toggleTorch(),
          ),
        ],
      ),
      body: MobileScanner(
        controller: cameraController,
        onDetect: (capture) async {
          final List<Barcode> barcodes = capture.barcodes;
          final Uint8List? image = capture.image;
          try {
            if (!barcodeDetected) {
              barcodeDetected = true;
              debugPrint('Barcode found! ${barcodes[0].rawValue}');
              Navigator.of(context).pop(barcodes[0].rawValue);
            }
          } catch (e) {
            debugPrint('Error popping: $e');
          }
        },
      ),
    );
  }
}
