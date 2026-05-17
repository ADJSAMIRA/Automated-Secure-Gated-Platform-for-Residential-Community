import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'ChatScreen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ConversationsScreen extends StatefulWidget {
  final VoidCallback? onBack;

  const ConversationsScreen({super.key, this.onBack});

  @override
  State<ConversationsScreen> createState() => _ConversationsScreenState();
}

class _ConversationsScreenState extends State<ConversationsScreen> {
  bool isLoading = true;
  List conversations = [];
  int? adminId;
  
  
  Map<String, dynamic>? selectedContact; 

  final Color primaryBlue = const Color(0xFF1B2559); 
  final Color scaffoldBg = const Color(0xFFF8F9FD); 

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    if (!mounted) return;
    setState(() => isLoading = true);
    
    try {
      final adminData = await ApiService.getAdminInfo();
      if (adminData != null && adminData['id_user'] != null) {
        adminId = int.parse(adminData['id_user'].toString());
      } else {
        final prefs = await SharedPreferences.getInstance();
        adminId = prefs.getInt('userId');
      }

      if (adminId != null) {
        final data = await ApiService.getConversations(adminId!);
        if (mounted) {
          setState(() {
            conversations = data;
            isLoading = false;
          });
        }
      } else {
        if (mounted) setState(() => isLoading = false);
        _showLoginError();
      }
    } catch (e) {
      if (mounted) setState(() => isLoading = false);
    }
  }

  void _showLoginError() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Could not identify Admin. Please Login again."), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
  
    if (selectedContact != null && adminId != null) {
      return ChatScreen(
        currentUserId: adminId!,
        contactId: selectedContact!['contact_id'],
        contactName: selectedContact!['contact_name'] ?? "Resident",
        onBackToConversations: () {
          setState(() {
            selectedContact = null; 
          });
          _loadInitialData(); 
        },
      );
    }

    return Container(
      color: scaffoldBg,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(15, 20, 25, 10),
            child: Row(
              children: [
                if (widget.onBack != null)
                  IconButton(
                    icon: Icon(Icons.arrow_back_ios_rounded, color: primaryBlue, size: 20),
                    onPressed: widget.onBack, 
                  ),
                Text(
                  "| Resident Messages", 
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: primaryBlue, letterSpacing: 0.5),
                ),
              ],
            ),
          ),
          Expanded(
            child: isLoading
                ? Center(child: CircularProgressIndicator(color: primaryBlue))
                : conversations.isEmpty
                    ? _buildEmptyState()
                    : RefreshIndicator(
                        color: primaryBlue,
                        onRefresh: _loadInitialData,
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
                          itemCount: conversations.length,
                          itemBuilder: (context, index) {
                            final conv = conversations[index];
                            return _buildModernConversationCard(conv);
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernConversationCard(dynamic conv) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.015), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: CircleAvatar(
          radius: 24,
          backgroundColor: primaryBlue.withOpacity(0.08),
          child: Icon(Icons.person_rounded, color: primaryBlue, size: 24),
        ),
        title: Text(conv['contact_name'] ?? "Resident", style: TextStyle(fontWeight: FontWeight.bold, color: primaryBlue, fontSize: 16)),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            conv['lastMessage'] ?? "Click to view chat", 
            maxLines: 1, 
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
          ),
        ),
        trailing: Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.grey.shade400),
        onTap: () {
          setState(() {
            selectedContact = conv; 
          });
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.chat_bubble_outline_rounded, size: 70, color: Colors.grey.shade300),
          const SizedBox(height: 14),
          Text("No messages yet", style: TextStyle(color: Colors.grey.shade400, fontSize: 15)),
        ],
      ),
    );
  }
}