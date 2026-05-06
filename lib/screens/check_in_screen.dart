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

class _CheckInScreenState extends ConsumerState<CheckInScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _manualIdController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  void _handleCheckIn(String id, String name) async {
    HapticFeedback.mediumImpact();
    final error = await ref.read(attendanceProvider.notifier).checkIn(id, name);
    if (!mounted) return;

    if (error == null) {
      _showSuccessDialog(name);
      _manualIdController.clear();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error), backgroundColor: Colors.red));
    }
  }

  void _showSuccessDialog(String name) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle, color: Color(0xFF00A389), size: 60),
            const SizedBox(height: 16),
            const Text("Check-in Success", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 8),
            Text("$name is checked in."),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00A389)),
              child: const Text("OK", style: TextStyle(color: Colors.white)),
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
        title: const Text("Check-in", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF00A389), // Emerald Teal from reference
        centerTitle: true,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white), onPressed: () => Navigator.pop(context)),
      ),
      body: Column(
        children: [
          Container(
            color: Colors.white,
            child: TabBar(
              controller: _tabController,
              labelColor: const Color(0xFF00A389),
              unselectedLabelColor: Colors.grey,
              indicatorColor: const Color(0xFF00A389),
              indicatorWeight: 3,
              tabs: const [
                Tab(text: "QR Scanner"),
                Tab(text: "Manual Entry"),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildScannerTab(),
                _buildManualTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScannerTab() {
    return Column(
      children: [
        const SizedBox(height: 40),
        Container(
          height: 300,
          width: 300,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: Colors.grey.shade100, width: 2),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(28),
            child: Stack(
              children: [
                MobileScanner(
                  onDetect: (capture) {
                    final List<Barcode> barcodes = capture.barcodes;
                    if (barcodes.isNotEmpty && barcodes.first.rawValue != null) {
                      _handleCheckIn(barcodes.first.rawValue!, "Attendee");
                    }
                  },
                ),
                _buildOverlay(),
              ],
            ),
          ),
        ),
        const SizedBox(height: 32),
        const Text("Align QR code within the frame\nto scan", textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)),
        const Spacer(),
        const Text("OR", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
        const Spacer(),
        _buildManualInputSection(),
        const SizedBox(height: 40),
      ],
    );
  }

  Widget _buildManualTab() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Enter Participant ID", style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          _buildManualInputSection(),
        ],
      ),
    );
  }

  Widget _buildManualInputSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
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
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => _handleCheckIn(_manualIdController.text, "Attendee"),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00A389),
              minimumSize: const Size(double.infinity, 56),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text("Check-in", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(color: Colors.green.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
            child: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.green, size: 20),
                const SizedBox(width: 12),
                Text("Ready to scan", style: TextStyle(color: Colors.green.shade800, fontWeight: FontWeight.bold, fontSize: 13)),
                const Spacer(),
                Text("Scan QR or enter ID", style: TextStyle(color: Colors.green.shade600, fontSize: 11)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverlay() {
    return Container(
      decoration: ShapeDecoration(
        shape: QrScannerOverlayShape(
          borderColor: const Color(0xFF00A389),
          borderRadius: 20,
          borderLength: 40,
          borderWidth: 8,
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

    final backgroundPaint = Paint()..color = Colors.black.withOpacity(0.5)..style = PaintingStyle.fill;
    canvas.drawPath(
      Path.combine(
        PathOperation.difference,
        Path()..addRect(rect),
        Path()..addRRect(RRect.fromRectAndRadius(Rect.fromLTWH(left, top, boxWidth, boxHeight), Radius.circular(borderRadius))),
      ),
      backgroundPaint,
    );

    final borderPaint = Paint()..color = borderColor..style = PaintingStyle.stroke..strokeWidth = borderWidth..strokeCap = StrokeCap.round;
    
    // Draw corners
    canvas.drawPath(Path()..moveTo(left, top + borderLength)..lineTo(left, top + borderRadius)..arcToPoint(Offset(left + borderRadius, top), radius: Radius.circular(borderRadius))..lineTo(left + borderLength, top), borderPaint);
    canvas.drawPath(Path()..moveTo(left + boxWidth - borderLength, top)..lineTo(left + boxWidth - borderRadius, top)..arcToPoint(Offset(left + boxWidth, top + borderRadius), radius: Radius.circular(borderRadius), clockwise: true)..lineTo(left + boxWidth, top + borderLength), borderPaint);
    canvas.drawPath(Path()..moveTo(left, top + boxHeight - borderLength)..lineTo(left, top + boxHeight - borderRadius)..arcToPoint(Offset(left + borderRadius, top + boxHeight), radius: Radius.circular(borderRadius), clockwise: false)..lineTo(left + borderLength, top + boxHeight), borderPaint);
    canvas.drawPath(Path()..moveTo(left + boxWidth - borderLength, top + boxHeight)..lineTo(left + boxWidth - borderRadius, top + boxHeight)..arcToPoint(Offset(left + boxWidth, top + boxHeight - borderRadius), radius: Radius.circular(borderRadius), clockwise: false)..lineTo(left + boxWidth, top + boxHeight - borderLength), borderPaint);
  }

  @override
  ShapeBorder scale(double t) => this;
}
