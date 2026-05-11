import 'package:flutter/material.dart';

import 'package:rawasii/pages/loading.dart';

import 'package:rawasii/pages/profile/ProfilePage.dart';
import 'package:rawasii/pages/profile/EditProfile.dart';
import 'package:rawasii/pages/profile/addapost.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:rawasii/pages/Home/appshell.dart';
import 'package:rawasii/pages/Home/auth.dart';
import 'package:rawasii/pages/Home/SearchResult.dart';
import 'package:rawasii/admin/admin_panel_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: 'https://ilqeknvefqtnvbcimfca.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImlscWVrbnZlZnF0bnZiY2ltZmNhIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzMwNDU1NDEsImV4cCI6MjA4ODYyMTU0MX0.7wQEiqAcgfgAcOFHrrtuz-y0rhynUMsggI-ldmRJrgA',
  );
  runApp(
    MaterialApp(
      initialRoute: '/',
      routes: {
        '/': (context) => Loading(),
        '/profilepage': (context) => Profilepage(),
        '/editpage': (context) => EditProfile(),
        '/login': (context) => LoginPage(),

        '/addapost': (context) => AddPost(),
        '/search': (context) => SearchPage(),
        '/adminPage': (context) => AdminPanelPage(),

        '/appshell': (context) => Appshell(),
      },
    ),
  );
}
