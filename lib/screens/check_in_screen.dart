import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../providers/attendance_provider.dart';

class CheckInScreen extends ConsumerStatefulWidget {
  const CheckInScreen({super.key});

  @override
  ConsumerState<CheckInScreen> createState() => _CheckInScreenState();
}

class _CheckInScreenState extends ConsumerState<CheckInScreen> {
  final _manualIdController = TextEditingController();
  final _manualNameController = TextEditingController();
  bool _isScanning = true;

  void _handleCheckIn(String id, String name) async {
    final error = await ref.read(attendanceProvider.notifier).checkIn(id, name);
    if (!mounted) return;

    if (error == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Successfully checked in: $name"),
          backgroundColor: Colors.green,
        ),
      );
      _manualIdController.clear();
      _manualNameController.clear();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Check-in", style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: Icon(_isScanning ? Icons.keyboard : Icons.qr_code_scanner),
            onPressed: () => setState(() => _isScanning = !_isScanning),
          )
        ],
      ),
      body: _isScanning ? _buildScanner() : _buildManualEntry(),
    );
  }

  Widget _buildScanner() {
    return Stack(
      children: [
        MobileScanner(
          onDetect: (capture) {
            final List<Barcode> barcodes = capture.barcodes;
            for (final barcode in barcodes) {
              if (barcode.rawValue != null) {
                // For simulation/demo purposes, we'll use the QR code raw value as ID and "Guest" as name
                _handleCheckIn(barcode.rawValue!, "QR User");
                // Stop scanning briefly to prevent multiple scans
                setState(() => _isScanning = false);
                Future.delayed(const Duration(seconds: 2), () {
                  if (mounted) setState(() => _isScanning = true);
                });
                break;
              }
            }
          },
        ),
        _buildOverlay(),
      ],
    );
  }

  Widget _buildOverlay() {
    return Container(
      decoration: ShapeDecoration(
        shape: QrScannerOverlayShape(
          borderColor: Theme.of(context).colorScheme.primary,
          borderRadius: 20,
          borderLength: 30,
          borderWidth: 10,
          cutOutSize: 250,
        ),
      ),
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: 260),
            Text(
              "Center the QR code within the frame",
              style: TextStyle(color: Colors.white, backgroundColor: Colors.black45),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildManualEntry() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            "Manual Validation",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _manualIdController,
            decoration: const InputDecoration(
              labelText: "Participant ID",
              prefixIcon: Icon(Icons.badge),
            ),
          ),
          const SizedBox(height: 15),
          TextField(
            controller: _manualNameController,
            decoration: const InputDecoration(
              labelText: "Participant Name",
              prefixIcon: Icon(Icons.person),
            ),
          ),
          const SizedBox(height: 30),
          ElevatedButton(
            onPressed: () {
              if (_manualIdController.text.isNotEmpty && _manualNameController.text.isNotEmpty) {
                _handleCheckIn(_manualIdController.text, _manualNameController.text);
              }
            },
            child: const Text("Validate Entry"),
          ),
        ],
      ),
    );
  }
}

// Simple overlay shape for QR scanner (copied pattern)
class QrScannerOverlayShape extends ShapeBorder {
  final Color borderColor;
  final double borderWidth;
  final double borderLength;
  final double borderRadius;
  final double cutOutSize;

  const QrScannerOverlayShape({
    this.borderColor = Colors.white,
    this.borderWidth = 1.0,
    this.borderLength = 20.0,
    this.borderRadius = 0.0,
    this.cutOutSize = 250.0,
  });

  @override
  EdgeInsetsGeometry get dimensions => EdgeInsets.zero;

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) => Path();

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
    return Path()..addRect(rect);
  }

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {
    final width = rect.width;
    final height = rect.height;
    final boxWidth = cutOutSize;
    final boxHeight = cutOutSize;
    final left = (width - boxWidth) / 2;
    final top = (height - boxHeight) / 2;

    final backgroundPaint = Paint()
      ..color = Colors.black54
      ..style = PaintingStyle.fill;

    canvas.drawPath(
      Path.combine(
        PathOperation.difference,
        Path()..addRect(rect),
        Path()..addRRect(RRect.fromRectAndRadius(
            Rect.fromLTWH(left, top, boxWidth, boxHeight),
            Radius.circular(borderRadius))),
      ),
      backgroundPaint,
    );

    final borderPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth;

    // Draw corners
    // Top Left
    canvas.drawPath(
      Path()
        ..moveTo(left, top + borderLength)
        ..lineTo(left, top + borderRadius)
        ..arcToPoint(Radius.circular(borderRadius))
        ..lineTo(left + borderLength, top),
      borderPaint,
    );
    // Top Right
    canvas.drawPath(
      Path()
        ..moveTo(left + boxWidth - borderLength, top)
        ..lineTo(left + boxWidth - borderRadius, top)
        ..arcToPoint(Radius.circular(borderRadius))
        ..lineTo(left + boxWidth, top + borderLength),
      borderPaint,
    );
    // Bottom Left
    canvas.drawPath(
      Path()
        ..moveTo(left, top + boxHeight - borderLength)
        ..lineTo(left, top + boxHeight - borderRadius)
        ..arcToPoint(Radius.circular(borderRadius))
        ..lineTo(left + borderLength, top + boxHeight),
      borderPaint,
    );
    // Bottom Right
    canvas.drawPath(
      Path()
        ..moveTo(left + boxWidth - borderLength, top + boxHeight)
        ..lineTo(left + boxWidth - borderRadius, top + boxHeight)
        ..arcToPoint(Radius.circular(borderRadius))
        ..lineTo(left + boxWidth, top + boxHeight - borderLength),
      borderPaint,
    );
  }

  @override
  ShapeBorder scale(double t) {
    return QrScannerOverlayShape(
      borderColor: borderColor,
      borderWidth: borderWidth,
      borderLength: borderLength,
      borderRadius: borderRadius,
      cutOutSize: cutOutSize,
    );
  }
}
