import 'dart:async';
import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:adminspace/main.dart'; 
import 'package:adminspace/screens/ResidentsListScreen.dart';
import 'AdminManagePage.dart';
import 'ManageEventsPage.dart';
import 'AlertScreen.dart';
import 'ConversationsScreen.dart';
import 'EventsLists.dart'; 
import 'GuestlistScreen.dart';
import 'ApprovalsEventsPage.dart'; 
import 'CreateEventPage.dart';
import 'DeleteEventsPage.dart';
import 'EditEventsPage.dart';
import 'NotificationScreen.dart'; 
import 'CommunityFeedScreen.dart';
import 'package:adminspace/services/api_service.dart';

class AdminHomePage extends StatefulWidget {
  static ValueNotifier<bool> hasUnreadNotifications = ValueNotifier<bool>(false);

  const AdminHomePage({super.key});

  @override
  State<AdminHomePage> createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHomePage> {
  int _selectedPageIndex = 0; 
  final Color primaryColor = const Color(0xFF1A237E);

  // Stats 
  int totalResidents = 0;
  int pendingApprovals = 0;
  int activeEvents = 0;
  int openAlerts = 0;
  bool isLoading = true;
  bool isNightMode = false;
  String lightStatus = "off";
  Timer? _timer;

  String adminName = "Loading...";
  String adminId = ""; 

  @override
  void initState() {
    super.initState();
    _fetchStats();
    _fetchAdminName(); 
    _startPolling();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startPolling() {
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) async {
      final state = await ApiService.getLightingState();
      if (mounted) setState(() => lightStatus = state['lightStatus'] ?? "off");
    });
  }

  void _fetchAdminName() async {

    if (adminId.isNotEmpty && adminName != "Loading...") return;

    try {
      final adminData = await ApiService.getAdminInfo();
      if (adminData != null && mounted) {
        setState(() {
          adminName = adminData['username'] ?? adminData['name'] ?? adminData['fullName'] ?? "Admin User";
        
          adminId = adminData['id_user']?.toString() ?? adminData['id']?.toString() ?? "1"; 
        });
        WidgetsBinding.instance.addPostFrameCallback((_) {
          AdminDashboard.of(context)?.startAdminNotificationChecking(adminId);
        });
      } else {
        if (mounted) setState(() => adminName = "Admin");
      }
    } catch (e) {
      print("Error setting admin name in UI: $e");
      if (mounted) setState(() => adminName = "Admin");
    }
  }

  void _fetchStats() async {
    final stats = await ApiService.getDashboardStats();
    if (mounted) {
      setState(() {
        totalResidents = stats['totalResidents'] ?? 0;
        pendingApprovals = stats['pendingApprovals'] ?? 0;
        activeEvents = stats['activeEvents'] ?? 0; 
        openAlerts = stats['activeAlerts'] ?? 0;   
        isLoading = false;
      });
    }
  }

  void _toggleNightMode(bool value) async {
    setState(() => isNightMode = value);
    await ApiService.updateNightMode(value);
  }

  void _changePage(int index) {
    if (index == -1) {
      Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
    } else {
      
      if (index == 8) {
        AdminHomePage.hasUnreadNotifications.value = false;
      }
      setState(() { _selectedPageIndex = index; });
    }
  }

