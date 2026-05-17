import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart'; 
import '../services/api_service.dart';

class ManageEventsScreen extends StatefulWidget {
  final String userId;
  const ManageEventsScreen({super.key, required this.userId});

  @override
  State<ManageEventsScreen> createState() => _ManageEventsScreenState();
}

class _ManageEventsScreenState extends State<ManageEventsScreen> {
  List myEvents = [];
  List allResidents = []; 
  List<int> selectedUserIds = []; 
  bool isLoading = true;
  bool isUpcomingSelected = false; 
  bool _inviteAll = true;

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  final TextEditingController _locationController = TextEditingController(text: "Event Hall"); 
  
  DateTime? selectedDate;
  TimeOfDay? startTime;
  TimeOfDay? endTime;

final Color skyBlue = const Color(0xFF4A90E2);

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() => isLoading = true);
    try {
      final response = await ApiService.listEvents(widget.userId);
      final residents = await ApiService.getAllResidents(); 
      if (response.statusCode == 200) {
        setState(() {
          myEvents = jsonDecode(response.body);
          allResidents = residents.where((res) => res['id_user'].toString() != widget.userId).toList();
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  Future<List> _getAttendees(String eventId) async {
    try {
      final res = await http.get(Uri.parse("${ApiService.baseUrl}/api/resident/events/$eventId/participants"));
      if (res.statusCode == 200) return jsonDecode(res.body);
    } catch (e) { print(e); }
    return [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD),
      appBar: AppBar(
        title: const Text("Manage Events", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        centerTitle: true, backgroundColor: Colors.white, elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.black), onPressed: () => Navigator.pop(context)),
      ),
      body: isLoading ? const Center(child: CircularProgressIndicator()) : Column(
        children: [
          _buildHostCard(),
          _buildTabs(),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _fetchData,
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: _getFilteredList().length,
                itemBuilder: (context, i) => _buildEventCard(_getFilteredList()[i]),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHostCard() {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: skyBlue, 
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
        
          Expanded(
            child: Row(
              children: [
            
                const Icon(Icons.celebration, color: Colors.white, size: 40),
                const SizedBox(width: 15), 
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Create your Event", 
                        style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                      Text("Share your happy moments with neighbors", 
                        style: TextStyle(color: Colors.white70, fontSize: 12)),
                    ],
                  ),
                ),
              ],
            ),
          ),
         
          IconButton(
            icon: const Icon(Icons.add_circle_outline, color: Colors.white, size: 40), 
            onPressed: () => _showEventForm()
          )
        ],
      ),
    );
  }

  Widget _buildTabs() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(children: [
        _tabBtn("My Requests", !isUpcomingSelected),
        const SizedBox(width: 10),
        _tabBtn("Upcoming", isUpcomingSelected),
      ]),
    );
  }

  Widget _tabBtn(String title, bool active) {
    return Expanded(child: InkWell(
      onTap: () => setState(() => isUpcomingSelected = (title == "Upcoming")),
      child: Container(padding: const EdgeInsets.symmetric(vertical: 15), decoration: BoxDecoration(color: active ? skyBlue : Colors.white, borderRadius: BorderRadius.circular(15), border: active ? null : Border.all(color: Colors.grey[200]!)), child: Center(child: Text(title, style: TextStyle(color: active ? Colors.white : Colors.grey, fontWeight: FontWeight.bold)))),
    ));
  }

  Widget _buildEventCard(dynamic event) {
    bool isMyEvent = event['organizer_id'].toString() == widget.userId;
    String organizer = event['organizer_name'] ?? event['fullName'] ?? "Resident";

    return GestureDetector(
      onTap: () => _showEventDetails(event),
      child: Container(
        margin: const EdgeInsets.only(bottom: 15),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.grey[100]!)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text(event['title'] ?? "No Title", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            if (isMyEvent) _statusBadge(event['status'] ?? "Pending"),
          ]),
          const SizedBox(height: 10),
          Row(children: [Icon(Icons.person, size: 16, color: skyBlue), const SizedBox(width: 8), Text(organizer)]),
          const SizedBox(height: 5),
          Row(children: [const Icon(Icons.location_on, size: 16, color: Colors.red), const SizedBox(width: 8), Text(event['location'] ?? "Event Hall")]),
        ]),
      ),
    );
  }

  Widget _statusBadge(String status) {
    Color c = status == "Approved" ? Colors.green : Colors.orange;
    return Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: c.withOpacity(0.1), borderRadius: BorderRadius.circular(8)), child: Text(status, style: TextStyle(color: c, fontSize: 10, fontWeight: FontWeight.bold)));
  }

  void _showEventDetails(dynamic event) async {
    bool isOwner = event['organizer_id'].toString() == widget.userId;
    List attendees = await _getAttendees(event['id_Event'].toString());

    showModalBottomSheet(
      context: context, isScrollControlled: true, shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
      builder: (context) => Container(
        padding: const EdgeInsets.all(25),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(event['title'] ?? "No Title", style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          Text("Hosted by: ${event['organizer_name'] ?? 'Resident'}", style: TextStyle(color: skyBlue)),
          const Divider(height: 30),
          const Text("Attendees joined:", style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          attendees.isEmpty 
            ? const Text("No attendees yet", style: TextStyle(color: Colors.grey))
            : Wrap(spacing: 8, children: attendees.map((a) => Chip(label: Text(a['fullName'] ?? 'User'), backgroundColor: skyBlue.withOpacity(0.1))).toList()),
          const SizedBox(height: 30),
          if (isOwner) 
            Row(children: [
              Expanded(child: OutlinedButton(onPressed: () { Navigator.pop(context); _showEventForm(isEdit: true, event: event); }, child: const Text("Edit"))),
              const SizedBox(width: 10),
              Expanded(child: ElevatedButton(onPressed: () => _handleDelete(event['id_Event'].toString()), style: ElevatedButton.styleFrom(backgroundColor: Colors.red), child: const Text("Delete"))),
            ])
          else 
            ElevatedButton(onPressed: () => _handleJoin(event['id_Event'].toString()), style: ElevatedButton.styleFrom(backgroundColor: skyBlue, minimumSize: const Size(double.infinity, 50)), child: const Text("Join Event", style: TextStyle(color: Colors.white))),
        ]),
      ),
    );
  }

  void _showEventForm({bool isEdit = false, dynamic event}) {
    if (isEdit) {
      _titleController.text = event['title'] ?? "";
      _descController.text = event['description'] ?? "";
      selectedDate = event['eventDate'] != null ? DateTime.parse(event['eventDate']) : DateTime.now();
      _inviteAll = event['isPublic'] == 1 || event['isPublic'] == true;
      try {
        String? timeStr = event['time'] ?? event['startTime'];
        if(timeStr != null) {
          final parts = timeStr.split(':');
          startTime = TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
        }
      } catch(e) {}
    } else {
      _titleController.clear(); _descController.clear();
      selectedDate = null; startTime = null; endTime = null; _inviteAll = true; selectedUserIds = [];
    }

    showModalBottomSheet(
      context: context, isScrollControlled: true, shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
      builder: (context) => StatefulBuilder(builder: (context, setModalState) => Container(
        height: MediaQuery.of(context).size.height * 0.85,
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 25, right: 25, top: 25),
        child: SingleChildScrollView(
          child: Column(children: [
            Text(isEdit ? "Update Event" : "Create Event", style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            _buildField(_titleController, "Title", Icons.title),
            _buildField(_descController, "Description", Icons.notes),
            _buildField(_locationController, "Location", Icons.location_on, enabled: false), 
            
            _buildTile("Date", selectedDate == null ? "Select Date" : DateFormat('yyyy-MM-dd').format(selectedDate!), Icons.calendar_today, () async {
              DateTime? p = await showDatePicker(context: context, initialDate: DateTime.now(), firstDate: DateTime.now(), lastDate: DateTime(2030));
              if (p != null) setModalState(() => selectedDate = p);
            }),

            Row(children: [
              Expanded(child: _buildTile("Start", startTime == null ? "Set" : startTime!.format(context), Icons.access_time, () async {
                TimeOfDay? t = await showTimePicker(context: context, initialTime: TimeOfDay.now());
                if (t != null) setModalState(() => startTime = t);
              })),
              Expanded(child: _buildTile("End", endTime == null ? "Set" : endTime!.format(context), Icons.timer_off, () async {
                TimeOfDay? t = await showTimePicker(context: context, initialTime: TimeOfDay.now());
                if (t != null) setModalState(() => endTime = t);
              })),
            ]),
            
            SwitchListTile(title: const Text("Invite Everyone"), value: _inviteAll, activeColor: skyBlue, onChanged: (v) => setModalState(() => _inviteAll = v)),
            
            if (!_inviteAll) ...[
              const Align(alignment: Alignment.centerLeft, child: Text("Select Neighbors:", style: TextStyle(fontWeight: FontWeight.bold))),
              Container(
                height: 180, decoration: BoxDecoration(border: Border.all(color: Colors.grey[200]!), borderRadius: BorderRadius.circular(15)),
                child: allResidents.isEmpty ? const Center(child: Text("Loading...")) : ListView.builder(
                  itemCount: allResidents.length,
                  itemBuilder: (context, idx) {
                    final res = allResidents[idx];
                    final rid = int.parse(res['id_user'].toString());
                    return CheckboxListTile(
                      title: Text(res['fullName'] ?? "Resident"),
                      value: selectedUserIds.contains(rid),
                      onChanged: (v) => setModalState(() { v! ? selectedUserIds.add(rid) : selectedUserIds.remove(rid); }),
                    );
                  }
                ),
              )
            ],
            const SizedBox(height: 25),
            ElevatedButton(
            onPressed: () {
  if (isEdit) {
    _handleUpdate(event); 
  } else {
    _submitForm(false, null); 
  }
},
              style: ElevatedButton.styleFrom(backgroundColor: skyBlue, minimumSize: const Size(double.infinity, 55), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
              child: Text(isEdit ? "Update Event" : "Post Event", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ]),
        ),
      )),
    );
  }

  Widget _buildField(TextEditingController ctrl, String label, IconData icon, {bool enabled = true}) {
    return Padding(padding: const EdgeInsets.only(bottom: 15), child: TextField(controller: ctrl, enabled: enabled, decoration: InputDecoration(labelText: label, prefixIcon: Icon(icon, color: skyBlue), border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)))));
  }

  Widget _buildTile(String label, String val, IconData icon, VoidCallback tap) {
    return ListTile(contentPadding: EdgeInsets.zero, leading: Icon(icon, color: skyBlue), title: Text(label, style: const TextStyle(fontSize: 12)), subtitle: Text(val, style: const TextStyle(fontWeight: FontWeight.bold)), onTap: tap);
  }

  void _submitForm(bool isEdit, dynamic oldEvent) async {
    if (selectedDate == null || startTime == null) {
      _showSnackBar("Please set date and start time", Colors.orange);
      return;
    }

    String formattedDate = DateFormat('yyyy-MM-dd').format(selectedDate!);
    String formattedStartTime = "${startTime!.hour.toString().padLeft(2, '0')}:${startTime!.minute.toString().padLeft(2, '0')}:00";
    String formattedEndTime = endTime != null 
        ? "${endTime!.hour.toString().padLeft(2, '0')}:${endTime!.minute.toString().padLeft(2, '0')}:00"
        : "22:00:00";

    String newStatus = oldEvent != null ? (oldEvent['status'] ?? "Approved") : "Pending";

    if (isEdit) {
      String oldDate = oldEvent['eventDate'].toString().split('T')[0];
      String oldTime = oldEvent['time'] ?? oldEvent['startTime'] ?? "";
      if (formattedDate != oldDate || formattedStartTime != oldTime) {
        newStatus = "Pending"; 
      }
    }

    
    final data = {
      "title": _titleController.text,
      "description": _descController.text,
      "eventDate": formattedDate,
      "time": formattedStartTime, 
      "endTime": formattedEndTime,
      "organizer_id": int.parse(widget.userId), 
      "isPublic": _inviteAll ? 1 : 0,
      "invitedUsers": selectedUserIds,
      "status": newStatus
    };

    try {
      http.Response res;
      if (isEdit) {
        res = await http.put(
          Uri.parse("${ApiService.baseUrl}/api/resident/events/${oldEvent['id_Event']}"),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode(data),
        );
      } else {
        res = await ApiService.createEvent(data);
      }

      if (res.statusCode == 200 || res.statusCode == 201) {
        _showSnackBar(newStatus == "Pending" ? "Sent for Admin approval!" : "Done!", Colors.green);
        _fetchData();
        Navigator.pop(context);
      } else {
        print("Backend Error: ${res.body}");
        _showSnackBar("Failed: ${jsonDecode(res.body)['error'] ?? 'Error'}", Colors.red);
      }
    } catch (e) {
      print("Flutter Error: $e");
      _showSnackBar("Connection error", Colors.red);
    }
  }

  void _handleJoin(String id) async {
    final res = await http.post(Uri.parse('${ApiService.baseUrl}/api/resident/events/join'), headers: {'Content-Type': 'application/json'}, body: jsonEncode({'eventId': id, 'userId': widget.userId}));
    if (res.statusCode == 200 || res.statusCode == 201)
     { _showSnackBar("Joined successfully", Colors.green);
      _fetchData(); Navigator.pop(context); }
  }

void _handleUpdate(dynamic event) async {
  try {
   
    final int eId = int.parse(event['id_Event'].toString());
    final int uId = int.parse(widget.userId.toString());

   
    final Map<String, dynamic> updateData = {
      "id_Event": eId, 
      "title": _titleController.text.trim(),
      "description": _descController.text.trim(),
      "eventDate": DateFormat('yyyy-MM-dd').format(selectedDate!),
      "time": "${startTime!.hour.toString().padLeft(2, '0')}:${startTime!.minute.toString().padLeft(2, '0')}:00",
      "endTime": endTime != null 
          ? "${endTime!.hour.toString().padLeft(2, '0')}:${endTime!.minute.toString().padLeft(2, '0')}:00" 
          : "23:59:00",
      "isPublic": _inviteAll ? 1 : 0,
      "organizer_id": uId, 
      "status": "Pending" 
    };

    print("Sending Update Request for Event ID: $eId by User: $uId");

    final response = await http.put(
      Uri.parse("${ApiService.baseUrl}/api/resident/events/$eId"),
      headers: {
        "Content-Type": "application/json",
        "Accept": "application/json"
      },
      body: jsonEncode(updateData),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      _showSnackBar("Event updated! Waiting for approval.", Colors.green);
      _fetchData();
      Navigator.pop(context);
    } else {
     
      print("Server Response: ${response.body}");
      final msg = jsonDecode(response.body)['message'] ?? "Unauthorized";
      _showSnackBar("Error: $msg", Colors.red);
    }
  } catch (e) {
    print("Flutter Error: $e");
    _showSnackBar("Fill all fields correctly", Colors.red);
  }
}
  void _handleDelete(String id) async {
    final res = await ApiService.deleteEvent(id, widget.userId);
    if (res.statusCode == 200) {
      _showSnackBar("Deleted successfully", Colors.green);
      _fetchData();
      Navigator.pop(context);
    }
  }

  List _getFilteredList() {
    if (isUpcomingSelected) return myEvents.where((e) => e['organizer_id'].toString() != widget.userId && e['status'] == "Approved").toList();
    return myEvents.where((e) => e['organizer_id'].toString() == widget.userId).toList();
  }

  void _showSnackBar(String m, Color c) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(m), backgroundColor: c));
}