import 'package:adminspace/screens/ApprovalsPage.dart';
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'EditAccountsPage.dart'; 
import 'DeleteAccountsPage.dart'; 

class ManageAccountsPage extends StatefulWidget {
  final VoidCallback onBack; 

  const ManageAccountsPage({super.key, required this.onBack});

  @override
  State<ManageAccountsPage> createState() => _ManageAccountsPageState();
}

class _ManageAccountsPageState extends State<ManageAccountsPage> {
 
  int viewIndex = 0;
  late Future<List<dynamic>> _allRequests;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    setState(() {
      _allRequests = ApiService.getPendingUsers();
    });
  }

  Future<void> _processAction(int id, String action) async {
    bool success = await ApiService.approveUser(id, action);
    if (!mounted) return;
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(action == 'active' ? "Approved!" : "Rejected!"),
          backgroundColor: action == 'active' ? Colors.green : Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
      _loadData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: const Color(0xFFF8F9FD),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 400),
        child: _buildCurrentView(),
      ),
    );
  }
//return pages
  Widget _buildCurrentView() {
    switch (viewIndex) {
      case 1:
      
        return ApprovalsPage(onBack: () => setState(() => viewIndex = 0));
      case 2:
        return EditAccountsPage(onBack: () => setState(() => viewIndex = 0));
      case 3:
        return DeleteAccountsPage(onBack: () => setState(() => viewIndex = 0));
      default:
        return _buildDashboardGrid();
    }
  }

  Widget _buildDashboardGrid() {
    return SingleChildScrollView(
      key: const ValueKey(0),
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
       
          Row(
            crossAxisAlignment: CrossAxisAlignment.start, 
            children: [
              Padding(
              
                padding: const EdgeInsets.only(top: 4), 
                child: IconButton(
                  icon: const Icon(Icons.arrow_back_ios_rounded, color: Color(0xFF1B2559), size: 20),
                  onPressed: widget.onBack, 
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildSectionHeader(
                  "Account Management", 
                  "Take control of different users  and registrations."
                ),
              ),
            ],
          ),
          const SizedBox(height: 40),
          Wrap(
            spacing: 25,
            runSpacing: 25,
            children: [
              _buildModernCard(
                title: "Active Accounts",
                subtitle: "Approve pending users",
                icon: Icons.person_add_alt_1_rounded,
                color: Colors.green,
                onTap: () => setState(() => viewIndex = 1),
              ),
              _buildModernCard(
                title: "Edit Accounts",
                subtitle: "Modify resident info",
                icon: Icons.edit_note_rounded,
                color: Colors.blueAccent,
                onTap: () => setState(() => viewIndex = 2),
              ),
              _buildModernCard(
                title: "Delete Accounts",
                subtitle: "Remove community data",
                icon: Icons.person_remove_rounded,
                color: Colors.redAccent,
                onTap: () => setState(() => viewIndex = 3),
              ),
            ],
          ),
        ],
      ),
    );
  }
 

  Widget _buildModernCard({
    required String title, 
    required String subtitle, 
    required IconData icon, 
    required Color color, 
    required VoidCallback onTap
  }) {
    return SizedBox(
      width: 270,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(25),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.grey.shade100),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.02), 
                blurRadius: 15, 
                offset: const Offset(0, 4)
              )
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(height: 20),
              Text(title, style: const TextStyle(fontSize: 19, fontWeight: FontWeight.bold, color: Color(0xFF1B2559))),
              const SizedBox(height: 6),
              Text(subtitle, style: TextStyle(color: Colors.grey[500], fontSize: 13)),
              const SizedBox(height: 20),
              const Divider(height: 1, thickness: 0.5),
              const SizedBox(height: 15),
              Row(
                children: [
                  Text("Go to list", style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12)),
                  const Spacer(),
                  Icon(Icons.chevron_right_rounded, color: color, size: 18),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, String sub) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 5, 
              height: 25, 
              decoration: BoxDecoration(
                color: const Color(0xFF1A237E), 
                borderRadius: BorderRadius.circular(10)
              )
            ),
            const SizedBox(width: 12),
            Text(
              title, 
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF1B2559))
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(sub, style: TextStyle(color: Colors.grey[500], fontSize: 14)),
      ],
    );
  }
}