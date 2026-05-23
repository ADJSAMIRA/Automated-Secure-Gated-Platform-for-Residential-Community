import 'package:flutter/material.dart';
import '../services/api_service.dart';

class ApprovedEventsPage extends StatefulWidget {
  
  final VoidCallback? onBack; 

  const ApprovedEventsPage({super.key, this.onBack});

  @override
  State<ApprovedEventsPage> createState() => _ApprovedEventsPageState();
}

class _ApprovedEventsPageState extends State<ApprovedEventsPage> {
  bool isLoading = true;
  List events = [];
  final Color primaryBlue = const Color(0xFF1B2559); 
  final Color scaffoldBg = const Color(0xFFF8F9FD); 

  @override
  void initState() {
    super.initState();
    _fetchEvents();
  }

  Future<void> _fetchEvents() async {
    if (!mounted) return;
    setState(() => isLoading = true);
    
    final data = await ApiService.getApprovedEvents();
    final now = DateTime.now();

  
    final filteredData = data.where((event) {
      String? eventDateStr = event['eventDate'];
      if (eventDateStr != null) {
        DateTime? eventDate = DateTime.tryParse(eventDateStr);
        if (eventDate != null) {
          return now.difference(eventDate).inHours <= 24;
        }
      }
      return true; 
    }).toList();
    
    if (mounted) {
      setState(() {
        events = filteredData;
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
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
                  "| Approved Community Events", 
                  style: TextStyle(
                    fontSize: 22, 
                    fontWeight: FontWeight.bold, 
                    color: primaryBlue,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),

          
          Expanded(
            child: isLoading
                ? Center(child: CircularProgressIndicator(color: primaryBlue))
                : events.isEmpty
                    ? _buildEmptyState()
                    : RefreshIndicator(
                        color: primaryBlue,
                        onRefresh: _fetchEvents,
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
                          itemCount: events.length,
                          itemBuilder: (context, index) {
                            return _buildModernEventCard(events[index]);
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernEventCard(dynamic event) {
    String rawDate = event['eventDate'] ?? 'Not set';
    String cleanDate = rawDate.contains('T') ? rawDate.split('T')[0] : rawDate;

    String startTime = event['time']?.toString().substring(0, 5) ?? '--:--';
    String endTime = event['endTime']?.toString().substring(0, 5) ?? '--:--';

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20), 
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02), 
            blurRadius: 12,
            offset: const Offset(0, 5),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  event['title'] ?? "Untitled Event",
                  style: TextStyle(
                    fontSize: 18, 
                    fontWeight: FontWeight.bold, 
                    color: primaryBlue,
                  ),
                ),
              ),
              _statusBadge(event['status'] ?? "Approved"),
            ],
          ),
          const SizedBox(height: 10),
          
          Text(
            event['description'] ?? "No additional details provided.",
            style: TextStyle(
              color: Colors.grey.shade600, 
              fontSize: 14, 
              height: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          
          Row(
            children: [
              Icon(Icons.calendar_today_rounded, size: 14, color: Colors.grey.shade400),
              const SizedBox(width: 6),
              Text(cleanDate, style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
              const SizedBox(width: 25),
              Icon(Icons.access_time_rounded, size: 14, color: Colors.grey.shade400),
              const SizedBox(width: 6),
              Text(
                "$startTime - $endTime",
                style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
              ),
            ],
          ),
          
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 14),
            child: Divider(height: 1, thickness: 0.5),
          ),

          Row(
            children: [
              Icon(Icons.person_outline_rounded, size: 16, color: primaryBlue),
              const SizedBox(width: 6),
              Text(
                event['organizer_name'] ?? 'Residence Admin',
                style: TextStyle(
                  color: Colors.grey.shade800, 
                  fontWeight: FontWeight.bold, 
                  fontSize: 13,
                ),
              ),
              if (event['organizer_email'] != null || event['email'] != null) ...[
                const SizedBox(width: 20),
                Icon(Icons.mail_outline_rounded, size: 14, color: Colors.grey.shade400),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    event['organizer_email'] ?? event['email'] ?? '',
                    style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _statusBadge(String status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F5E9), 
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        status.toUpperCase(),
        style: const TextStyle(
          color: Color(0xFF2E7D32), 
          fontSize: 10, 
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.event_note_outlined, size: 70, color: Colors.grey.shade300),
          const SizedBox(height: 14),
          Text("No events found", style: TextStyle(color: Colors.grey.shade400, fontSize: 15)),
        ],
      ),
    );
  }
}