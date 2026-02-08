import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../models/todo_model.dart';
import 'package:uuid/uuid.dart';

typedef OnSaveTodo = void Function(TodoModel todo);

class TodoFormSheet extends StatefulWidget {
  const TodoFormSheet({
    super.key,
    this.todo,
    required this.onSave,
  });

  final TodoModel? todo;
  final OnSaveTodo onSave;

  @override
  State<TodoFormSheet> createState() => _TodoFormSheetState();
}

class _TodoFormSheetState extends State<TodoFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _descController;
  late final TextEditingController _minController;
  late final TextEditingController _secController;
  bool get isEditing => widget.todo != null;

  static const int maxTotalSeconds = 5 * 60; // 5 min

  @override
  void initState() {
    super.initState();
    final t = widget.todo;
    _titleController = TextEditingController(text: t?.title ?? '');
    _descController = TextEditingController(text: t?.description ?? '');
    final dur = t?.durationSeconds ?? 0;
    _minController = TextEditingController(text: '${dur ~/ 60}');
    _secController = TextEditingController(text: '${dur % 60}');
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _minController.dispose();
    _secController.dispose();
    super.dispose();
  }

  int get _totalSeconds {
    final m = int.tryParse(_minController.text) ?? 0;
    final s = int.tryParse(_secController.text) ?? 0;
    return m * 60 + s;
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    if (_totalSeconds <= 0) {
      Get.snackbar('Error', 'Time must be at least 1 second');
      return;
    }
    if (_totalSeconds > maxTotalSeconds) {
      Get.snackbar('Error', 'Time cannot exceed 5 minutes');
      return;
    }
    final isEditing = widget.todo != null;
    final existing = widget.todo;
    TodoModel todo;
    if (isEditing && existing != null) {
      todo = existing.copyWith(
        title: _titleController.text.trim(),
        description: _descController.text.trim(),
        durationSeconds: _totalSeconds,
      );
      // When a Done todo's timer is edited, reset to TODO and clear elapsed/timer.
      if (existing.status == TodoStatus.done &&
          _totalSeconds != existing.durationSeconds) {
        todo.status = TodoStatus.todo;
        todo.elapsedSeconds = 0;
        todo.timerStartedAt = null;
        todo.timerRunStartElapsed = null;
      }
    } else {
      todo = TodoModel(
        id: const Uuid().v4(),
        title: _titleController.text.trim(),
        description: _descController.text.trim(),
        durationSeconds: _totalSeconds,
      );
    }
    widget.onSave(todo);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                isEditing ? 'Edit TODO' : 'Add TODO',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  border: OutlineInputBorder(),
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Enter a title';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _minController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Minutes (0–5)',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _secController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Seconds (0–59)',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Max 5 minutes total',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.back(),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: _save,
                      child: const Text('Save'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
