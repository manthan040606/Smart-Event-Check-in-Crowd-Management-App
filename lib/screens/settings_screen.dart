import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/user_role_provider.dart';
import '../providers/event_provider.dart';
import '../models/event.dart';
import '../theme.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final role = ref.watch(userRoleProvider);
    final isHost = role == UserRole.host;

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            backgroundColor: const Color(0xFF1A1F71),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF1A1F71), Color(0xFF4A4EED)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 40),
                    const CircleAvatar(
                      radius: 40,
                      backgroundColor: Colors.white24,
                      child: Icon(Icons.person, color: Colors.white, size: 40),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      isHost ? "Host Admin" : "Event Participant",
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                    Text(
                      isHost ? "System Configuration Active" : "Attendee Mode Enabled",
                      style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 13),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionLabel("Core Actions"),
                  _buildSettingItem(
                    Icons.settings_outlined, 
                    "Event Settings", 
                    "Update event name and capacity",
                    onTap: () => _showEventSettings(context, ref)
                  ),
                  _buildSettingItem(
                    Icons.swap_horizontal_circle_outlined, 
                    "Role Preferences", 
                    "Switch between Host & Attendee",
                    onTap: () => _showRoleSwitcher(context, ref)
                  ),
                  _buildSettingItem(
                    Icons.delete_sweep_outlined, 
                    "Reset Session", 
                    "Clear current event data entirely",
                    color: Colors.orange,
                    onTap: () => _showResetConfirmation(context, ref)
                  ),
                  
                  const SizedBox(height: 24),
                  _buildSectionLabel("App Info"),
                   _buildSettingItem(
                    Icons.verified_user_outlined, 
                    "Security Status", 
                    "Device is encrypted and secured",
                    onTap: () => _showInfo(context, "Security", "Your session is secured with local-only storage. No data leaves your device.")
                  ),
                   _buildSettingItem(
                    Icons.info_outline_rounded, 
                    "About QRifyME", 
                    "Version 1.2.0 - Advanced Build",
                    onTap: () => _showInfo(context, "About QRifyME", "Developed for premium event management with high-speed QR synchronization.")
                  ),
                  
                  const SizedBox(height: 32),
                  ElevatedButton.icon(
                    onPressed: () => ref.read(userRoleProvider.notifier).logout(),
                    icon: const Icon(Icons.logout_rounded, color: Colors.white),
                    label: const Text("Logout Session", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.shade600,
                      minimumSize: const Size(double.infinity, 56),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 0,
                    ),
                  ),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showEventSettings(BuildContext context, WidgetRef ref) {
    final event = ref.read(eventProvider);
    if (event == null) return;
    
    final nameCtrl = TextEditingController(text: event.name);
    final capCtrl = TextEditingController(text: event.maxCapacity.toString());

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
      builder: (context) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 24, right: 24, top: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Quick Event Edit", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
            const SizedBox(height: 4),
            Text("Updating details for ${event.name}", style: TextStyle(color: Colors.grey.shade500, fontSize: 13)),
            const SizedBox(height: 24),
            _buildSheetField("Event Name", nameCtrl, Icons.edit_note_outlined),
            const SizedBox(height: 16),
            _buildSheetField("Max Capacity", capCtrl, Icons.people_outline, isNum: true),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () async {
                final newEvent = Event(
                  name: nameCtrl.text,
                  maxCapacity: int.tryParse(capCtrl.text) ?? event.maxCapacity,
                  dateTime: event.dateTime,
                  location: event.location,
                  description: event.description,
                  instructions: event.instructions,
                );
                await ref.read(eventProvider.notifier).setEvent(newEvent);
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Event updated successfully"), backgroundColor: Colors.green));
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1A1F71), 
                minimumSize: const Size(double.infinity, 56),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text("Save Changes", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildSheetField(String label, TextEditingController ctrl, IconData icon, {bool isNum = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
        const SizedBox(height: 8),
        TextField(
          controller: ctrl,
          keyboardType: isNum ? TextInputType.number : TextInputType.text,
          decoration: InputDecoration(
            prefixIcon: Icon(icon, size: 20),
            filled: true,
            fillColor: Colors.grey.shade50,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade200)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade200)),
          ),
        ),
      ],
    );
  }

  void _showRoleSwitcher(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Switch Role"),
        content: const Text("Switching roles will reset your current navigation. Continue?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () {
              final currentRole = ref.read(userRoleProvider);
              ref.read(userRoleProvider.notifier).setRole(currentRole == UserRole.host ? UserRole.attendee : UserRole.host);
              Navigator.pop(context);
            }, 
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1A1F71)),
            child: const Text("Switch Now", style: TextStyle(color: Colors.white))
          ),
        ],
      ),
    );
  }

  void _showResetConfirmation(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Clear All Data?"),
        content: const Text("This will permanently delete the current event and all participant logs."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () {
              ref.read(eventProvider.notifier).clearEvent();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Data successfully cleared."), backgroundColor: Colors.orange));
            }, 
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            child: const Text("Yes, Reset", style: TextStyle(color: Colors.white))
          ),
        ],
      ),
    );
  }

  void _showInfo(BuildContext context, String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Close")),
        ],
      ),
    );
  }

  Widget _buildSectionLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 12),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(color: Colors.grey.shade500, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.2),
      ),
    );
  }

  Widget _buildSettingItem(IconData icon, String title, String subtitle, {VoidCallback? onTap, Color? color}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: (color ?? const Color(0xFF1A1F71)).withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, color: color ?? const Color(0xFF1A1F71), size: 20),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
        subtitle: Text(subtitle, style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
        trailing: const Icon(Icons.chevron_right_rounded, color: Colors.grey, size: 20),
      ),
    );
  }
}
