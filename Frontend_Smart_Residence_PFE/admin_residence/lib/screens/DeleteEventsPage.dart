import 'package:flutter/material.dart';
import '../services/api_service.dart';

class DeleteEventsPage extends StatefulWidget {
  final VoidCallback onBack;

  const DeleteEventsPage({super.key, required this.onBack});

  @override
  _DeleteEventsPageState createState() => _DeleteEventsPageState();
}

class _DeleteEventsPageState extends State<DeleteEventsPage> {
  late Future<List<dynamic>> _eventsFuture;
  
  
  final Color primaryBlue = const Color(0xFF1B2559);
  final Color dangerColor = const Color(0xFFE53935);
  final Color lightGrayBg = const Color(0xFFF4F7FE);

  @override
  void initState() {
    super.initState();
    _loadEvents();
  }

  void _loadEvents() {
    setState(() {
      _eventsFuture = ApiService.getApprovedEvents(); 
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF8F9FD),
      child: Column(
        children: [
        
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
            child: Row(
              children: [
                IconButton(
                  icon: Icon(Icons.arrow_back_ios, size: 20, color: primaryBlue),
                  onPressed: widget.onBack,
                ),
                Text("| Remove Events", 
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: primaryBlue)),
              ],
            ),
          ),

          Expanded(
            child: FutureBuilder<List<dynamic>>(
              future: _eventsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) 
                  return Center(child: CircularProgressIndicator(color: primaryBlue));
                
                if (snapshot.hasError) 
                  return Center(child: Text("Error: ${snapshot.error}", style: const TextStyle(color: Colors.red)));

                if (!snapshot.hasData || snapshot.data!.isEmpty) 
                  return _buildEmptyState();

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 10),
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) => _buildModernDeleteCard(snapshot.data![index]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernDeleteCard(Map<String, dynamic> event) {
    String organizerName = event['organizer_name'] ?? "Unknown";
    String eventDate = event['eventDate']?.split('T')[0] ?? 'No Date';
    String startTime = event['time'] ?? '00:00'; 
    String endTime = event['endTime'] ?? '00:00';
    bool isAdminEvent = event['organizer_role']?.toString().toLowerCase() == 'admin';

    return Container(
      margin: const EdgeInsets.only(bottom: 20, left: 15, right: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 15,
            offset: const Offset(0, 8),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                   
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: isAdminEvent ? const Color(0xFFE3F2FD) : const Color(0xFFF1F3F4),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        isAdminEvent ? "Admin Event" : "Resident Event",
                        style: TextStyle(
                          color: isAdminEvent ? const Color(0xFF2196F3) : Colors.grey[700],
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    
                   
                    InkWell(
                      onTap: () => _confirmDelete(event['id_Event'], event['title'] ?? 'this event'),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFEBEE),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.delete_outline_rounded, color: dangerColor, size: 18),
                            const SizedBox(width: 6),
                            Text("Delete", 
                              style: TextStyle(color: dangerColor, fontWeight: FontWeight.bold, fontSize: 14)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 12),
                
                Text(
                  event['title'] ?? 'Untitled Event',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 19, color: primaryBlue),
                ),
                const SizedBox(height: 4),
                Text("By: $organizerName", style: TextStyle(color: Colors.grey.shade500, fontSize: 13)),
                
                const SizedBox(height: 20),

               
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                  decoration: BoxDecoration(
                    color: lightGrayBg, 
                    borderRadius: BorderRadius.circular(15), 
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildInfoItem(Icons.calendar_month_outlined, "Date", eventDate),
                      _buildInfoItem(Icons.access_time_rounded, "Start", startTime),
                    
                      _buildInfoItem(Icons.history, "End", endTime),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String label, String value) {
    return Column(
      children: [
        Icon(icon, size: 18, color: primaryBlue.withOpacity(0.6)),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(color: Colors.grey.shade500, fontSize: 10)),
        Text(
          value,
          style: TextStyle(color: primaryBlue, fontWeight: FontWeight.bold, fontSize: 12),
        ),
      ],
    );
  }

  void _confirmDelete(dynamic eventId, String title) {
    if (eventId == null) return;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Confirm Action"),
        content: Text("Are you sure you want to delete '$title' permanently?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () async {
              final result = await ApiService.manageEventStatus(eventId, 'Deleted');
              if (result['success'] == true) {
                if (!mounted) return;
                Navigator.pop(context);
                _loadEvents();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Event deleted successfully"), 
                    backgroundColor: Colors.green, 
                    behavior: SnackBarBehavior.floating
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: dangerColor, 
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))
            ),
            child: const Text("Delete", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(Icons.delete_sweep_outlined, size: 80, color: Colors.grey.shade200),
          const SizedBox(height: 15),
          Text("No events found", style: TextStyle(color: Colors.grey.shade400, fontSize: 16)),
      ]),
    );
  }
}