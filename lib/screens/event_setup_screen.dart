import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../providers/event_provider.dart';
import '../models/event.dart';
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
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Event Setup", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: AppTheme.primaryPurple,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white), onPressed: () => Navigator.pop(context)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Create New Event", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, letterSpacing: -0.5)),
            const SizedBox(height: 8),
            Text("Fill in the details to create a new event.", style: TextStyle(color: Colors.grey.shade500, fontSize: 13)),
            const SizedBox(height: 32),
            
            _buildInputLabel("Event Name"),
            _buildTextField(_nameController, "Annual Tech Fest 2025", Icons.person_outline),
            
            const SizedBox(height: 20),
            _buildInputLabel("Date"),
            _buildDatePicker(),
            
            const SizedBox(height: 20),
            _buildInputLabel("Time"),
            _buildTimePicker(),
            
            const SizedBox(height: 20),
            _buildInputLabel("Maximum Capacity"),
            _buildTextField(_capacityController, "500", Icons.people_outline, isNumber: true),
            
            const SizedBox(height: 20),
            _buildInputLabel("Description (Optional)"),
            _buildTextField(_descriptionController, "Briefly describe the event...", null, maxLines: 3),
            
            const SizedBox(height: 40),
            ElevatedButton.icon(
              onPressed: _submit,
              icon: const Icon(Icons.event_available_rounded, color: Colors.white),
              label: const Text("Create Event", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryPurple,
                minimumSize: const Size(double.infinity, 60),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 4,
                shadowColor: AppTheme.primaryPurple.withOpacity(0.3),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.black)),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint, IconData? icon, {bool isNumber = false, int maxLines = 1}) {
    return TextField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      maxLines: maxLines,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
        prefixIcon: icon != null ? Icon(icon, size: 20, color: Colors.grey) : null,
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade200)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppTheme.primaryPurple, width: 2)),
      ),
    );
  }

  Widget _buildDatePicker() {
    return InkWell(
      onTap: () async {
        final date = await showDatePicker(context: context, initialDate: DateTime.now(), firstDate: DateTime.now(), lastDate: DateTime.now().add(const Duration(days: 365)));
        if (date != null) setState(() => _selectedDate = date);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_month_outlined, size: 20, color: Colors.grey),
            const SizedBox(width: 12),
            Text(
              _selectedDate != null ? DateFormat('dd MMM yyyy').format(_selectedDate!) : "Select Date",
              style: TextStyle(color: _selectedDate != null ? Colors.black : Colors.grey.shade400, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimePicker() {
    return InkWell(
      onTap: () async {
        final time = await showTimePicker(context: context, initialTime: TimeOfDay.now());
        if (time != null) setState(() => _selectedTime = time);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          children: [
            const Icon(Icons.access_time, size: 20, color: Colors.grey),
            const SizedBox(width: 12),
            Text(
              _selectedTime != null ? _selectedTime!.format(context) : "10:00 AM",
              style: TextStyle(color: _selectedTime != null ? Colors.black : Colors.grey.shade400, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  void _submit() async {
    if (_nameController.text.isEmpty || _capacityController.text.isEmpty) return;
    
    final event = Event(
      name: _nameController.text,
      maxCapacity: int.parse(_capacityController.text),
      dateTime: _selectedDate ?? DateTime.now(),
      location: "Main Hall",
      description: _descriptionController.text,
    );

    await ref.read(eventProvider.notifier).setEvent(event);
  }
}
