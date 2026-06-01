# Architecture Guide

This guide explains how to think about a modern Flutter codebase using:

- Feature-first structure
- BLoC/Cubit state management
- Layered repositories and clients
- Clean architecture principles (in practical form)

You should be able to read this once and know where new code belongs.

---

## 1) Big Picture (Simple Mental Model)

Think of the app in 4 layers:

1. **UI Layer**  
   Screens, widgets, and UI-only logic.
2. **State Layer**  
   BLoC/Cubit that handles events, calls repositories, and emits states.
3. **Domain/Data Access Layer**  
   Repositories that expose business-friendly methods.
4. **Infrastructure Layer**  
   Clients (Supabase, location, navigation, etc.) that talk to external SDKs/APIs.

High-level flow:

```text
UI (Page/Widget)
   -> BLoC/Cubit
      -> Repository
         -> Client / Database implementation
            -> External service (Supabase, SDK, device API)
```

---

## 2) Why `lib/` is Feature-First

`lib/` is organized by **business features** (auth, home, calendar, trip, encounter), not by file type.

This project's default `lib/` style is:

```text
lib/<feature>/
  <feature>.dart
  view/
  widgets/
  bloc/ or cubit/
```

For larger features with multiple user flows:

```text
lib/<feature>/
  <feature>.dart
  view/
  bloc/ or cubit/
  <subfeature>/
    <subfeature>.dart
    view/
    widgets/
    bloc/ or cubit/
```

Rules:

- Default to `view/`, `widgets/`, and `bloc/` or `cubit/`.
- Add a barrel file like `<feature>.dart` for each top-level feature.
- Add a barrel file like `<subfeature>.dart` for each meaningful sub-feature.
- Do not create extra folders in `lib/` unless there is a strong, explicit reason.

### Domain Grouping (Sub-Features)

If a feature is large and consists of multiple distinct user flows, you should use **Domain Grouping**.
Instead of polluting the root `lib/` folder, group related sub-features under a single main feature folder.

Example for the `auth` domain:
```text
lib/
  auth/
    auth.dart
    view/             <- Main orchestrator (e.g. AuthPage)
    cubit/            <- Shared parent state
    login/            <- Sub-feature
      login.dart
      view/
      cubit/
    verify_otp/       <- Sub-feature
      verify_otp.dart
      view/
      cubit/
```

Rules for sub-features:

- Sub-features must never import each other directly.
- The root feature folder owns shared coordination state such as selected patient, selected tab, or current step.
- Shared state must flow up to the parent `bloc/` or `cubit/`, then back down into children.
- Passing blocs through routes or `extra` payloads should be treated as a migration-only exception, not a normal pattern.

If `login` needs to pass a phone number to `verify_otp`, it must emit that data up to the parent `cubit/` inside the main `auth/` folder, which then passes it down to `verify_otp`.

### No `models/` in `lib/` by Default

Do not create `lib/<feature>/models/` as a default pattern.

- Feature-related data models should usually live in repository packages or `packages/shared`.
- `lib/<feature>/models/` is not a normal folder in this project.
- Only add a `models/` folder in `lib/` if the team explicitly agrees the type is presentation-only, cannot reasonably live in repository/shared, and is large enough to justify a dedicated folder.

### No Loose Helper Files at Feature Roots

Do not place loose helper files directly under `lib/<feature>/` or `lib/<feature>/<subfeature>/` unless the file is the barrel file.

- If logic is used by one screen only, keep it private in that page/widget file.
- If logic is reused across screens in one sub-feature, move it into the owning `bloc/` or `cubit/`.
- If logic is shared across top-level features, move it to `packages/shared` or a repository package.

### Barrel File Policy

- Every top-level feature should have a barrel file like `auth.dart`.
- Meaningful sub-features should also have a barrel file like `login.dart`.
- Root barrels should export only intentional public entrypoints.
- Do not export internal widgets broadly from the feature root unless they are meant for reuse across that feature.

### Why this is good

- Easy to work on one feature without touching the full app
- Easier ownership for teams
- Cleaner scaling when features grow

---

## 3) Why `packages/` Exists

`packages/` holds reusable modules with clear responsibilities.

### A) `*_client` packages

Examples: authentication client, location client, navigation client.

Purpose:

- Wrap external SDKs/platform APIs
- Hide low-level details
- Provide stable interfaces for upper layers

