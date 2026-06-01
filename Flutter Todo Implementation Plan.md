# **Flutter Todo Application**

## **Full Implementation Plan**

Tech Stack: Flutter • Supabase • BLoC/Cubit • Clean Architecture

## **1\. Project Overview**

This document is the complete implementation plan for a Flutter Todo Application using Supabase as the backend, BLoC/Cubit for state management, and Clean Architecture principles as outlined in the Architecture Guide. Every decision in this plan strictly follows the dependency direction rule, feature-first folder structure, and layer separation described in the guide.

### **1.1 Architecture Mental Model**

The app is organized into 4 strict layers with dependencies flowing in one direction only:

| Layer | Responsibility | Examples in this App |
| :---- | :---- | :---- |
| UI Layer | Screens, widgets, UI-only logic | TodoPage, LoginPage, TodoCard |
| State Layer | BLoC/Cubit — events, repo calls, state emission | TodoCubit, AuthCubit, LoginCubit |
| Domain Layer | Repository interfaces & business methods | TodoRepository, AuthenticationRepository |
| Infrastructure Layer | Clients wrapping external SDKs/APIs | SupabaseTodoClient, SupabaseAuthClient |

## **2\. Project Structure**

The root is split into lib/ (feature-first app code) and packages/ (reusable infrastructure modules). No models/, utils/, or helpers/ folders are created in lib/ per architecture rules.

### **2.1 lib/ — Feature-First**

lib/  
├── app/  
│   └── app.dart                    \# Root widget, provider setup  
├── auth/  
│   ├── auth.dart                   \# Barrel file  
│   ├── cubit/                      \# Parent coordinator (session)  
│   │   ├── auth\_cubit.dart  
│   │   └── auth\_state.dart  
│   ├── login/                      \# Sub-feature  
│   │   ├── login.dart  
│   │   ├── view/login\_page.dart  
│   │   └── cubit/login\_cubit.dart  
│   └── signup/                     \# Sub-feature  
│       ├── signup.dart  
│       ├── view/signup\_page.dart  
│       └── cubit/signup\_cubit.dart  
└── todo/  
    ├── todo.dart                   \# Barrel file  
    ├── cubit/todo\_cubit.dart  
    ├── view/todo\_page.dart  
    └── widgets/  
        ├── todo\_list.dart  
        └── todo\_card.dart

### **2.2 packages/ — Infrastructure Modules**

packages/  
├── authentication\_client/          \# Wraps Supabase Auth SDK  
├── authentication\_repository/      \# Business-level auth methods  
├── todo\_client/                    \# Wraps Supabase todos table  
├── todo\_repository/                \# Business-level todo methods \+ TodoModel  
├── app\_ui/                         \# Theme, colors, typography, shared widgets  
└── shared/                         \# Formatters, pure utils, extensions

## **3\. Supabase Setup**

### **3.1 Database Schema**

Create the todos table with Row Level Security so each user only sees their own data:

create table todos (  
  id          uuid primary key default gen\_random\_uuid(),  
  user\_id     uuid references auth.users(id) on delete cascade not null,  
  title       text not null,  
  description text,  
  due\_date    date,  
  due\_time    time,  
  created\_at  timestamptz default now()  
);

\-- Enable Row Level Security  
alter table todos enable row level security;

\-- Policy: users see only their own todos  
create policy "Users see own todos" on todos  
  for all using (auth.uid() \= user\_id);

Session persistence is handled automatically by the Supabase Flutter SDK, which stores the session token on device. The AuthCubit subscribes to onAuthStateChange — on app restart, if a valid session exists, the stream fires immediately and emits the authenticated state before the user sees any UI.

## **4\. Package Layer Implementation**

### **4.1 authentication\_client**

Wraps Supabase Auth SDK. No UI code. Exposes a stable abstract interface.

**Abstract Interface**

abstract class AuthenticationClient {  
  Stream\<AuthUser?\> get user;  
  Future\<void\> signUp({required String email, required String password});  
  Future\<void\> signIn({required String email, required String password});  
  Future\<void\> signOut();  
}

