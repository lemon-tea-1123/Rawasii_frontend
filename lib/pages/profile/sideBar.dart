import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:rawasii/globals.dart';
import 'package:rawasii/Classes/user.dart';
import 'package:rawasii/utils/user_data.dart';

class Sidebar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onItemTapped;
  final bool compact;
  final bool isAdmin;

  Sidebar({
    super.key,
    required this.selectedIndex,
    required this.onItemTapped,
    this.compact = false,
    required this.isAdmin, // ← false by default, not everyone sees it
  });

  // ── Each item: (svgPath, label, index) ────────────────────────────────────
  // index 10+ range for sidebar
  static const _items = [
    ('assets/houseSolid.svg', 'Dashboard', 10),
    ('assets/SearchSide.svg', 'Explore', 11),
    ('assets/danger.svg', 'Monument in Danger', 12),
    ('assets/visit.svg', 'Visits', 13),
    ('assets/setting.svg', 'Settings', 14),
  ];

  // admin item separately so we can show/hide it
  static const _adminItem = ('assets/admin.svg', 'Admin Panel', 15);
  final user = UserData.userOne;
  // void _isAdmin (){
  //   setState((){
  //   if(user?.id==34){
  //     this.isAdmin =true;

  //   }
  // })
  // }

  Widget _buildContent(BuildContext context) {
    return Container(
      color: bgColor,
      child: Column(
        children: [
          const SizedBox(height: 60),

          // ── User header ────────────────────────────────────────────────────
          if (!compact)
            Padding(
              padding: const EdgeInsets.only(left: 20),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 25,
                    backgroundColor: darkColor.withOpacity(0.2),
                    child: Icon(Icons.person, color: darkColor),
                  ),
                  const SizedBox(width: 15),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Welcome to Rawasii',
                        style: TextStyle(color: darkColor),
                      ),
                      Text(
                        'Good Morning',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: darkColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            )
          else
            CircleAvatar(
              radius: 20,
              backgroundColor: darkColor.withOpacity(0.2),
              child: Icon(Icons.person, color: darkColor, size: 20),
            ),

          const SizedBox(height: 40),

          // ── Regular menu items ─────────────────────────────────────────────
          ..._items.map((item) {
            final (path, label, index) = item;
            return _MenuItem(
              svgPath: path,
              label: label,
              selected: selectedIndex == index,
              compact: compact,
              onTap: () => onItemTapped(index),
            );
          }),

          // ── Admin panel (only if isAdmin is true) ──────────────────────────
          if (isAdmin) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Divider(color: darkColor.withOpacity(0.2)),
            ),
            _MenuItem(
              svgPath: _adminItem.$1,
              label: _adminItem.$2,
              selected: selectedIndex == _adminItem.$3,
              compact: compact,
              onTap: () => Navigator.pushNamed(context, '/adminPage'),
              isAdmin: true, // ← special styling for admin
            ),
          ],

          const Spacer(),

          // ── Logout at bottom ───────────────────────────────────────────────
          _MenuItem(
            svgPath: 'assets/logout.svg',
            label: 'Logout',
            selected: false,
            compact: compact,
            onTap: () {
              // your logout logic
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) => _buildContent(context);
}

// ── Single menu item ──────────────────────────────────────────────────────────
class _MenuItem extends StatelessWidget {
  final String svgPath;
  final String label;
  final bool selected;
  final bool compact;
  final bool isAdmin;
  final VoidCallback onTap;

  const _MenuItem({
    required this.svgPath,
    required this.label,
    required this.selected,
    required this.compact,
    required this.onTap,
    this.isAdmin = false,
  });

  Widget _icon({required bool active}) {
    return SvgPicture.asset(
      svgPath,
      width: 24,
      height: 24,
      colorFilter: ColorFilter.mode(
        isAdmin
            ? Colors
                  .redAccent // admin always red
            : active
            ? thirdColor // selected → accent color
            : darkColor, // normal → dark color
        BlendMode.srcIn,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: compact ? 8 : 15, vertical: 6),
      child: Container(
        decoration: BoxDecoration(
          color: selected ? thirdColor.withOpacity(0.2) : Colors.transparent,
          borderRadius: BorderRadius.circular(30),
        ),
        child: compact
            ? IconButton(
                icon: _icon(active: selected),
                onPressed: onTap,
                tooltip: label,
              )
            : ListTile(
                leading: _icon(active: selected),
                title: Text(
                  label,
                  style: TextStyle(
                    color: isAdmin
                        ? Colors.redAccent
                        : selected
                        ? thirdColor
                        : darkColor,
                    fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
                onTap: onTap,
              ),
      ),
    );
  }
}
