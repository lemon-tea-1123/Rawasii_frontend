import 'package:flutter/material.dart';
import 'package:rawasii/Classes/user.dart';
import 'package:rawasii/pages/Home/SearchResult.dart';
import 'package:rawasii/responsiveWrapper.dart';
import 'package:rawasii/pages/Home/home.dart';
import 'package:rawasii/pages/profile/ProfilePage.dart';
import 'package:rawasii/pages/profile/sideBar.dart';
import 'package:rawasii/pages/Home/rightPanel.dart';
import 'package:rawasii/globals.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:rawasii/pages/Home/notification.dart';
import 'package:rawasii/pages/Home/savedPosts.dart';
import 'package:rawasii/pages/Home/visit.dart';
import 'package:rawasii/pages/Home/monuments.dart';
import 'package:rawasii/utils/user_data.dart';
import 'package:rawasii/navigation_notifier.dart';
import 'package:rawasii/pages/Home/groups.dart'; // ← shellNav lives here

class Appshell extends StatefulWidget {
  const Appshell({super.key});

  @override
  AppshellState createState() => AppshellState();
}

class AppshellState extends State<Appshell> {
  int _selectedIndex = 0;

  // ── Who to show on the profile page (null = own profile) ─────────────
  User? _profileTarget;

  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _initData();
    shellNav.addListener(_onNavChange);
  }

  @override
  void dispose() {
    shellNav.removeListener(_onNavChange);
    super.dispose();
  }

  // ── Called whenever any widget calls shellNav.goTo() or goToProfile() ─
  void _onNavChange() {
    setState(() {
      _selectedIndex = shellNav.index;
      _profileTarget = shellNav.profileUser; // may be null = own profile
    });

    // Close drawer if open
    final scaffold = Scaffold.maybeOf(context);
    if (scaffold != null && scaffold.isDrawerOpen) {
      Navigator.pop(context);
    }
  }

  Future<void> _initData() async {
    await UserData.init();
    if (mounted) setState(() => _loading = false);
  }

  // ── Also keep _onTap for the bottom nav / sidebar ─────────────────────
  void _onTap(int index) {
    setState(() {
      _selectedIndex = index;
      _profileTarget = null; // bottom nav profile = own profile
    });
    final scaffold = Scaffold.maybeOf(context);
    if (scaffold != null && scaffold.isDrawerOpen) Navigator.pop(context);
  }

  Widget _getPage() {
    switch (_selectedIndex) {
      case 0:
        return const HomePage();
      case 1:
        return const NotificationPage();
      case 2:
        return const SavedPosts();
      case 3:
        return const GroupsPage();
      case 4:
        // ✅ Pass _profileTarget — null means own profile, user = other profile
        return Profilepage(otherUser: _profileTarget);
      case 5:
        // ← UniqueKey forces a fresh widget every time search is opened,
        //   so initState re-runs and keyboard always opens.
        return SearchPage(key: UniqueKey());
      case 12:
        return const MonumentsInDangerPage();
      case 13:
        return const VisitsPage();
      default:
        return const HomePage();
    }
  }

  Widget _svgIcon(String path, {bool active = false}) => SvgPicture.asset(
    path,
    width: 35,
    height: 35,
    colorFilter: ColorFilter.mode(darkColor, BlendMode.modulate),
  );

  @override
  Widget build(BuildContext context) {
    final layout = AdaptiveLayout.layoutOf(context);
    final isTablet = layout == LayoutType.tablet;
    final User? user = UserData.userOne;

    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return AdaptiveLayout(
      mainContent: _getPage(),

      sidebar: Sidebar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onTap,
        compact: isTablet,
        isAdmin: user?.id == 34,
      ),

      rightPanel: const RightPanel(),

      appBar: AppBar(
        backgroundColor: bgColor,
        title: SizedBox(
          width: MediaQuery.sizeOf(context).width * 0.4,
          child: Image.asset('assets/logodark.png'),
        ),
        centerTitle: true,
        leading: Builder(
          builder: (ctx) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(ctx).openDrawer(),
          ),
        ),
      ),

      drawer: Drawer(
        child: Sidebar(
          selectedIndex: _selectedIndex,
          onItemTapped: _onTap,
          compact: false,
          isAdmin: user?.id == 34,
        ),
      ),

      bottomNav: NavigationBar(
        selectedIndex: _selectedIndex.clamp(0, 4),
        backgroundColor: secColor,
        onDestinationSelected: _onTap,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysHide,
        height: 65,
        destinations: [
          NavigationDestination(
            icon: _svgIcon('assets/Home.svg'),
            selectedIcon: _svgIcon('assets/Home.svg', active: true),
            label: '',
          ),
          NavigationDestination(
            icon: _svgIcon('assets/Bell.svg'),
            selectedIcon: _svgIcon('assets/Bell.svg', active: true),
            label: '',
          ),
          NavigationDestination(
            icon: _svgIcon('assets/Star.svg'),
            selectedIcon: _svgIcon('assets/Star.svg', active: true),
            label: '',
          ),
          NavigationDestination(
            icon: _svgIcon('assets/messages.svg'),
            selectedIcon: _svgIcon('assets/messages.svg', active: true),
            label: '',
          ),
          NavigationDestination(
            icon: _svgIcon('assets/User.svg'),
            selectedIcon: _svgIcon('assets/User.svg', active: true),
            label: '',
          ),
        ],
      ),
    );
  }
}
