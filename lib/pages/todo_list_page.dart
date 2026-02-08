import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/todo_controller.dart';
import '../models/todo_model.dart';
import '../widgets/todo_item.dart';
import 'todo_form_sheet.dart';

class TodoListPage extends StatefulWidget {
  const TodoListPage({super.key});

  @override
  State<TodoListPage> createState() => _TodoListPageState();
}

class _TodoListPageState extends State<TodoListPage>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      if (Get.isRegistered<TodoController>()) {
        Get.find<TodoController>().onAppResumed();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(TodoController());

    return Scaffold(
      appBar: AppBar(
        title: const Text('Todos'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Obx(() {
        if (controller.todos.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.assignment_outlined, size: 64, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  'No todos yet',
                  style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                ),
              ],
            ),
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.only(top: 8, bottom: 80),
          itemCount: controller.todos.length,
          itemBuilder: (_, i) => TodoItem(todo: controller.todos[i]),
        );
      }),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () => _openForm(context, null),
      //   child: const Icon(Icons.add),
      // ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: ElevatedButton(
        onPressed: () => _openForm(context, null),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue.shade200,
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: const Text(
          'Add Todo',
          style: TextStyle(fontSize: 16,color: Colors.black),
        ),
      ),
    );
  }

  void _openForm(BuildContext context, TodoModel? todo) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => TodoFormSheet(
        todo: todo,
        onSave: (model) {
          final c = Get.find<TodoController>();
          if (todo == null) {
            c.addTodo(model);
          } else {
            c.updateTodo(model);
          }
          Get.back();
        },
      ),
    );
  }
}
