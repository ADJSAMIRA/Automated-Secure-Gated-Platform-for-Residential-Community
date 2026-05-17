import 'package:flutter/material.dart';
//import 'dart:convert';
import 'package:qr_flutter/qr_flutter.dart'; 
import 'package:residenceapp/services/api_service.dart'; 

class SecurityHomeScreen extends StatefulWidget {
  final String userName;
  final String userId;

  const SecurityHomeScreen({super.key, required this.userName, required this.userId});

  @override
  _SecurityHomeScreenState createState() => _SecurityHomeScreenState();
}

class _SecurityHomeScreenState extends State<SecurityHomeScreen> {
  int _selectedIndex = 0;
  Map<String, dynamic>? homeData;
  List<dynamic> tasks = []; 
  bool isLoading = true;
  bool isTasksLoading = false;

  @override
  void initState() {
    super.initState();
    _loadHomeData(); 
  }

 
  Future<void> _loadHomeData() async {
    setState(() => isLoading = true);
    try {
    //get info profile 
      final profileData = await ApiService.getSecurityHome(widget.userId);
      
  
      final statsData = await ApiService.getSecurityStats(widget.userId);
      
      setState(() {
        homeData = statsData; 
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      print("Error loading home data or stats: $e");
    }
  }


  Future<void> _loadTasks() async {
    setState(() => isTasksLoading = true);
    try {
      final fetchedTasks = await ApiService.getSecurityTasks(widget.userId);
      setState(() {
        tasks = fetchedTasks;
        isTasksLoading = false;
      });
    } catch (e) {
      setState(() => isTasksLoading = false);
      print("Error loading tasks: $e");
    }
  }


  Future<void> _handleUpdateTask(String taskId, String newStatus) async {
    try {
     
      bool success = await ApiService.updateSecurityTask(taskId, newStatus, remarks: "Updated by staff"); 
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Task updated successfully!")),
        );
        _loadTasks();
      } else {
        throw Exception("Failed to update");
      }
    } catch (e) {
      print("Update Error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error updating task: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE),
      drawer: _buildDrawer(),
      appBar: AppBar(
        title: const Text("Security Dashboard", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF1A237E),
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: _buildCurrentPage(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() => _selectedIndex = index);
          if (index == 3) _loadTasks(); 
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF1A237E),
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.badge_outlined), label: 'Access Card'),
          BottomNavigationBarItem(icon: Icon(Icons.list_alt), label: 'Logs'),
          BottomNavigationBarItem(icon: Icon(Icons.notifications_active), label: 'Alerts'),
        ],
      ),
    );
  }

  Widget _buildCurrentPage() {
    switch (_selectedIndex) {
      case 0: return _buildQuickOverview();
      case 1: return _buildDigitalCardPage();
      case 2: return const Center(child: Text("Entry Logs List"));
      case 3: return _buildAlertsPage(); 
      default: return _buildQuickOverview();
    }
  }

 Widget _buildAlertsPage() {
  if (isTasksLoading) return const Center(child: CircularProgressIndicator());
  if (tasks.isEmpty) return const Center(child: Text("No active alerts."));

  return RefreshIndicator(
    onRefresh: _loadTasks,
    child: ListView.builder(
      padding: const EdgeInsets.all(15),
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        final task = tasks[index];
       
        bool isPending = task['task_status'] == 'pending';

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          elevation: 2,
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: isPending ? Colors.red.shade100 : Colors.green.shade100,
              child: Icon(
                isPending ? Icons.warning_amber_rounded : Icons.check_circle,
                color: isPending ? Colors.red : Colors.green,
              ),
            ),
            title: Text(
              task['title'] ?? 'Security Alert',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(task['description'] ?? ''),
                const SizedBox(height: 4),
                Text(
                  "Reported by: ${task['reportedBy'] ?? 'Unknown'}",
                  style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
                ),
              ],
            ),
           trailing: task['task_status'] == 'completed' || task['task_status'] == 'canceled'
    ? Icon(
        task['task_status'] == 'completed' ? Icons.check_circle : Icons.cancel,
        color: task['task_status'] == 'completed' ? Colors.green : Colors.grey,
        size: 28,
      )
    : IconButton(
        icon: const Icon(Icons.arrow_forward_ios, size: 18, color: Colors.blueGrey),
        onPressed: () => _showActionSheet(context, task),
      ),
                
          ),
        );
      },
    ),
  );
}

 //access card
  Widget _buildDigitalCardPage() {
    final String qrData = "https://adjsamira.github.io/smartgate-pfe/?id=${widget.userId}";
    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 30),
        padding: const EdgeInsets.all(25),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(25),
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 20)],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("SCAN AT GATE", style: TextStyle(letterSpacing: 2, fontWeight: FontWeight.bold, color: Colors.grey)),
            const SizedBox(height: 25),
            QrImageView(data: qrData, version: QrVersions.auto, size: 200.0),
            const Divider(height: 50),
            _rowInfo("Staff Name", widget.userName),
            _rowInfo("Position", "Security Staff"),
          ],
        ),
      ),
    );
  }

 //quick overview
  Widget _buildQuickOverview() {
    if (isLoading) return const Center(child: CircularProgressIndicator());

    return RefreshIndicator(
      onRefresh: _loadHomeData,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Welcome, ${widget.userName}", style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF1A237E))),
            const Text("Security Status: Operational", style: TextStyle(color: Colors.green, fontWeight: FontWeight.w500)),
            const SizedBox(height: 25),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 15,
              mainAxisSpacing: 15,
              children: [
                _overviewCard(
                  title: "Security Alerts",
                  value: "${homeData?['alertsCount'] ?? 0} New", 
                  icon: Icons.warning_amber_rounded,
                  color: Colors.redAccent,
                  onTap: () {
                    setState(() => _selectedIndex = 3);
                    _loadTasks();
                  },
                ),
                _overviewCard(
                  title: "Entry Logs",
                  value: "${homeData?['logsCount'] ?? 0} Today",
                  icon: Icons.history,
                  color: Colors.blueAccent,
                  onTap: () => setState(() => _selectedIndex = 2),
                ),
              ],
            ),
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

  Widget _overviewCard({required String title, required String value, required IconData icon, required Color color, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(backgroundColor: color.withOpacity(0.1), child: Icon(icon, color: color)),
            const SizedBox(height: 12),
            Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text(title, textAlign: TextAlign.center, style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            decoration: const BoxDecoration(color: Color(0xFF1A237E)),
            accountName: Text(widget.userName),
            accountEmail: const Text("Security Department"),
            currentAccountPicture: const CircleAvatar(backgroundColor: Colors.white, child: Icon(Icons.security, color: Color(0xFF1A237E))),
          ),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text("Logout", style: TextStyle(color: Colors.red)),
            onTap: () => Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false),
          ),
        ],
      ),
    );
  }
  void _showActionSheet(BuildContext context, dynamic task) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent, 
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
          ),
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 50,
                height: 5,
                decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10)),
              ),
              const SizedBox(height: 25),
              const Text("Update Task Status", 
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1A237E))),
              const SizedBox(height: 20),
              
              _buildModernAction(
                icon: Icons.play_circle_filled_rounded,
                color: Colors.orange,
                label: "Start Working",
                onTap: () {
                  Navigator.pop(context);
                  _handleUpdateTask(task['id_Task'].toString(), 'in progress');
                },
              ),
              
              _buildModernAction(
                icon: Icons.check_circle_rounded,
                color: Colors.green,
                label: "Mark as Done",
                onTap: () {
                  Navigator.pop(context);
                  _handleUpdateTask(task['id_Task'].toString(), 'completed');
                },
              ),
              
              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }

  Widget _buildModernAction({required IconData icon, required Color color, required String label, required VoidCallback onTap}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(15),
      ),
      child: ListTile(
        leading: Icon(icon, color: color, size: 30),
        title: Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
        trailing: const Icon(Icons.chevron_right, color: Colors.grey),
        onTap: onTap,
      ),
    );
  }
}