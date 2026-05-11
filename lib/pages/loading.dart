import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:rawasii/pages/Home/appshell.dart';
import 'package:rawasii/pages/Home/auth.dart';

class Loading extends StatefulWidget {
  const Loading({super.key});

  @override
  State<Loading> createState() => _LoadingState();
}

class _LoadingState extends State<Loading> {
  @override
  void initState() {
    super.initState();
    _checkConnectionAndNavigate();
  }

  // ── web-compatible connection check ───────────────────────────────────
  Future<bool> _hasConnection() async {
    if (kIsWeb) {
      // on web — just assume connected
      // browser will handle network errors naturally
      return true;
    }
    try {
      // on mobile — try a quick ping
      final res = await http
          .get(Uri.parse('https://www.google.com'))
          .timeout(const Duration(seconds: 5));
      return res.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  Future<void> _checkConnectionAndNavigate() async {
    await Future.delayed(const Duration(seconds: 1));

    final hasConnection = await _hasConnection();

    if (!hasConnection) {
      if (mounted) _showNoConnectionDialog();
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    final isLoggedIn = token != null && token.isNotEmpty;

    if (mounted) {
      if (isLoggedIn) {
        Navigator.pushReplacementNamed(context, '/appshell');
      } else {
        Navigator.pushReplacementNamed(context, '/login');
      }
    }
  }

  Future<void> _showNoConnectionDialog() async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text('No Internet Connection'),
        content: const Text(
          'Please check your internet connection and try again.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _checkConnectionAndNavigate();
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2EDE6),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/logodark.png', width: 300),
            const SizedBox(height: 40),
            const SpinKitFadingCube(color: Color(0xFF4A2C24), size: 50.0),
          ],
        ),
      ),
    );
  }
}
