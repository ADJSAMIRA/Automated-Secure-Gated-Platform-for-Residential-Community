import 'package:flutter/material.dart';
import '../services/api_service.dart';

class DeleteAccountsPage extends StatefulWidget {
  final VoidCallback onBack;

  const DeleteAccountsPage({super.key, required this.onBack});

  @override
  _DeleteAccountsPageState createState() => _DeleteAccountsPageState();
}

class _DeleteAccountsPageState extends State<DeleteAccountsPage> {
  late Future<List<dynamic>> _usersFuture;

 
  final Color primaryNavy = const Color(0xFF1A237E);
  final Color deleteRed = const Color(0xFFEE5D50);
  final Color backgroundGrey = const Color(0xFFF8F9FD);

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  void _loadUsers() {
    setState(() {
      _usersFuture = ApiService.getAllUsers();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: backgroundGrey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
        
          Padding(
            padding: const EdgeInsets.fromLTRB(30, 35, 30, 20),
            child: Row(
              children: [
                _buildCircularBackButton(),
                const SizedBox(width: 20),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Delete Accounts",
                      style: TextStyle(
                        fontSize: 28, 
                        fontWeight: FontWeight.bold, 
                        color: Color(0xFF1B2559),
                        letterSpacing: -0.5
                      ),
                    ),
                    Text(
                      "Carefully remove users from the system",
                      style: TextStyle(color: Colors.grey[500], fontSize: 14),
                    ),
                  ],
                ),
              ],
            ),
          ),

        
          Expanded(
            child: FutureBuilder<List<dynamic>>(
              future: _usersFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator(color: primaryNavy));
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return _buildEmptyState();
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) => _buildDeleteUserCard(snapshot.data![index]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCircularBackButton() {
    return InkWell(
      onTap: widget.onBack,
      borderRadius: BorderRadius.circular(15),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))
          ],
        ),
        child: Icon(Icons.arrow_back_ios_new_rounded, color: primaryNavy, size: 18),
      ),
    );
  }

  Widget _buildDeleteUserCard(Map<String, dynamic> user) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFE0E5F2).withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 10),
          )
        ],
      ),
      child: Row(
        children: [
         
          Container(
            height: 60,
            width: 60,
            decoration: BoxDecoration(
              color: deleteRed.withOpacity(0.1),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Center(
              child: Text(
                user['fullName']?[0].toUpperCase() ?? "U",
                style: TextStyle(color: deleteRed, fontWeight: FontWeight.bold, fontSize: 22),
              ),
            ),
          ),
          const SizedBox(width: 20),
          
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user['fullName'] ?? 'N/A',
                  style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 17, color: Color(0xFF1B2559)),
                ),
                Text(
                  user['email'] ?? '',
                  style: TextStyle(color: Colors.grey[500], fontSize: 13),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    "ID: ${user['id_user']}",
                    style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.black54),
                  ),
                ),
              ],
            ),
          ),

         
          Material(
            color: deleteRed.withOpacity(0.1),
            borderRadius: BorderRadius.circular(15),
            child: InkWell(
              onTap: () => _confirmDelete(user),
              borderRadius: BorderRadius.circular(15),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    Icon(Icons.delete_outline_rounded, color: deleteRed, size: 20),
                    const SizedBox(width: 4),
                    Text("Delete", style: TextStyle(color: deleteRed, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(Map<String, dynamic> user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        title: const Text("Confirm Deletion", style: TextStyle(fontWeight: FontWeight.bold)),
        content: Text("Are you sure you want to delete ${user['fullName']}? This action cannot be undone."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () async {
              bool success = await ApiService.deleteUser(user['id_user']);
              if (success) {
                Navigator.pop(context);
                _loadUsers();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Account deleted"), backgroundColor: Colors.redAccent)
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: deleteRed, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            child: const Text("Confirm Delete", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.person_off_rounded, size: 80, color: Colors.grey[200]),
          const SizedBox(height: 16),
          Text("No users to display", style: TextStyle(color: Colors.grey[400])),
        ],
      ),
    );
  }
}