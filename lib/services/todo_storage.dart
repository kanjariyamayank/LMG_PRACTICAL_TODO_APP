import 'package:hive_flutter/hive_flutter.dart';

import '../models/todo_model.dart';

const String _boxName = 'todos';
const String _listKey = 'list';


class TodoStorage {
  Box<dynamic>? _box;

  Future<void> init() async {
    await Hive.initFlutter();
    _box = await Hive.openBox(_boxName);
  }

  Future<List<TodoModel>> loadTodos() async {
    if (_box == null) return [];
    final list = _box!.get(_listKey);
    if (list is! List) return [];
    final result = <TodoModel>[];
    for (final item in list) {
      if (item is Map) {
        try {
          result.add(TodoModel.fromJson(Map<String, dynamic>.from(item)));
        } catch (_) {}
      }
    }
    return result;
  }

  Future<void> saveTodos(List<TodoModel> todos) async {
    if (_box == null) return;
    final list = todos.map((e) => e.toJson()).toList();
    await _box!.put(_listKey, list);
  }
}
