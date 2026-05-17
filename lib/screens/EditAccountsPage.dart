import 'package:flutter/material.dart';
import '../services/api_service.dart';

class EditAccountsPage extends StatefulWidget {
  final VoidCallback onBack; 

  const EditAccountsPage({super.key, required this.onBack});

  @override
  _EditAccountsPageState createState() => _EditAccountsPageState();
}

class _EditAccountsPageState extends State<EditAccountsPage> {
  late Future<List<dynamic>> _usersFuture;

 
  final Color primaryNavy = const Color(0xFF1A237E);
  final Color backgroundGrey = const Color(0xFFF8F9FD);
  final Color accentBlue = const Color(0xFF3F51B5);

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
                      "Edit Accounts",
                      style: TextStyle(
                        fontSize: 28, 
                        fontWeight: FontWeight.bold, 
                        color: Color(0xFF1B2559),
                        letterSpacing: -0.5
                      ),
                    ),
                    Text(
                      "Manage and update resident information",
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
                  itemBuilder: (context, index) => _buildUltraModernCard(snapshot.data![index]),
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

  Widget _buildUltraModernCard(Map<String, dynamic> user) {
    bool isResident = user['role'] == 'Resident';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white),
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
              gradient: LinearGradient(
                colors: [primaryNavy, accentBlue],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Center(
              child: Text(
                user['fullName']?[0].toUpperCase() ?? "U",
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 22),
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
                  style: const TextStyle(
                    fontWeight: FontWeight.w800, 
                    fontSize: 17, 
                    color: Color(0xFF1B2559)
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.alternate_email, size: 14, color: Colors.grey[400]),
                    const SizedBox(width: 5),
                    Text(
                      user['email'] ?? '',
                      style: TextStyle(color: Colors.grey[500], fontSize: 13, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _buildStatusBadge(
                      user['role'] ?? 'Resident', 
                      isResident ? const Color(0xFFE9EDF7) : const Color(0xFFE2F6E9), 
                      isResident ? primaryNavy : Colors.green[700]!
                    ),
                    if (isResident) ...[
                      const SizedBox(width: 8),
                      _buildStatusBadge(
                        "B${user['blockNumber']} • A${user['apartmentNumber']}", 
                        const Color(0xFFFFF4E5), 
                        const Color(0xFFFFAB2D)
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),

          Material(
            color: backgroundGrey,
            borderRadius: BorderRadius.circular(15),
            child: InkWell(
              onTap: () => _showEditForm(user),
              borderRadius: BorderRadius.circular(15),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    Icon(Icons.edit_note_rounded, color: primaryNavy, size: 22),
                    const SizedBox(width: 4),
                    Text("Edit", style: TextStyle(color: primaryNavy, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String text, Color bg, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12)),
      child: Text(
        text, 
        style: TextStyle(color: textColor, fontSize: 11, fontWeight: FontWeight.bold)
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.group_off_rounded, size: 80, color: Colors.grey[200]),
          const SizedBox(height: 16),
          Text("No registered users found", style: TextStyle(color: Colors.grey[400], fontSize: 16)),
        ],
      ),
    );
  }

 
  void _showEditForm(Map<String, dynamic> user) {
    final nameCtrl = TextEditingController(text: user['fullName']);
    final emailCtrl = TextEditingController(text: user['email']);
    final blockCtrl = TextEditingController(text: user['blockNumber']?.toString() ?? '');
    final aptCtrl = TextEditingController(text: user['apartmentNumber']?.toString() ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        title: Column(
          children: [
            const Text("Update Profile", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 22)),
            const SizedBox(height: 5),
            Text("Modify user credentials", style: TextStyle(color: Colors.grey[500], fontSize: 14, fontWeight: FontWeight.normal)),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildModernTextField(nameCtrl, "Full Name", Icons.person_rounded),
              const SizedBox(height: 18),
              _buildModernTextField(emailCtrl, "Email", Icons.alternate_email_rounded),
              if (user['role'] == 'Resident') ...[
                const SizedBox(height: 18),
                Row(
                  children: [
                    Expanded(child: _buildModernTextField(blockCtrl, "Block", Icons.grid_view_rounded)),
                    const SizedBox(width: 12),
                    Expanded(child: _buildModernTextField(aptCtrl, "Apt", Icons.meeting_room_rounded)),
                  ],
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context), 
            child: Text("Cancel", style: TextStyle(color: Colors.grey[600], fontWeight: FontWeight.bold))
          ),
          ElevatedButton(
            onPressed: () async {
              String role = user['role'] ?? 'Resident';
              Map<String, dynamic> data = {
                "fullName": nameCtrl.text.trim(),
                "email": emailCtrl.text.trim(),
                "role": role,
                "apartmentNumber": role == 'Resident' ? aptCtrl.text.trim() : null,
                "blockNumber": role == 'Resident' ? blockCtrl.text.trim() : null,
              };

              bool success = await ApiService.updateUser(user['id_user'], data);
              if (success) {
                Navigator.pop(context);
                _loadUsers();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text("User info updated successfully"),
                    backgroundColor: primaryNavy,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  )
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryNavy,
              padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 15),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              elevation: 0,
            ),
            child: const Text("Save Updates", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildModernTextField(TextEditingController ctrl, String label, IconData icon) {
    return TextField(
      controller: ctrl,
      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
        prefixIcon: Icon(icon, color: primaryNavy, size: 20),
        filled: true,
        fillColor: const Color(0xFFF4F7FE),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: BorderSide(color: primaryNavy, width: 1.5)),
      ),
    );
  }
}