import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/todo_controller.dart';
import '../models/todo_model.dart';
import 'todo_form_sheet.dart';

class TodoDetailPage extends StatelessWidget {
  const TodoDetailPage({super.key});

  static String _formatTime(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  static String _statusLabel(TodoStatus status) {
    switch (status) {
      case TodoStatus.todo:
        return 'TODO';
      case TodoStatus.inProgress:
        return 'In-Progress';
      case TodoStatus.done:
        return 'Done';
    }
  }

  @override
  Widget build(BuildContext context) {
    final id = Get.arguments as String?;
    if (id == null) {
      Get.back();
      return const SizedBox.shrink();
    }

    final controller = Get.find<TodoController>();
    final todo = controller.getTodoById(id);
    if (todo == null) {
      Get.back();
      return const SizedBox.shrink();
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Todo List'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => _openEdit(context, todo),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Obx(() {
          final t = controller.getTodoById(id);
          if (t == null) return const SizedBox.shrink();

          final isRunning = controller.isRunning(t.id);
          final canStart = t.status != TodoStatus.done && t.elapsedSeconds < t.durationSeconds;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                t.title,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              if (t.description.isNotEmpty)
                Text(
                  t.description,
                  style: TextStyle(color: Colors.grey[700], height: 1.4),
                ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Chip(
                    label: Text(_statusLabel(t.status)),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '${_formatTime(t.elapsedSeconds)} / ${_formatTime(t.durationSeconds)}',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ],
              ),
              const SizedBox(height: 32),
              if (t.status != TodoStatus.done) ...[
                const Text('Timer', style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                Center(
                  child: Text(
                    _formatTime(t.elapsedSeconds),
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                          fontFeatures: [const FontFeature.tabularFigures()],
                        ),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (canStart)
                      IconButton.filled(
                        onPressed: isRunning
                            ? null
                            : () => controller.startTimer(t.id),
                        icon: const Icon(Icons.play_arrow),
                        tooltip: 'Start',
                      ),
                    const SizedBox(width: 12),
                    IconButton.filledTonal(
                      onPressed: isRunning ? () => controller.pauseTimer(t.id) : null,
                      icon: const Icon(Icons.pause),
                      tooltip: 'Pause',
                    ),
                    const SizedBox(width: 12),
                    IconButton.filledTonal(
                      onPressed: () => controller.stopTimer(t.id),
                      icon: const Icon(Icons.stop),
                      tooltip: 'Stop (mark done)',
                    ),
                  ],
                ),
              ] else
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Text('Completed', style: TextStyle(color: Colors.green)),
                  ),
                ),
            ],
          );
        }),
      ),
    );
  }

  void _openEdit(BuildContext context, TodoModel todo) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => TodoFormSheet(
        todo: todo,
        onSave: (model) {
          Get.find<TodoController>().updateTodo(model);
          Get.back();
        },
      ),
    );
  }
}
