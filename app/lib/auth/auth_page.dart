import 'package:flutter/material.dart';

import '../core/api_exception.dart';
import '../core/app_theme.dart';
import '../core/retro_panel.dart';
import 'auth_api.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key, required this.onAuthenticated});

  final ValueChanged<String> onAuthenticated;

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final authApi = AuthApi();
  final email = TextEditingController();
  final password = TextEditingController();
  final name = TextEditingController();
  bool register = false;
  bool loading = false;
  String? error;

  Future<void> submit() async {
    setState(() {
      loading = true;
      error = null;
    });

    try {
      final token = await authApi.authenticate(
        register: register,
        email: email.text,
        password: password.text,
        name: name.text,
      );
      widget.onAuthenticated(token);
    } catch (e) {
      setState(() => error = errorMessage(e));
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF9DAED0), Color(0xFFB9CFB1)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: RetroPanel(
                padding: const EdgeInsets.all(20),
                color: const Color(0xFFECE6C4),
                child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: retroShell,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: retroInk, width: 2),
                  ),
                  child: const Text(
                    'IDEAPOCKET',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                const RetroScreen(
                  shadow: false,
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: Text(
                    'POCKET OS // CAPTURE READY',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900),
                  ),
                ),
                const SizedBox(height: 18),
                if (register) ...[
                  TextField(controller: name, decoration: const InputDecoration(labelText: 'Nombre')),
                  const SizedBox(height: 12),
                ],
                TextField(controller: email, decoration: const InputDecoration(labelText: 'Email')),
                const SizedBox(height: 12),
                TextField(
                  controller: password,
                  decoration: const InputDecoration(labelText: 'Password'),
                  obscureText: true,
                ),
                const SizedBox(height: 12),
                if (error != null) Text(error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
                const SizedBox(height: 12),
                FilledButton(
                  onPressed: loading ? null : submit,
                  child: Text(register ? 'Crear cuenta' : 'Entrar'),
                ),
                TextButton(
                  onPressed: loading ? null : () => setState(() => register = !register),
                  child: Text(register ? 'Ya tengo cuenta' : 'Crear cuenta personal'),
                ),
              ],
            ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
