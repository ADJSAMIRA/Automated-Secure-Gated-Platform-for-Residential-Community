import 'dart:async';
import 'package:flutter/material.dart';
import 'package:adminspace/screens/welcome_page.dart';
import 'package:adminspace/screens/AdminLoginPage.dart';
import 'package:adminspace/screens/AdminSignupPage.dart';
import 'package:adminspace/screens/AdminHomePage.dart';
import 'package:adminspace/services/api_service.dart';


final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() {
  runApp(const AdminDashboard());
}

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  static _AdminDashboardState? of(BuildContext context) =>
      context.findAncestorStateOfType<_AdminDashboardState>();

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  Timer? _notificationTimer;
  String? _currentAdminId;
  int _lastCheckedNotificationId = 0;

  
  void startAdminNotificationChecking(String adminId) {
    _currentAdminId = adminId;
    _notificationTimer?.cancel(); 
    
    // check every 4s if there is new notiff
    _notificationTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      _checkNewNotifications();
    });
    
    _checkNewNotifications();
  }

  Future<void> _checkNewNotifications() async {
    if (_currentAdminId == null) return;

    try {
      final list = await ApiService.getUserNotifications(_currentAdminId!);
      if (list.isNotEmpty) {
        final latest = list.first;
        bool isRead = latest['is_read'] == 1 || latest['is_read'] == true;

        if (!isRead) {
          int currentId = latest['id_notification'] ?? latest['id'] ?? 0;
          if (currentId != _lastCheckedNotificationId) {
            _lastCheckedNotificationId = currentId;
            AdminHomePage.hasUnreadNotifications.value = true;
            _showTopRightSnackBar(
              latest['title'] ?? "New Notification",
              latest['message'] ?? "You have a new update in your dashboard.",
            );
          }
        }
      }
    } catch (e) {
      print("Error in background notification check: $e");
    }
  }

  void _showTopRightSnackBar(String title, String message) {
    if (navigatorKey.currentContext == null) return;

    final context = navigatorKey.currentContext!;
  
    ScaffoldMessenger.of(context).hideCurrentSnackBar();

  
    final screenWidth = MediaQuery.of(context).size.width;
    
   
    double leftMargin = screenWidth > 600 ? screenWidth - 360 : 20;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.only(top: 2.0),
              child: Icon(Icons.notifications_active_rounded, color: Colors.amber, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.white),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    message,
                    style: const TextStyle(fontSize: 12, color: Colors.white, height: 1.3),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            InkWell(
              onTap: () {
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
              },
              child: const Icon(Icons.close, color: Colors.white60, size: 18),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF1A237E), 
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 8), 
        
        
        margin: EdgeInsets.fromLTRB(
          leftMargin, 
          20, 
          20, 
          MediaQuery.of(context).size.height - 140 // يدفعه لأعلى الشاشة بدلاً من الأسفل
        ),
      ),
    );
  }

  @override
  void dispose() {
    _notificationTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey, 
      debugShowCheckedModeBanner: false,
      title: 'Admin Dashboard',
      theme: ThemeData(
        primaryColor: const Color(0xFF1A237E),
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1A237E)),
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const WelcomePage(),
        '/login': (context) => AdminLoginPage(),
        '/signup': (context) => AdminSignupPage(),
        '/home': (context) => const AdminHomePage(),
      },
    );
  }
}