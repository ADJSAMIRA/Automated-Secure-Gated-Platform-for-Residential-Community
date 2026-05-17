import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../services/api_service.dart';

class GuestScreen extends StatefulWidget {
  final String apartmentId;
  const GuestScreen({super.key, required this.apartmentId});

  @override
  State<GuestScreen> createState() => _GuestScreenState();
}

class _GuestScreenState extends State<GuestScreen> {
  List<dynamic> _guests = [];
  bool _isLoadingList = true;

  @override
  void initState() {
    super.initState();
    _fetchGuests(); 
  }

 Future<void> _fetchGuests() async {
  setState(() => _isLoadingList = true);
  try {
    final data = await ApiService.getMyGuests(widget.apartmentId);
    
    
    print("Fetched Guests: $data"); 
    
    setState(() {
      _guests = data;
      _isLoadingList = false;
    });
  } catch (e) {
    setState(() => _isLoadingList = false);
    print("Fetch Error: $e");
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      appBar: AppBar(
        title: const Text("Guest Management", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent, elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.black), onPressed: () => Navigator.pop(context)),
       // actions: [
         // IconButton(onPressed: _fetchGuests, icon: const Icon(Icons.refresh, color: Colors.blue))
        //],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Card
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(24),
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFF64B5F6), Color(0xFF2196F3)]),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.person_add_alt_1, color: Colors.white, size: 40),
                const SizedBox(height: 12),
                const Text("Hello, Resident!", style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                Text("Manage your guest invitations here.", style: TextStyle(color: Colors.white.withOpacity(0.9))),
              ],
            ),
          ),


          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: InkWell(
              onTap: () => _openRegisterForm(context),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 15),
                decoration: BoxDecoration(color: Colors.blue, borderRadius: BorderRadius.circular(15)),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add_circle_outline, color: Colors.white),
                    SizedBox(width: 10),
                    Text("Invite New Guest", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
          ),

          const Padding(
            padding: EdgeInsets.only(left: 20, top: 25, bottom: 10),
            child: Text("My Guest List", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ),

          // get list dirct
         Expanded(
  child: _isLoadingList
      ? const Center(child: CircularProgressIndicator())
      : RefreshIndicator(
          onRefresh: _fetchGuests, 
          child: _guests.isEmpty
              ? const Center(child: Text("No invitations found."))
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _guests.length,
                  itemBuilder: (context, index) => _buildGuestCard(_guests[index]),
                ),
        ),
),
        ],
      ),
    );
  }

  Widget _buildGuestCard(dynamic guest) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
    child: Column(
      children: [
       Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: const Color(0xFFE3F2FD),
              child: const Icon(Icons.person, color: Color(0xFF2196F3), size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    guest['guest_name'] ?? "Unknown",
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  Text(
                    guest['guest_phone'] ?? "No Phone",
                    style: TextStyle(color: Colors.grey[600], fontSize: 13),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: const Color(0xFFE8F5E9),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                guest['status'] ?? "Accepted",
                style: const TextStyle(color: Color(0xFF2E7D32), fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        const Divider(height: 30),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
          
            _infoDetail(Icons.calendar_today, "Date", guest['requestTime'].toString().split('T')[0]),
            _infoDetail(Icons.access_time, "Time", guest['visit_time'] ?? "--:--"),
            _infoDetail(Icons.timer_outlined, "Duration", "${guest['duration_hours']}h"),
            
            _infoDetail(Icons.local_parking, "Spot", guest['spot_number'] ?? "None"),
          ],
        ),
          // button QR
          SizedBox(
            width: double.infinity,
            height: 45,
            child: ElevatedButton.icon(
              onPressed: () => _viewQR(guest),
              icon: const Icon(Icons.qr_code_scanner, size: 20),
              label: const Text("View Access Card", style: TextStyle(fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1A237E), // نفس لون الـ Resident Card
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  
  Widget _infoDetail(IconData icon, String label, String value) {
    return Column(
      children: [
        Icon(icon, size: 18, color: Colors.blue[300]),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 10)),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
      ],
    );
  }

  void _openRegisterForm(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => RegisterGuestSheet(
        apartmentId: widget.apartmentId,
        onSuccess: _fetchGuests, 
      ),
    );
  }

  void _viewQR(dynamic guest) {
  
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GuestInvitationCard(
          guestName: guest['guest_name'],
          token: guest['qr_code_token'],
          parkingSpot: guest['spot_number'],
          visitDate: guest['requestTime'].toString().split('T')[0],
        ),
      ),
    );
  }
}

