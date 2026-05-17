import 'package:flutter/material.dart';
import 'dart:convert';
import '../services/api_service.dart';

class AlertScreen extends StatefulWidget {
  final String userId; 
  const AlertScreen({super.key, required this.userId});

  @override
  State<AlertScreen> createState() => _AlertScreenState();
}

class _AlertScreenState extends State<AlertScreen> {
 
  final Color skyBlue = const Color(0xFF4A90E2);
  final Color softOrange = const Color(0xFFF59E0B); 
  final Color background = const Color(0xFFF8FAFC);

  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  String? selectedCategory; 
  String? selectedUrgency;  
  bool isSubmitting = false;
  bool _showHistory = false;

  //list of alerts
  final List<String> categories = ['Fire', 'Plumbing', 'Electrical', 'Security', 'Cleaning'];
  final List<String> urgencyLevels = ['Low', 'Medium', 'High', 'Critical'];

  
  Future<void> _submitQuickAlert(String category) async {
    _showSnackBar("Sending Emergency Alert...", Colors.redAccent);
    
    final quickData = {
      "title": "QUICK ALERT: $category", 
      "description": "User reported an urgent $category issue via Quick Action button.",
      "category": category,
      "source": "Mobile Quick Button",
      "reportedBy_id": int.tryParse(widget.userId),
      "urgencyLevel": "Critical", 
    };

    try {
      final response = await ApiService.reportAlert(quickData);
      if (response.statusCode == 201) {
        _showSnackBar("Emergency Report Sent Successfully!", Colors.green);
        if (_showHistory) setState(() {}); 
      } else {
        _showSnackBar("Server Error", Colors.red);
      }
    } catch (e) {
      _showSnackBar("Connection failed", Colors.red);
    }
  }

  
  void _openQuickAlertSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
      builder: (context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 25),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10))),
            const SizedBox(height: 20),
            const Text("QUICK EMERGENCY", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.red)),
            const Text("Tap a category to send alert immediately", style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 25),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: categories.map((cat) => ActionChip(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                backgroundColor: cat == 'Fire' ? Colors.red : Colors.red.shade50,
                label: Text(cat, style: TextStyle(color: cat == 'Fire' ? Colors.white : Colors.red, fontWeight: FontWeight.bold)),
                onPressed: () {
                  Navigator.pop(context);
                  _submitQuickAlert(cat);
                },
              )).toList(),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  // submit alert with formule
  Future<void> _submitReport(StateSetter setModalState) async {
    if (_titleController.text.isEmpty || selectedCategory == null || selectedUrgency == null) {
      _showSnackBar("Please fill all fields", softOrange);
      return;
    }
    setModalState(() => isSubmitting = true);
    final reportData = {
      "title": _titleController.text.trim(),
      "description": _descController.text.trim(),
      "category": selectedCategory,
      "source": "Mobile App",
      "reportedBy_id": int.tryParse(widget.userId),
      "urgencyLevel": selectedUrgency,
    };
    try {
      final response = await ApiService.reportAlert(reportData);
      if (response.statusCode == 201) {
        Navigator.pop(context);
        _showSnackBar("Report submitted successfully!", Colors.green);
        _clearFields();
        if (_showHistory) setState(() {});
      } else {
        setModalState(() => isSubmitting = false);
        _showSnackBar("Server Error", Colors.red);
      }
    } catch (e) {
      setModalState(() => isSubmitting = false);
      _showSnackBar("Connection failed", Colors.red);
    }
  }

  void _clearFields() {
    _titleController.clear();
    _descController.clear();
    setState(() {
      selectedCategory = null;
      selectedUrgency = null;
    });
  }

  void _openReportForm() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(35))),
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom + 25, left: 25, right: 25, top: 15),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(width: 50, height: 5, decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(10))),
              const SizedBox(height: 25),
              Text("Submit an Issue", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: skyBlue)),
              const SizedBox(height: 25),
              _buildInput("Title (e.g. Water Leak)", Icons.edit_note, _titleController),
              const SizedBox(height: 15),
              _buildDropdown("Select Category", Icons.category_outlined, categories, selectedCategory, (v) => setModalState(() => selectedCategory = v)),
              const SizedBox(height: 15),
              _buildDropdown("Urgency level", Icons.bolt, urgencyLevels, selectedUrgency, (v) => setModalState(() => selectedUrgency = v)),
              const SizedBox(height: 15),
              _buildInput("Describe the problem", Icons.description_outlined, _descController, maxLines: 3),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity, height: 55,
                child: ElevatedButton(
                  onPressed: isSubmitting ? null : () => _submitReport(setModalState),
                  style: ElevatedButton.styleFrom(backgroundColor: skyBlue, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
                  child: isSubmitting ? const CircularProgressIndicator(color: Colors.white) : const Text("SUBMIT REPORT", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        title: const Text("Report Issues", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18)),
        backgroundColor: Colors.white, elevation: 0, centerTitle: true,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.black), onPressed: () => Navigator.pop(context)),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeader(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  Row(
                    children: [
                  //submit button
                      Expanded(
                        flex: 3, 
                        child: _buildMainButton("Report Issue", Icons.add_circle_outline, skyBlue, _openReportForm),
                      ),
                      const SizedBox(width: 12),
                   //quiq button
                      Expanded(
                        flex: 2,
                        child: GestureDetector(
                          onTap: _openQuickAlertSheet,
                          child: Container(
                            height: 60,
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            decoration: BoxDecoration(
                              color: Colors.red, 
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [BoxShadow(color: Colors.red.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 5))]
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Icon(Icons.emergency, color: Colors.white, size: 22),
                                SizedBox(width: 5),
                                Text("QUICK\nEMR", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 10, height: 1.1)),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  _buildMainButton(_showHistory ? "Hide My Problems" : "Track status of my Problems", Icons.history, Colors.white, () => setState(() => _showHistory = !_showHistory), isOutlined: true),
                ],
              ),
            ),
            if (_showHistory) _buildHistoryList(),
            if (!_showHistory) _buildEmptyStateIcons(),
          ],
        ),
      ),
    );
  }


  Widget _buildHeader() {
    return Container(
      margin: const EdgeInsets.all(20), padding: const EdgeInsets.all(25), width: double.infinity,
      decoration: BoxDecoration(gradient: LinearGradient(colors: [skyBlue, skyBlue.withOpacity(0.85)]), borderRadius: BorderRadius.circular(30)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: softOrange.withOpacity(0.2), shape: BoxShape.circle), child: Icon(Icons.engineering, color: softOrange, size: 30)),
          const SizedBox(height: 20),
          const Text("Hello, Resident!", style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
          const Text("Do you have any problem? Submit your report to fix.", style: TextStyle(color: Colors.white70, fontSize: 15, height: 1.4)),
        ],
      ),
    );
  }

  Widget _buildHistoryList() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: FutureBuilder(
        future: ApiService.getAlertHistory(widget.userId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
          if (snapshot.hasError || snapshot.data?.statusCode != 200) return const Text("No problems found or connection error");
          final alerts = json.decode(snapshot.data!.body)['data'] ?? [];
          if (alerts.isEmpty) return const Text("You haven't reported any issues yet.");
          return ListView.builder(
            shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
            itemCount: alerts.length,
            itemBuilder: (context, index) {
              final alert = alerts[index];
              Color statusColor = (alert['status'] == 'completed' || alert['status'] == 'approved') ? Colors.green : Colors.orange;
              return Container(
                margin: const EdgeInsets.only(bottom: 12), padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10)]),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(alert['title'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      Text("${alert['category']} • ${alert['timeStamp']?.toString().split('T')[0] ?? ''}", style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                    ])),
                    Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5), decoration: BoxDecoration(color: statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(10)), child: Text(alert['status'].toString().toUpperCase(), style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.bold))),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildEmptyStateIcons() {
    return const Padding(padding: EdgeInsets.only(top: 60), child: Opacity(opacity: 0.1, child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.build_outlined, size: 80), SizedBox(width: 30), Icon(Icons.security_outlined, size: 80)])));
  }

  Widget _buildMainButton(String text, IconData icon, Color color, VoidCallback onTap, {bool isOutlined = false}) {
    return SizedBox(width: double.infinity, height: 60, child: ElevatedButton.icon(onPressed: onTap, icon: Icon(icon, color: isOutlined ? skyBlue : Colors.white), label: Text(text, style: TextStyle(color: isOutlined ? skyBlue : Colors.white, fontWeight: FontWeight.bold)), style: ElevatedButton.styleFrom(backgroundColor: color, elevation: isOutlined ? 0 : 4, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: isOutlined ? BorderSide(color: skyBlue, width: 2) : BorderSide.none))));
  }

  Widget _buildInput(String hint, IconData icon, TextEditingController ctrl, {int maxLines = 1}) {
    return TextField(controller: ctrl, maxLines: maxLines, decoration: InputDecoration(hintText: hint, prefixIcon: Icon(icon, color: skyBlue), filled: true, fillColor: Colors.grey[50], border: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: BorderSide.none)));
  }

  Widget _buildDropdown(String hint, IconData icon, List<String> items, String? val, Function(String?) onChange) {
    return Container(padding: const EdgeInsets.symmetric(horizontal: 12), decoration: BoxDecoration(color: Colors.grey[50], borderRadius: BorderRadius.circular(18)), child: DropdownButtonFormField<String>(value: val, hint: Text(hint), decoration: InputDecoration(prefixIcon: Icon(icon, color: skyBlue), border: InputBorder.none), items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(), onChanged: onChange));
  }

  void _showSnackBar(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: color, behavior: SnackBarBehavior.floating));
  }
}