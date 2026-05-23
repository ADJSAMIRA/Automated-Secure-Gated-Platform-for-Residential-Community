import 'package:flutter/material.dart';
import '../services/api_service.dart';

class AlertsScreen extends StatefulWidget {
  final VoidCallback onBack;

  const AlertsScreen({super.key, required this.onBack});

  @override
  State<AlertsScreen> createState() => _AlertsScreenState();
}

class _AlertsScreenState extends State<AlertsScreen> {
  List alerts = [];
  bool isLoading = true;
  final Color primaryBlue = const Color(0xFF1B2559);
  final Color scaffoldBg = const Color(0xFFF8F9FD);

  @override
  void initState() {
    super.initState();
    _fetchAlerts();
  }

  Future<void> _fetchAlerts() async {
    setState(() => isLoading = true);
    try {
      final data = await ApiService.getAllAlerts();
      final now = DateTime.now();
      
     //alert pass 48H delete
      final filteredData = data.where((alert) {
        if (alert['status']?.toString().toLowerCase() == 'completed') {
          DateTime? updatedAt = DateTime.tryParse(alert['updatedAt'] ?? "");
          if (updatedAt != null) {
            return now.difference(updatedAt).inHours <= 48;
          }
        }
        return true;
      }).toList();

      setState(() {
        alerts = filteredData;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: scaffoldBg,
      body: Column(
        children: [
         
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 40, 20, 10),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios, size: 20, color: Color(0xFF1B2559)),
                  onPressed: widget.onBack,
                ),
                Text("| Task Management", 
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: primaryBlue)),
              ],
            ),
          ),

          Expanded(
            child: isLoading
                ? Center(child: CircularProgressIndicator(color: primaryBlue))
                : alerts.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        itemCount: alerts.length,
                        itemBuilder: (context, index) => _buildModernAlertCard(alerts[index]),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernAlertCard(dynamic alert) {
    String status = alert['status']?.toString() ?? 'pending';
    String urgency = alert['urgencyLevel']?.toString() ?? 'Low';
    String category = alert['category']?.toString() ?? 'general';
    Color urgencyColor = _getUrgencyColor(urgency);

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
              Row(
                children: [
                  Icon(_getCategoryIcon(category), color: primaryBlue, size: 22),
                  const SizedBox(width: 10),
                  Text(alert['title'] ?? "Untitled", 
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: primaryBlue)),
                ],
              ),
              _buildBadge(status, Colors.blue.withOpacity(0.1), Colors.blue),
            ],
          ),
          const SizedBox(height: 12),
          Text(alert['description'] ?? "No description.", 
              style: TextStyle(color: Colors.grey.shade600, fontSize: 14, height: 1.4)),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.location_on_rounded, size: 16, color: Colors.grey.shade400),
                  const SizedBox(width: 5),
                  Text(alert['source'] ?? "General", style: TextStyle(color: Colors.grey.shade500, fontSize: 13)),
                ],
              ),
              Row(
                children: [
                  Icon(Icons.error_outline_rounded, size: 16, color: urgencyColor),
                  const SizedBox(width: 5),
                  _buildBadge(urgency, urgencyColor.withOpacity(0.1), urgencyColor),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _actionButton(
                  label: "Assign Staff",
                  icon: Icons.person_add_alt_1_rounded,
                  color: primaryBlue,
                  onTap: () => _showAssignDialog(alert),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _actionButton(
                  label: "Status",
                  icon: Icons.sync_problem_rounded,
                  color: Colors.orange,
                  onTap: () => _showStatusDialog(alert),
                  isOutlined: true,
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _actionButton({required String label, required IconData icon, required Color color, required VoidCallback onTap, bool isOutlined = false}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isOutlined ? Colors.white : color,
          borderRadius: BorderRadius.circular(15),
          border: isOutlined ? Border.all(color: color) : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: isOutlined ? color : Colors.white, size: 18),
            const SizedBox(width: 8),
            Text(label, style: TextStyle(color: isOutlined ? color : Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
          ],
        ),
      ),
    );
  }

  void _showAssignDialog(dynamic alert) async {
    showDialog(context: context, builder: (context) => const Center(child: CircularProgressIndicator()));
    List staffList = await ApiService.getStaffList();
    if (!mounted) return;
    Navigator.pop(context);

    int? selectedStaffId;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        insetPadding: const EdgeInsets.symmetric(horizontal: 50), // تصغير الـ Dialog
        title: Text("Assign Professional", style: TextStyle(fontWeight: FontWeight.bold, color: primaryBlue)),
        content: StatefulBuilder(
          builder: (context, setModalState) => SizedBox(
            width: 300, 
            child: DropdownButtonFormField<int>(
              isExpanded: true,
              hint: const Text("Select staff member", style: TextStyle(fontSize: 13)),
              decoration: InputDecoration(
                filled: true,
                fillColor: const Color(0xFFF4F7FE),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
              items: staffList.map((staff) {
                String job = (staff['job_type'] ?? staff['role'] ?? "Staff").toString();
                return DropdownMenuItem<int>(
                  value: staff['id_user'],
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(staff['fullName'] ?? "Name", style: const TextStyle(fontSize: 13)),
                      _buildBadge(job, _getJobColor(job).withOpacity(0.1), _getJobColor(job)),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (val) => setModalState(() => selectedStaffId = val),
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: primaryBlue, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
            onPressed: () async {
              if (selectedStaffId != null) {
                await ApiService.assignTaskToStaff(alert['id_Alert'], selectedStaffId!);
                Navigator.pop(context);
                _fetchAlerts();
              }
            },
            child: const Text("Confirm", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showStatusDialog(dynamic alert) {
    String selectedStatus = alert['status']?.toString() ?? 'pending';
    final List<String> statuses = ['pending', 'in progress', 'completed', 'canceled'];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Update Status"),
        content: DropdownButtonFormField<String>(
          value: statuses.contains(selectedStatus) ? selectedStatus : 'pending',
          decoration: InputDecoration(filled: true, fillColor: const Color(0xFFF4F7FE), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none)),
          items: statuses.map((s) => DropdownMenuItem(value: s, child: Text(s.toUpperCase()))).toList(),
          onChanged: (val) => selectedStatus = val!,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: primaryBlue, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
            onPressed: () async {
              await ApiService.updateAlertStatus(alert['id_Alert'], selectedStatus);
              Navigator.pop(context);
              _fetchAlerts();
            },
            child: const Text("Update", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  
  Widget _buildBadge(String text, Color bg, Color textCol) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(8)),
      child: Text(text.toUpperCase(), style: TextStyle(color: textCol, fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }

  Color _getUrgencyColor(String level) {
    String l = level.toLowerCase();
    if (l == 'critical' || l == 'high') return const Color(0xFFE63946); 
    if (l == 'medium') return Colors.orange;
    return const Color(0xFF2A9D8F); 
  }

  Color _getJobColor(String job) {
    String j = job.toLowerCase();
    if (j.contains('secu')) return Colors.blue.shade700;
    if (j.contains('plum') || j.contains('main')) return Colors.cyan.shade700;
    if (j.contains('elec')) return Colors.orange.shade700;
    return Colors.grey.shade600;
  }

  IconData _getCategoryIcon(String category) {
    String c = category.toLowerCase();
    if (c.contains('fire')) return Icons.local_fire_department_rounded;
    if (c.contains('security')) return Icons.shield_rounded;
    if (c.contains('plumb')) return Icons.water_drop_rounded;
    if (c.contains('elec')) return Icons.bolt_rounded;
    return Icons.notifications_active_rounded;
  }

  Widget _buildEmptyState() => const Center(child: Text("No pending alerts found", style: TextStyle(color: Colors.grey)));
}