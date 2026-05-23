import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'package:intl/intl.dart';

class ChatScreen extends StatefulWidget {
  final int currentUserId;
  final int contactId;
  final String contactName;
  final VoidCallback onBackToConversations; 

  const ChatScreen({
    super.key,
    required this.currentUserId,
    required this.contactId,
    required this.contactName,
    required this.onBackToConversations,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  List messages = [];
  bool isSending = false;
  
  
  final Color primaryBlue = const Color(0xFF1B2559); 
  final Color scaffoldBg = const Color(0xFFF8F9FD); 

  @override
  void initState() {
    super.initState();
    _loadMessages();
  }

  void _loadMessages() async {
    final data = await ApiService.getChatHistory(widget.currentUserId, widget.contactId);
    if (mounted) setState(() => messages = data);
  }

  void _send() async {
    if (_controller.text.trim().isEmpty) return;
    setState(() => isSending = true);
    bool ok = await ApiService.sendMessage(
      senderId: widget.currentUserId,
      receiverId: widget.contactId,
      content: _controller.text,
    );
    if (ok) {
      _controller.clear();
      _loadMessages();
    }
    setState(() => isSending = false);
  }

  @override
  Widget build(BuildContext context) {
 
    return Container(
      color: scaffoldBg,
      child: Column(
        children: [
          
          Container(
            padding: const EdgeInsets.fromLTRB(15, 20, 25, 15),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.02),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                )
              ],
            ),
            child: Row(
              children: [
                IconButton(
                  icon: Icon(Icons.arrow_back_ios_rounded, color: primaryBlue, size: 20),
                  onPressed: widget.onBackToConversations, // استدعاء دالة الرجوع الممررة من صفحة الـ Conversations
                ),
                CircleAvatar(
                  radius: 18,
                  backgroundColor: primaryBlue.withOpacity(0.08),
                  child: Icon(Icons.person_rounded, color: primaryBlue, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    widget.contactName,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: primaryBlue,
                    ),
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final msg = messages[index];
                bool isMe = msg['sender_id'] == widget.currentUserId;

                bool showDate = false;
                if (index == 0) {
                  showDate = true;
                } else {
                  DateTime prevDate = DateTime.parse(messages[index - 1]['timestamp']);
                  DateTime currDate = DateTime.parse(msg['timestamp']);
                  if (prevDate.day != currDate.day || prevDate.month != currDate.month || prevDate.year != currDate.year) {
                    showDate = true;
                  }
                }

                return Column(
                  children: [
                    if (showDate) _buildDateSeparator(msg['timestamp']),
                    GestureDetector(
                      onSecondaryTapDown: (details) {
                        if (isMe) {
                          _showRightClickMenu(details.globalPosition, msg['id_message'].toString(), msg['content']);
                        }
                      },
                      onLongPressStart: (details) {
                        if (isMe) {
                          _showRightClickMenu(details.globalPosition, msg['id_message'].toString(), msg['content']);
                        }
                      },
                      child: _buildMessageBubble(msg, isMe),
                    ),
                  ],
                );
              },
            ),
          ),
          
         
          _buildInputArea(),
        ],
      ),
    );
  }

  Widget _buildDateSeparator(String timestamp) {
    DateTime date = DateTime.parse(timestamp);
    String formattedDate = DateFormat('MMMM dd, yyyy').format(date);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            formattedDate,
            style: TextStyle(fontSize: 11, color: Colors.grey.shade600, fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );
  }

  Widget _buildMessageBubble(Map<String, dynamic> msg, bool isMe) {
    DateTime time = DateTime.parse(msg['timestamp'] ?? DateTime.now().toString());
    String formattedTime = DateFormat('HH:mm').format(time);
    bool isEdited = msg['is_edited'] == 1 || msg['is_edited'] == true;

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Column(
        crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            margin: const EdgeInsets.symmetric(vertical: 4),
            constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.7),
            decoration: BoxDecoration(
              color: isMe ? primaryBlue : Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(18),
                topRight: const Radius.circular(18),
                bottomLeft: Radius.circular(isMe ? 18 : 4),
                bottomRight: Radius.circular(isMe ? 4 : 18),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.015), 
                  blurRadius: 5, 
                  offset: const Offset(0, 2)
                )
              ],
            ),
            child: Text(
              msg['content'],
              style: TextStyle(
                color: isMe ? Colors.white : Colors.black87, 
                fontSize: 14,
                height: 1.4,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 12, left: 4, right: 4),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isEdited) 
                  Text("Edited  ", style: TextStyle(fontSize: 9, color: Colors.grey.shade400, fontStyle: FontStyle.italic)),
                Text(formattedTime, style: TextStyle(fontSize: 10, color: Colors.grey.shade400)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showRightClickMenu(Offset position, String msgId, String currentContent) {
    showMenu(
      context: context,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      position: RelativeRect.fromLTRB(position.dx, position.dy, position.dx, position.dy),
      items: [
        PopupMenuItem(
          onTap: () => Future.delayed(Duration.zero, () => _showEditDialog(msgId, currentContent)),
          child: ListTile(
            horizontalTitleGap: 0,
            leading: Icon(Icons.edit_rounded, size: 18, color: primaryBlue), 
            title: Text("Edit", style: TextStyle(color: primaryBlue, fontSize: 14))
          ),
        ),
        PopupMenuItem(
          onTap: () async {
            bool ok = await ApiService.deleteMessage(msgId);
            if (ok) _loadMessages();
          },
          child: const ListTile(
            horizontalTitleGap: 0,
            leading: Icon(Icons.delete_outline_rounded, color: Colors.red, size: 18), 
            title: Text("Delete", style: TextStyle(color: Colors.red, fontSize: 14))
          ),
        ),
      ],
    );
  }

  void _showEditDialog(String messageId, String oldContent) {
    final TextEditingController editCtrl = TextEditingController(text: oldContent);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text("Edit Message", style: TextStyle(color: primaryBlue, fontWeight: FontWeight.bold, fontSize: 18)),
        content: TextField(
          controller: editCtrl, 
          autofocus: true, 
          decoration: InputDecoration(
            hintText: "Enter new message",
            hintStyle: TextStyle(color: Colors.grey.shade400),
            focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: primaryBlue)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context), 
            child: Text("Cancel", style: TextStyle(color: Colors.grey.shade600))
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryBlue,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              elevation: 0,
            ),
            onPressed: () async {
              if (editCtrl.text.trim().isNotEmpty) {
                Navigator.pop(context);
                bool ok = await ApiService.editMessage(messageId, editCtrl.text.trim());
                if (ok) _loadMessages();
              }
            },
            child: const Text("Save", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
      decoration: BoxDecoration(
        color: Colors.white, 
        border: Border(top: BorderSide(color: Colors.grey.shade100, width: 1))
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              style: const TextStyle(fontSize: 14),
              decoration: InputDecoration(
                hintText: "Type a message...",
                hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
                filled: true,
                fillColor: Colors.grey.shade100,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              ),
            ),
          ),
          const SizedBox(width: 10),
          CircleAvatar(
            radius: 20,
            backgroundColor: primaryBlue,
            child: IconButton(
              icon: isSending 
                ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : const Icon(Icons.send_rounded, color: Colors.white, size: 16),
              onPressed: isSending ? null : _send,
            ),
          ),
        ],
      ),
    );
  }
}