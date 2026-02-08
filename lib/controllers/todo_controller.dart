import 'dart:async';

import 'package:get/get.dart';

import '../models/todo_model.dart';
import '../services/todo_storage.dart';

class TodoController extends GetxController {
  TodoController({TodoStorage? storage})
      : _storage = storage ?? Get.find<TodoStorage>();

  final TodoStorage _storage;
  final RxList<TodoModel> todos = <TodoModel>[].obs;
  Timer? _timer;

  @override
  void onInit() {
    super.onInit();
    loadTodos();
  }

  @override
  void onClose() {
    _timer?.cancel();
    super.onClose();
  }

  Future<void> loadTodos() async {
    final list = await _storage.loadTodos();
    todos.assignAll(list);
    _recalcAnyRunningTodo();
    if (_hasAnyRunningTodo()) _startTicker();
    _persist();
  }

  Future<void> _persist() async {
    await _storage.saveTodos(todos);
  }

  int _computeElapsed(TodoModel todo) {
    final started = todo.timerStartedAt;
    final runStart = todo.timerRunStartElapsed;
    if (started == null || runStart == null) return todo.elapsedSeconds;
    final sec = runStart + DateTime.now().difference(started).inSeconds;
    final cap = todo.durationSeconds;
    return sec > cap ? cap : sec;
  }

  bool _hasAnyRunningTodo() {
    return todos.any((t) => t.timerStartedAt != null);
  }

  void _recalcAnyRunningTodo() {
    for (final todo in todos) {
      if (todo.timerStartedAt == null) continue;
      todo.elapsedSeconds = _computeElapsed(todo);
      if (todo.elapsedSeconds >= todo.durationSeconds) {
        todo.status = TodoStatus.done;
        todo.timerStartedAt = null;
        todo.timerRunStartElapsed = null;
      }
    }
    todos.refresh();
  }

  void onAppResumed() {
    _recalcAnyRunningTodo();
    if (_hasAnyRunningTodo()) _startTicker();
    _persist();
  }

  void _startTicker() {
    if (_timer != null) return;
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      bool anyRunning = false;
      for (final todo in todos) {
        if (todo.timerStartedAt == null) continue;
        anyRunning = true;
        final elapsed = _computeElapsed(todo);
        todo.elapsedSeconds = elapsed;
        if (elapsed >= todo.durationSeconds) {
          todo.status = TodoStatus.done;
          todo.timerStartedAt = null;
          todo.timerRunStartElapsed = null;
        }
      }
      if (!anyRunning) _stopTicker();
      todos.refresh();
      _persist();
    });
  }

  void _stopTicker() {
    if (!_hasAnyRunningTodo()) {
      _timer?.cancel();
      _timer = null;
    }
  }

  TodoModel? getTodoById(String id) {
    try {
      return todos.firstWhere((t) => t.id == id);
    } catch (_) {
      return null;
    }
  }

  void addTodo(TodoModel todo) {
    todos.insert(0, todo);
    _persist();
  }

  void updateTodo(TodoModel todo) {
    final index = todos.indexWhere((t) => t.id == todo.id);
    if (index >= 0) {
      todos[index] = todo;
      _stopTicker();
      todos.refresh();
      _persist();
    }
  }

  void deleteTodo(String id) {
    todos.removeWhere((t) => t.id == id);
    _stopTicker();
    _persist();
  }

  void startTimer(String id) {
    final todo = getTodoById(id);
    if (todo == null || todo.status == TodoStatus.done) return;
    if (todo.elapsedSeconds >= todo.durationSeconds) return;
    todo.timerStartedAt = DateTime.now();
    todo.timerRunStartElapsed = todo.elapsedSeconds;
    todo.status = TodoStatus.inProgress;
    todos.refresh();
    _startTicker();
    _persist();
  }

  void pauseTimer(String id) {
    final todo = getTodoById(id);
    if (todo == null || todo.timerStartedAt == null) return;
    todo.elapsedSeconds = _computeElapsed(todo);
    todo.timerStartedAt = null;
    todo.timerRunStartElapsed = null;
    todos.refresh();
    _stopTicker();
    _persist();
  }

  void stopTimer(String id) {
    final todo = getTodoById(id);
    if (todo != null) {
      todo.elapsedSeconds = _computeElapsed(todo);
      todo.timerStartedAt = null;
      todo.timerRunStartElapsed = null;
      todo.status = TodoStatus.done;
      todos.refresh();
      _stopTicker();
      _persist();
    }
  }

  bool isRunning(String id) {
    final t = getTodoById(id);
    return t != null && t.timerStartedAt != null;
  }
}
