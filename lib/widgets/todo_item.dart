import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/todo_controller.dart';
import '../models/todo_model.dart';

class TodoItem extends StatelessWidget {
  const TodoItem({super.key, required this.todo});

  final TodoModel todo;

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

  static Color _statusColor(TodoStatus status) {
    switch (status) {
      case TodoStatus.todo:
        return Colors.grey;
      case TodoStatus.inProgress:
        return Colors.orange;
      case TodoStatus.done:
        return Colors.green;
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<TodoController>();
    final isRunning = controller.isRunning(todo.id);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: InkWell(
        onTap: () => Get.toNamed('/detail', arguments: todo.id),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      todo.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    if (todo.description.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        todo.description,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: _statusColor(todo.status).withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            _statusLabel(todo.status),
                            style: TextStyle(
                              color: _statusColor(todo.status),
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        if (todo.status != TodoStatus.todo || isRunning)
                          Text(
                            '${_formatTime(todo.elapsedSeconds)} / ${_formatTime(todo.durationSeconds)}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[700],
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.red),
                onPressed: () {
                  Get.dialog(
                    AlertDialog(
                      title: const Text('Delete'),
                      content: Text(
                        'Remove "${todo.title}"?',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Get.back(),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () {
                            controller.deleteTodo(todo.id);
                            Get.back();
                          },
                          child: const Text('Delete', style: TextStyle(color: Colors.red)),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