class AuthUser {  
  final String id;  
  final String email;  
  const AuthUser({required this.id, required this.email});  
}

**Concrete Implementation (SupabaseAuthenticationClient)**

class SupabaseAuthenticationClient implements AuthenticationClient {  
  final SupabaseClient \_supabase;

  @override  
  Stream\<AuthUser?\> get user \=\>  
    \_supabase.auth.onAuthStateChange.map((event) {  
      final u \= event.session?.user;  
      if (u \== null) return null;  
      return AuthUser(id: u.id, email: u.email ?? '');  
    });

  @override  
  Future\<void\> signUp({required String email, required String password}) \=\>  
    \_supabase.auth.signUp(email: email, password: password);

  @override  
  Future\<void\> signIn({required String email, required String password}) \=\>  
    \_supabase.auth.signInWithPassword(email: email, password: password);

  @override  
  Future\<void\> signOut() \=\> \_supabase.auth.signOut();  
}

### **4.2 authentication\_repository**

Exposes business-level auth methods to BLoC/Cubit. Calls client only — never the Supabase SDK directly.

class AuthenticationRepository {  
  final AuthenticationClient \_client;  
  AuthenticationRepository(this.\_client);

  Stream\<AuthUser?\> get user \=\> \_client.user;

  Future\<void\> signUp({required String email, required String password}) \=\>  
    \_client.signUp(email: email, password: password);

  Future\<void\> signIn({required String email, required String password}) \=\>  
    \_client.signIn(email: email, password: password);

  Future\<void\> signOut() \=\> \_client.signOut();  
}

### **4.3 todo\_repository — TodoModel**

The TodoModel lives here (not in lib/) because it is a domain/data model, not a presentation-only type.

class TodoModel {  
  final String    id;  
  final String    userId;  
  final String    title;  
  final String?   description;  
  final DateTime? dueDate;  
  final TimeOfDay? dueTime;  
  final DateTime  createdAt;

  factory TodoModel.fromJson(Map\<String, dynamic\> json) \=\> TodoModel(  
    id:          json\['id'\],  
    userId:      json\['user\_id'\],  
    title:       json\['title'\],  
    description: json\['description'\],  
    dueDate:     json\['due\_date'\] \!= null ? DateTime.parse(json\['due\_date'\]) : null,  
    dueTime:     json\['due\_time'\] \!= null ? \_parseTime(json\['due\_time'\]) : null,  
    createdAt:   DateTime.parse(json\['created\_at'\]),  
  );

  Map\<String, dynamic\> toJson() \=\> {  
    'title':       title,  
    'description': description,  
    'due\_date':    dueDate?.toIso8601String().split('T').first,  
    'due\_time':    dueTime \!= null  
      ? '${dueTime\!.hour.toString().padLeft(2,'0')}:${dueTime\!.minute.toString().padLeft(2,'0')}'  
      : null,  
  };  
}

### **4.4 todo\_client**

**Abstract Interface**

abstract class TodoClient {  
  Future\<List\<TodoModel\>\> getTodos({required String userId});  
  Future\<TodoModel\> createTodo({required String userId, required TodoModel todo});  
  Future\<TodoModel\> updateTodo({required TodoModel todo});  
  Future\<void\>      deleteTodo({required String id});  
}

**Supabase Implementation**

class SupabaseTodoClient implements TodoClient {  
  final SupabaseClient \_supabase;

  @override  
  Future\<List\<TodoModel\>\> getTodos({required String userId}) async {  
    final data \= await \_supabase.from('todos').select()  
      .eq('user\_id', userId).order('created\_at', ascending: false);  
    return (data as List).map((e) \=\> TodoModel.fromJson(e)).toList();  
  }

  @override  
  Future\<TodoModel\> createTodo({required String userId, required TodoModel todo}) async {  
    final data \= await \_supabase.from('todos')  
      .insert({...todo.toJson(), 'user\_id': userId}).select().single();  
    return TodoModel.fromJson(data);  
  }

