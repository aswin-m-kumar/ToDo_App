import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/todo_cubit.dart';

class TodoCard extends StatelessWidget {
  final TodoItem todo;

  const TodoCard({super.key, required this.todo});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: colors.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        title: Text(
          todo.title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: colors.onSurface,
          ),
        ),
        subtitle: todo.description != null
            ? Text(
                todo.description!,
                style: TextStyle(
                  fontSize: 14,
                  color: colors.onSurfaceVariant,
                ),
              )
            : null,
        trailing: IconButton(
          icon: Icon(Icons.delete_outline, color: colors.error),
          onPressed: () => context.read<TodoCubit>().deleteTodo(todo.id),
        ),
      ),
    );
  }
}
