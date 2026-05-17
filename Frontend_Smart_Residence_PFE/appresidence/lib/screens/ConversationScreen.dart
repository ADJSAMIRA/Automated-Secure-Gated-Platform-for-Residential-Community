import 'dart:async';
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'ChatUI.dart';

class InboxScreen extends StatefulWidget {
  final String currentUserId;
  const InboxScreen({super.key, required this.currentUserId});

  @override
  State<InboxScreen> createState() => _InboxScreenState();
}

class _InboxScreenState extends State<InboxScreen> {
  String searchQuery = "";
  final TextEditingController _searchController = TextEditingController();
  Timer? _refreshTimer;
  Map<String, dynamic>? _adminData;

  @override
  void initState() {
    super.initState();
    _fetchAdminData();
   //refrech every 5s if eny new mesgs
    _refreshTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (searchQuery.isEmpty && mounted) {
        setState(() {});
      }
    });
  }

  //get admin info
  Future<void> _fetchAdminData() async {
    final data = await ApiService.getAdminInfo();
    if (mounted && data != null) {
      setState(() {
        _adminData = data['data'] ?? data;
      });
    }
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Community Chat",
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 22)),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          Expanded(
            child: FutureBuilder<List<dynamic>>(
              future: searchQuery.isEmpty
                  ? ApiService.getUserInbox(widget.currentUserId)
                  : ApiService.searchResidents(searchQuery),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator(color: Color(0xFF00ADEE)));
                }

                List<dynamic> list = List.from(snapshot.data ?? []);

                //pinned admin
                if (searchQuery.isEmpty && _adminData != null) {
                  String adminId = _adminData!['id_user']?.toString() ?? "26";
                  String adminName = _adminData!['fullName'] ?? "Admin Support";

                  int adminIndex = list.indexWhere((item) =>
                      (item['contact_id'] ?? item['id_user']).toString() == adminId);

                  Map<String, dynamic> adminTile;
                  if (adminIndex != -1) {
                    adminTile = Map<String, dynamic>.from(list[adminIndex]);
                    list.removeAt(adminIndex);
                  } else {
                    adminTile = {
                      'contact_name': adminName,
                      'contact_id': adminId,
                      'contact_role': 'Admin',
                      'lastMessage': 'Tap to contact support',
                    };
                  }
                  adminTile['is_pinned'] = true; 
                  list.insert(0, adminTile); 
                }

                return ListView.builder(
                  padding: const EdgeInsets.only(top: 10),
                  itemCount: list.length,
                  itemBuilder: (context, index) => _buildChatTile(list[index]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatTile(dynamic item) {
    String name = item['contact_name'] ?? item['fullName'] ?? "Neighbor";
    String id = (item['contact_id'] ?? item['id_user']).toString();
    bool isPinned = item['is_pinned'] == true;
    
   //badge admin for admin
    bool isAdmin = (item['contact_role']?.toString().toLowerCase() == 'admin' || 
                    item['role']?.toString().toLowerCase() == 'admin' || 
                    isPinned);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: isPinned ? const Color(0xFFF0F7FF) : Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))
        ],
        border: Border.all(
          color: isPinned ? const Color(0xFF00ADEE).withOpacity(0.3) : Colors.grey.withOpacity(0.1),
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          radius: 28,
          backgroundColor: isPinned ? const Color(0xFF00ADEE) : Colors.grey[300],
          child: Text(name[0].toUpperCase(),
              style: TextStyle(color: isPinned ? Colors.white : Colors.black87, fontWeight: FontWeight.bold)),
        ),
        title: Row(
          children: [
            Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            if (isAdmin) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFF00ADEE).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFF00ADEE), width: 0.5),
                ),
                child: const Text("Admin",
                    style: TextStyle(color: Color(0xFF00ADEE), fontSize: 10, fontWeight: FontWeight.bold)),
              ),
            ],
          ],
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(item['lastMessage'] ?? "Tap to chat",
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: isPinned ? const Color(0xFF00ADEE).withOpacity(0.8) : Colors.grey[600])),
        ),
        trailing: isPinned
            ? const Icon(Icons.push_pin_rounded, size: 18, color: Color(0xFF00ADEE))
            : const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChatUI(
                currentUserId: widget.currentUserId,
                receiverId: id,
                receiverName: name,
              ),
            ),
          ).then((_) { if (mounted) setState(() {}); });
        },
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Container(
        decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(20)),
        child: TextField(
          controller: _searchController,
          onChanged: (v) => setState(() => searchQuery = v),
          decoration: const InputDecoration(
            hintText: "Search for neighbors...",
            prefixIcon: Icon(Icons.search, color: Colors.grey),
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(vertical: 15),
          ),
        ),
      ),
    );
  }
}