  @override  
  Future\<TodoModel\> updateTodo({required TodoModel todo}) async {  
    final data \= await \_supabase.from('todos')  
      .update(todo.toJson()).eq('id', todo.id).select().single();  
    return TodoModel.fromJson(data);  
  }

  @override  
  Future\<void\> deleteTodo({required String id}) \=\>  
    \_supabase.from('todos').delete().eq('id', id);  
}

### **4.5 todo\_repository**

class TodoRepository {  
  final TodoClient \_client;  
  TodoRepository(this.\_client);

  Future\<List\<TodoModel\>\> getTodos({required String userId}) \=\>  
    \_client.getTodos(userId: userId);

  Future\<TodoModel\> createTodo({required String userId, required TodoModel todo}) \=\>  
    \_client.createTodo(userId: userId, todo: todo);

  Future\<TodoModel\> updateTodo({required TodoModel todo}) \=\>  
    \_client.updateTodo(todo: todo);

  Future\<void\> deleteTodo({required String id}) \=\>  
    \_client.deleteTodo(id: id);  
}

## **5\. State Layer — BLoC / Cubit**

### **5.1 Auth Domain Cubits**

The auth domain uses domain grouping with a parent AuthCubit at the root and two child sub-feature cubits (login, signup). Sub-features never communicate directly — data flows up to the parent.

**AuthState & AuthCubit (Parent Coordinator)**

enum AuthStatus { unknown, authenticated, unauthenticated }

class AuthState extends Equatable {  
  final AuthStatus status;  
  final AuthUser?  user;  
  const AuthState({this.status \= AuthStatus.unknown, this.user});  
  @override List\<Object?\> get props \=\> \[status, user\];  
}

class AuthCubit extends Cubit\<AuthState\> {  
  final AuthenticationRepository \_repo;  
  late final StreamSubscription\<AuthUser?\> \_userSub;

  AuthCubit(this.\_repo) : super(const AuthState()) {  
    \_userSub \= \_repo.user.listen((user) {  
      if (user \!= null) {  
        emit(AuthState(status: AuthStatus.authenticated, user: user));  
      } else {  
        emit(const AuthState(status: AuthStatus.unauthenticated));  
      }  
    });  
  }

  Future\<void\> signOut() \=\> \_repo.signOut();

  @override  
  Future\<void\> close() { \_userSub.cancel(); return super.close(); }  
}

**LoginState & LoginCubit**

enum LoginStatus { initial, loading, success, failure }

class LoginState extends Equatable {  
  final LoginStatus status;  
  final String?     errorMessage;  
  const LoginState({this.status \= LoginStatus.initial, this.errorMessage});  
  @override List\<Object?\> get props \=\> \[status, errorMessage\];  
}

class LoginCubit extends Cubit\<LoginState\> {  
  final AuthenticationRepository \_repo;  
  LoginCubit(this.\_repo) : super(const LoginState());

  Future\<void\> logIn({required String email, required String password}) async {  
    emit(const LoginState(status: LoginStatus.loading));  
    try {  
      await \_repo.signIn(email: email, password: password);  
      emit(const LoginState(status: LoginStatus.success));  
    } catch (e) {  
      emit(LoginState(status: LoginStatus.failure, errorMessage: e.toString()));  
    }  
  }  
}

SignupCubit mirrors LoginCubit exactly, calling \_repo.signUp(...) instead.

### **5.2 Todo Cubit**

**TodoState**

enum TodoStatus { initial, loading, populated, failure }

class TodoState extends Equatable {  
  final TodoStatus    status;  
  final List\<TodoModel\> todos;  
  final String?       errorMessage;

  const TodoState({  
    this.status \= TodoStatus.initial,  
    this.todos  \= const \[\],  
    this.errorMessage,  
  });

  TodoState copyWith({TodoStatus? status, List\<TodoModel\>? todos, String? errorMessage}) \=\>  
    TodoState(  
      status:       status       ?? this.status,  
      todos:        todos        ?? this.todos,  
      errorMessage: errorMessage ?? this.errorMessage,  
    );

