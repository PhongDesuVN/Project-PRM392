import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'features/auth/login/login_page.dart';
import 'firebase_options.dart';
import 'shared/ui.dart';

void main() async {
  // 1. Đảm bảo Flutter Binding sẵn sàng trước khi chạy các tác vụ nền
  WidgetsFlutterBinding.ensureInitialized();

  // 2. Khởi tạo Firebase Authentication và Services
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // 3. Khởi chạy ứng dụng
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Nihon',
      theme: AppTheme.light,
      debugShowCheckedModeBanner: false,
      home: const LoginPage(),
    );
  }
}
