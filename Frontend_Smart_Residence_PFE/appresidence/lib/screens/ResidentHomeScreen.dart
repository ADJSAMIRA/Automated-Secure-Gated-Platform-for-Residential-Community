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

//community feed class intger here
class CommunityFeedScreen extends StatefulWidget {
  final String userId;
  final String userName;
  const CommunityFeedScreen({super.key, required this.userId, required this.userName});

  @override
  State<CommunityFeedScreen> createState() => _CommunityFeedScreenState();
}

class _CommunityFeedScreenState extends State<CommunityFeedScreen> {
  List<dynamic> _posts = [];
  bool _isLoading = true;
  final TextEditingController _postController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchFeed();
  }

  Future<void> _fetchFeed() async {
    try {
     
      final response = await ApiService.getCommunityFeed(); 
      if (response.statusCode == 200) {
        setState(() {
          _posts = jsonDecode(response.body)['data'] ?? [];
          _isLoading = false;
        });
      }
    } catch (e) {
      print("Error fetching community feed: $e");
      setState(() => _isLoading = false);
    }
  }

  Future<void> _handleCreatePost() async {
    if (_postController.text.trim().isEmpty) return;
    try {
      final response = await ApiService.createNewPost(widget.userId, _postController.text.trim(), 'Normal');
      if (response.statusCode == 201 || response.statusCode == 200) {
        _postController.clear();
        _fetchFeed(); 
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Post published successfully! ✅")));
      }
    } catch (e) {
      print("Error creating post: $e");
    }
  }

  Future<void> _handleLikeToggle(int postId, int index) async {
    try {
      final response = await ApiService.likePostToggle(postId.toString(), widget.userId);
      if (response.statusCode == 200) {
        final resBody = jsonDecode(response.body);
        setState(() {
          if (resBody['action'] == 'liked') {
            _posts[index]['likesCount'] = (_posts[index]['likesCount'] ?? 0) + 1;
          } else {
            _posts[index]['likesCount'] = (_posts[index]['likesCount'] ?? 1) - 1;
          }
        });
      }
    } catch (e) {
      print("Error toggling like: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),
      body: Column(
        children: [
         
          Container(
            padding: const EdgeInsets.all(15),
            color: Colors.white,
            child: Row(
              children: [
                const CircleAvatar(backgroundColor: Color(0xFF1A237E), child: Icon(Icons.person, color: Colors.white)),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _postController,
                    decoration: InputDecoration(
                      hintText: "What's on your mind, ${widget.userName}?",
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(25), borderSide: BorderSide.none),
                      filled: true,
                      fillColor: Colors.grey[100],
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.send_rounded, color: Color(0xFF1A237E)),
                  onPressed: _handleCreatePost,
                )
              ],
            ),
          ),
          const Divider(height: 1),
       
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: _fetchFeed,
                    child: ListView.builder(
                      itemCount: _posts.length,
                      itemBuilder: (context, index) {
                        final post = _posts[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                          elevation: 2,
                          child: Padding(
                            padding: const EdgeInsets.all(15),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    CircleAvatar(
                                      backgroundColor: post['authorRole'] == 'Admin' ? Colors.red[100] : Colors.blue[100],
                                      child: Icon(Icons.person, color: post['authorRole'] == 'Admin' ? Colors.red : Colors.blue),
                                    ),
                                    const SizedBox(width: 10),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(post['authorName'] ?? 'Resident', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                        Text(post['authorRole'] ?? 'Resident', style: TextStyle(color: Colors.grey[600], fontSize: 11)),
                                      ],
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Text(post['content'] ?? '', style: const TextStyle(fontSize: 14, height: 1.4)),
                                const SizedBox(height: 15),
                                const Divider(),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                                  children: [
                                    TextButton.icon(
                                      icon: const Icon(Icons.thumb_up_off_alt, size: 18, color: Colors.blue),
                                      label: Text("Like (${post['likesCount'] ?? 0})", style: const TextStyle(color: Colors.blue)),
                                      onPressed: () => _handleLikeToggle(post['id_post'], index),
                                    ),
                                    TextButton.icon(
                                      icon: const Icon(Icons.chat_bubble_outline, size: 18, color: Colors.grey),
                                      label: Text("Comments (${post['commentsCount'] ?? 0})", style: const TextStyle(color: Colors.grey)),
                                      onPressed: () {
                                        _showCommentsModal(post['id_post']);
                                      },
                                    ),
                                  ],
                                )
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }

 
  void _showCommentsModal(int postId) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
      builder: (context) {
        final TextEditingController commentField = TextEditingController();
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, top: 20, left: 15, right: 15),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text("Comments", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 10),
                  FutureBuilder(
                    future: ApiService.getPostComments(postId.toString()),
                    builder: (context, AsyncSnapshot response) {
                      if (!response.hasData) return const Center(child: CircularProgressIndicator());
                      final comments = jsonDecode(response.data.body)['data'] ?? [];
                      return SizedBox(
                        height: 250,
                        child: ListView.builder(
                          itemCount: comments.length,
                          itemBuilder: (context, cIndex) {
                            final comment = comments[cIndex];
                            return ListTile(
                              leading: const CircleAvatar(radius: 15, child: Icon(Icons.person, size: 15)),
                              title: Text(comment['commenterName'] ?? 'User', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                              subtitle: Text(comment['text'] ?? ''),
                            );
                          },
                        ),
                      );
                    },
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: commentField,
                          decoration: InputDecoration(hintText: "Write a comment...", border: OutlineInputBorder(borderRadius: BorderRadius.circular(20))),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.send, color: Color(0xFF1A237E)),
                        onPressed: () async {
                          if (commentField.text.trim().isEmpty) return;
                          final res = await ApiService.addPostComment(postId.toString(), widget.userId, commentField.text.trim());
                          if (res.statusCode == 201 || res.statusCode == 200) {
                            commentField.clear();
                            setModalState(() {}); 
                            _fetchFeed(); 
                          }
                        },
                      )
                    ],
                  ),
                  const SizedBox(height: 15),
                ],
              ),
            );
          },
        );
      },
    );
  }
}