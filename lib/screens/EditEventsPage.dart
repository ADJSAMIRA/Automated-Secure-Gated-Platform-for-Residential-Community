import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/api_service.dart';

class EditEventsPage extends StatefulWidget {
  final VoidCallback onBack; 

  const EditEventsPage({super.key, required this.onBack});

  @override
  State<EditEventsPage> createState() => _EditEventsPageState();
}

class _EditEventsPageState extends State<EditEventsPage> {
  List adminEvents = [];
  bool isLoading = true;

  final Color primaryBlue = const Color(0xFF1B2559);
  final Color scaffoldBg = const Color(0xFFF8F9FD);

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    if (!mounted) return;
    setState(() => isLoading = true);
    try {
      final data = await ApiService.getAdminOnlyEvents();
      if (mounted) {
        setState(() {
          adminEvents = data;
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container( 
      color: scaffoldBg,
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
                const Text("| My Events Management", 
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF1B2559))),
              ],
            ),
          ),
          Expanded(
            child: isLoading
                ? Center(child: CircularProgressIndicator(color: primaryBlue))
                : adminEvents.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
                        itemCount: adminEvents.length,
                        itemBuilder: (context, index) => _buildModernEditCard(adminEvents[index]),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernEditCard(dynamic event) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 15, offset: const Offset(0, 8))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildBadge("Admin Event", Colors.blue),
              InkWell(
                onTap: () => _openEditForm(event),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: const [
                      Icon(Icons.edit, color: Colors.orange, size: 16),
                      SizedBox(width: 5),
                      Text("Edit", style: TextStyle(color: Colors.orange, fontSize: 12, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            event['title'] ?? "Untitled",
            style: const TextStyle(fontSize: 19, fontWeight: FontWeight.bold, color: Color(0xFF1B2559)),
          ),
          const SizedBox(height: 8),
          Text(
            event['description'] ?? "No description.",
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(color: const Color(0xFFF4F7FE), borderRadius: BorderRadius.circular(15)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _infoTile(Icons.calendar_month, "Date", event['eventDate']?.split('T')[0] ?? "N/A"),
                _infoTile(Icons.access_time, "Start", event['time'] ?? "N/A"),
                _infoTile(Icons.history, "End", event['endTime'] ?? "N/A"),
              ],
            ),
          ),
        ],
      ),
    );
  }

 
  void _openEditForm(dynamic event) {
    final titleCtrl = TextEditingController(text: event['title']);
    final descCtrl = TextEditingController(text: event['description']); // استرجاع الوصف
    final startCtrl = TextEditingController(text: event['time'] ?? "08:00");
    final endCtrl = TextEditingController(text: event['endTime'] ?? "10:00");
    DateTime sDate = DateTime.tryParse(event['eventDate'] ?? "") ?? DateTime.now();

    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        child: StatefulBuilder(
          builder: (context, setModalState) => Container(
            padding: const EdgeInsets.all(20),
            constraints: const BoxConstraints(maxWidth: 450),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Edit Event Details", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: primaryBlue)),
                      IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close, size: 20)),
                    ],
                  ),
                  const Divider(),
                  const SizedBox(height: 15),

                  _label("Event Title"),
                  _inputField(titleCtrl, Icons.title_rounded, "Title"),

                  const SizedBox(height: 15),
                  _label("Description"), 
                  _inputField(descCtrl, Icons.description_outlined, "Enter description...", maxLines: 3),

                  const SizedBox(height: 15),
                  Row(
                    children: [
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [_label("Start Time"), _inputField(startCtrl, Icons.access_time, "08:00")])),
                      const SizedBox(width: 10),
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [_label("End Time"), _inputField(endCtrl, Icons.history, "10:00")])),
                    ],
                  ),

                  const SizedBox(height: 15),
                  _label("Event Date"),
                  InkWell(
                    onTap: () async {
                      DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate: sDate,
                        firstDate: DateTime.now(),
                        lastDate: DateTime(2030),
                      );
                      if (picked != null) setModalState(() => sDate = picked);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
                      decoration: BoxDecoration(color: const Color(0xFFF4F7FE), borderRadius: BorderRadius.circular(12)),
                      child: Row(children: [Icon(Icons.calendar_today, color: primaryBlue, size: 18), const SizedBox(width: 10), Text(DateFormat('yyyy-MM-dd').format(sDate), style: const TextStyle(fontWeight: FontWeight.bold))]),
                    ),
                  ),

                  const SizedBox(height: 25),
                  _actionButton(
                    label: "Update Changes",
                    icon: Icons.done_all_rounded,
                    color: primaryBlue,
                    onTap: () async {
                      final body = {
                        "title": titleCtrl.text,
                        "description": descCtrl.text,
                        "eventDate": DateFormat('yyyy-MM-dd').format(sDate),
                        "time": startCtrl.text,   
                        "endTime": endCtrl.text,   
                      };
                      final res = await ApiService.updateAdminEvent(event['id_Event'].toString(), body);
                      if (res.statusCode == 200) {
                        if (context.mounted) Navigator.pop(context);
                        _fetchData();
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _label(String text) => Padding(padding: const EdgeInsets.only(bottom: 6, left: 4), child: Text(text, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF1B2559))));

  Widget _inputField(TextEditingController ctrl, IconData icon, String hint, {int maxLines = 1}) {
    return TextField(
      controller: ctrl,
      maxLines: maxLines,
      style: const TextStyle(fontSize: 14),
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: primaryBlue.withOpacity(0.5), size: 18),
        filled: true,
        fillColor: const Color(0xFFF4F7FE),
        hintText: hint,
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: primaryBlue)),
      ),
    );
  }

  Widget _actionButton({required String label, required IconData icon, required Color color, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(12)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [Icon(icon, color: Colors.white, size: 18), const SizedBox(width: 8), Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))],
        ),
      ),
    );
  }

  Widget _infoTile(IconData icon, String label, String value) {
    return Column(
      children: [
        Icon(icon, size: 16, color: const Color(0xFF1B2559)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
      child: Text(text, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildEmptyState() => const Center(child: Text("No events found"));
}