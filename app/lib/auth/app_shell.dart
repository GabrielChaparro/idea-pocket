import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../items/inbox_page.dart';
import 'auth_page.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  String? token;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _loadToken();
  }

  Future<void> _loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      token = prefs.getString('token');
      loading = false;
    });
  }

  Future<void> _setToken(String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', value);
    setState(() => token = value);
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    setState(() => token = null);
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (token == null) {
      return AuthPage(onAuthenticated: _setToken);
    }

    return InboxPage(token: token!, onLogout: _logout);
  }
}

