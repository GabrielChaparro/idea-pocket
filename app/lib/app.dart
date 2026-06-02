import 'package:flutter/material.dart';

import 'auth/app_shell.dart';
import 'core/app_theme.dart';

class IdeaPocketApp extends StatelessWidget {
  const IdeaPocketApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'IdeaPocket',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      home: const AppShell(),
    );
  }
}

