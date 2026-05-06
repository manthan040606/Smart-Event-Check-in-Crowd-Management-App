import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../providers/attendance_provider.dart';
import '../providers/event_provider.dart';
import '../theme.dart';
import '../models/event.dart';

class LogsScreen extends ConsumerStatefulWidget {
  const LogsScreen({super.key});

  @override
  ConsumerState<LogsScreen> createState() => _LogsScreenState();
}

class _LogsScreenState extends ConsumerState<LogsScreen> {
  String _searchQuery = "";
  String _filter = "All"; // All, Checked-in, Not Checked-in

  @override
  Widget build(BuildContext context) {
    final participants = ref.watch(attendanceProvider);
    final event = ref.watch(eventProvider);
    
    final filtered = participants.where((p) {
      final query = _searchQuery.toLowerCase();
      final matchesSearch = p.name.toLowerCase().contains(query) || p.id.toLowerCase().contains(query);
      
      bool matchesFilter = true;
      if (_filter == "Checked-in") matchesFilter = p.isCheckedIn;
      if (_filter == "Not Checked-in") matchesFilter = !p.isCheckedIn;
      
      return matchesSearch && matchesFilter;
    }).toList();

    filtered.sort((a, b) => (b.checkInTime ?? DateTime(0)).compareTo(a.checkInTime ?? DateTime(0)));

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Logs / Search", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: AppTheme.primaryPurple,
        actions: [
          IconButton(icon: const Icon(Icons.search, color: Colors.white), onPressed: () {}),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: TextField(
              onChanged: (val) => setState(() => _searchQuery = val),
              decoration: InputDecoration(
                hintText: "Search by ID or Name...",
                prefixIcon: const Icon(Icons.search),
                suffixIcon: const Icon(Icons.tune_rounded),
                filled: true,
                fillColor: Colors.grey.shade50,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                _buildFilterChip("All"),
                const SizedBox(width: 12),
                _buildFilterChip("Checked-in"),
                const SizedBox(width: 12),
                _buildFilterChip("Not Checked-in"),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: filtered.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final p = filtered[index];
                      return _buildParticipantTile(p, index + 101);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label) {
    final isSelected = _filter == label;
    return GestureDetector(
      onTap: () => setState(() => _filter = label),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryPurple : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey.shade600,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildDbStats(Event? event, int participantCount) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.primaryPurple.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.primaryPurple.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.storage_rounded, color: AppTheme.primaryPurple, size: 18),
              const SizedBox(width: 8),
              const Text("DATABASE TRACE (HIVE)", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppTheme.primaryPurple)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStatItem("Active Event", event != null ? "CONFIGURED" : "NONE"),
              _buildStatItem("Records", participantCount.toString()),
              _buildStatItem("Sync Status", "HEALTHY"),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: Colors.grey.shade500, fontSize: 10, fontWeight: FontWeight.bold)),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14)),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(color: Colors.grey.shade100, shape: BoxShape.circle),
            child: Icon(Icons.folder_open_rounded, size: 64, color: Colors.grey.shade400),
          ),
          const SizedBox(height: 24),
          const Text("No entries found", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text("Try adjusting your search criteria.", style: TextStyle(color: Colors.grey.shade600)),
        ],
      ),
    );
  }

  Widget _buildParticipantTile(p, int indexNumber) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade50),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.01), blurRadius: 5)],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: AppTheme.primaryPurple.withOpacity(0.05),
            child: Text(indexNumber.toString(), style: const TextStyle(color: AppTheme.primaryPurple, fontSize: 13, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(p.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                Text("ID: ${p.id}", style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                p.isCheckedIn ? "Checked-in" : "Not Checked-in",
                style: TextStyle(
                  color: p.isCheckedIn ? AppTheme.successGreen : AppTheme.errorRed,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                p.checkInTime != null ? DateFormat('hh:mm a').format(p.checkInTime!) : "-",
                style: TextStyle(color: Colors.grey.shade400, fontSize: 11),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
