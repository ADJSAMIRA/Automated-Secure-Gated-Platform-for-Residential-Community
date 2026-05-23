import 'package:flutter/material.dart';
import 'package:residenceapp/screens/AlertsScreen.dart';
import 'package:residenceapp/screens/ConversationScreen.dart';
import 'package:residenceapp/screens/GuestScreen.dart';
import 'package:residenceapp/screens/ManageReservationsScreen.dart';
import 'package:residenceapp/screens/ParkingScreen.dart';
import 'dart:convert';
import '../services/api_service.dart'; 
import 'package:residenceapp/screens/AccessCardScreen.dart';
import 'ManageEventsScreen.dart'; 
import 'package:residenceapp/screens/NotificationScreen.dart'; 
import 'package:overlay_support/overlay_support.dart';
import 'CommunityFeedScreen.dart';

class ResidentHomeScreen extends StatefulWidget {
  final String userName;
  final String userId;
  final String apartmentNo;

  static String? currentLoggedInUserId;
  static ValueNotifier<bool> notificationNotifier = ValueNotifier<bool>(false);

  const ResidentHomeScreen({
    super.key,
    required this.userName,
    required this.userId,
    required this.apartmentNo,
  });

  @override
  State<ResidentHomeScreen> createState() => _ResidentHomeScreenState();
}

class _ResidentHomeScreenState extends State<ResidentHomeScreen> {
  int _selectedIndex = 0;
  Map<String, dynamic> stats = {
    "activeGuests": "...",
    "upcomingEvents": "...",
    "pendingAlerts": "...",
    "unreadMessages": "..."
  };
  String currentApt = "Loading...";
  String currentBlock = "A";
  bool hasNewNotifications = false;

