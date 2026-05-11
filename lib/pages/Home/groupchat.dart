import 'package:flutter/material.dart';
import 'package:rawasii/globals.dart';
import 'package:rawasii/services/api.dart';
import 'groupchat_members.dart' hide thirdColor, darkColor, bgColor, secColor;

class GroupChatPage extends StatefulWidget {
  final String groupName;
  final String groupId;
  final String userId;

  const GroupChatPage({
    Key? key,
    required this.groupName,
    required this.groupId,
    required this.userId,
  }) : super(key: key);

  @override
  State<GroupChatPage> createState() => _GroupChatPageState();
}

class _GroupChatPageState extends State<GroupChatPage> {
  List<Map<String, dynamic>> messages = [];
  final ScrollController _controller = ScrollController();
  final TextEditingController _messageController = TextEditingController();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMessages();
  }

  Future<void> _loadMessages() async {
    setState(() => _isLoading = true);

    final realMessages = await ApiService.getMessages(widget.groupId);

    setState(() {
      messages = realMessages.map((msg) {
        final user = msg['user'] ?? {};
        return {
          "text": msg['content'],
          "isMe": msg['user_id'].toString() == widget.userId,
          "username": user['username'] ?? 'Unknown',
          "time": _formatTime(msg['created_at']),
        };
      }).toList();
      _isLoading = false;
    });
  }

  String _formatTime(String? dateTimeString) {
    if (dateTimeString == null) return "";
    try {
      final time = DateTime.parse(dateTimeString);
      return "${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}";
    } catch (e) {
      return "";
    }
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;

    final success = await ApiService.sendMessage(
      senderId: widget.userId,
      groupId: widget.groupId,
      content: _messageController.text.trim(),
    );

    if (success) {
      _messageController.clear();
      await _loadMessages();

      // Scroll to bottom after sending
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_controller.hasClients) {
          _controller.animateTo(
            0,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Failed to send message')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: darkColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.groupName,
          style: const TextStyle(
            color: darkColor,
            fontFamily: "Tajawal",
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.people, color: darkColor),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => GroupMembersPage(
                    groupName: widget.groupName,
                    groupId: widget.groupId,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : messages.isEmpty
                ? const Center(
                    child: Text(
                      'No messages yet.\nSend the first message!',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: darkColor),
                    ),
                  )
                : ListView.builder(
                    controller: _controller,
                    reverse: true,
                    padding: const EdgeInsets.all(10),
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final msg = messages[index];
                      final isMe = msg["isMe"] == true;

                      return Align(
                        alignment: isMe
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                        child: Column(
                          crossAxisAlignment: isMe
                              ? CrossAxisAlignment.end
                              : CrossAxisAlignment.start,
                          children: [
                            if (!isMe)
                              Padding(
                                padding: const EdgeInsets.only(
                                  left: 8,
                                  bottom: 2,
                                ),
                                child: Text(
                                  msg["username"],
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: darkColor,
                                  ),
                                ),
                              ),
                            Container(
                              margin: const EdgeInsets.symmetric(vertical: 4),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: isMe ? secColor : thirdColor,
                                borderRadius: BorderRadius.circular(15),
                              ),
                              constraints: BoxConstraints(
                                maxWidth:
                                    MediaQuery.of(context).size.width * 0.7,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    msg["text"],
                                    style: const TextStyle(
                                      color: darkColor,
                                      fontFamily: "Tajawal",
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    msg["time"],
                                    style: const TextStyle(
                                      fontSize: 10,
                                      color: darkColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            color: bgColor,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    onSubmitted: (_) => _sendMessage(),
                    style: const TextStyle(
                      fontFamily: "Tajawal",
                      fontWeight: FontWeight.bold,
                      color: darkColor,
                    ),
                    decoration: InputDecoration(
                      hintText: "Type a message...",
                      hintStyle: const TextStyle(
                        fontFamily: "Tajawal",
                        fontWeight: FontWeight.bold,
                        color: thirdColor,
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 15,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 5),
                GestureDetector(
                  onTap: _sendMessage,
                  child: const Icon(Icons.send, color: darkColor),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
