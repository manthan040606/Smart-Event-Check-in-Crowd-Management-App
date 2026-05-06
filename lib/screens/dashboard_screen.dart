import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../providers/event_provider.dart';
import '../providers/attendance_provider.dart';
import '../providers/user_role_provider.dart';
import '../theme.dart';
import '../models/event.dart';
import 'event_setup_screen.dart';
import 'check_in_screen.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final event = ref.watch(eventProvider);
    final participants = ref.watch(attendanceProvider);
    final role = ref.watch(userRoleProvider);
    final isHost = role == UserRole.host;

    final checkedIn = participants.where((p) => p.isCheckedIn).length;
    final int totalCapacity = (event?.maxCapacity ?? 0) > 0 ? event!.maxCapacity : 1;
    final remaining = totalCapacity - checkedIn;
    final percentage = (checkedIn / totalCapacity) * 100;

    String crowdLevel = "SAFE";
    Color levelColor = Colors.green;
    if (percentage > 90) {
      crowdLevel = "DANGER";
      levelColor = Colors.red;
    } else if (percentage > 70) {
      crowdLevel = "WARNING";
      levelColor = Colors.orange;
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Dashboard", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF1A1F71), // Dark Navy from reference
        elevation: 0,
        leading: const Icon(Icons.menu, color: Colors.white),
        actions: const [
          Icon(Icons.notifications_none_rounded, color: Colors.white),
          SizedBox(width: 16),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Top Event Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF1A1F71),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                   Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                    child: const Icon(Icons.calendar_today, color: Colors.white, size: 20),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(event?.name ?? "Event Name", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                      const SizedBox(height: 4),
                      Text(
                        "${event?.dateTime != null ? DateFormat('dd MMM yyyy').format(event!.dateTime) : 'TBD'}  •  10:00 AM",
                        style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 13),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            
            // 2x2 Stats Grid
            Row(
              children: [
                Expanded(child: _buildStatItem("Total Capacity", totalCapacity.toString(), Icons.people_outline, Colors.blue)),
                const SizedBox(width: 16),
                Expanded(child: _buildStatItem("Checked-in", checkedIn.toString(), Icons.check_circle_outline, Colors.green)),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: _buildStatItem("Remaining Capacity", remaining.toString(), Icons.person_remove_outlined, Colors.orange)),
                const SizedBox(width: 16),
                Expanded(child: _buildStatItem("Check-in Rate", "${percentage.toStringAsFixed(0)}%", Icons.auto_graph_rounded, Colors.purple)),
              ],
            ),
            const SizedBox(height: 24),
            
            // Crowd Status Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
              ),
              child: Column(
                children: [
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text("Crowd Status", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  ),
                  const SizedBox(height: 20),
                  _buildGauge(percentage, crowdLevel, levelColor),
                  const SizedBox(height: 8),
                  Text("${percentage.toStringAsFixed(0)}% of capacity used", style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
                ],
              ),
            ),
            const SizedBox(height: 24),
            
            // Bottom Action Buttons
            Row(
              children: [
                Expanded(
                  child: _buildBigBtn(
                    "Check-in", 
                    Icons.qr_code_scanner, 
                    const Color(0xFF4A4EED),
                    () => ref.read(navigationProvider.notifier).state = 1
                  )
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildBigBtn(
                    "View Logs", 
                    Icons.list_alt, 
                    const Color(0xFFC4EED0),
                    () => ref.read(navigationProvider.notifier).state = 2,
                    textColor: Colors.green.shade800
                  )
                ),
              ],
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
              Icon(icon, color: color.withOpacity(0.5), size: 18),
            ],
          ),
          const SizedBox(height: 12),
          Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }

  Widget _buildGauge(double percentage, String level, Color color) {
    return Stack(
      alignment: Alignment.center,
      children: [
        SizedBox(
          height: 140,
          width: 240,
          child: PieChart(
            PieChartData(
              startDegreeOffset: 180,
              sectionsSpace: 0,
              centerSpaceRadius: 80,
              sections: [
                PieChartSectionData(value: percentage, color: color, radius: 15, showTitle: false),
                PieChartSectionData(value: 100 - percentage, color: Colors.grey.shade100, radius: 15, showTitle: false),
                PieChartSectionData(value: 100, color: Colors.transparent, radius: 15, showTitle: false), // Bottom half
              ],
            ),
          ),
        ),
        Column(
          children: [
            const SizedBox(height: 20),
            Text(level, style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: color)),
          ],
        ),
      ],
    );
  }

  Widget _buildBigBtn(String label, IconData icon, Color color, VoidCallback onTap, {Color? textColor}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 110,
        decoration: BoxDecoration(color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(20)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: textColor ?? color, size: 28),
            const SizedBox(height: 8),
            Text(label, style: TextStyle(color: textColor ?? color, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
