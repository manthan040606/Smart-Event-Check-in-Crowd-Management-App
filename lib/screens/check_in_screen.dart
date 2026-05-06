import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../providers/attendance_provider.dart';
import '../theme.dart';

class CheckInScreen extends ConsumerStatefulWidget {
  const CheckInScreen({super.key});

  @override
  ConsumerState<CheckInScreen> createState() => _CheckInScreenState();
}

class _CheckInScreenState extends ConsumerState<CheckInScreen> {
  final _manualIdController = TextEditingController();
  final _manualNameController = TextEditingController();
  final _manualEmailController = TextEditingController();
  bool _isScanning = true;

  void _handleCheckIn(String id, String name, {String? email}) async {
    final error = await ref.read(attendanceProvider.notifier).checkIn(id, name, email: email);
    if (!mounted) return;

    if (error == null) {
      HapticFeedback.heavyImpact();
      _showSuccessDialog(name);
      _manualIdController.clear();
      _manualNameController.clear();
      _manualEmailController.clear();
    } else {
      HapticFeedback.vibrate();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error),
          backgroundColor: AppTheme.errorRed,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _showSuccessDialog(String name) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle_rounded, color: AppTheme.successGreen, size: 60),
            const SizedBox(height: 16),
            const Text("Check-in Success", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
            const SizedBox(height: 8),
            Text("$name is now registered.", textAlign: TextAlign.center),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Done"),
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Check-in", style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF00A389), // Teal from reference
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              height: 350,
              margin: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: Colors.grey.shade100, width: 2),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(28),
                child: _buildScanner(),
              ),
            ),
            const Text(
              "Align QR code within the frame\nto scan",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, fontSize: 13),
            ),
            const SizedBox(height: 16),
            const Row(
              children: [
                Expanded(child: Divider(indent: 40, endIndent: 20)),
                Text("OR", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
                Expanded(child: Divider(indent: 20, endIndent: 40)),
              ],
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text("Enter Participant ID", style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _manualIdController,
                    decoration: InputDecoration(
                      hintText: "Enter Participant ID",
                      prefixIcon: const Icon(Icons.person_outline),
                      filled: true,
                      fillColor: Colors.grey.shade50,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      if (_manualIdController.text.isNotEmpty) {
                        _handleCheckIn(_manualIdController.text, "Manual User");
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00A389),
                      minimumSize: const Size(double.infinity, 56),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text("Check-in", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
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
                _handleCheckIn(barcode.rawValue!, "Scan User");
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
      decoration: const ShapeDecoration(
        shape: QrScannerOverlayShape(
          borderColor: Color(0xFF00A389),
          borderRadius: 30,
          borderLength: 40,
          borderWidth: 10,
          cutOutSize: 220,
        ),
      ),
    );
  }
}

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
      ..color = Colors.black87.withOpacity(0.7)
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
      ..strokeWidth = borderWidth
      ..strokeCap = StrokeCap.round;

    // Draw corners
    canvas.drawPath(
      Path()
        ..moveTo(left, top + borderLength)
        ..lineTo(left, top + borderRadius)
        ..arcToPoint(Offset(left + borderRadius, top), radius: Radius.circular(borderRadius))
        ..lineTo(left + borderLength, top),
      borderPaint,
    );
    canvas.drawPath(
      Path()
        ..moveTo(left + boxWidth - borderLength, top)
        ..lineTo(left + boxWidth - borderRadius, top)
        ..arcToPoint(Offset(left + boxWidth, top + borderRadius), radius: Radius.circular(borderRadius), clockwise: true)
        ..lineTo(left + boxWidth, top + borderLength),
      borderPaint,
    );
    canvas.drawPath(
      Path()
        ..moveTo(left, top + boxHeight - borderLength)
        ..lineTo(left, top + boxHeight - borderRadius)
        ..arcToPoint(Offset(left + borderRadius, top + boxHeight), radius: Radius.circular(borderRadius), clockwise: false)
        ..lineTo(left + borderLength, top + boxHeight),
      borderPaint,
    );
    canvas.drawPath(
      Path()
        ..moveTo(left + boxWidth - borderLength, top + boxHeight)
        ..lineTo(left + boxWidth - borderRadius, top + boxHeight)
        ..arcToPoint(Offset(left + boxWidth, top + boxHeight - borderRadius), radius: Radius.circular(borderRadius), clockwise: false)
        ..lineTo(left + boxWidth, top + boxHeight - borderLength),
      borderPaint,
    );
  }

  @override
  ShapeBorder scale(double t) => this;
}
