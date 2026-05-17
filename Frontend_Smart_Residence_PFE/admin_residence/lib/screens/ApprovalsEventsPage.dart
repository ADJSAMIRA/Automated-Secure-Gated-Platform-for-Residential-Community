import 'package:flutter/material.dart';
import '../services/api_service.dart';

class ApprovalsEventsPage extends StatefulWidget {
  final VoidCallback onBack; 

  const ApprovalsEventsPage({super.key, required this.onBack});

  @override
  _ApprovalsPageState createState() => _ApprovalsPageState();
}

class _ApprovalsPageState extends State<ApprovalsEventsPage> {
  late Future<List<dynamic>> _eventsFuture;

  @override
  void initState() {
    super.initState();
    _loadEvents();
  }

  void _loadEvents() {
    setState(() {
      _eventsFuture = ApiService.getPendingEvents();
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
                  icon: const Icon(Icons.arrow_back_ios, size: 20, color: Color(0xFF1B2559)),
                  onPressed: widget.onBack,
                ),
                const Text("| Event Approval Requests", 
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF1B2559))),
              ],
            ),
          ),
          
          Expanded(
            child: FutureBuilder<List<dynamic>>(
              future: _eventsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: Color(0xFF1A237E)));
                }
                if (snapshot.hasError) {
                  return Center(child: Text("Error: ${snapshot.error}", style: const TextStyle(color: Colors.red)));
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return _buildEmptyState();
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) => _buildModernEventCard(snapshot.data![index]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernEventCard(Map<String, dynamic> event) {
    final int currentId = event['id_Event'] ?? 0;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 15, offset: const Offset(0, 8))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
        
          Row(
            children: [
              CircleAvatar(
                backgroundColor: Colors.blue.shade50,
                child: const Icon(Icons.person, color: Colors.blue, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(event['organizer_name'] ?? "Resident", 
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF1B2559))),
                    Text("Submitted on: ${event['created_at']?.toString().substring(0, 10) ?? 'N/A'}", 
                        style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
                  ],
                ),
              ),
              _buildBadge("Pending Review", Colors.orange),
            ],
          ),
          const Divider(height: 30, thickness: 0.5),

         //details of event
          Text(event['title'] ?? "Untitled Event", 
              style: const TextStyle(fontSize: 19, fontWeight: FontWeight.bold, color: Color(0xFF1B2559))),
          const SizedBox(height: 8),
          Text(event['description'] ?? "No description available.", 
              style: TextStyle(color: Colors.grey.shade600, fontSize: 14, height: 1.4)),
          
          const SizedBox(height: 20),

         
          Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(color: const Color(0xFFF4F7FE), borderRadius: BorderRadius.circular(15)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _infoTile(Icons.calendar_month, "Date", event['eventDate']?.toString().substring(0, 10) ?? "N/A"),
                _infoTile(Icons.access_time, "Start", event['time'] ?? "N/A"),
                _infoTile(Icons.history, "End", event['endTime'] ?? "N/A"),
              ],
            ),
          ),

          const SizedBox(height: 25),

         
          Row(
            children: [
              Expanded(
                child: _actionButton(
                  label: "Reject",
                  icon: Icons.close_rounded,
                  color: Colors.red.shade600,
                  onTap: () => _updateStatus(currentId, 'Rejected'),
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: _actionButton(
                  label: "Approve",
                  icon: Icons.check_rounded,
                  color: Colors.green.shade600,
                  onTap: () => _updateStatus(currentId, 'Approved'),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _infoTile(IconData icon, String label, String value) {
    return Column(
      children: [
        Icon(icon, size: 18, color: const Color(0xFF1B2559)),
        const SizedBox(height: 5),
        Text(label, style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
        Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF1B2559))),
      ],
    );
  }

  Widget _actionButton({required String label, required IconData icon, required Color color, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [BoxShadow(color: color.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 18),
            const SizedBox(width: 8),
            Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
          ],
        ),
      ),
    );
  }

  Widget _buildBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
      child: Text(text, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.event_available_outlined, size: 80, color: Colors.grey.shade300),
          const SizedBox(height: 15),
          Text("No pending requests", style: TextStyle(color: Colors.grey.shade500, fontSize: 16)),
        ],
      ),
    );
  }

  void _updateStatus(int id, String status) async {
    if (id == 0) return;
    
    final result = await ApiService.manageEventStatus(id, status);
    if (!mounted) return;

    if (result['success'] == true) {
      _loadEvents();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['message'] ?? "Updated Successfully"), backgroundColor: Colors.green, behavior: SnackBarBehavior.floating),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['message'] ?? "Error occurred"), backgroundColor: Colors.red, behavior: SnackBarBehavior.floating),
      );
    }
  }
}