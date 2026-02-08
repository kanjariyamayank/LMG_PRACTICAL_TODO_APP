import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'pages/todo_detail_page.dart';
import 'pages/todo_list_page.dart';
import 'services/todo_storage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final storage = TodoStorage();
  await storage.init();
  Get.put<TodoStorage>(storage);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Todo App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue.shade200),
        useMaterial3: true,
      ),
      initialRoute: '/',
      getPages: [
        GetPage(name: '/', page: () => const TodoListPage()),
        GetPage(name: '/detail', page: () => const TodoDetailPage()),
      ],
    );
  }
}