Rule: **No UI code in clients.**

---

### B) `*_repository` packages

Examples: appointment repository, user repository, encounter repository.

Purpose:

- Expose business-level methods used by BLoC/Cubit
- Combine or transform data from one or more clients
- Keep app logic independent from external SDK details

Rule: **BLoCs should call repositories, not SDK clients directly.**

---

### C) `shared` package

Purpose:

- Common utilities, constants, logger, flavor config, extensions, shared models
- Things used by many features/packages

Rule: Put code in `shared` only if it is genuinely cross-cutting.

Default contents:

- Cross-feature models
- Pure utilities
- Formatters
- Non-UI extensions
- Generic debouncers, loggers, and helpers

---

### D) `app_ui` package

Purpose:

- Design system: theme, colors, typography, common widgets, spacing

Rule: Reusable visual components go here, feature-specific widgets stay in feature folders.

Default contents:

- Reusable widgets
- Theme, colors, spacing, typography
- UI-only extensions

---

### E) Other support packages

- `form_fields` -> validation objects
- `env` -> environment variables/config values
- `database_client` -> abstract DB contract + concrete DB implementation

### Placement Decision Table

| Place | Put this here | Do not put this here |
| --- | --- | --- |
| `packages/shared` | Cross-feature models, pure utilities, formatters, non-UI extensions, generic helpers | Feature-specific screen logic |
| `packages/app_ui` | Reusable UI widgets, theme, colors, spacing, typography, UI-only extensions | Feature-specific business logic |
| `lib/<feature>` | Feature flow, feature widgets, feature state management, feature-only screen logic | Shared mini-libraries or cross-feature utilities |
| `*_repository` packages | Data shaping needed by multiple screens, backend joins/aggregation, SDK/database-facing transformation | Widget concerns or UI rendering |

### Quick Placement Checklist

Before creating a new file, ask:

- Is this cross-feature?
- Is it UI?
- Is it data shaping?
- Is it only for one screen?
- Does it belong in `bloc/` or `cubit/` instead of a loose file?

---

## 4) Multiple Clients Pattern (Important)

You may see different client packages because each one wraps a different external dependency:

- auth provider
- database provider
- device location service
- maps/navigation SDK

This prevents external SDK code from spreading across the app.

If one SDK changes later, only the client/repository layers need updates.

---

## 5) BLoC/Cubit Pattern (How to Think)

### What BLoC/Cubit should do

- Receive event/user action
- Validate small UI state conditions
- Call repository methods
- Emit loading/success/failure states

### What BLoC/Cubit should NOT do

- Direct API/SDK calls
- Big SQL/network logic
- Heavy UI code

### Presentation Logic Ownership

- UI rendering stays in pages/widgets.
- Screen-local filtering, sorting, and temporary UI state may stay in the page.
- Reusable presentation shaping across multiple screens in one feature should live in the feature `bloc/` or `cubit/`.
- Data assembly that depends on joins, backend fields, or multiple repositories should move to repository/database layers.

Examples:

- Grouping prescriptions by service
- Deriving patient names for lab reports
- Appointment-scoped record lookups

Keep state objects explicit and predictable:

- `initial`
- `loading`
- `populated/success`
- `failure`

This makes UI rendering and testing much easier.

---

## 6) Feature-First + Clean Architecture (How They Fit Together)

This project style is **practical clean architecture**:

- Feature-first in folder organization
- Layer separation in responsibilities

Mapping to clean architecture concepts:

- **Presentation** -> pages, widgets, bloc/cubit
- **Domain/Application rules** -> repository interfaces + business methods
- **Data/Infrastructure** -> database/client implementations and SDK adapters

So even if it is not “textbook strict” clean architecture, the important dependency direction is still respected:

**UI depends on abstractions, not on SDK details.**

---

## 7) Dependency Direction Rule (Must Follow)

Preferred direction:

```text
Feature UI -> Feature BLoC/Cubit -> Repository -> Client/Database Impl -> External SDK/API
```

Avoid reverse dependencies.

Examples of bad patterns:

- UI importing Supabase SDK directly
- BLoC importing geolocator/google nav directly
- Shared package depending on feature-specific widgets

---

## 8) Route Ownership Rule

A business domain should own its own route namespace.

