import 'package:flutter/material.dart';

import '../core/api_exception.dart';
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
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('IdeaPocket', style: Theme.of(context).textTheme.headlineLarge),
                const SizedBox(height: 24),
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
    );
  }
}
