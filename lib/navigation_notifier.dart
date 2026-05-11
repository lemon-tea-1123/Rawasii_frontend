// lib/navigation_notifier.dart
//
// Global navigation state for the app shell.
// Any widget can trigger shell-level navigation without ancestor lookup:
//
//   // Go to a page by index (no user context):
//   shellNav.goTo(5);
//
//   // Go to another user's profile:
//   shellNav.goToProfile(user);
//
//   // Go to own profile:
//   shellNav.goTo(4);

import 'package:flutter/foundation.dart';
import 'package:rawasii/Classes/user.dart';

class _ShellNavNotifier extends ChangeNotifier {
  int _index = 0;
  User? _profileUser; // null = current user's own profile

  int get index => _index;

  /// The user whose profile should be shown when index == 4.
  /// null means "show my own profile".
  User? get profileUser => _profileUser;

  /// Navigate to any shell page by index.
  /// Always notifies — even if already on that index — so re-tapping
  /// the search bar always re-focuses the TextField.
  void goTo(int index) {
    _index = index;
    _profileUser = null;
    notifyListeners(); // always fires, even if _index unchanged
  }

  /// Navigate to the profile page showing [user].
  /// Pass null to show the current user's own profile.
  void goToProfile(User? user) {
    _index = 4; // profile page index
    _profileUser = user;
    notifyListeners();
  }
}

/// Single global instance — import this everywhere.
final shellNav = _ShellNavNotifier();
