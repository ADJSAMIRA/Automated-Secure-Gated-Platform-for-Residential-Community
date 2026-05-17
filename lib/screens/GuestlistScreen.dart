import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'package:intl/intl.dart';

class GuestListScreen extends StatefulWidget {
  final VoidCallback onBack; 

  const GuestListScreen({super.key, required this.onBack});

  @override
  State<GuestListScreen> createState() => _GuestListScreenState();
}

class _GuestListScreenState extends State<GuestListScreen> {
  bool isLoading = true;
  List guests = [];

  
  static const Color primaryBlue = Color(0xFF1B2559);
  static const Color successGreen = Color(0xFF4CAF50);
  static const Color scaffoldBg = Color(0xFFF8F9FD);

  @override
  void initState() {
    super.initState();
    _loadGuests();
  }

  Future<void> _loadGuests() async {
    if (!mounted) return;
    setState(() => isLoading = true);
    
    try {
      final data = await ApiService.getAllGuestsForAdmin();
      if (mounted) {
        setState(() {
          guests = data;
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => isLoading = false);
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
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios_rounded, color: primaryBlue, size: 20),
                  onPressed: widget.onBack, 
                ),
                const SizedBox(width: 4),
                const Text(
                  "| Active Guest List", 
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: primaryBlue, letterSpacing: 0.5),
                ),
              ],
            ),
          ),

         
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 5),
            child: Text(
              "Monitoring all active entries and parking spots", 
              style: TextStyle(color: Colors.grey[500], fontSize: 14),
            ),
          ),
          
          const SizedBox(height: 10),

          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator(color: primaryBlue))
                : RefreshIndicator(
                    color: primaryBlue,
                    onRefresh: _loadGuests,
                    child: guests.isEmpty
                        ? _buildEmptyState()
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
                            itemCount: guests.length,
                            itemBuilder: (context, index) => _buildGuestCard(guests[index]),
                          ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildGuestCard(dynamic guest) {
    String formattedDate = "N/A";
    try {
      if (guest['visit_date'] != null) {
        DateTime dt = DateTime.parse(guest['visit_date'].toString());
        formattedDate = DateFormat('EEE, MMM d, yyyy').format(dt);
      }
    } catch (e) {
      formattedDate = guest['visit_date'].toString();
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: const Border(left: BorderSide(color: successGreen, width: 6)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.015), blurRadius: 15, offset: const Offset(0, 4))
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        guest['guest_name'] ?? "Unknown Guest",
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: primaryBlue),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        guest['guest_phone'] ?? "No phone number",
                        style: TextStyle(color: Colors.grey[400], fontSize: 13),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: successGreen.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Text(
                    "ACTIVE", 
                    style: TextStyle(color: successGreen, fontWeight: FontWeight.bold, fontSize: 10, letterSpacing: 1),
                  ),
                )
              ],
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 15),
              child: Divider(height: 1, thickness: 0.5),
            ),
            
            Row(
              children: [
                _buildInfoBlock(Icons.person_pin_rounded, "Host Resident", guest['resident_name'] ?? "N/A"),
                _buildInfoBlock(Icons.location_on_rounded, "Location", 
                    "B ${guest['blockNumber'] ?? '-'} / Apt ${guest['apartment_number'] ?? '-'}"),
              ],
            ),
            const SizedBox(height: 15),

            Row(
              children: [
                _buildInfoBlock(Icons.calendar_month_rounded, "Visit Date", formattedDate),
                _buildInfoBlock(Icons.timer_outlined, "Time & Duration", 
                    "${guest['visit_time'] ?? '--:--'} (${guest['duration_hours'] ?? '0'}h)"),
              ],
            ),
            
            if (guest['spot_number'] != null)
              Container(
                margin: const EdgeInsets.only(top: 15),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF8E1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.orange.withOpacity(0.15)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.directions_car_filled_rounded, color: Colors.orange, size: 18),
                    const SizedBox(width: 10),
                    Text(
                      "Parking Spot: ${guest['spot_number']}",
                      style: const TextStyle(color: Color(0xFFE65100), fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                  ],
                ),
              ),
            
            const SizedBox(height: 15),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF4F7FE),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("SECURITY TOKEN", style: TextStyle(color: Colors.grey.shade400, fontSize: 10, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(
                    guest['qr_code_token'] ?? "NOT-GENERATED",
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: primaryBlue, letterSpacing: 1),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoBlock(IconData icon, String label, String value) {
    return Expanded(
      child: Row(
        children: [
          Icon(icon, color: primaryBlue.withOpacity(0.4), size: 18),
          const SizedBox(width: 8),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(color: Colors.grey.shade400, fontSize: 10, fontWeight: FontWeight.w600)),
                Text(
                  value, 
                  maxLines: 1, 
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: primaryBlue),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.people_outline_rounded, size: 70, color: Colors.grey.shade300),
          const SizedBox(height: 14),
          Text("No active guests found", style: TextStyle(color: Colors.grey.shade400, fontSize: 15)),
        ],
      ),
    );
  }
}