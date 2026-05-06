import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../providers/attendance_provider.dart';
import '../models/participant.dart';
import '../theme.dart';

class LogsScreen extends ConsumerStatefulWidget {
  const LogsScreen({super.key});

  @override
  ConsumerState<LogsScreen> createState() => _LogsScreenState();
}

class _LogsScreenState extends ConsumerState<LogsScreen> {
  String _searchQuery = "";
  String _filter = "All";

  @override
  Widget build(BuildContext context) {
    final participants = ref.watch(attendanceProvider);
    final filtered = participants.where((p) {
      final matchesSearch = p.name.toLowerCase().contains(_searchQuery.toLowerCase()) || p.id.toLowerCase().contains(_searchQuery.toLowerCase());
      if (_filter == "Checked-in") return matchesSearch && p.isCheckedIn;
      if (_filter == "Not Checked-in") return matchesSearch && !p.isCheckedIn;
      return matchesSearch;
    }).toList();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Logs / Search", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF0066CC), // Blue from reference
        centerTitle: false,
        elevation: 0,
        leading: const Icon(Icons.menu, color: Colors.white),
        actions: const [
          Icon(Icons.search, color: Colors.white),
          SizedBox(width: 16),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(20),
            child: TextField(
              onChanged: (val) => setState(() => _searchQuery = val),
              decoration: InputDecoration(
                hintText: "Search by ID or Name...",
                prefixIcon: const Icon(Icons.search, size: 20),
                suffixIcon: const Icon(Icons.tune, size: 20),
                filled: true,
                fillColor: Colors.grey.shade50,
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ),
          ),
          
          // Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: ["All", "Checked-in", "Not Checked-in"].map((f) => Padding(
                padding: const EdgeInsets.only(right: 12),
                child: FilterChip(
                  label: Text(f, style: TextStyle(color: _filter == f ? Colors.white : Colors.grey, fontSize: 12)),
                  selected: _filter == f,
                  onSelected: (val) => setState(() => _filter = f),
                  backgroundColor: Colors.grey.shade50,
                  selectedColor: const Color(0xFF0066CC),
                  checkmarkColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8), side: BorderSide.none),
                ),
              )).toList(),
            ),
          ),
          const SizedBox(height: 16),
          
          // Logs List
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: filtered.length,
              separatorBuilder: (context, index) => const Divider(height: 1, color: Color(0xFFEEEEEE)),
              itemBuilder: (context, index) {
                final p = filtered[index];
                return _buildParticipantItem(p, index + 101); // Simulated index start
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildParticipantItem(Participant p, int displayIndex) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        children: [
          // Circular Avatar with Index
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppTheme.primaryPurple.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              displayIndex.toString(),
              style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryPurple, fontSize: 13),
            ),
          ),
          const SizedBox(width: 16),
          
          // Participant Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(p.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                const SizedBox(height: 4),
                Text("ID: ${p.id}", style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
              ],
            ),
          ),
          
          // Status Label
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                p.isCheckedIn ? "Checked-in" : "Not Checked-in",
                style: TextStyle(
                  color: p.isCheckedIn ? Colors.green : Colors.red,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
              if (p.isCheckedIn) ...[
                const SizedBox(height: 4),
                Text(
                  DateFormat('HH:mm a').format(p.checkInTime!),
                  style: TextStyle(color: Colors.grey.shade500, fontSize: 11),
                ),
                Text(
                  DateFormat('dd MMM yyyy').format(p.checkInTime!),
                  style: TextStyle(color: Colors.grey.shade500, fontSize: 10),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