// formule
class RegisterGuestSheet extends StatefulWidget {
  final String apartmentId;
  final VoidCallback onSuccess;
  const RegisterGuestSheet({super.key, required this.apartmentId, required this.onSuccess});

  @override
  State<RegisterGuestSheet> createState() => _RegisterGuestSheetState();
}

class _RegisterGuestSheetState extends State<RegisterGuestSheet> {
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _durCtrl = TextEditingController(text: "2");
  DateTime? _date;
  TimeOfDay? _time;
  bool _parking = false;
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 20, right: 20, top: 20),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("New Invitation", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            _field("Full Name", _nameCtrl, Icons.person),
            _field("Phone", _phoneCtrl, Icons.phone, isNum: true),
            Row(
              children: [
                Expanded(child: _tile(_date == null ? "Date" : DateFormat('yyyy-MM-dd').format(_date!), Icons.event, () async {
                  DateTime? p = await showDatePicker(context: context, initialDate: DateTime.now(), firstDate: DateTime.now(), lastDate: DateTime(2027));
                  if (p != null) setState(() => _date = p);
                })),
                const SizedBox(width: 10),
                Expanded(child: _tile(_time == null ? "Time" : _time!.format(context), Icons.schedule, () async {
                  TimeOfDay? t = await showTimePicker(context: context, initialTime: TimeOfDay.now());
                  if (t != null) setState(() => _time = t);
                })),
              ],
            ),
            const SizedBox(height: 10),
            _field("Duration (Hours)", _durCtrl, Icons.timer, isNum: true),
            SwitchListTile(
              title: const Text("Parking Required?"),
              value: _parking,
              onChanged: (v) => setState(() => _parking = v),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity, height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                onPressed: _loading ? null : _submit,
                child: _loading ? const CircularProgressIndicator(color: Colors.white) : const Text("Confirm & Generate QR", style: TextStyle(color: Colors.white)),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _field(String l, TextEditingController c, IconData i, {bool isNum = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: c,
        keyboardType: isNum ? TextInputType.number : TextInputType.text,
        decoration: InputDecoration(labelText: l, prefixIcon: Icon(i), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
      ),
    );
  }

  Widget _tile(String t, IconData i, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(12)),
        child: Row(children: [Icon(i, size: 18, color: Colors.blue), const SizedBox(width: 8), Text(t)]),
      ),
    );
  }

 Future<void> _submit() async {
  if (_nameCtrl.text.isEmpty || _date == null || _time == null) return;
  
  setState(() => _loading = true);
  
  
  final res = await ApiService.registerGuest({
    "apartment_id": int.parse(widget.apartmentId), // تحويل لرقم
    "guest_name": _nameCtrl.text,
    "guest_phone": _phoneCtrl.text.isEmpty ? "None" : _phoneCtrl.text,
    "visit_date": DateFormat('yyyy-MM-dd').format(_date!),
    "visit_time": _time!.format(context),
    "duration": int.tryParse(_durCtrl.text) ?? 2,
    "needs_parking": _parking 
  });

  if (res['success'] == true) {
    widget.onSuccess();
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Invitation Sent!"), backgroundColor: Colors.green),
    );
  } else {
  
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(res['message'] ?? "Error occurred")),
    );
  }
  
  if (mounted) setState(() => _loading = false);
}
}


class GuestInvitationCard extends StatelessWidget {
  final String guestName;
  final String token;
  final String? parkingSpot;
  final String visitDate;

  const GuestInvitationCard({super.key, required this.guestName, required this.token, this.parkingSpot, required this.visitDate});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A237E),
      appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0, iconTheme: const IconThemeData(color: Colors.white)),
      body: Center(
        child: Container(
          margin: const EdgeInsets.all(20),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(25)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("SCAN AT GATE", style: TextStyle(letterSpacing: 2, fontWeight: FontWeight.bold, color: Colors.grey)),
              const SizedBox(height: 20),
              QrImageView(data: "https://adjsamira.github.io/smartgate-pfe/?token=$token", size: 200),
              const Divider(height: 40),
              _row("Guest", guestName),
              _row("Date", visitDate),
              _row("Parking", parkingSpot ?? "None"),
            ],
          ),
        ),
      ),
    );
  }

  Widget _row(String l, String v) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(l, style: const TextStyle(color: Colors.grey)), Text(v, style: const TextStyle(fontWeight: FontWeight.bold))]),
    );
  }
}