  @override
  void initState() {
    super.initState();
    ResidentHomeScreen.currentLoggedInUserId = widget.userId; 
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final statsRes = await ApiService.getResidentStats(widget.userId);
      final profileRes = await ApiService.getResidentProfile(widget.userId);

      if (statsRes.statusCode == 200) {
        setState(() {
          stats = jsonDecode(statsRes.body)['data'];
        });
      }
      if (profileRes.statusCode == 200) {
        final profileData = jsonDecode(profileRes.body)['data'];
        setState(() {
          currentApt = profileData['apartmentNumber'].toString();
          currentBlock = profileData['blockNumber'] ?? "A";
        });
      }

      final notifications = await ApiService.getUserNotifications(widget.userId);
      if (notifications.isNotEmpty) {
        final unreadNotification = notifications.firstWhere(
          (item) => item['is_read'] == false || item['is_read'] == 0,
          orElse: () => null,
        );

        setState(() {
          hasNewNotifications = unreadNotification != null;
        });

        if (unreadNotification != null) {
          _showTopNotificationBanner(unreadNotification);
        }
      } else {
        setState(() {
          hasNewNotifications = false;
        });
      }

    } catch (e) {
      print("Error loading data: $e");
    }
  }

 
  Widget _getBodyWidget() {
    switch (_selectedIndex) {
      case 0:
        return _buildHomeContent();
      case 1:
        return AccessCardScreen(
          fullName: widget.userName,
          apartmentNo: currentApt,
          userId: widget.userId,
        );
      case 2:
        return InboxScreen(currentUserId: widget.userId);
      case 3:
        return CommunityFeedScreen(userId: widget.userId, userName: widget.userName);
      default:
        return _buildHomeContent();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FF),
      drawer: _buildSideMenu(),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 26, 35, 126),
        elevation: 0,
        title: const Text("Smart Residence", style: TextStyle(color: Colors.white, fontSize: 18)),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          ValueListenableBuilder<bool>(
            valueListenable: ResidentHomeScreen.notificationNotifier,
            builder: (context, hasNew, child) {
              return Stack(
                alignment: Alignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.notifications_none_rounded, size: 26),
                    onPressed: () {
                      ResidentHomeScreen.notificationNotifier.value = false; 
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => NotificationScreen(userId: widget.userId),
                        ),
                      ).then((_) => _loadData());
                    },
                  ),
                  if (hasNew)
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                          border: Border.all(color: const Color.fromARGB(255, 26, 35, 126), width: 1.5),
                        ),
                        constraints: const BoxConstraints(minWidth: 10, minHeight: 10),
                      ),
                    ),
                ],
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() => _selectedIndex = index);
          _loadData(); 
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF1A237E),
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.qr_code), label: 'Access'),
          BottomNavigationBarItem(icon: Icon(Icons.chat_outlined), label: 'Chat'),
          BottomNavigationBarItem(icon: Icon(Icons.groups_outlined), label: 'Community'),
        ],
      ),
      body: _getBodyWidget(),
    );
  }

  
  Widget _buildHomeContent() {
    return RefreshIndicator(
      onRefresh: _loadData,
      child: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Quick Overview", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1A237E))),
                  const SizedBox(height: 15),
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    mainAxisSpacing: 15,
                    crossAxisSpacing: 15,
                    childAspectRatio: 1.1,
                    children: [
                      _buildStatCard("Active Guests", stats['activeGuests'].toString(), Icons.people, Colors.blue),
                      _buildStatCard("Events", stats['upcomingEvents'].toString(), Icons.event, Colors.purple),
                      _buildStatCard("My Alerts", stats['pendingAlerts'].toString(), Icons.warning_amber, Colors.orange),
                      _buildStatCard("Messages", stats['unreadMessages'].toString(), Icons.chat_bubble_outline, Colors.green),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSideMenu() {
    return Drawer(
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            decoration: const BoxDecoration(color: Color(0xFF1A237E)),
            accountName: Text(widget.userName, style: const TextStyle(fontWeight: FontWeight.bold)),
            accountEmail: Text("Apt. $currentApt | Block $currentBlock"),
            currentAccountPicture: const CircleAvatar(backgroundColor: Colors.white, child: Icon(Icons.person, size: 40, color: Color(0xFF1A237E))),
          ),
          _drawerItem(Icons.event_available, "Manage Events", () {
            Navigator.pop(context);
            Navigator.push(context, MaterialPageRoute(builder: (context) => ManageEventsScreen(userId: widget.userId)));
          }),
          _drawerItem(Icons.event_available, "Manage Reservations", () {
            Navigator.pop(context);
            Navigator.push(context, MaterialPageRoute(builder: (context) => ManageReservationScreen(userId: widget.userId)));
          }),
          _drawerItem(Icons.local_parking, "Parking Spot", () {
            Navigator.pop(context);
            Navigator.push(context, MaterialPageRoute(builder: (context) => ParkingScreen(userId: widget.userId)));
          }),
          _drawerItem(Icons.event_available, "Emergency Alerts", () {
            Navigator.pop(context);
            Navigator.push(context, MaterialPageRoute(builder: (context) => AlertScreen(userId: widget.userId)));
          }),
          _drawerItem(Icons.person_add_alt, "Guest List", () {
            Navigator.pop(context);
            Navigator.push(context, MaterialPageRoute(builder: (context) => GuestScreen(apartmentId: widget.userId.toString())));
          }),
          const Divider(),
          _drawerItem(Icons.logout, "Logout", () => _showLogoutDialog(), color: Colors.red),
        ],
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: const Text("Logout"),
        content: const Text("Are you sure you want to exit?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          TextButton(
            onPressed: () {
              Navigator.pop(context); 
              Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
            }, 
            child: const Text("Logout", style: TextStyle(color: Colors.red))
          ),
        ],
      ),
    );
  }

  Widget _drawerItem(IconData icon, String title, VoidCallback onTap, {Color color = Colors.black87}) {
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(title, style: TextStyle(color: color, fontWeight: FontWeight.w500)),
      onTap: onTap,
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(left: 20, right: 20, bottom: 30, top: 10),
      decoration: const BoxDecoration(
        color: Color.fromARGB(255, 26, 35, 126),
        borderRadius: BorderRadius.only(bottomLeft: Radius.circular(30), bottomRight: Radius.circular(30)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Welcome, ${widget.userName}", style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text("Block $currentBlock - Apartment $currentApt", style: const TextStyle(color: Colors.white70, fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          Text(title, style: const TextStyle(color: Colors.grey, fontSize: 12)),
        ],
      ),
    );
  }

  void _showTopNotificationBanner(dynamic notification) {
    showOverlayNotification((context) {
      return SafeArea(
        child: Card(
          margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
          color: Colors.white,
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.green.withOpacity(0.1),
              child: const Icon(Icons.event_available_rounded, color: Colors.green),
            ),
            title: Text(notification['title'] ?? 'New Notification', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            subtitle: Text(notification['message'] ?? '', maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
            trailing: IconButton(icon: const Icon(Icons.close, size: 18), onPressed: () => OverlaySupportEntry.of(context)?.dismiss()),
          ),
        ),
      );
    }, duration: const Duration(seconds: 5));
  }
}
