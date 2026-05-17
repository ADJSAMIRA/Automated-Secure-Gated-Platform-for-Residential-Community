import 'package:flutter/material.dart';
import 'dart:convert';
import '../services/api_service.dart';

class ManageReservationScreen extends StatefulWidget {
  final String userId; 
  const ManageReservationScreen({super.key, required this.userId});

  @override
  State<ManageReservationScreen> createState() => _ManageReservationScreenState();
}

class _ManageReservationScreenState extends State<ManageReservationScreen> {
  final Color skyBlue = const Color(0xFF4A90E2);
  final Color bgLight = const Color(0xFFF5F7FA);

  List<dynamic> sharedSpaces = [];
  List<dynamic> myReservations = [];
  bool isLoading = true;

  int? selectedSpaceId;
  String? selectedDate;
  String? selectedStartTime;
  String? selectedEndTime;
  String? inlineErrorMessage; 

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final spaces = await ApiService.getSharedSpaces();
      List<dynamic> reservations = [];
      try {
        reservations = await ApiService.getUpcomingReservations(widget.userId);
      } catch (e) {
        print("Error fetching reservations: $e");
      }

      setState(() {
        sharedSpaces = spaces;
        myReservations = reservations;
        isLoading = false;
      });
    } catch (e) {
      print("General Error: $e");
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgLight,
      appBar: AppBar(
        title: const Text("Community Services", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: isLoading 
          ? Center(child: CircularProgressIndicator(color: skyBlue))
          : RefreshIndicator(
              onRefresh: _loadData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeaderBanner(),
                    
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      child: Column(
                        children: [
                          _actionButton("Make a New Reservation", Icons.add_circle, skyBlue, Colors.white, () {
                            _resetForm();
                            _openBookingSheet();
                          }),
                          const SizedBox(height: 12),
                          _actionButton("View My Reservations", Icons.history, Colors.white, skyBlue, _showMyReservations, isBorder: true),
                        ],
                      ),
                    ),

                    const Padding(
                      padding: EdgeInsets.only(left: 25, top: 20, bottom: 10),
                      child: Text("Available Spaces", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    ),

                    sharedSpaces.isEmpty
                        ? const Center(child: Padding(
                            padding: EdgeInsets.all(40.0),
                            child: Text("No shared spaces available right now.", style: TextStyle(color: Colors.grey)),
                          ))
                        : ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            itemCount: sharedSpaces.length,
                            itemBuilder: (context, index) {
                              final space = sharedSpaces[index];
                              return _buildSpaceCardWide(space);
                            },
                          ),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildHeaderBanner() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [skyBlue, const Color(0xFF5AB9EA)]),
        borderRadius: BorderRadius.circular(25),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Icon(Icons.wb_cloudy_rounded, color: Colors.white, size: 35),
          SizedBox(height: 10),
          Text("Hello, Resident!", style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
          Text("Choose a space below to start booking.", style: TextStyle(color: Colors.white70)),
        ],
      ),
    );
  }

  Widget _actionButton(String text, IconData icon, Color bg, Color textColor, VoidCallback onTap, {bool isBorder = false}) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: bg,
        foregroundColor: textColor,
        minimumSize: const Size(double.infinity, 55),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
          side: isBorder ? BorderSide(color: skyBlue, width: 1.5) : BorderSide.none,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: 10),
          Text(text, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildSpaceCardWide(dynamic space) {
    final String name = space['name']?.toString() ?? "Space";
    
    String formatTime(dynamic time) {
      if (time == null) return "--:--";
      String t = time.toString();
      return t.length >= 5 ? t.substring(0, 5) : t;
    }

    String open = formatTime(space['openTime']);
    String close = formatTime(space['closeTime']);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8)],
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: bgLight,
            child: Icon(_getSpaceIcon(name), color: skyBlue),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 4),
                Text("Available: $open - $close", 
                     style: const TextStyle(color: Colors.green, fontSize: 13, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
          Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey.shade400),
        ],
      ),
    );
  }

  void _showMyReservations() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Text("My Reservations", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const Divider(),
            if (myReservations.isEmpty) const Expanded(child: Center(child: Text("No records found."))),
            if (myReservations.isNotEmpty)
              Expanded(
                child: ListView.builder(
                  itemCount: myReservations.length,
                  itemBuilder: (context, index) {
                    final r = myReservations[index];
                    
                    int resId = int.tryParse(r['id_Reservation']?.toString() ?? '0') ?? 0;

                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(Icons.event_available, color: skyBlue),
                      title: Text(r['space_name']?.toString() ?? "Space"),
                      subtitle: Text("${r['reservationDate']?.toString().split('T')[0] ?? ''} | ${r['startTime']?.toString().substring(0, 5) ?? '--:--'}"),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.orange, size: 20),
                            onPressed: () {
                              if (resId == 0) {
                                _showMsg("Error: Invalid Reservation ID", Colors.red);
                                return;
                              }
                              Navigator.pop(context); 
                              _openUpdateSheet(r, resId); 
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                            onPressed: () {
                              if (resId == 0) {
                                _showMsg("Error: Invalid Reservation ID", Colors.red);
                                return;
                              }
                              _deleteReservationConfirm(resId);
                            },
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _deleteReservationConfirm(int resId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: const [
            Icon(Icons.warning_amber_rounded, color: Colors.red),
            SizedBox(width: 10),
            Text("Delete Reservation", style: TextStyle(fontSize: 18)),
          ],
        ),
        content: const Text("Are you sure you want to delete this reservation?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel", style: TextStyle(color: Colors.grey))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              Navigator.pop(ctx); 
              Navigator.pop(context); 
              try {
                int parsedUserId = int.tryParse(widget.userId) ?? 0;
                final res = await ApiService.deleteReservation(resId, parsedUserId);
                
                if (res.statusCode == 200 || res.statusCode == 204) {
                  _showMsg("Reservation deleted successfully.", Colors.green);
                  _loadData();
                } else {
                  String errorMsg = "Failed to delete.";
                  try {
                    final decoded = json.decode(res.body);
                    if (decoded['message'] != null) errorMsg = decoded['message'];
                  } catch (_) {}
                  _showMsg(errorMsg, Colors.red);
                }
              } catch (e) {
                _showMsg("Error connecting to server.", Colors.red);
              }
            }, 
            child: const Text("Yes, Delete", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _openUpdateSheet(dynamic reservation, int resId) {
    int? correctSpaceId;
    try {
      var foundSpace = sharedSpaces.firstWhere((s) => s['name'] == reservation['space_name']);
      correctSpaceId = int.tryParse(foundSpace['id_space'].toString());
    } catch (e) {
      correctSpaceId = null;
    }

    setState(() {
      selectedSpaceId = correctSpaceId; 
      selectedDate = reservation['reservationDate']?.toString().split('T')[0];
      selectedStartTime = reservation['startTime'];
      selectedEndTime = reservation['endTime'];
      inlineErrorMessage = null;
    });

    _showBookingForm(isUpdate: true, reservationId: resId);
  }

  void _openBookingSheet() {
    _showBookingForm(isUpdate: false);
  }

  void _resetForm() {
    setState(() {
      selectedSpaceId = null;
      selectedDate = null;
      selectedStartTime = null;
      selectedEndTime = null;
      inlineErrorMessage = null;
    });
  }

  void _showBookingForm({required bool isUpdate, int? reservationId}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setSheetState) => Container(
          padding: EdgeInsets.only(top: 20, left: 20, right: 20, bottom: MediaQuery.of(context).viewInsets.bottom + 20),
          decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(isUpdate ? "Update Time & Date" : "New Booking", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              
              DropdownButtonFormField<int>(
                value: selectedSpaceId,
                decoration: _inputDeco("Select Space", Icons.location_on),
                items: sharedSpaces.map<DropdownMenuItem<int>>((s) => DropdownMenuItem<int>(
                  value: s['id_space'] as int,
                  child: Text(s['name'].toString())
                )).toList(),
                onChanged: isUpdate ? null : (val) => setSheetState(() {
                  selectedSpaceId = val;
                  inlineErrorMessage = null;
                }),
              ),
              const SizedBox(height: 15),
              
              _buildPickerTile(selectedDate ?? "Date", Icons.calendar_month, () async {
                DateTime? d = await showDatePicker(context: context, initialDate: DateTime.now(), firstDate: DateTime.now(), lastDate: DateTime(2027));
                if (d != null) setSheetState(() {
                  selectedDate = d.toString().split(' ')[0];
                  inlineErrorMessage = null;
                });
              }),
              const SizedBox(height: 15),
              
              Row(
                children: [
                  Expanded(child: _buildPickerTile(selectedStartTime?.substring(0, 5) ?? "Start", Icons.access_time, () async {
                    TimeOfDay? t = await showTimePicker(context: context, initialTime: TimeOfDay.now());
                    if (t != null) setSheetState(() {
                      selectedStartTime = "${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}:00";
                      inlineErrorMessage = null;
                    });
                  })),
                  const SizedBox(width: 10),
                  Expanded(child: _buildPickerTile(selectedEndTime?.substring(0, 5) ?? "End", Icons.access_time, () async {
                    TimeOfDay? t = await showTimePicker(context: context, initialTime: TimeOfDay.now());
                    if (t != null) setSheetState(() {
                      selectedEndTime = "${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}:00";
                      inlineErrorMessage = null;
                    });
                  })),
                ],
              ),
              
              if (inlineErrorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.red.shade200),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline, color: Colors.red, size: 20),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(inlineErrorMessage!, style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 13)),
                        ),
                      ],
                    ),
                  ),
                ),

              const SizedBox(height: 25),
              ElevatedButton(
                onPressed: () => isUpdate 
                    ? _submitUpdate(setSheetState, reservationId!) 
                    : _submitCreate(setSheetState),
                style: ElevatedButton.styleFrom(backgroundColor: skyBlue, minimumSize: const Size(double.infinity, 55), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
                child: Text(isUpdate ? "Save Changes" : "Confirm Reservation", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }


  Future<void> _submitUpdate(StateSetter setSheetState, int reservationId) async {
    if (selectedSpaceId == null || selectedDate == null || selectedStartTime == null || selectedEndTime == null) {
      setSheetState(() => inlineErrorMessage = "Please complete all fields.");
      return;
    }

    if (selectedStartTime!.compareTo(selectedEndTime!) >= 0) {
      setSheetState(() => inlineErrorMessage = "End time must be logically after start time.");
      return;
    }

    final data = {
      "id_space": selectedSpaceId, 
      "id_user": int.tryParse(widget.userId) ?? 0, 
      "reservationDate": selectedDate,
      "startTime": selectedStartTime,
      "endTime": selectedEndTime,
    };

    try {
      final res = await ApiService.updateReservation(reservationId, data);
      if (res.statusCode == 200 || res.statusCode == 204) {
        Navigator.pop(context);
        _showMsg("Reservation updated successfully.", Colors.green);
        _loadData();
      } else {
        String errorMsg = "Update failed.";
        try {
          final decoded = json.decode(res.body);
          if (decoded['message'] != null) errorMsg = decoded['message']; 
        } catch (_) {}
        setSheetState(() => inlineErrorMessage = errorMsg);
      }
    } catch (e) {
      setSheetState(() => inlineErrorMessage = "Connection failed!");
    }
  }

 
  Future<void> _submitCreate(StateSetter setSheetState) async {
    if (selectedSpaceId == null || selectedDate == null || selectedStartTime == null || selectedEndTime == null) {
      setSheetState(() => inlineErrorMessage = "Please complete all fields.");
      return;
    }

    if (selectedStartTime!.compareTo(selectedEndTime!) >= 0) {
      setSheetState(() => inlineErrorMessage = "End time must be logically after start time.");
      return;
    }

    final data = {
      "id_space": selectedSpaceId, 
      "id_user": int.tryParse(widget.userId) ?? 0, 
      "reservationDate": selectedDate,
      "startTime": selectedStartTime,
      "endTime": selectedEndTime,
    };

    try {
      final res = await ApiService.createReservation(data);
      if (res.statusCode == 200 || res.statusCode == 201) {
        Navigator.pop(context);
        _showMsg("Success! Reservation confirmed.", Colors.green);
        _loadData();
      } else {
        String errorMsg = "Invalid time or space is fully booked.";
        try {
          final decoded = json.decode(res.body);
          if (decoded['message'] != null) errorMsg = decoded['message']; 
        } catch (_) {}
        setSheetState(() => inlineErrorMessage = errorMsg);
      }
    } catch (e) {
      setSheetState(() => inlineErrorMessage = "Connection failed!");
    }
  }

  Widget _buildPickerTile(String text, IconData icon, VoidCallback onTap) => InkWell(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(color: bgLight, borderRadius: BorderRadius.circular(12)),
      child: Row(children: [Icon(icon, size: 18, color: skyBlue), const SizedBox(width: 10), Text(text)]),
    ),
  );

  InputDecoration _inputDeco(String hint, IconData icon) => InputDecoration(
    prefixIcon: Icon(icon, color: skyBlue),
    hintText: hint, filled: true, fillColor: bgLight,
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
  );

  IconData _getSpaceIcon(String name) {
    String n = name.toLowerCase();
    if (n.contains("bbq")) return Icons.outdoor_grill;
    if (n.contains("library") || n.contains("study")) return Icons.menu_book;
    if (n.contains("gym")) return Icons.fitness_center;
    return Icons.deck;
  }

  void _showMsg(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: color));
  }
}