import 'package:flutter/material.dart';
import '../services/api_service.dart';

class ApprovalsPage extends StatefulWidget {
  final VoidCallback? onBack; 
  const ApprovalsPage({super.key, this.onBack});

  @override
  State<ApprovalsPage> createState() => _ApprovalsPageState();
}

class _ApprovalsPageState extends State<ApprovalsPage> {
  late Future<List<dynamic>> _allRequests;
  
  static const Color primaryBlue = Color(0xFF1B2559);
  static const Color successGreen = Color(0xFF4CAF50);
  static const Color errorRed = Color(0xFFE53935);

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
      _showCustomSnackBar(
        action == 'active' ? "User approved successfully!" : "User rejected successfully!",
        action == 'active' ? successGreen : errorRed,
        action == 'active' ? Icons.check_circle : Icons.cancel,
      );
      _loadData(); 
    }
  }

  void _showCustomSnackBar(String message, Color color, IconData icon) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(width: 10),
            Text(message),
          ],
        ),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(30, 25, 30, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20, color: primaryBlue),
                      onPressed: widget.onBack ?? () => Navigator.pop(context),
                    ),
                    const Text("Pending Requests", 
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: primaryBlue)),
                  ],
                ),
                const Padding(
                  padding: EdgeInsets.only(left: 48),
                  child: Text("Review resident contact info and housing details", 
                      style: TextStyle(color: Colors.grey, fontSize: 14)),
                ),
              ],
            ),
          ),
          
          Expanded(
            child: FutureBuilder<List<dynamic>>(
              future: _allRequests,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: primaryBlue));
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return _buildEmptyState();
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) => _buildModernUserCard(snapshot.data![index]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernUserCard(Map<String, dynamic> user) {
    final String name = user['fullName'] ?? "Unknown User";
    final String email = user['email'] ?? "No Email";
    final String phone = (user['phoneNumber'] ?? user['phone'] ?? "No Phone").toString();
    
    final String apt = (user['doorNumber'] ?? user['apartmentNumber'] ?? "N/A").toString();
    final String block = (user['blockNumber'] ?? "N/A").toString();
    final int userId = user['id_user'] ?? user['id'] ?? 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: const Color(0xFFF0F2FF),
            child: Text(name.isNotEmpty ? name[0].toUpperCase() : "U", 
                style: const TextStyle(color: primaryBlue, fontWeight: FontWeight.bold, fontSize: 18)),
          ),
          const SizedBox(width: 20),
          
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: primaryBlue)),
                const SizedBox(height: 4),
               
                Row(
                  children: [
                    const Icon(Icons.email_outlined, size: 14, color: Colors.grey),
                    const SizedBox(width: 6),
                    Text(email, style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                  ],
                ),
                const SizedBox(height: 4),
               
                Row(
                  children: [
                    const Icon(Icons.phone_outlined, size: 14, color: Colors.grey),
                    const SizedBox(width: 6),
                    Text(phone, style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                  ],
                ),
                const SizedBox(height: 12),
                
               
                Row(
                  children: [
                    _buildTinyBadge("Block $block"),
                    const SizedBox(width: 8),
                    _buildTinyBadge("Apt $apt"),
                  ],
                )
              ],
            ),
          ),

       
          Row(
            children: [
              _buildActionButton(
                label: "Reject",
                color: errorRed,
                onPressed: () => _processAction(userId, 'rejected'),
              ),
              const SizedBox(width: 10),
              _buildActionButton(
                label: "Approve",
                color: successGreen,
                isPrimary: true,
                onPressed: () => _processAction(userId, 'active'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTinyBadge(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFF4F7FE),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(text, style: const TextStyle(color: Color(0xFF8F9BBA), fontSize: 11, fontWeight: FontWeight.w600)),
    );
  }

  Widget _buildActionButton({required String label, required Color color, required VoidCallback onPressed, bool isPrimary = false}) {
    return SizedBox(
      height: 40,
      width: 100,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: isPrimary ? color : Colors.white,
          foregroundColor: isPrimary ? Colors.white : color,
          elevation: 0,
          side: BorderSide(color: isPrimary ? Colors.transparent : color.withOpacity(0.3)),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          padding: EdgeInsets.zero,
        ),
        child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.person_search_rounded, size: 70, color: Colors.grey[200]),
          const SizedBox(height: 15),
          const Text("No pending requests", style: TextStyle(color: Colors.grey, fontSize: 16)),
        ],
      ),
    );
  }
}