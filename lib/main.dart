import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:do_an/Theme/theme.dart';
import 'package:do_an/Stores/auth_store.dart';
import 'package:do_an/Screens/login_screen.dart';
import 'package:do_an/Screens/main_screen.dart';
import 'package:do_an/Screens/admin_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );
  runApp(const TrafficReportApp());
}

class TrafficReportApp extends StatefulWidget {
  const TrafficReportApp({super.key});

  @override
  State<TrafficReportApp> createState() => _TrafficReportAppState();
}

class _TrafficReportAppState extends State<TrafficReportApp> {
  final _auth = AuthStore();

  @override
  void initState() {
    super.initState();
    _auth.addListener(_onAuthChanged);
  }

  @override
  void dispose() {
    _auth.removeListener(_onAuthChanged);
    super.dispose();
  }

  void _onAuthChanged() => setState(() {});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CIR - Báo cáo đô thị',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: _buildHome(),
    );
  }

  Widget _buildHome() {
    if (!_auth.isLoggedIn) return const LoginScreen();
    if (_auth.isAdmin) return const AdminScreen();
    return const MainScreen();
  }
}
