import 'package:flutter/material.dart';
import '../services/api_service.dart';

class CreateEventPage extends StatefulWidget {
  final VoidCallback onBack; 

  const CreateEventPage({super.key, required this.onBack});

  @override
  _CreateEventPageState createState() => _CreateEventPageState();
}

class _CreateEventPageState extends State<CreateEventPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController titleCtrl = TextEditingController();
  final TextEditingController descCtrl = TextEditingController();
  final TextEditingController dateCtrl = TextEditingController();
  final TextEditingController startTimeCtrl = TextEditingController();
  final TextEditingController endTimeCtrl = TextEditingController();

  final String fixedLocation = "Hall Event";
  final Color primaryBlue = const Color(0xFF1A237E);
  final Color accentColor = const Color(0xFF448AFF);

  Future<void> _selectDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: ColorScheme.light(primary: primaryBlue),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() {
        dateCtrl.text = picked.toString().split(' ')[0];
      });
    }
  }

  Future<void> _selectTime(TextEditingController controller) async {
    TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        final hour = picked.hour.toString().padLeft(2, '0');
        final minute = picked.minute.toString().padLeft(2, '0');
        controller.text = "$hour:$minute";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF8F9FD),
      child: Column(
        children: [
         
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios, size: 20, color: Color(0xFF1B2559)),
                  onPressed: widget.onBack,
                ),
                const Text("| Create New Event", 
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF1B2559))),
              ],
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                   
                    _buildTopInfoCard(),
                    const SizedBox(height: 30),

                    _buildSectionTitle("General Information"),
                    const SizedBox(height: 15),
                    _buildLabel("Event Title"),
                    TextFormField(
                      controller: titleCtrl,
                      decoration: _inputStyle("Enter event name...", Icons.title_rounded),
                      validator: (v) => v!.isEmpty ? "Required" : null,
                    ),

                    const SizedBox(height: 20),
                    _buildLabel("Description"),
                    TextFormField(
                      controller: descCtrl,
                      maxLines: 3,
                      decoration: _inputStyle("Describe the event details...", Icons.notes_rounded),
                      validator: (v) => v!.isEmpty ? "Required" : null,
                    ),

                    const SizedBox(height: 30),
                    _buildSectionTitle("Schedule Details"),
                    const SizedBox(height: 15),
                    _buildLabel("Date"),
                    TextFormField(
                      controller: dateCtrl,
                      readOnly: true,
                      onTap: _selectDate,
                      decoration: _inputStyle("Select event date", Icons.calendar_today_rounded),
                      validator: (v) => v!.isEmpty ? "Required" : null,
                    ),

                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildLabel("Start Time"),
                              TextFormField(
                                controller: startTimeCtrl,
                                readOnly: true,
                                onTap: () => _selectTime(startTimeCtrl),
                                decoration: _inputStyle("00:00", Icons.access_time_rounded),
                                validator: (v) => v!.isEmpty ? "Required" : null,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildLabel("End Time"),
                              TextFormField(
                                controller: endTimeCtrl,
                                readOnly: true,
                                onTap: () => _selectTime(endTimeCtrl),
                                decoration: _inputStyle("00:00", Icons.timer_off_rounded),
                                validator: (v) => v!.isEmpty ? "Required" : null,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 45),
                    _buildPublishButton(),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopInfoCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [primaryBlue, accentColor], begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(25),
        boxShadow: [BoxShadow(color: primaryBlue.withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 6))],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(15)),
            child: const Icon(Icons.location_on_rounded, color: Colors.white, size: 30),
          ),
          const SizedBox(width: 15),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Fixed Location", style: TextStyle(color: Colors.white70, fontSize: 13)),
              Text(fixedLocation, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1B2559)));
  }

  Widget _buildLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(label, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: Colors.grey.shade700)),
    );
  }

  InputDecoration _inputStyle(String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
      prefixIcon: Icon(icon, color: primaryBlue, size: 20),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: BorderSide(color: Colors.grey.shade200)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: BorderSide(color: primaryBlue, width: 1.5)),
      errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: const BorderSide(color: Colors.redAccent)),
      focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: const BorderSide(color: Colors.redAccent)),
    );
  }

  Widget _buildPublishButton() {
    return InkWell(
      onTap: _submitEvent,
      child: Container(
        width: double.infinity,
        height: 60,
        decoration: BoxDecoration(
          color: primaryBlue,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: primaryBlue.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 5))],
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.rocket_launch_rounded, color: Colors.white, size: 22),
            const SizedBox(width: 12),
            Text("Publish Event", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  void _submitEvent() async {
    if (_formKey.currentState!.validate()) {
      Map<String, dynamic> eventData = {
        "title": titleCtrl.text,
        "description": descCtrl.text,
        "eventDate": dateCtrl.text,
        "time": startTimeCtrl.text,
        "endTime": endTimeCtrl.text,
        "location": fixedLocation,
        "organizer_id": 14,
        "status": "Approved",
      };

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Creating event..."), behavior: SnackBarBehavior.floating),
      );

      bool success = await ApiService.createAdminEvent(eventData);

      if (success) {
        widget.onBack();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Event Published Successfully!"), backgroundColor: Colors.green, behavior: SnackBarBehavior.floating),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Submission Failed."), backgroundColor: Colors.red, behavior: SnackBarBehavior.floating),
        );
      }
    }
  }
}