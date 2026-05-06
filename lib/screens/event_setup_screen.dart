import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../models/event.dart';
import '../providers/event_provider.dart';
import '../theme.dart';

class EventSetupScreen extends ConsumerStatefulWidget {
  const EventSetupScreen({super.key});

  @override
  ConsumerState<EventSetupScreen> createState() => _EventSetupScreenState();
}

class _EventSetupScreenState extends ConsumerState<EventSetupScreen> {
  final _nameController = TextEditingController();
  final _capacityController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _instructionsController = TextEditingController();
  final _locationController = TextEditingController();
  DateTime _selectedDate = DateTime.now();

  @override
  void dispose() {
    _nameController.dispose();
    _capacityController.dispose();
    _descriptionController.dispose();
    _instructionsController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Event Setup", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: AppTheme.primaryPurple,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Create New Event", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: -0.5)),
            const SizedBox(height: 8),
            const Text("Fill in the details to create a new event.", style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 32),
            _buildInputLabel("Event Name"),
            _buildField(_nameController, "Annual Tech Fest 2025", Icons.person_outline),
            const SizedBox(height: 20),
            _buildInputLabel("Date"),
            _buildField(TextEditingController(text: DateFormat('dd MMM yyyy').format(_selectedDate)), "25 May 2025", Icons.calendar_today_outlined, onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: _selectedDate,
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                );
                if (date != null) setState(() => _selectedDate = date);
            }),
            const SizedBox(height: 20),
            _buildInputLabel("Time"),
            _buildField(_instructionsController, "10:00 AM", Icons.access_time),
            const SizedBox(height: 20),
            _buildInputLabel("Maximum Capacity"),
            _buildField(_capacityController, "500", Icons.people_outline, isNumeric: true),
            const SizedBox(height: 20),
            _buildInputLabel("Description (Optional)"),
            _buildField(_descriptionController, "Event description...", null, maxLines: 4),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () {
                final event = Event(
                  name: _nameController.text,
                  dateTime: _selectedDate,
                  maxCapacity: int.tryParse(_capacityController.text) ?? 100,
                  description: _descriptionController.text,
                  instructions: _instructionsController.text,
                  location: _locationController.text.isEmpty ? "Main Hall" : _locationController.text,
                );
                ref.read(eventProvider.notifier).setEvent(event);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryPurple,
                minimumSize: const Size(double.infinity, 56),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.edit_note_rounded, color: Colors.white),
                  SizedBox(width: 8),
                  Text("Create Event", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildInputLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF4A5568))),
    );
  }

  Widget _buildField(TextEditingController controller, String hint, IconData? icon, {bool isNumeric = false, VoidCallback? onTap, int maxLines = 1}) {
    return TextField(
      controller: controller,
      readOnly: onTap != null,
      onTap: onTap,
      maxLines: maxLines,
      keyboardType: isNumeric ? TextInputType.number : TextInputType.text,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: icon != null ? Icon(icon, size: 20) : null,
        filled: true,
        fillColor: Colors.white,
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade300)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppTheme.primaryPurple, width: 2)),
      ),
    );
  }
}
