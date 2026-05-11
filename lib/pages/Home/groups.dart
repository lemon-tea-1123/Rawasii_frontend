import 'package:flutter/material.dart';
import 'package:rawasii/globals.dart';
import 'package:rawasii/utils/user_data.dart';
import 'groupchat.dart' hide bgColor, darkColor, secColor;

class GroupsPage extends StatelessWidget {
  const GroupsPage({super.key});

  static const List<Map<String, String>> _groups = [
    {"name": "Algerian Monuments", "id": "3"},
    {"name": "Numidian Echoes", "id": "2"},
    {"name": "L'Algérie Blanche", "id": "4"},
    {"name": "Sauver le Patrimoine", "id": "5"},
    {"name": "Amis de Patrimoine", "id": "6"},
    {"name": "The Casbah Corner", "id": "7"},
  ];

  @override
  Widget build(BuildContext context) {
    // ✅ Real user ID from session — not hardcoded "1"
    final userId = UserData.userOne?.id.toString() ?? '';

    return ColoredBox(
      color: bgColor,
      child: ListView.separated(
        itemCount: _groups.length,
        separatorBuilder: (_, __) => Divider(
          color: darkColor.withOpacity(0.12),
          thickness: 0.8,
          indent: 15,
          endIndent: 15,
        ),
        itemBuilder: (context, index) {
          final group = _groups[index];
          return ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 6,
            ),
            leading: CircleAvatar(
              backgroundColor: secColor,
              child: Icon(Icons.group_rounded, color: darkColor),
            ),
            title: Text(
              group["name"]!,
              style: TextStyle(
                color: darkColor,
                fontFamily: "Tajawal",
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            trailing: Icon(
              Icons.chevron_right,
              color: darkColor.withOpacity(0.4),
            ),
            onTap: () {
              // ✅ Navigator.push is correct here — GroupChatPage has its
              // own AppBar with a back button, so leaving the shell is fine.
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => GroupChatPage(
                    groupName: group["name"]!,
                    groupId: group["id"]!,
                    userId: userId, // ✅ real user ID
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
