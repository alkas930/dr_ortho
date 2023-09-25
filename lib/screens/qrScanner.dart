// ignore_for_file: file_names

import 'dart:developer';
import 'dart:io';
import 'package:drortho/constants/colorconstants.dart';
import 'package:drortho/providers/homeProvider.dart';
import 'package:drortho/utilities/loadingWrapper.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

import '../routes.dart';

class QrScanner extends StatefulWidget {
  const QrScanner({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _QrScannerState();
}

class _QrScannerState extends State<QrScanner> {
  bool isLoading = false;
  QRViewController? controller;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');

  // In order to get hot reload to work we need to pause the camera if the platform
  // is android, or resume the camera if the platform is iOS.
  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      controller!.pauseCamera();
    }
    controller!.resumeCamera();
  }

  @override
  Widget build(BuildContext context) {
    return LoadingWrapper(
      child: Scaffold(
        body: Column(
          children: [
            Expanded(
              child: Consumer<HomeProvider>(
                builder: (_, homeProvider, __) {
                  return _buildQrView(context, homeProvider);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQrView(BuildContext context, HomeProvider homeProvider) {
    // For this example we check how width or tall the device is and change the scanArea and overlay accordingly.
    var scanArea = (MediaQuery.of(context).size.width < 400 ||
            MediaQuery.of(context).size.height < 400)
        ? 300.0
        : 300.0;
    // To ensure the Scanner view is properly sizes after rotation
    // we need to listen for Flutter SizeChanged notification and update controller
    return QRView(
      key: qrKey,
      onQRViewCreated: (QRViewController controller) {
        _onQRViewCreated(controller, homeProvider);
      },
      overlay: QrScannerOverlayShape(
          overlayColor: const Color.fromRGBO(0, 0, 0, 0.75),
          borderColor: themeRed,
          borderRadius: 16,
          borderLength: 25,
          borderWidth: 8,
          cutOutSize: scanArea),
      onPermissionSet: (ctrl, p) => _onPermissionSet(context, ctrl, p),
    );
  }

  void _onQRViewCreated(
      QRViewController controller, HomeProvider homeProvider) {
    setState(() {
      this.controller = controller;
    });
    controller.scannedDataStream.listen((scanData) {
      List<String>? slug = scanData.code?.split("/");
      if (slug != null && slug.isNotEmpty) {
        if (slug[slug.length - 1].trim().isNotEmpty) {
          getProduct(controller, slug[slug.length - 1], homeProvider);
        } else {
          getProduct(controller, slug[slug.length - 2], homeProvider);
        }
      }
    });
  }

  void _onPermissionSet(BuildContext context, QRViewController ctrl, bool p) {
    log('${DateTime.now().toIso8601String()}_onPermissionSet $p');
    if (!p) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('no Permission')),
      );
    }
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  getProduct(
      QRViewController controller, String slug, HomeProvider homeProvider) {
    controller.pauseCamera();
    homeProvider.getProductDetailsFromSlug(slug);
    homeProvider.getUser();
    Navigator.popAndPushNamed(context, productDetailsRoute);
  }
}
