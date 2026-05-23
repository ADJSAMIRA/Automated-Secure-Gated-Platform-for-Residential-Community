import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:adminspace/services/api_service.dart';

class CommunityFeedScreen extends StatefulWidget {
  final String adminId;
  final VoidCallback onBack;

  const CommunityFeedScreen({super.key, required this.adminId, required this.onBack});

  @override
  State<CommunityFeedScreen> createState() => _CommunityFeedScreenState();
}

class _CommunityFeedScreenState extends State<CommunityFeedScreen> {
  final Color primaryColor = const Color(0xFF1A237E);
  final TextEditingController _postController = TextEditingController();
  String _selectedPostType = 'Normal';
  List<dynamic> _posts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFeed();
  }

 
  Future<void> _loadFeed() async {
    setState(() => _isLoading = true);
    try {
      final response = await ApiService.getCommunityFeed();
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        setState(() {
          _posts = decoded['data'] ?? decoded ?? [];
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      print("Error loading feed: $e");
      setState(() => _isLoading = false);
    }
  }

  
  Future<void> _handleCreatePost() async {
    if (_postController.text.trim().isEmpty) return;

    try {
      final response = await ApiService.createNewPost(
        widget.adminId,
        _postController.text.trim(),
        _selectedPostType,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        _postController.clear();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Post created successfully!"), backgroundColor: Colors.green),
        );
        _loadFeed(); 
      }
    } catch (e) {
      print("Error creating post: $e");
    }
  }

 
  Future<void> _handleLike(dynamic postId, int index) async {
    try {
      final response = await ApiService.likePostToggle(postId.toString(), widget.adminId);
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        setState(() {
          
          if (decoded['action'] == 'liked' || decoded['message']?.contains('liked') == true) {
            _posts[index]['likesCount'] = (_posts[index]['likesCount'] ?? 0) + 1;
          } else {
            _posts[index]['likesCount'] = (_posts[index]['likesCount'] ?? 1) - 1;
            if (_posts[index]['likesCount'] < 0) _posts[index]['likesCount'] = 0;
          }
        });
      }
    } catch (e) {
      print("Error toggling like: $e");
    }
  }

 
  void _openCommentsBottomSheet(dynamic postId, int postIndex) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return _CommentSectionWidget(
          postId: postId.toString(),
          adminId: widget.adminId,
          primaryColor: primaryColor,
          onCommentAdded: () {
            setState(() {
              _posts[postIndex]['commentsCount'] = (_posts[postIndex]['commentsCount'] ?? 0) + 1;
            });
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD),
      body: Container(
        padding: const EdgeInsets.all(25),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
           
            Row(
              children: [
                IconButton(
                  icon: Icon(Icons.arrow_back_ios, color: primaryColor, size: 20),
                  onPressed: widget.onBack,
                ),
                const SizedBox(width: 10),
                const Text(
                  "Community Feed",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF1B2559)),
                ),
              ],
            ),
            const SizedBox(height: 25),

           
            _buildCreatePostBox(),
            const SizedBox(height: 25),

            
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _posts.isEmpty
                      ? const Center(child: Text("No posts available in the feed yet."))
                      : RefreshIndicator(
                          onRefresh: _loadFeed,
                          child: ListView.builder(
                            itemCount: _posts.length,
                            itemBuilder: (context, index) {
                              final post = _posts[index];
                              return _buildPostCard(post, index);
                            },
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCreatePostBox() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)],
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(backgroundColor: primaryColor, child: const Icon(Icons.admin_panel_settings, color: Colors.white)),
              const SizedBox(width: 15),
              Expanded(
                child: TextField(
                  controller: _postController,
                  decoration: const InputDecoration(
                    hintText: "Share something with your community...",
                    border: InputBorder.none,
                  ),
                  maxLines: 2,
                ),
              ),
            ],
          ),
          const Divider(height: 25),
          Row(
            children: [
             
              DropdownButton<String>(
                value: _selectedPostType,
                underline: const SizedBox(),
                items: <String>['Normal', 'Announcement'].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value, style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold)),
                  );
                }).toList(),
                onChanged: (newValue) {
                  if (newValue != null) setState(() => _selectedPostType = newValue);
                },
              ),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: _handleCreatePost,
                icon: const Icon(Icons.send, size: 16, color: Colors.white),
                label: const Text("Post", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPostCard(dynamic post, int index) {
    bool isAnnouncement = post['postType'] == 'Announcement';
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.01), blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: post['authorRole'] == 'Admin' ? primaryColor : Colors.grey.shade300,
                child: Icon(post['authorRole'] == 'Admin' ? Icons.admin_panel_settings : Icons.person, color: Colors.white),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(post['authorName'] ?? "Unknown", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF1B2559))),
                  Text(post['authorRole'] ?? "Resident", style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
                ],
              ),
              const Spacer(),
              if (isAnnouncement)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(8)),
                  child: const Text("Announcement", style: TextStyle(color: Colors.red, fontSize: 11, fontWeight: FontWeight.bold)),
                ),
            ],
          ),
          const SizedBox(height: 15),
          Text(post['content'] ?? "", style: const TextStyle(fontSize: 14, color: Color(0xFF1B2559), height: 1.4)),
          const Divider(height: 30),
          Row(
            children: [
              InkWell(
                onTap: () => _handleLike(post['id_post'], index),
                child: Row(
                  children: [
                    const Icon(Icons.favorite_border, color: Colors.redAccent, size: 20),
                    const SizedBox(width: 6),
                    Text("${post['likesCount'] ?? 0} Likes", style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
              const SizedBox(width: 25),
              InkWell(
                onTap: () => _openCommentsBottomSheet(post['id_post'], index),
                child: Row(
                  children: [
                    Icon(Icons.chat_bubble_outline, color: primaryColor, size: 20),
                    const SizedBox(width: 6),
                    Text("${post['commentsCount'] ?? 0} Comments", style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}


class _CommentSectionWidget extends StatefulWidget {
  final String postId;
  final String adminId;
  final Color primaryColor;
  final VoidCallback onCommentAdded;

  const _CommentSectionWidget({required this.postId, required this.adminId, required this.primaryColor, required this.onCommentAdded});

  @override
  State<_CommentSectionWidget> createState() => _CommentSectionWidgetState();
}

class _CommentSectionWidgetState extends State<_CommentSectionWidget> {
  List<dynamic> _comments = [];
  bool _loadingComments = true;
  final TextEditingController _commentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadComments();
  }

  Future<void> _loadComments() async {
    try {
      final response = await ApiService.getPostComments(widget.postId);
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        setState(() {
          _comments = decoded['data'] ?? decoded ?? [];
          _loadingComments = false;
        });
      }
    } catch (e) {
      print("Error loading comments: $e");
    }
  }

  Future<void> _submitComment() async {
    if (_commentController.text.trim().isEmpty) return;
    try {
      final response = await ApiService.addPostComment(widget.postId, widget.adminId, _commentController.text.trim());
      if (response.statusCode == 200 || response.statusCode == 201) {
        _commentController.clear();
        widget.onCommentAdded();
        _loadComments(); 
      }
    } catch (e) {
      print("Error submitting comment: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, top: 20, left: 20, right: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text("Comments", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1B2559))),
          const SizedBox(height: 15),
          Container(
            constraints: const BoxConstraints(maxHeight: 300),
            child: _loadingComments
                ? const Center(child: CircularProgressIndicator())
                : _comments.isEmpty
                    ? const Center(child: Padding(padding: EdgeInsets.all(20), child: Text("No comments yet. Be the first!")))
                    : ListView.builder(
                        shrinkWrap: true,
                        itemCount: _comments.length,
                        itemBuilder: (context, idx) {
                          final c = _comments[idx];
                          return ListTile(
                            leading: CircleAvatar(backgroundColor: widget.primaryColor.withOpacity(0.1), child: Icon(Icons.person, color: widget.primaryColor, size: 18)),
                            title: Text(c['commenterName'] ?? "Anonymous", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                            subtitle: Text(c['text'] ?? "", style: const TextStyle(color: Color(0xFF1B2559))),
                          );
                        },
                      ),
          ),
          const Divider(),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _commentController,
                  decoration: const InputDecoration(hintText: "Write a comment...", border: InputBorder.none),
                ),
              ),
              IconButton(icon: Icon(Icons.send, color: widget.primaryColor), onPressed: _submitComment),
            ],
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}