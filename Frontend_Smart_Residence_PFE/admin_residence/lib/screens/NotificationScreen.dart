import 'package:flutter/material.dart';
import 'package:adminspace/services/api_service.dart';

class NotificationScreen extends StatefulWidget {
  final String adminId;
  final VoidCallback onBack;

  const NotificationScreen({super.key, required this.adminId, required this.onBack});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  List<dynamic> _notifications = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchNotifications();
  }

  Future<void> _fetchNotifications() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      
      List<dynamic> list = await ApiService.getUserNotifications(widget.adminId);
      
     
      if (list.isEmpty) {
        list = await ApiService.getUserNotifications("1"); 
      }

      if (mounted) {
        setState(() {
          _notifications = list;
          _isLoading = false;
        });
      }
    } catch (e) {
      print("Error loading notifications in screen: $e");
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleNotificationClick(dynamic item, int index) async {
   
    final idNotification = item['id_notification'] ?? item['id'] ?? item['user_id'] ?? 0;
    bool isRead = item['is_read'] == 1 || item['is_read'] == true;

    if (!isRead) {
      bool success = await ApiService.markNotificationAsRead(idNotification);
      if (success && mounted) {
        setState(() {
          _notifications[index]['is_read'] = true;
        });
      }
    }
    _showDetailsModal(item);
  }

  void _showDetailsModal(dynamic item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(item['title'] ?? 'Notification Details', 
            style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1B2559))),
        content: Text(item['message'] ?? '', 
            style: const TextStyle(fontSize: 15, height: 1.5, color: Colors.black87)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("CLOSE", style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1A237E))),
          )
        ],
      ),
    );
  }

 
  Map<String, dynamic> _getNotificationStyle(String type) {
    switch (type) {
      case 'Message': 
        return {'icon': Icons.chat_bubble_rounded, 'color': Colors.blue};
      case 'Alert':
        return {'icon': Icons.warning_amber_rounded, 'color': Colors.redAccent};
      case 'Reservation':
        return {'icon': Icons.bookmark_added_rounded, 'color': Colors.green};
      case 'Event':
        return {'icon': Icons.celebration_rounded, 'color': Colors.purple};
      default:
        return {'icon': Icons.notifications_none_rounded, 'color': const Color(0xFF1A237E)};
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
        
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF1B2559), size: 20),
                onPressed: widget.onBack,
              ),
              const SizedBox(width: 10),
              const Text(
                "Notifications Center",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF1B2559)),
              ),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: _fetchNotifications,
                icon: const Icon(Icons.refresh, size: 18),
                label: const Text("Refresh"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFF1A237E),
                  elevation: 0,
                  side: BorderSide(color: Colors.grey.shade200),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              )
            ],
          ),
          const SizedBox(height: 25),
          
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _notifications.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                        itemCount: _notifications.length,
                        itemBuilder: (context, index) {
                          final item = _notifications[index];
                          final style = _getNotificationStyle(item['type'] ?? 'System');
                          bool isRead = item['is_read'] == 1 || item['is_read'] == true;
                          String dateStr = item['created_at'] ?? item['createdAt'] ?? '';

                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            decoration: BoxDecoration(
                              color: isRead ? Colors.white : const Color(0xFFF4F6FF),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isRead ? Colors.grey.shade100 : const Color(0xFFC5CFFF),
                                width: 1.2
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.01),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4)
                                )
                              ]
                            ),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(16),
                              onTap: () => _handleNotificationClick(item, index),
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    CircleAvatar(
                                      backgroundColor: (style['color'] as Color).withOpacity(0.1),
                                      radius: 22,
                                      child: Icon(style['icon'], color: style['color'], size: 22),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  item['title'] ?? 'New Notification',
                                                  style: TextStyle(
                                                    fontWeight: isRead ? FontWeight.w600 : FontWeight.bold,
                                                    fontSize: 15,
                                                    color: const Color(0xFF1B2559)
                                                  ),
                                                ),
                                              ),
                                              if (!isRead)
                                                Container(
                                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                                  decoration: BoxDecoration(color: Colors.blue.shade100, borderRadius: BorderRadius.circular(12)),
                                                  child: const Text("NEW", style: TextStyle(color: Colors.blue, fontSize: 10, fontWeight: FontWeight.bold)),
                                                ),
                                            ],
                                          ),
                                          const SizedBox(height: 6),
                                          Text(
                                            item['message'] ?? '',
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(color: Colors.grey[600], fontSize: 13, height: 1.3),
                                          ),
                                          const SizedBox(height: 10),
                                          Text(
                                            dateStr.contains('T') ? dateStr.split('T')[0] : dateStr,
                                            style: TextStyle(color: Colors.grey[400], fontSize: 11),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
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
          Icon(Icons.notifications_off_outlined, size: 65, color: Colors.grey[300]),
          const SizedBox(height: 15),
          Text(
            "Your notification feed is perfectly clear!",
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }
}