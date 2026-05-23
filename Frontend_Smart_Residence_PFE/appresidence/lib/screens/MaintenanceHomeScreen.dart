import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:qr_flutter/qr_flutter.dart'; 
import '../services/api_service.dart';

class MaintenanceHomeScreen extends StatefulWidget {
  final int staffId; 

  const MaintenanceHomeScreen({super.key, required this.staffId});

  @override
  State<MaintenanceHomeScreen> createState() => _MaintenanceHomeScreenState();
}

class _MaintenanceHomeScreenState extends State<MaintenanceHomeScreen> {
  int _currentIndex = 0;
  bool _isLoading = false;
  
  String _staffName = "";
  String _staffStatus = "Active";
  String _jobType = "";

  List<dynamic> _myTasks = [];
  int _pendingCount = 0;
  int _completedCount = 0;

  @override
  void initState() {
    super.initState();
    _fetchMaintenanceData(); 
  }

  
  Future<void> _fetchMaintenanceData() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    
    try {
   
      final Map<String, dynamic>? profileData = await ApiService.getMaintenanceProfile(widget.staffId);
      print("🔵 Profile Data Received in Screen: $profileData");

      if (profileData != null) {
        if (mounted) {
          setState(() {
           
            _staffName = profileData['fullName']?.toString() ?? "Maintenance Member";
            _staffStatus = profileData['status']?.toString() ?? "Active";
            _jobType = profileData['job_type']?.toString() ?? "Maintenance";
          });
        }
      }

    
      final dynamic tasksResponse = await ApiService.getMaintenanceTasks(widget.staffId);
      print("🔵 Tasks Response Raw: $tasksResponse"); 

      if (tasksResponse != null) {
        List<dynamic> tasksData = [];
        
        if (tasksResponse is String) {
          try {
            final decoded = jsonDecode(tasksResponse);
            if (decoded is List) {
              tasksData = decoded;
            } else if (decoded is Map && decoded['data'] is List) {
              tasksData = decoded['data'];
            }
          } catch (_) {}
        } else if (tasksResponse is List) {
          tasksData = tasksResponse;
        } else if (tasksResponse is Map && tasksResponse['data'] is List) {
          tasksData = tasksResponse['data'];
        }

        if (mounted) {
          setState(() {
            _myTasks = tasksData;
            _pendingCount = _myTasks.where((t) => t['task_status'] == 'pending' || t['task_status'] == 'in progress').length;
            _completedCount = _myTasks.where((t) => t['task_status'] == 'completed').length;
          });
        }
      }
    } catch (e, stacktrace) {
      print("❌ Error in _fetchMaintenanceData: $e");
      print("❌ Stacktrace: $stacktrace");
      if (mounted) {
        Fluttertoast.showToast(msg: "Data parsing error", backgroundColor: Colors.red);
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _handleLogout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Logout"),
        content: const Text("Are you sure you want to log out?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context), 
            child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFD32F2F)),
            onPressed: () {
              Navigator.pop(context); 
              Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
            },
            child: const Text("Logout", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      _buildHomeView(),         
      _buildAccessCardView(),   
      _buildTasksListView(), 
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1D2A6B), 
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white), 
        title: const Text(
          "Maintenance Dashboard",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Colors.white),
            onPressed: _fetchMaintenanceData,
          )
        ],
      ),
      
      drawer: Drawer(
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(30),
            bottomRight: Radius.circular(30),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.only(top: 60, left: 24, bottom: 24, right: 24),
              decoration: const BoxDecoration(
                color: Color(0xFF1D2A6B),
                borderRadius: BorderRadius.only(topRight: Radius.circular(30)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start, 
                children: [
                  const CircleAvatar(
                    radius: 35,
                    backgroundColor: Colors.white,
                    child: Icon(Icons.build_rounded, size: 35, color: Color(0xFF1D2A6B)),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _staffName.isEmpty ? "Loading..." : _staffName,
                    style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _jobType.isEmpty ? "Maintenance Department" : "$_jobType Department",
                    style: const TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.logout_rounded, color: Color(0xFFE57373), size: 26),
              title: const Text(
                "Logout",
                style: TextStyle(color: Color(0xFFE57373), fontSize: 16, fontWeight: FontWeight.w500),
              ),
              onTap: () {
                Navigator.pop(context); 
                _handleLogout(); 
              },
            ),
          ],
        ),
      ),
      
      body: _isLoading && _staffName.isEmpty
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF1D2A6B)))
          : pages[_currentIndex],
      
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: const Color(0xFF1D2A6B),
        unselectedItemColor: Colors.grey.shade400,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.badge_outlined), label: 'Access Card'),
          BottomNavigationBarItem(icon: Icon(Icons.build_circle_outlined), label: 'Tasks'),
        ],
      ),
    );
  }

  Widget _buildHomeView() {
    return RefreshIndicator(
      onRefresh: _fetchMaintenanceData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start, 
          children: [
            Text(
              _staffName.isEmpty ? "Welcome!" : "Welcome, $_staffName",
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF1D2A6B)),
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(Icons.work_outline, size: 16, color: Colors.grey),
                const SizedBox(width: 6),
                Text(
                  _jobType.isEmpty ? "Job Type: General" : "Job Type: $_jobType",
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade600, fontWeight: FontWeight.w500),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Text("Staff Status: ", style: TextStyle(fontSize: 14, color: Colors.grey)),
                Text(
                  _staffStatus,
                  style: const TextStyle(fontSize: 14, color: Colors.green, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 24),

            Row(
              children: [
                Expanded(
                  child: _buildDashboardCard(
                    icon: Icons.warning_amber_rounded,
                    iconColor: Colors.orange.shade600,
                    bgColor: Colors.orange.shade50,
                    count: "$_pendingCount New",
                    label: "Pending Tasks",
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildDashboardCard(
                    icon: Icons.check_circle_outline_rounded,
                    iconColor: Colors.blue.shade600,
                    bgColor: Colors.blue.shade50,
                    count: "$_completedCount Total",
                    label: "Completed Tasks",
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAccessCardView() {
    final String qrData = "https://adjsamira.github.io/smartgate-pfe/?id=${widget.staffId}";

    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 30),
        padding: const EdgeInsets.all(25),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(25),
          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 20)],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "SCAN AT GATE", 
              style: TextStyle(letterSpacing: 2, fontWeight: FontWeight.bold, color: Colors.grey),
            ),
            const SizedBox(height: 25),
            QrImageView(
              data: qrData, 
              version: QrVersions.auto, 
              size: 200.0,
              eyeStyle: const QrEyeStyle(eyeShape: QrEyeShape.square, color: Color(0xFF1D2A6B)),
              dataModuleStyle: const QrDataModuleStyle(dataModuleShape: QrDataModuleShape.square, color: Color(0xFF1D2A6B)),
            ),
            const Divider(height: 50),
            _rowInfo("Staff Name", _staffName.isEmpty ? "Maintenance Staff" : _staffName),
            _rowInfo("Position", "Maintenance Staff"),
            _rowInfo("Job Type", _jobType.isEmpty ? "General Maintenance" : _jobType),
          ],
        ),
      ),
    );
  }

  Widget _rowInfo(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        ],
      ),
    );
  }

  Widget _buildTasksListView() {
    return _myTasks.isEmpty
        ? const Center(child: Text("No tasks assigned to you yet. 👍", style: TextStyle(fontSize: 16, color: Colors.grey)))
        : RefreshIndicator(
            onRefresh: _fetchMaintenanceData,
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _myTasks.length,
              itemBuilder: (context, index) {
                final task = _myTasks[index];
                String status = task['task_status'] ?? 'pending';
                
                Color statusColor = Colors.orange;
                IconData statusIcon = Icons.error_outline_rounded;
                if (status == 'in progress') {
                  statusColor = Colors.blue;
                  statusIcon = Icons.play_circle_fill_rounded;
                } else if (status == 'completed') {
                  statusColor = Colors.green;
                  statusIcon = Icons.check_circle_rounded;
                } else if (status == 'canceled') {
                  statusColor = Colors.red;
                  statusIcon = Icons.cancel_rounded;
                }

                return Card(
                  elevation: 2,
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(statusIcon, color: statusColor, size: 24),
                                const SizedBox(width: 8),
                                Text(
                                  "QUICK ALERT: ${task['category'] ?? 'General'}",
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.black87),
                                ),
                              ],
                            ),
                            if (status != 'completed' && status != 'canceled')
                              IconButton(
                                icon: const Icon(Icons.arrow_forward_ios_rounded, size: 18, color: Colors.grey),
                                onPressed: () => _openUpdateStatusBottomSheet(task['id_Task'], status),
                              )
                            else
                              const Icon(Icons.check_circle_rounded, color: Colors.green, size: 20)
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(task['title'] ?? "No Title", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Text(
                          task['description'] ?? "No description provided.",
                          style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Reported by: ${task['resident_name'] ?? 'N/A'} (Apt: ${task['apartmentNumber'] ?? 'N/A'})",
                          style: const TextStyle(fontStyle: FontStyle.italic, color: Colors.grey, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
  }

  void _openUpdateStatusBottomSheet(int taskId, String currentStatus) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 50,
                  height: 5,
                  decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(10)),
                ),
              ),
              const SizedBox(height: 20),
              const Center(
                child: Text(
                  "Update Task Status",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1D2A6B)),
                ),
              ),
              const SizedBox(height: 25),

              if (currentStatus == 'pending')
                _buildBottomSheetActionButton(
                  icon: Icons.play_arrow_rounded,
                  iconColor: Colors.blue,
                  label: "Start Working",
                  onPressed: () => _submitStatusUpdate(taskId, 'in progress'),
                ),

              if (currentStatus == 'pending' || currentStatus == 'in progress') ...[
                if (currentStatus == 'pending') const SizedBox(height: 16),
                _buildBottomSheetActionButton(
                  icon: Icons.check_circle_rounded,
                  iconColor: Colors.green,
                  label: "Mark as Done",
                  onPressed: () => _submitStatusUpdate(taskId, 'completed'),
                ),
              ],
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBottomSheetActionButton({
    required IconData icon,
    required Color iconColor,
    required String label,
    required VoidCallback onPressed,
  }) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        decoration: BoxDecoration(
          color: iconColor.withOpacity(0.08), 
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: iconColor.withOpacity(0.2)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(icon, color: iconColor, size: 26),
                const SizedBox(width: 12),
                Text(
                  label,
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black87),
                ),
              ],
            ),
            Icon(Icons.arrow_forward_ios_rounded, size: 16, color: iconColor.withOpacity(0.6)),
          ],
        ),
      ),
    );
  }

  Future<void> _submitStatusUpdate(int taskId, String newStatus) async {
    Navigator.pop(context); 
    setState(() => _isLoading = true);
    
    try {
      final isSuccess = await ApiService.updateMaintenanceTask(taskId, newStatus, "");
      if (isSuccess) {
        Fluttertoast.showToast(msg: "Status updated to $newStatus! 🎉", backgroundColor: Colors.green);
        _fetchMaintenanceData(); 
      } else {
        Fluttertoast.showToast(msg: "Failed to update task on server", backgroundColor: Colors.red);
      }
    } catch (e) {
      Fluttertoast.showToast(msg: "Error updating task status", backgroundColor: Colors.red);
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Widget _buildDashboardCard({
    required IconData icon,
    required Color iconColor,
    required Color bgColor,
    required String count,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: Colors.grey.shade100, blurRadius: 10, offset: const Offset(0, 6)),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: bgColor, shape: BoxShape.circle),
            child: Icon(icon, color: iconColor, size: 28),
          ),
          const SizedBox(height: 16),
          Text(count, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF212121))),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(fontSize: 12, color: Colors.grey.shade500, fontWeight: FontWeight.w500), textAlign: TextAlign.center),
        ],
      ),
    );
  }
}