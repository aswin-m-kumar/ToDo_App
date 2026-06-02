import 'package:flutter/material.dart';
import '../cubit/todo_cubit.dart';

class TodoListWidget extends StatelessWidget {
  final List<TodoItem> todos;

  const TodoListWidget({super.key, required this.todos});

  @override
  Widget build(BuildContext context) {
    if (todos.isEmpty) {
      return const Center(child: Text('No quests yet. Add one!'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: todos.length,
      itemBuilder: (context, index) {
        final todo = todos[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            title: Text(todo.title),
            subtitle: todo.description != null ? Text(todo.description!) : null,
          ),
        );
      },
    );
  }
}
