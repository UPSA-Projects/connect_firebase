import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import 'guest.dart';

class QRScanPage extends StatefulWidget {
  final String email;
  const QRScanPage({Key? key, required this.email}) : super(key: key);

  @override
  State<QRScanPage> createState() => _QRScanPageState();
}

class _QRScanPageState extends State<QRScanPage> {

  MobileScannerController cameraController = MobileScannerController();

  bool qrCodeReadSuccesfully = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          color: Colors.black,
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back),
        ),
        actions: [
          IconButton(
            color: Colors.black,
            icon: ValueListenableBuilder(
              valueListenable: cameraController.torchState,
              builder: (context, state, child) {
                switch (state) {
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
          IconButton(
            color: Colors.white,
            icon: ValueListenableBuilder(
              valueListenable: cameraController.cameraFacingState,
              builder: (context, state, child) {
                switch (state) {
                  case CameraFacing.front:
                    return const Icon(Icons.camera_front);
                  case CameraFacing.back:
                    return const Icon(Icons.camera_rear);
                }
              },
            ),
            iconSize: 32.0,
            onPressed: () => cameraController.switchCamera(),
          ),
        ],
      ),
      body: qrCodeReadSuccesfully
          ? const Center(
        child: Text(
          'QR aceptado',
          style: TextStyle(
            fontSize: 32.0,
            fontWeight: FontWeight.bold,
          ),
        ),
      )
          : MobileScanner(
        fit: BoxFit.cover,
        controller: cameraController,
        onDetect: (capture) async {
          log('QR Code detected');
          log(capture.barcodes.last.rawValue!);
          if (!mounted) return;
          if (capture.barcodes.last.rawValue! != 'PromoUPSA FAI 2023') {
            setState(() {
              qrCodeReadSuccesfully = true;
            });
            cameraController.stop();
            log('QR Code is valid');
            log('I scanned ${capture.barcodes.last.rawValue!}');
            if (mounted) {
              // context.replace('/group-stage-page');

              // Ir a QR
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PasswordEntryGuest(groupId: capture.barcodes.last.rawValue!, email: widget.email),
                ),
              );

            }
          }
        },
      ),
    );
  }
}