  @override List\<Object?\> get props \=\> \[status, todos, errorMessage\];  
}

**TodoCubit**

class TodoCubit extends Cubit\<TodoState\> {  
  final TodoRepository \_repo;  
  final String userId;

  TodoCubit(this.\_repo, {required this.userId}) : super(const TodoState());

  Future\<void\> loadTodos() async {  
    emit(state.copyWith(status: TodoStatus.loading));  
    try {  
      final todos \= await \_repo.getTodos(userId: userId);  
      emit(state.copyWith(status: TodoStatus.populated, todos: todos));  
    } catch (e) {  
      emit(state.copyWith(status: TodoStatus.failure, errorMessage: e.toString()));  
    }  
  }

  Future\<void\> addTodo(TodoModel todo) async {  
    try {  
      final created \= await \_repo.createTodo(userId: userId, todo: todo);  
      emit(state.copyWith(todos: \[created, ...state.todos\]));  
    } catch (e) {  
      emit(state.copyWith(status: TodoStatus.failure, errorMessage: e.toString()));  
    }  
  }

  Future\<void\> updateTodo(TodoModel todo) async {  
    try {  
      final updated \= await \_repo.updateTodo(todo: todo);  
      final todos \= state.todos  
        .map((t) \=\> t.id \== updated.id ? updated : t).toList();  
      emit(state.copyWith(todos: todos));  
    } catch (e) {  
      emit(state.copyWith(status: TodoStatus.failure, errorMessage: e.toString()));  
    }  
  }

  Future\<void\> deleteTodo(String id) async {  
    try {  
      await \_repo.deleteTodo(id: id);  
      emit(state.copyWith(  
        todos: state.todos.where((t) \=\> t.id \!= id).toList()));  
    } catch (e) {  
      emit(state.copyWith(status: TodoStatus.failure, errorMessage: e.toString()));  
    }  
  }  
}

## **6\. UI Layer**

### **6.1 app.dart — Root Widget**

Provides all repositories and the parent AuthCubit at the app root. Navigation is stream-driven — AuthCubit state drives route selection automatically, so no manual navigation calls are needed on login/logout.

class App extends StatelessWidget {  
  @override Widget build(BuildContext context) {  
    return MultiRepositoryProvider(  
      providers: \[  
        RepositoryProvider(create: (\_) \=\> AuthenticationRepository(  
          SupabaseAuthenticationClient(Supabase.instance.client))),  
        RepositoryProvider(create: (\_) \=\> TodoRepository(  
          SupabaseTodoClient(Supabase.instance.client))),  
      \],  
      child: BlocProvider(  
        create: (ctx) \=\> AuthCubit(ctx.read\<AuthenticationRepository\>()),  
        child: MaterialApp(  
          home: BlocBuilder\<AuthCubit, AuthState\>(  
            builder: (ctx, state) \=\> switch (state.status) {  
              AuthStatus.authenticated   \=\> TodoPage(),  
              AuthStatus.unauthenticated \=\> LoginPage(),  
              AuthStatus.unknown         \=\> SplashScreen(),  
            },  
          ),  
        ),  
      ),  
    );  
  }  
}

### **6.2 Auth Pages**

LoginPage provides its own LoginCubit and listens to state. On LoginStatus.success, navigation is automatic because AuthCubit stream fires and rebuilds the root BlocBuilder. No explicit Navigator.push needed.

// login/view/login\_page.dart  
class LoginPage extends StatelessWidget {  
  @override Widget build(BuildContext context) {  
    return BlocProvider(  
      create: (ctx) \=\> LoginCubit(ctx.read\<AuthenticationRepository\>()),  
      child: LoginView(),  
    );  
  }  
}

// LoginView renders email \+ password fields, submit button.  
// BlocListener handles LoginStatus.failure \-\> show SnackBar.  
// On LoginStatus.loading \-\> show CircularProgressIndicator.  
// SignupPage follows the identical pattern with SignupCubit.

