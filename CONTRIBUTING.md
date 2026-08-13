# Contributing to ZenFlashCards

Thank you for your interest in ZenFlashCards! Below are the guidelines for contributing to the project.

---

## 🚀 Quick Start

### System Requirements

| Tool | Minimum Version |
|-----------------|---------------------|
| Flutter SDK | 3.x |
| Dart SDK | 3.x |
| Android SDK | API 21+ (minSdk) |
| Android Studio | Latest stable |

### Environment Setup

```bash
# 1. Clone repository
git clone https://github.com/githubuser2777/ZenFlashCard.git
cd ZenFlashCard

# 2. Install dependencies
flutter pub get

# 3. Check environment
flutter doctor

# 4. Run the app on an emulator or device
flutter run
```

---

## 📐 Coding Standards

### Directory Structure

The project follows a **Clean Architecture + Feature-Driven Structure**:

```
lib/
├── core/         # Database, Models, Algorithms, Utils
├── features/     # Features (Home, Deck, Study, Stats, Settings)
└── shared/       # Shared Widgets & Theme
```

### Naming Conventions

- **Files**: `snake_case.dart` (e.g., `deck_dao.dart`, `study_viewmodel.dart`)
- **Classes**: `PascalCase` (e.g., `FlashCard`, `DeckViewModel`)
- **Variables/Functions**: `camelCase` (e.g., `getCardsDueToday()`)
- **Constants**: `camelCase` with prefix `k` or `const` (e.g., `const kMinEasiness = 1.3`)

### Dart Best Practices

- Use `const` constructors whenever possible
- Dispose `AnimationController` and `StreamController` properly (to avoid memory leaks)
- Prefer immutable data classes with `toMap()` / `fromMap()`

---

## 🧪 Testing

### Running Tests

```bash
# Unit tests for SM-2 algorithm
flutter test test/core/algorithms/sm2_test.dart

# Entire test suite
flutter test

# Static analysis
flutter analyze
```

### Writing New Tests

- Place test files in the `test/` directory mirroring the `lib/` structure
- Every test file must end with `_test.dart`
- Use `group()` to group related test cases

---

## 🔀 Pull Request Process

1. **Fork** the repository
2. Create a **feature branch**: `git checkout -b feature/feature-name`
3. **Commit** with a clear message: `git commit -m "feat: add XYZ feature"`
4. **Push** to the fork: `git push origin feature/feature-name`
5. Create a **Pull Request** to the `main` branch

### Commit Message Convention

```
feat: add a new feature
fix: fix a bug
docs: update documentation
style: format changes (does not affect logic)
refactor: refactor code
test: add or modify tests
chore: update build scripts, dependencies
```

---

## 🐛 Bug Reporting

When reporting a bug, please provide:

1. A clear **Bug description**
2. Specific **Steps to reproduce**
3. **Expected result** vs **Actual result**
4. **Device information**: Model, Android version, Flutter version
5. **Screenshots / Logs** if available

---

## 📜 License

By contributing to the project, you agree that your code will be distributed under the [MIT License](LICENSE).
