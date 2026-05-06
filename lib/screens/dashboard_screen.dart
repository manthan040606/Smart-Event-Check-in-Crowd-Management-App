import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/event_provider.dart';
import '../providers/attendance_provider.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final event = ref.watch(eventProvider);
    final participants = ref.watch(attendanceProvider);
    
    final checkedIn = participants.where((p) => p.isCheckedIn).length;
    final remaining = (event?.maxCapacity ?? 0) - checkedIn;
    final percentage = (event?.maxCapacity ?? 0) > 0 
        ? (checkedIn / event!.maxCapacity) * 100 
        : 0.0;

    String crowdLevel = "Safe";
    Color levelColor = Colors.green;
    if (percentage > 90) {
      crowdLevel = "Full";
      levelColor = Colors.red;
    } else if (percentage > 60) {
      crowdLevel = "Moderate";
      levelColor = Colors.orange;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Dashboard", style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildEventCard(event),
            const SizedBox(height: 20),
            _buildStatGrid(checkedIn, remaining, event?.maxCapacity ?? 0),
            const SizedBox(height: 30),
            _buildCrowdIndicator(crowdLevel, levelColor, percentage),
            const SizedBox(height: 30),
            SizedBox(
              height: 200,
              child: PieChart(
                PieChartData(
                  sections: [
                    PieChartSectionData(
                      value: checkedIn.toDouble(),
                      color: Theme.of(context).colorScheme.primary,
                      title: 'Checked-in',
                      radius: 50,
                      titleStyle: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    PieChartSectionData(
                      value: remaining.toDouble() < 0 ? 0 : remaining.toDouble(),
                      color: Colors.grey.shade200,
                      title: 'Remaining',
                      radius: 40,
                      titleStyle: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEventCard(event) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.indigo.shade400, Colors.indigo.shade700],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.indigo.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            event?.name ?? "No Event",
            style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 5),
          Text(
            event?.dateTime.toString().split(' ')[0] ?? "",
            style: TextStyle(color: Colors.white.withOpacity(0.8)),
          ),
        ],
      ),
    );
  }

  Widget _buildStatGrid(int checkedIn, int remaining, int total) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 15,
      mainAxisSpacing: 15,
      childAspectRatio: 1.5,
      children: [
        _buildStatCard("Checked-in", checkedIn.toString(), Icons.check_circle_outline, Colors.blue),
        _buildStatCard("Remaining", remaining.toString(), Icons.hourglass_empty, Colors.orange),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color),
          const SizedBox(height: 5),
          Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildCrowdIndicator(String level, Color color, double percentage) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Crowd Level", style: TextStyle(color: color, fontWeight: FontWeight.bold)),
              Text(level, style: TextStyle(color: color, fontSize: 24, fontWeight: FontWeight.bold)),
            ],
          ),
          Text("${percentage.toStringAsFixed(1)}%", style: TextStyle(color: color, fontSize: 24, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
