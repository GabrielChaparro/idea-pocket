import 'package:flutter/material.dart';

import 'auth/app_shell.dart';
import 'core/app_theme.dart';

class FarodeckApp extends StatelessWidget {
  const FarodeckApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Farodeck',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      home: const AppShell(),
    );
  }
}
