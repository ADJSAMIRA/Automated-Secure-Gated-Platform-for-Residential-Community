import 'package:flutter/material.dart';
import '../services/api_service.dart';

class ActiveResidentsScreen extends StatefulWidget {
  final VoidCallback onBack; 

  const ActiveResidentsScreen({super.key, required this.onBack});

  @override
  State<ActiveResidentsScreen> createState() => _ActiveResidentsScreenState();
}

class _ActiveResidentsScreenState extends State<ActiveResidentsScreen> {
  List residents = [];
  bool isLoading = true;

  final Color primaryBlue = const Color(0xFF1B2559);
  final Color scaffoldBg = const Color(0xFFF8F9FD);

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => isLoading = true);
    try {
      final data = await ApiService.getActiveResidents();
      setState(() {
        residents = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: scaffoldBg,
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
                const Text("| Active Residents List", 
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF1B2559))),
              ],
            ),
          ),

          
          _buildHeaderSummary(),

          Expanded(
            child: isLoading
                ? Center(child: CircularProgressIndicator(color: primaryBlue))
                : residents.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        itemCount: residents.length,
                        itemBuilder: (context, index) => _buildModernResidentCard(residents[index]),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderSummary() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1A237E), Color(0xFF3949AB)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(color: const Color(0xFF1A237E).withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 10))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Total Residents In Residence", 
              style: TextStyle(color: Colors.white70, fontSize: 16, fontWeight: FontWeight.w500)),
          const SizedBox(height: 5),
          Text("${residents.length}", 
              style: const TextStyle(color: Colors.white, fontSize: 40, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildModernResidentCard(dynamic resident) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 15, offset: const Offset(0, 5))
        ],
      ),
      child: Row(
        children: [
         
          CircleAvatar(
            radius: 30,
            backgroundColor: const Color(0xFFF4F7FE),
            child: Text(
              resident['fullName']?.substring(0, 1).toUpperCase() ?? "R",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: primaryBlue),
            ),
          ),
          const SizedBox(width: 15),
          
          // info of residnet
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      resident['fullName'] ?? "Resident",
                      style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: primaryBlue),
                    ),
                    _buildStatusBadge(),
                  ],
                ),
                const SizedBox(height: 8),
                _infoRow(Icons.mail_outline, resident['email'] ?? "No email provided"),
                const SizedBox(height: 4),
                _infoRow(Icons.phone_iphone, resident['phoneNumber'] ?? "N/A"),
                const SizedBox(height: 4),
                _infoRow(Icons.apartment, "Apartment: ${resident['apartmentNumber'] ?? '?'}"),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 14, color: Colors.grey.shade400),
        const SizedBox(width: 8),
        Text(text, style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
      ],
    );
  }

  Widget _buildStatusBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Text("ACTIVE", 
          style: TextStyle(color: Colors.green, fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.people_outline, size: 80, color: Colors.grey.shade200),
          const SizedBox(height: 15),
          Text("No active residents", style: TextStyle(color: Colors.grey.shade400, fontSize: 16)),
        ],
      ),
    );
  }
}