### **6.3 Todo Page**

class TodoPage extends StatelessWidget {  
  @override Widget build(BuildContext context) {  
    final user \= context.read\<AuthCubit\>().state.user\!;  
    return BlocProvider(  
      create: (ctx) \=\> TodoCubit(  
        ctx.read\<TodoRepository\>(), userId: user.id)..loadTodos(),  
      child: TodoView(),  
    );  
  }  
}

### **6.4 Widget Responsibilities**

| Widget | Responsibility |
| :---- | :---- |
| TodoView | Scaffold with FloatingActionButton (add todo). BlocBuilder renders list or loading/error state. |
| TodoList | Stateless widget. Receives List and renders TodoCard for each item. |
| TodoCard | Displays title, description, due date/time, created date. Edit icon \-\> opens form. Delete icon \-\> calls context.read().deleteTodo(id). |
| TodoFormPage | Used for both create and edit. showModalBottomSheet or push. Fields: title (required), description, DatePicker, TimePicker. Submit calls addTodo or updateTodo on cubit. |
| SplashScreen | Shown while AuthStatus is unknown. Simple centered logo/spinner. |

## **7\. Dependency Flow Verification**

The following traces confirm no layer violates the architecture dependency direction rule:

**Auth Flow**

LoginPage  
  \-\> LoginCubit  
    \-\> AuthenticationRepository  
      \-\> SupabaseAuthenticationClient  
        \-\> SupabaseClient  (SDK — never exposed above this layer)

**Session / Route Flow**

AuthCubit (app root)  
  \-\> AuthenticationRepository (stream subscription)  
    \-\> SupabaseAuthenticationClient.onAuthStateChange  
      \-\> emits AuthState \-\> BlocBuilder rebuilds route

**Todo CRUD Flow**

TodoPage \-\> TodoCubit  
  \-\> TodoRepository  
    \-\> SupabaseTodoClient  
      \-\> SupabaseClient  (SDK — never exposed above this layer)

## **8\. Key Architectural Decisions**

| Decision | Rationale (Architecture Guide Rule) |
| :---- | :---- |
| login/ and signup/ are sub-features of auth/ | Multiple distinct user flows under one domain \-\> use domain grouping |
| Parent AuthCubit owns session state | Sibling sub-features (login, signup) never share state directly; data flows up to parent coordinator |
| Navigation driven by AuthCubit stream | Avoids passing blocs through routes or extra payloads — architecture guide exception only |
| TodoModel lives in todo\_repository package | Not a presentation-only model; domain/data models belong in repository packages |
| No models/, utils/, helpers/ in lib/ | Architecture guide explicitly forbids these by default |
| BLoC/Cubit never imports SupabaseClient | Dependency direction rule — SDKs stay in client packages only |
| Single TodoCubit for all CRUD operations | Todo is one feature, not multiple sub-features; single cubit keeps state predictable |
| MockRepository substitutable in tests | Liskov Substitution / Dependency Inversion — BLoC depends on abstract repository, not concrete impl |

## **9\. pubspec.yaml Key Dependencies**

| Package | Version | Purpose |
| :---- | :---- | :---- |
| flutter\_bloc | ^8.x | BLoC/Cubit state management |
| equatable | ^2.x | Value equality for state objects |
| supabase\_flutter | ^2.x | Auth \+ database SDK (used only in client packages) |
| intl | ^0.x | Date/time formatting — lives in shared package |

## **10\. Anti-Patterns Explicitly Avoided**

* UI widgets never import SupabaseClient or call SDK methods directly  
* BLoC/Cubit layers never instantiate SDK clients; they only call repository methods  
* login/ and signup/ sub-features have no cross-imports; all shared session state lives in parent AuthCubit  
* No models/, helpers/, or utils/ folders created inside lib/  
* Blocs are never passed through Navigator route extra payloads  
* No god-cubit holding both auth and todo state; each domain owns its own cubit  
* No cross-feature widget imports; any widget needed by multiple features would be extracted to app\_ui

— End of Implementation Plan —