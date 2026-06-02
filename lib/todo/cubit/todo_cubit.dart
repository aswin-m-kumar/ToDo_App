import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

enum TodoStatus { initial, loading, populated, failure }

class TodoItem extends Equatable {
  final String id;
  final String title;
  final String? description;
  final DateTime createdAt;

  const TodoItem({
    required this.id,
    required this.title,
    this.description,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, title, description, createdAt];
}

class TodoState extends Equatable {
  final TodoStatus status;
  final List<TodoItem> todos;
  final String? errorMessage;

  const TodoState({
    this.status = TodoStatus.initial,
    this.todos = const [],
    this.errorMessage,
  });

  TodoState copyWith({
    TodoStatus? status,
    List<TodoItem>? todos,
    String? errorMessage,
  }) {
    return TodoState(
      status: status ?? this.status,
      todos: todos ?? this.todos,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, todos, errorMessage];
}

class TodoCubit extends Cubit<TodoState> {
  final String userId;

  TodoCubit({required this.userId}) : super(const TodoState());

  Future<void> loadTodos() async {
    emit(state.copyWith(status: TodoStatus.loading));
    try {
      await Future.delayed(const Duration(milliseconds: 500));
      emit(state.copyWith(
        status: TodoStatus.populated,
        todos: _mockTodos,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: TodoStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  void addTodo(TodoItem todo) {
    emit(state.copyWith(todos: [todo, ...state.todos]));
  }

  void deleteTodo(String id) {
    emit(state.copyWith(
      todos: state.todos.where((t) => t.id != id).toList(),
    ));
  }

  static final _mockTodos = <TodoItem>[
    TodoItem(
      id: '1',
      title: 'Complete Flutter setup',
      description: 'Set up the development environment and create the project',
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
    ),
    TodoItem(
      id: '2',
      title: 'Design the auth screen',
      description: 'Create the QuestDo themed authentication page',
      createdAt: DateTime.now().subtract(const Duration(hours: 1)),
    ),
  ];
}
