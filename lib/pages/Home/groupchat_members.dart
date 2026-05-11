import 'package:flutter/material.dart';
import 'package:rawasii/globals.dart';
import 'package:rawasii/services/api.dart';

class GroupMembersPage extends StatefulWidget {
  final String groupName;
  final String groupId;

  const GroupMembersPage({
    Key? key,
    required this.groupName,
    required this.groupId,
  }) : super(key: key);

  @override
  State<GroupMembersPage> createState() => _GroupMembersPageState();
}

class _GroupMembersPageState extends State<GroupMembersPage> {
  List<dynamic> members = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMembers();
  }

  Future<void> _loadMembers() async {
    setState(() {
      isLoading = true;
    });

    final fetchedMembers = await ApiService.getGroupMembers(widget.groupId);

    setState(() {
      members = fetchedMembers;
      isLoading = false;
    });
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
          "${widget.groupName} Members",
          style: const TextStyle(
            color: darkColor,
            fontFamily: "Tajawal",
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : members.isEmpty
          ? const Center(
              child: Text('No members yet', style: TextStyle(color: darkColor)),
            )
          : Column(
              children: [
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: Row(
                    children: [
                      const Icon(Icons.group, color: darkColor),
                      const SizedBox(width: 10),
                      Text(
                        "${members.length} Members",
                        style: const TextStyle(
                          color: darkColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(color: secColor, thickness: 1),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    itemCount: members.length,
                    itemBuilder: (context, index) {
                      final member = members[index]['user'] ?? {};
                      final username = member['username'] ?? 'Unknown';
                      final email = member['email'] ?? '';

                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: secColor,
                          child: const Icon(Icons.person, color: darkColor),
                        ),
                        title: Text(
                          username,
                          style: const TextStyle(
                            color: darkColor,
                            fontFamily: "Tajawal",
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: email.isNotEmpty
                            ? Text(
                                email,
                                style: const TextStyle(
                                  color: darkColor,
                                  fontSize: 12,
                                ),
                              )
                            : null,
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}