import 'package:flutter/material.dart';
import 'dart:async';
import 'package:intl/intl.dart';
import '../services/api_service.dart';

class ChatUI extends StatefulWidget {
  final String currentUserId, receiverId, receiverName;
  const ChatUI({
    super.key,
    required this.currentUserId,
    required this.receiverId,
    required this.receiverName
  });

  @override
  State<ChatUI> createState() => _ChatUIState();
}

class _ChatUIState extends State<ChatUI> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  List<dynamic> _messages = [];
  Timer? _timer;
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    _loadMessages();
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (!_isSending && mounted) {
        _loadMessages(isAuto: true);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  String _formatMessageTime(String? timestamp) {
    if (timestamp == null || timestamp.isEmpty) return "";
    try {
      DateTime dt = DateTime.parse(timestamp).toLocal();
      return DateFormat('HH:mm').format(dt);
    } catch (e) { return ""; }
  }

  Future<void> _loadMessages({bool isAuto = false}) async {
    if (_isSending) return;
    try {
      final data = await ApiService.getChatHistory(widget.currentUserId, widget.receiverId);
      if (mounted && !_isSending) {
        setState(() { _messages = data; });
        if (!isAuto && _messages.isNotEmpty) { _scrollToBottom(); }
      }
    } catch (e) { debugPrint("Error: $e"); }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendMessage() async {
    if (_controller.text.trim().isEmpty) return;
    String text = _controller.text.trim();
    setState(() { _isSending = true; });

    var tempMsg = {
      'sender_id': widget.currentUserId,
      'content': text,
      'timestamp': DateTime.now().toIso8601String(),
      'is_temp': true,
    };

    setState(() { _messages.add(tempMsg); });
    _controller.clear();
    _scrollToBottom();

    try {
      bool ok = await ApiService.sendMessage(widget.currentUserId, widget.receiverId, text);
      if (ok) { await _loadMessages(); } 
      else { setState(() { _messages.removeWhere((m) => m['is_temp'] == true); }); }
    } catch (e) {
      setState(() { _messages.removeWhere((m) => m['is_temp'] == true); });
    } finally {
      if (mounted) setState(() { _isSending = false; });
    }
  }

  // delete edit fonction
  void _showOptions(String msgId, String content) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Wrap(
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text("Options", style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          ListTile(
            leading: const Icon(Icons.edit, color: Color(0xFF00ADEE)),
            title: const Text('Edit message'),
            onTap: () {
              Navigator.pop(context);
              _showEditDialog(msgId, content);
            },
          ),
          ListTile(
            leading: const Icon(Icons.delete_forever, color: Colors.red),
            title: const Text('Delete for everyone', style: TextStyle(color: Colors.red)),
            onTap: () async {
              Navigator.pop(context);
              bool ok = await ApiService.deleteMessage(msgId);
              if (ok) _loadMessages();
            },
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  void _showEditDialog(String messageId, String oldContent) {
    final TextEditingController editCtrl = TextEditingController(text: oldContent);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Edit Message"),
        content: TextField(controller: editCtrl, autofocus: true),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00ADEE)),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F9),
      appBar: AppBar(
        title: Text(widget.receiverName, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white, elevation: 1,
        iconTheme: const IconThemeData(color: Color(0xFF00ADEE)),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                var msg = _messages[index];
                bool isMe = msg['sender_id'].toString() == widget.currentUserId.toString();
                bool isTemp = msg['is_temp'] == true;

                return GestureDetector(
                  onLongPress: isMe && !isTemp ? () => _showOptions(msg['id_message'].toString(), msg['content'] ?? "") : null,
                  child: Align(
                    alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                    child: ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: isMe ? const Color(0xFF00ADEE) : Colors.white,
                          borderRadius: BorderRadius.only(
                            topLeft: const Radius.circular(16),
                            topRight: const Radius.circular(16),
                            bottomLeft: Radius.circular(isMe ? 16 : 0),
                            bottomRight: Radius.circular(isMe ? 0 : 16),
                          ),
                          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5, offset: const Offset(0, 2))],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(msg['content'] ?? "", style: TextStyle(color: isMe ? Colors.white : Colors.black87, fontSize: 15)),
                            const SizedBox(height: 4),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(_formatMessageTime(msg['timestamp']), style: TextStyle(color: isMe ? Colors.white70 : Colors.black45, fontSize: 10)),
                                if (isMe) ...[
                                  const SizedBox(width: 4),
                                  Icon(isTemp ? Icons.access_time : Icons.done_all, size: 12, color: Colors.white70),
                                ]
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          _buildInput(),
        ],
      ),
    );
  }

  Widget _buildInput() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: const BoxDecoration(color: Colors.white, border: Border(top: BorderSide(color: Color(0xFFEEEEEE)))),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(color: const Color(0xFFF0F2F5), borderRadius: BorderRadius.circular(24)),
                child: TextField(
                  controller: _controller,
                  decoration: const InputDecoration(hintText: "Type a message...", border: InputBorder.none),
                  onSubmitted: (_) => _sendMessage(),
                ),
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: _isSending ? null : _sendMessage,
              child: CircleAvatar(
                backgroundColor: const Color(0xFF00ADEE),
                child: _isSending 
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Icon(Icons.send, color: Colors.white, size: 20),
              ),
            ),
          ],
        ),
      ),
    );
  }
}