- Do not nest a major feature under an unrelated feature just because of current navigation placement.
- Prefer routes that match the owning domain, such as `/records/...` for records.
- Temporary compatibility routes are acceptable during migration, but the canonical route should still match the owning domain.

---

## 9) How to Add a New Feature (Checklist)

When adding a new feature, follow this order:

1. Create feature folder in `lib/<feature_name>/`
2. Add the feature barrel file `<feature_name>.dart`
3. Add page/view and feature widgets
4. Add `bloc/` or `cubit/` + state + event
5. Decide whether the feature needs domain-grouped sub-features
6. Use existing repository methods
7. If needed, extend repository API
8. If needed, extend client implementation
9. Add tests for bloc/cubit behavior and key UI states

Quick check before PR:

- Does UI call only BLoC/Cubit?
- Does BLoC call repositories (not SDK)?
- Does the feature use the default `view/`, `widgets/`, `bloc/cubit/` shape?
- Did we avoid `models/`, `helpers/`, `utils/`, or loose root helper files in `lib/`?
- Is reusable UI moved to `app_ui` when appropriate?
- Is cross-cutting utility really shared before moving to `shared`?

---

## 10) Common Mistakes to Avoid

- Mixing business logic inside widgets
- Calling SDKs directly from BLoC/UI
- **Sibling Boundary Violations:** Sibling sub-features (e.g., `login` and `verify_otp`) should NEVER import each other or read each other's state directly. If they need to communicate, pass data *upwards* to a shared parent/coordinator BLoC, which can then flow *downwards* to the next sibling.
- **Cross-Feature UI Imports:** Top-level features (e.g., `home` and `calendar`) should never import widgets from each other. If a widget is needed by multiple features, extract it into the `app_ui` package. (Note: It is acceptable for `app_ui` to depend on repository models if it prevents massive refactors to primitive types, though primitives are preferred).
- Creating `helpers/`, `utils/`, or `models/` folders in `lib/` by habit
- Adding random root-level pure logic files inside a feature
- Passing blocs through routes or `extra` payloads as a normal pattern instead of using a parent coordinator
- Nesting a major route domain under an unrelated feature
- Creating “god” shared utilities that are actually feature-specific
- Duplicating similar status/state enums across features without reason
- Skipping tests for state transitions (loading -> success/failure)

---

## 11) Allowed Exceptions (Rare)

The following file types are allowed in `lib/` outside `view/`, `widgets/`, `bloc/`, or `cubit/`:

- Barrel files like `auth.dart`
- Distinct architectural concepts such as `provider`, `mixin`, or generated `*.g.dart`
- One-off files only when the concept is truly separate and naming it as a bloc/widget would be misleading

Not allowed by default:

- `helpers/`
- `utils/`
- `models/`
- Random root-level pure logic files

---

## 12) SOLID Principles in our Architecture

Our architecture naturally enforces the **SOLID** principles. Here is how they apply to our Flutter project:

- **S - Single Responsibility Principle:** One class/widget = one responsibility. 
  *Example:* A `Cubit` handles only state management. It delegates data fetching to a `Repository`. A UI widget handles only rendering.
- **O - Open/Closed Principle:** Extend behavior without modifying existing code. 
  *Example:* If you need a new payment method, you create a new client class that implements a shared interface, rather than modifying a massive `PaymentManager` class.
- **L - Liskov Substitution Principle:** Child classes (or interface implementations) should seamlessly replace parent classes.
  *Example:* A `MockUserRepository` can be substituted for a `SupabaseUserRepository` during testing, and the `HomeBloc` will continue to work perfectly because it only knows about the parent `UserRepository` interface.
- **I - Interface Segregation Principle:** Keep interfaces small and focused.
  *Example:* We don't have a single `AppRepository`. We split it into `UserRepository`, `AppointmentRepository`, etc., so features only depend on exactly what they need.
- **D - Dependency Inversion Principle:** Depend on abstractions, not concrete implementations.
  *Example:* Our BLoCs/Cubits require repository abstractions passed in through their constructor (usually provided via `BlocProvider`/`context.read`). They never instantiate a concrete `SupabaseClient` directly.

---

## 13) One-Line Summary

Build features vertically (UI + state + flow), keep infrastructure hidden behind repositories/clients, default to `view/`, `widgets/`, and `bloc/cubit/` in `lib/`, and keep dependencies flowing in one clean direction.