  void _handleInternalBack() {
    setState(() {
      if (_selectedPageIndex >= 201 && _selectedPageIndex <= 204) {
        _selectedPageIndex = 222;
      } else {
        _selectedPageIndex = 0;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
   
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    if (args != null && adminId.isEmpty) {
      setState(() {
        
        adminId = args['id_user']?.toString() ?? args['id']?.toString() ?? "";
        adminName = args['fullName'] ?? args['username'] ?? "Admin";
      });
      
      WidgetsBinding.instance.addPostFrameCallback((_) {
        AdminDashboard.of(context)?.startAdminNotificationChecking(adminId);
      });
    }

    return PopScope(
      canPop: _selectedPageIndex == 0, 
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _handleInternalBack(); 
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FD),
        body: Row(
          children: [
            _buildSidebar(), 
            Expanded(
              child: Column(
                children: [
                  _buildHeader(),
                  Expanded(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: _buildMainBody(),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(30, 40, 30, 20),
      child: Row(
        children: [
          const Text("Secure Gate Dashboard", 
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Color(0xFF1B2559))),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15), border: Border.all(color: Colors.grey.shade200)),
            child: Row(
              children: [
                Icon(isNightMode ? Icons.dark_mode : Icons.light_mode, color: isNightMode ? primaryColor : Colors.orange, size: 20),
                const SizedBox(width: 8),
                const Text("Night Mode", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                Transform.scale(
                  scale: 0.8,
                  child: Switch(value: isNightMode, onChanged: _toggleNightMode, activeColor: primaryColor),
                ),
              ],
            ),
          ),
          const SizedBox(width: 15),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: lightStatus == "on" ? Colors.yellow.shade100 : Colors.grey.shade100, shape: BoxShape.circle),
            child: Icon(Icons.lightbulb, color: lightStatus == "on" ? Colors.orange : Colors.grey, size: 22),
          ),
          const SizedBox(width: 25),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                adminName,
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF1B2559)),
              ),
              const SizedBox(width: 12),
              CircleAvatar(
                radius: 22, 
                backgroundColor: primaryColor, 
                child: const Icon(Icons.person, color: Colors.white),
              ),
            ],
          ),
        ],
      ),
    );
  }

 //sidebar
  Widget _buildSidebar() {
    return Container(
      width: 260,
      color: primaryColor,
      child: Column(
        children: [
          const SizedBox(height: 50),
          const Icon(Icons.security, size: 45, color: Colors.white),
          const SizedBox(height: 10),
          const Text("SECURE GATE", style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 40),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _menuItem(Icons.grid_view_rounded, "Dashboard", 0),
                  _menuItem(Icons.manage_accounts, "Accounts", 1),
                  _menuItem(Icons.event_note, "Manage Events", 222), 
                  _menuItem(Icons.format_list_bulleted_rounded, "List Events", 7), 
                  _buildNotificationMenuItem(8), 
                  _menuItem(Icons.people_alt, "Residents", 3),
                  _menuItem(Icons.warning_amber_rounded, "Alerts", 4),
                  _menuItem(Icons.chat_bubble_outline, "Messages", 5),
                  _menuItem(Icons.person_search_outlined, "Guest List", 6),
                 _menuItem(Icons.forum_outlined, "Community Feed", 9), 
                ],
              ),
            ),
          ),
          _menuItem(Icons.logout, "Logout", -1),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _menuItem(IconData icon, String title, int index) {
    bool isSelected = _selectedPageIndex == index;
    return ListTile(
      onTap: () => _changePage(index),
      leading: Icon(icon, color: isSelected ? Colors.white : Colors.white54),
      title: Text(title, style: TextStyle(color: isSelected ? Colors.white : Colors.white54, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
      selected: isSelected,
      selectedTileColor: Colors.white.withOpacity(0.1),
    );
  }

  //notifbutton
  Widget _buildNotificationMenuItem(int index) {
    bool isSelected = _selectedPageIndex == index;
    return ValueListenableBuilder<bool>(
      valueListenable: AdminHomePage.hasUnreadNotifications,
      builder: (context, hasBadge, child) {
        return ListTile(
          onTap: () => _changePage(index),
          leading: Stack(
            children: [
              Icon(Icons.notifications_active_rounded, color: isSelected ? Colors.white : Colors.white54),
              if (hasBadge)
                Positioned(
                  right: 0,
                  top: 0,
                  child: Container(
                    width: 9,
                    height: 9,
                    decoration: const BoxDecoration(color: Colors.redAccent, shape: BoxShape.circle),
                  ),
                )
            ],
          ),
          title: Text("Notifications", style: TextStyle(color: isSelected ? Colors.white : Colors.white54, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
          selected: isSelected,
          selectedTileColor: Colors.white.withOpacity(0.1),
        );
      },
    );
  }
//change concept of main page 
  Widget _buildMainBody() {
    switch (_selectedPageIndex) {
      case 0: return _buildDashboardStats();
      case 1:
        return ManageAccountsPage(
          onBack: () => setState(() { _selectedPageIndex = 0; }),
        );
      case 2: 
        return ApprovedEventsPage(
          onBack: () => setState(() { _selectedPageIndex = 0; }),
        );
      case 3: 
        return ActiveResidentsScreen(
          onBack: () => setState(() { _selectedPageIndex = 0; }),
        );
      case 4: 
        return AlertsScreen(
          onBack: () => setState(() { _selectedPageIndex = 0; }),
        );
      case 5: 
        return ConversationsScreen(
          onBack: () => setState(() { _selectedPageIndex = 0; }),
        );
      case 6: 
        return GuestListScreen(
          onBack: () => setState(() { _selectedPageIndex = 0; }),
        );
        
      case 7:
        return ApprovedEventsPage(
          onBack: () => setState(() { _selectedPageIndex = 0; }),
        );
        
      case 8:
        return NotificationScreen(
          adminId: adminId.isEmpty ? "1" : adminId,
          onBack: () => setState(() { _selectedPageIndex = 0; }),
        );

         case 9: 
  return CommunityFeedScreen(
    adminId: adminId.isEmpty ? "1" : adminId,
    onBack: () => setState(() { _selectedPageIndex = 0; }),
  );
      case 222:
        return ManageEventsPage(
          onOptionSelected: (index) => setState(() { _selectedPageIndex = index; }),
          onBack: () => setState(() { _selectedPageIndex = 0; }),
        );

      case 201: return ApprovalsEventsPage(onBack: _handleInternalBack); 
      case 202: return CreateEventPage(onBack: _handleInternalBack);    
      case 203: return EditEventsPage(onBack: _handleInternalBack);      
      case 204: return DeleteEventsPage(onBack: _handleInternalBack);    

      default: return _buildDashboardStats();
    }
  }

  Widget _buildDashboardStats() {
    if (isLoading) return const Center(child: CircularProgressIndicator());
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(25),
      child: Column(
        children: [
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 20,
            mainAxisSpacing: 20,
            childAspectRatio: 2.2,
            children: [
              _statCard("Total Residents", totalResidents.toString(), Icons.people, Colors.blue, 3),
              _statCard("Pending Accounts", pendingApprovals.toString(), Icons.manage_accounts, Colors.orange, 1),
              _statCard("Active Events", activeEvents.toString(), Icons.event, Colors.purple, 222),
              _statCard("Security Alerts", openAlerts.toString(), Icons.warning, Colors.red, 4),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statCard(String title, String value, IconData icon, Color color, int targetPage) {
    return InkWell(
      onTap: () => _changePage(targetPage), 
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)]),
        child: Row(
          children: [
            CircleAvatar(backgroundColor: color.withOpacity(0.1), child: Icon(icon, color: color)),
            const SizedBox(width: 15),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                Text(title, style: TextStyle(color: Colors.grey[500], fontSize: 13)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}