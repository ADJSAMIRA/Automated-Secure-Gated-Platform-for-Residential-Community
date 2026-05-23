import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:residenceapp/services/api_service.dart';

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
  bool _isPublishing = false;

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
      } else {
        setState(() => _isLoading = false);
        print("Server error fetching feed: ${response.statusCode}");
      }
    } catch (e) {
      print("Error fetching community feed: $e");
      setState(() => _isLoading = false);
    }
  }

  
  Future<void> _handleCreatePost(String content, BuildContext modalContext) async {
    if (content.trim().isEmpty) return;

    if (mounted) {
      setState(() => _isPublishing = true);
    }

    try {
      final response = await ApiService.createNewPost(widget.userId, content.trim(), 'Normal');
      if (response.statusCode == 201 || response.statusCode == 200) {
        Navigator.pop(modalContext); 
        setState(() {
          _isPublishing = false;
          _isLoading = true;
        });
        _fetchFeed(); 
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Post published successfully! ✅")),
        );
      } else {
        setState(() => _isPublishing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to publish post. ❌")),
        );
      }
    } catch (e) {
      print("Error creating post: $e");
      setState(() => _isPublishing = false);
    }
  }

  
  Future<void> _handleLikeToggle(dynamic postId, int index) async {
    if (postId == null) return;
    try {
      final response = await ApiService.likePostToggle(postId.toString(), widget.userId);
      if (response.statusCode == 200) {
        final resBody = jsonDecode(response.body);
        setState(() {
         
          if (resBody['action'] == 'liked' || 
              resBody['message'] == 'Post liked successfully' || 
              resBody['status'] == 'liked') {
            _posts[index]['likesCount'] = (_posts[index]['likesCount'] ?? 0) + 1;
          } else {
           
            _posts[index]['likesCount'] = (_posts[index]['likesCount'] ?? 1) - 1;
            if (_posts[index]['likesCount'] < 0) _posts[index]['likesCount'] = 0; 
          }
        });
      } else {
        print("Server error for like: ${response.statusCode} - ${response.body}");
      }
    } catch (e) {
      print("Error toggling like: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryBlue = Color(0xFF1A237E); 
    const Color lightBlueBackground = Color(0xFF42A5F5); 

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: primaryBlue))
          : RefreshIndicator(
              onRefresh: _fetchFeed,
              child: ListView(
                padding: const EdgeInsets.all(15),
                children: [
                  
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [lightBlueBackground, Color(0xFF1E88E5)], 
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(25),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.blue.withOpacity(0.15),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        )
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Community Share",
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                "Share news, moments or helpful tips with your neighbors.",
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.white.withOpacity(0.9),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 15),
                        
                        GestureDetector(
                          onTap: () => _showCreatePostModal(),
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.add,
                              color: primaryBlue,
                              size: 28,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 22),
                  
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 5),
                    child: Text(
                      "Recent Updates",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
                    ),
                  ),
                  
                  const SizedBox(height: 12),

                  if (_posts.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 50),
                      child: Center(child: Text("No posts published yet. Be the first!", style: TextStyle(color: Colors.grey))),
                    ),

                 
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _posts.length,
                    itemBuilder: (context, index) {
                      final post = _posts[index];
                     
                      final dynamic currentPostId = post['id_post'] ?? post['id'];

                      return Card(
                        margin: const EdgeInsets.only(bottom: 15),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        elevation: 1.5,
                        color: Colors.white,
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  CircleAvatar(
                                    backgroundColor: post['authorRole'] == 'Admin' ? Colors.red.shade50 : Colors.blue.shade50,
                                    child: Icon(Icons.person, color: post['authorRole'] == 'Admin' ? Colors.red : primaryBlue),
                                  ),
                                  const SizedBox(width: 12),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(post['authorName'] ?? 'Resident', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                      const SizedBox(height: 2),
                                      Text(post['authorRole'] ?? 'Resident', style: TextStyle(color: Colors.grey.shade500, fontSize: 11)),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 14),
                              Text(post['content'] ?? '', style: const TextStyle(fontSize: 14, height: 1.4, color: Colors.black87)),
                              const SizedBox(height: 12),
                              const Divider(height: 1, color: Color(0xFFEEEEEE)),
                              const SizedBox(height: 6),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                children: [
                                  TextButton.icon(
                                    icon: const Icon(Icons.thumb_up_off_alt, size: 18, color: Colors.blue),
                                    label: Text("Like (${post['likesCount'] ?? 0})", style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.w500)),
                                    
                                    onPressed: () => _handleLikeToggle(currentPostId, index),
                                  ),
                                  TextButton.icon(
                                    icon: const Icon(Icons.chat_bubble_outline, size: 18, color: Colors.grey),
                                    label: Text("Comments (${post['commentsCount'] ?? 0})", style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.w500)),
                                    onPressed: () => _showCommentsModal(currentPostId),
                                  ),
                                ],
                              )
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
    );
  }

 
  void _showCreatePostModal() {
    final TextEditingController postController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true, 
      backgroundColor: Colors.transparent,
      builder: (modalContext) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
              ),
              padding: EdgeInsets.only(
                top: 20,
                left: 20,
                right: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 20, 
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.black54),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const Text(
                        "Create New Post",
                        style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.black87),
                      ),
                      ElevatedButton(
                        onPressed: _isPublishing
                            ? null
                            : () async {
                                if (postController.text.trim().isEmpty) return;
                                setModalState(() => _isPublishing = true);
                                await _handleCreatePost(postController.text, modalContext);
                                setModalState(() => _isPublishing = false);
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1A237E),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                        ),
                        child: _isPublishing
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                              )
                            : const Text("Post", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                      ),
                    ],
                  ),
                  const Divider(height: 20),
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 18,
                        backgroundColor: Colors.blue.shade50,
                        child: const Icon(Icons.person, color: Color(0xFF1A237E), size: 18),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        widget.userName,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  TextField(
                    controller: postController,
                    maxLines: 5,
                    minLines: 2,
                    keyboardType: TextInputType.multiline,
                    autofocus: true, 
                    style: const TextStyle(fontSize: 15, height: 1.4),
                    decoration: InputDecoration(
                      hintText: "What's on your mind? Share it with neighbors...",
                      hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
                      border: InputBorder.none,
                      filled: true,
                      fillColor: Colors.grey.shade50,
                      contentPadding: const EdgeInsets.all(12),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide(color: Colors.grey.shade200)),
                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide(color: Colors.grey.shade300)),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

 
  void _showCommentsModal(dynamic postId) {
    if (postId == null) return;
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
                      if (response.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (!response.hasData || response.data == null) {
                        return const Center(child: Text("No comments yet."));
                      }
                      final comments = jsonDecode(response.data.body)['data'] ?? [];
                      if (comments.isEmpty) {
                        return const SizedBox(height: 80, child: Center(child: Text("Be the first to comment!")));
                      }
                      return SizedBox(
                        height: 220,
                        child: ListView.builder(
                          itemCount: comments.length,
                          itemBuilder: (context, cIndex) {
                            final comment = comments[cIndex];
                            return ListTile(
                              leading: const CircleAvatar(radius: 14, child: Icon(Icons.person, size: 14)),
                              title: Text(comment['commenterName'] ?? 'User', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                              subtitle: Text(comment['text'] ?? '', style: const TextStyle(fontSize: 13)),
                            );
                          },
                        ),
                      );
                    },
                  ),
                  const Divider(),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: commentField,
                          decoration: InputDecoration(
                            hintText: "Write a comment...", 
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
                            filled: true,
                            fillColor: Colors.grey.shade100,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8)
                          ),
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