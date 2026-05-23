import 'package:flutter/material.dart';
import 'package:residenceapp/screens/ResidentHomeScreen.dart';
import 'package:residenceapp/screens/WelcomeScreen.dart';
import 'screens/login_screen.dart';
import 'screens/signup_screen.dart';
import 'package:overlay_support/overlay_support.dart';
import 'services/api_service.dart'; 
import 'dart:async';

void main() {
  runApp(const ResidentApp());
}

class ResidentApp extends StatefulWidget {
  const ResidentApp({super.key});

  
  static _ResidentAppState? of(BuildContext context) =>
      context.findAncestorStateOfType<_ResidentAppState>();

  @override
  State<ResidentApp> createState() => _ResidentAppState();
}

class _ResidentAppState extends State<ResidentApp> {
  Timer? _globalTimer;
  String? _activeUserId; 
  int _lastNotificationId = 0;

 
  void setGlobalUser(String userId) {
    setState(() {
      _activeUserId = userId;
      ResidentHomeScreen.currentLoggedInUserId = userId;
    });
    print(" Global User ID set for Real-Time: $_activeUserId");
    _checkGlobalNotifications(); 
  }

  @override
  void initState() {
    super.initState();
   //every 4s check if eny new notif
    _globalTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      _checkGlobalNotifications();
    });
  }

  @override
  void dispose() {
    _globalTimer?.cancel();
    super.dispose();
  }

  Future<void> _checkGlobalNotifications() async {
   
    final userIdToCheck = _activeUserId ?? ResidentHomeScreen.currentLoggedInUserId;
    if (userIdToCheck == null || userIdToCheck.isEmpty) return;

    try {
      final notifications = await ApiService.getUserNotifications(userIdToCheck);
      
      if (notifications.isNotEmpty) {
      
        final lastNotification = notifications.first; 
        bool isRead = lastNotification['is_read'] == 1 || lastNotification['is_read'] == true;

        if (!isRead) {
          int currentId = lastNotification['id_notification'] ?? lastNotification['id'] ?? 0;
          
          if (currentId != _lastNotificationId) {
            _lastNotificationId = currentId;

           
            ResidentHomeScreen.notificationNotifier.value = true;

           
            _showPopup(lastNotification);
          }
        }
      }
    } catch (e) {
      print("Global Real-Time check error: $e");
    }
  }

  void _showPopup(dynamic notification) {
    showOverlayNotification((context) {
      String type = notification['type'] ?? 'System';
      IconData iconData = Icons.notifications_active_rounded;
      Color iconColor = Colors.blue;

      if (type == 'Alert') { iconData = Icons.warning_amber_rounded; iconColor = Colors.red; }
      else if (type == 'Reservation') { iconData = Icons.event_available_rounded; iconColor = Colors.green; }
      else if (type == 'Message') { iconData = Icons.chat_bubble_outline_rounded; iconColor = Colors.blue; }

      return SafeArea(
        child: Card(
          margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
          color: Colors.white,
          elevation: 6,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: iconColor.withOpacity(0.1),
              child: Icon(iconData, color: iconColor),
            ),
            title: Text(
              notification['title'] ?? 'New Notification',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            subtitle: Text(
              (notification['message'] ?? '').toString().replaceAll('"undefined"', 'details'),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
            trailing: IconButton(
              icon: const Icon(Icons.close, size: 18),
              onPressed: () => OverlaySupportEntry.of(context)?.dismiss(),
            ),
          ),
        ),
      );
    }, duration: const Duration(seconds: 5));
  }

  @override
  Widget build(BuildContext context) {
    return OverlaySupport.global(
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Smart Residence',
        theme: ThemeData(
          primarySwatch: Colors.indigo,
          fontFamily: 'Roboto',
        ),
        initialRoute: '/',
        routes: {
          '/': (context) => const WelcomeScreen(),
          '/login': (context) => const LoginScreen(),
          '/signup': (context) => const SignUpScreen(),
          '/home': (context) => const ResidentHomeScreen(userName: '', apartmentNo: '', userId: ''), 
        },
      ),
    );
  }
}