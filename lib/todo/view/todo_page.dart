import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:app_ui/app_ui.dart';
import 'package:todo_app/auth/auth.dart';
import '../cubit/todo_cubit.dart';

class TodoPage extends StatelessWidget {
  const TodoPage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.read<AuthCubit>().state.user;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colors = Theme.of(context).colorScheme;

    return BlocProvider(
      create: (ctx) => TodoCubit(userId: user?.id ?? '')..loadTodos(),
      child: Scaffold(
        appBar: AppBar(
          title: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: colors.primaryContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.psychology, size: 20, color: colors.onPrimaryContainer),
              ),
              const SizedBox(width: 8),
              Text(
                'QuestDo',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: colors.primary,
                ),
              ),
            ],
          ),
          actions: [
            IconButton(
              icon: Icon(
                isDark ? Icons.light_mode : Icons.dark_mode,
                color: colors.primary,
              ),
              onPressed: toggleTheme,
            ),
            const SizedBox(width: 4),
            IconButton(
              icon: Icon(Icons.exit_to_app, color: colors.primary),
              onPressed: () => context.read<AuthCubit>().signOut(),
              tooltip: 'Logout',
            ),
          ],
        ),
        body: BlocBuilder<TodoCubit, TodoState>(
          builder: (context, state) {
            switch (state.status) {
              case TodoStatus.initial:
              case TodoStatus.loading:
                return const Center(child: CircularProgressIndicator());
              case TodoStatus.failure:
                return Center(
                  child: Text('Error: ${state.errorMessage}'),
                );
              case TodoStatus.populated:
                if (state.todos.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.eco, size: 64, color: colors.primary.withValues(alpha: 0.3)),
                        const SizedBox(height: 16),
                        Text(
                          'No quests yet. Add one!',
                          style: TextStyle(
                            fontSize: 16,
                            color: colors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: state.todos.length,
                  itemBuilder: (context, index) {
                    final todo = state.todos[index];
                    return _TodoCard(todo: todo);
                  },
                );
            }
          },
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {},
          backgroundColor: colors.primary,
          foregroundColor: colors.onPrimary,
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}

class _TodoCard extends StatelessWidget {
  final TodoItem todo;

  const _TodoCard({required this.todo});

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
