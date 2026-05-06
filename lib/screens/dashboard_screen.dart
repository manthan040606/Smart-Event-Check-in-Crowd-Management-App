import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'dart:ui';
import '../providers/event_provider.dart';
import '../providers/attendance_provider.dart';
import '../providers/navigation_provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../providers/user_role_provider.dart';
import '../theme.dart';
import '../models/event.dart';
import 'event_setup_screen.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final event = ref.watch(eventProvider);
    final role = ref.watch(userRoleProvider);
    final isHost = role == UserRole.host;

    if (!isHost) {
      return _buildAttendeeDashboard(context, ref, event);
    }

    return _buildHostDashboard(context, ref, event);
  }

  Widget _buildHostDashboard(BuildContext context, WidgetRef ref, Event? event) {
    final participants = ref.watch(attendanceProvider);
    final checkedIn = participants.where((p) => p.isCheckedIn).length;
    final totalCapacity = event?.maxCapacity ?? 1;
    final remaining = totalCapacity - checkedIn;
    final percentage = (checkedIn / totalCapacity) * 100;

    String crowdLevel = "Safe";
    Color levelColor = AppTheme.successGreen;
    if (percentage > 90) {
      crowdLevel = "Full";
      levelColor = AppTheme.errorRed;
    } else if (percentage > 60) {
      crowdLevel = "Moderate";
      levelColor = AppTheme.warningOrange;
    }

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(ref, event, true),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  if (event == null) ...[
                    _buildEmptyEventState(context, true),
                  ] else ...[
                    _buildStatGrid(checkedIn, remaining, totalCapacity, percentage),
                    const SizedBox(height: 24),
                    _buildCrowdStatusGauge(percentage, crowdLevel, levelColor),
                    const SizedBox(height: 24),
                    _buildShortcuts(ref),
                  ],
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAttendeeDashboard(BuildContext context, WidgetRef ref, Event? event) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(ref, event, false),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  if (event == null) ...[
                    _buildEmptyEventState(context, false),
                  ] else ...[
                    _buildAttendeePass(context, ref, event),
                    const SizedBox(height: 32),
                    _buildEventInfoCard(event),
                  ],
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar(WidgetRef ref, Event? event, bool isHost) {
    return SliverAppBar(
      expandedHeight: 180,
      pinned: true,
      backgroundColor: AppTheme.primaryPurple,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          padding: const EdgeInsets.fromLTRB(20, 80, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                event?.name ?? "Event Hub",
                style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.calendar_today_rounded, color: Colors.white70, size: 16),
                  const SizedBox(width: 8),
                  Text(
                    event?.dateTime != null ? DateFormat('dd MMM yyyy').format(event!.dateTime) : "TBD",
                    style: const TextStyle(color: Colors.white70),
                  ),
                  const SizedBox(width: 16),
                  const Icon(Icons.location_on_rounded, color: Colors.white70, size: 16),
                  const SizedBox(width: 8),
                  Text(event?.location ?? "Virtual", style: const TextStyle(color: Colors.white70)),
                ],
              ),
            ],
          ),
        ),
      ),
      actions: [
        if (isHost) IconButton(
          icon: const Icon(Icons.delete_sweep_rounded, color: AppTheme.warningOrange),
          onPressed: () => ref.read(eventProvider.notifier).clearEvent(),
        ),
        IconButton(icon: const Icon(Icons.logout_rounded, color: Colors.white70), onPressed: () => ref.read(userRoleProvider.notifier).logout()),
      ],
    );
  }

  Widget _buildAttendeePass(BuildContext context, WidgetRef ref, Event event) {
    return FutureBuilder(
      future: Hive.openBox('settings'),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const CircularProgressIndicator();
        final userId = snapshot.data!.get('current_user_id', defaultValue: 'GUEST');
        
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(32),
            boxShadow: [BoxShadow(color: AppTheme.primaryPurple.withOpacity(0.1), blurRadius: 40, offset: const Offset(0, 20))],
            border: Border.all(color: AppTheme.primaryPurple.withOpacity(0.05)),
          ),
          child: Column(
            children: [
              const Text("Your Entry Pass", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, letterSpacing: -0.5)),
              const SizedBox(height: 8),
              Text("Show this QR to the event host", style: TextStyle(color: Colors.grey.shade500, fontSize: 13)),
              const SizedBox(height: 32),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.grey.shade100),
                ),
                child: QrImageView(
                  data: userId,
                  version: QrVersions.auto,
                  size: 200,
                  foregroundColor: AppTheme.primaryPurple,
                ),
              ),
              const SizedBox(height: 24),
              Text(userId, style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryPurple, letterSpacing: 2)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEventInfoCard(Event event) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.primaryPurple.withOpacity(0.05),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.info_outline_rounded, color: AppTheme.primaryPurple),
              SizedBox(width: 12),
              Text("About Event", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            event.description ?? "No description provided for this event.",
            style: TextStyle(color: Colors.grey.shade700, height: 1.5),
          ),
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 16),
          _buildInfoRow(Icons.access_time_rounded, "Time", "10:00 AM - 04:00 PM"),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.grey),
        const SizedBox(width: 12),
        Text("$label: ", style: const TextStyle(color: Colors.grey)),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
      ],
    );
  }

  // ... (Keeping Host methods _buildStatGrid, _buildSimpleStatCard, _buildCrowdStatusGauge, _buildShortcuts, _buildShortcutBtn, _buildEmptyEventState from previous version)
  Widget _buildStatGrid(int checkedIn, int remaining, int total, double rate) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _buildSimpleStatCard("Total Capacity", total.toString(), Icons.people_outline, Colors.blue)),
            const SizedBox(width: 16),
            Expanded(child: _buildSimpleStatCard("Checked-in", checkedIn.toString(), Icons.check_circle_outline, Colors.green)),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: _buildSimpleStatCard("Remaining", remaining.toString(), Icons.person_off_outlined, Colors.orange)),
            const SizedBox(width: 16),
            Expanded(child: _buildSimpleStatCard("Check-in Rate", "${rate.toStringAsFixed(0)}%", Icons.pie_chart_outline, Colors.purple)),
          ],
        ),
      ],
    );
  }

  Widget _buildSimpleStatCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: TextStyle(color: Colors.grey.shade600, fontSize: 13, fontWeight: FontWeight.w500)),
              Icon(icon, color: color.withOpacity(0.5), size: 18),
            ],
          ),
          const SizedBox(height: 12),
          Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }

  Widget _buildCrowdStatusGauge(double percentage, String level, Color color) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)],
      ),
      child: Column(
        children: [
          const Align(
            alignment: Alignment.centerLeft,
            child: Text("Crowd Status", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ),
          const SizedBox(height: 30),
          SizedBox(
            height: 120,
            child: PieChart(
              PieChartData(
                startDegreeOffset: 180,
                sectionsSpace: 0,
                centerSpaceRadius: 70,
                sections: [
                  PieChartSectionData(value: percentage, color: color, radius: 20, title: ''),
                  PieChartSectionData(value: 100 - percentage, color: Colors.grey.shade100, radius: 20, title: ''),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(level.toUpperCase(), style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: color)),
          Text("${percentage.toStringAsFixed(0)}% of capacity used", style: TextStyle(color: Colors.grey.shade500, fontSize: 13)),
        ],
      ),
    );
  }

  Widget _buildShortcuts(WidgetRef ref) {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () => ref.read(navigationProvider.notifier).state = 1,
            child: _buildShortcutBtn("Check-in", Icons.qr_code_scanner, AppTheme.primaryPurple),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: GestureDetector(
            onTap: () => ref.read(navigationProvider.notifier).state = 2,
            child: _buildShortcutBtn("View Logs", Icons.list_alt_rounded, Colors.green),
          ),
        ),
      ],
    );
  }

  Widget _buildShortcutBtn(String label, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 12),
          Text(label, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildEmptyEventState(BuildContext context, bool isHost) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(40),
      margin: const EdgeInsets.only(top: 40),
      decoration: BoxDecoration(
        color: AppTheme.primaryPurple.withOpacity(0.05),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Column(
        children: [
          Icon(Icons.event_busy_rounded, size: 80, color: AppTheme.primaryPurple.withOpacity(0.3)),
          const SizedBox(height: 24),
          const Text("No Active Event", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.primaryPurple)),
          const SizedBox(height: 12),
          Text(
            isHost 
              ? "You haven't setup an event yet. Please click the button below to start."
              : "Wait for the host to initialize the event.",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
          ),
          if (isHost) ...[
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const EventSetupScreen())
                );
              },
              style: ElevatedButton.styleFrom(
                 backgroundColor: AppTheme.primaryPurple,
                 shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                 padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              ),
              child: const Text("INITIALIZE NOW", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        ],
      ),
    );
  }
}
