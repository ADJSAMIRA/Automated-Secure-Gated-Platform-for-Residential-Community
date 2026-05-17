import 'package:flutter/material.dart';
import '../services/api_service.dart'; 
class NotificationScreen extends StatefulWidget {
  final String userId;
  const NotificationScreen({super.key, required this.userId});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  List<dynamic> notifications = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

 
  Future<void> _loadNotifications() async {
    setState(() => isLoading = true);
    final data = await ApiService.getUserNotifications(widget.userId);
    setState(() {
      notifications = data;
      isLoading = false;
    });
  }

  
  Future<void> _onNotificationTap(dynamic item, int index) async {
    final idNotification = item['id_notification'] ?? item['id'] ?? 0;
    bool isRead = item['is_read'] == 1 || item['is_read'] == true;

    if (!isRead) {
      bool success = await ApiService.markNotificationAsRead(idNotification);
      if (success) {
        setState(() {
          notifications[index]['is_read'] = true; 
        });
      }
    }
    
    _showDetailsDialog(item);
  }

 
  void _showDetailsDialog(dynamic item) {
    String rawMessage = item['message'] ?? '';
   
    String cleanMessage = rawMessage.replaceAll('"undefined"', 'your booking');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(item['title'] ?? 'Notification', style: const TextStyle(fontWeight: FontWeight.bold)),
        content: Text(cleanMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("CLOSE", style: TextStyle(fontWeight: FontWeight.bold)),
          )
        ],
      ),
    );
  }

 
  Map<String, dynamic> _getStyle(String type) {
    switch (type) {
      case 'Alert': return {'icon': Icons.warning_amber_rounded, 'color': Colors.red};
      case 'Reservation': return {'icon': Icons.event_available_rounded, 'color': Colors.green};
      case 'Event': return {'icon': Icons.celebration_rounded, 'color': Colors.orange};
      default: return {'icon': Icons.notifications_none_rounded, 'color': Colors.blue};
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text("Notifications", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black), 
          onPressed: () => Navigator.pop(context)
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.black), 
            onPressed: _loadNotifications
          )
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : notifications.isEmpty
              ? _buildEmptyState()
              : RefreshIndicator(
                  onRefresh: _loadNotifications,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(15),
                    itemCount: notifications.length,
                    itemBuilder: (context, index) {
                      final item = notifications[index];
                      final style = _getStyle(item['type'] ?? 'System');
                      bool isRead = item['is_read'] == 1 || item['is_read'] == true;
                      String createdAt = item['created_at'] ?? item['createdAt'] ?? '';
                      
                     
                      String messageText = (item['message'] ?? '').toString().replaceAll('"undefined"', 'your booking');

                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        elevation: 0,
                        color: isRead ? Colors.white : const Color(0xFFF0F5FF),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: BorderSide(color: isRead ? Colors.grey.shade200 : Colors.blue.shade100),
                        ),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: () => _onNotificationTap(item, index),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CircleAvatar(
                                  backgroundColor: (style['color'] as Color).withOpacity(0.1),
                                  child: Icon(style['icon'], color: style['color']),
                                ),
                                const SizedBox(width: 15),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                     
                                          Row(
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          Expanded(
                                            child: Text(
                                              item['title'] ?? '', 
                                              style: TextStyle(
                                                fontWeight: isRead ? FontWeight.w600 : FontWeight.bold, 
                                                fontSize: 16,
                                                color: Colors.black87,
                                              ),
                                            ),
                                          ),
                                          if (!isRead) ...[
                                            const SizedBox(width: 8),
                                            Container(
                                              width: 8, 
                                              height: 8, 
                                              decoration: const BoxDecoration(color: Colors.blue, shape: BoxShape.circle),
                                            ),
                                          ],
                                        ],
                                      ),
                                      const SizedBox(height: 6),
                                     
                                      Text(
                                        messageText, 
                                        maxLines: 2, 
                                        overflow: TextOverflow.ellipsis, 
                                        style: TextStyle(color: Colors.grey[600], fontSize: 14),
                                      ),
                                      const SizedBox(height: 10),
                                    
                                      Text(
                                        createdAt.contains('T') ? createdAt.split('T')[0] : createdAt, 
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
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.notifications_off_outlined, size: 70, color: Colors.grey[300]),
          const SizedBox(height: 15),
          Text("No notifications yet", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey[600])),
        ],
      ),
    );
  }
}