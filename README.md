# Casl Dart

[![Pub Version](https://img.shields.io/pub/v/casl_dart)](https://pub.dev/packages/casl_dart)
[![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)

Casl Dart is a Dart implementation of [CASL.js](https://casl.js.org/), a powerful and flexible access control library. It enables defining, checking, and enforcing permissions in Flutter applications.

## Features

✅ Define and update access control rules dynamically.  
✅ Check user permissions efficiently.  
✅ Use declarative UI-based permission handling with the `Can` widget.

---

## 📦 Installation

Add `casl_dart` to your `pubspec.yaml`:

```yaml
dependencies:
  casl_dart: latest_version
```

Then, run:

```sh
flutter pub get
```

---

## 🚀 Usage

### 1️⃣ Wrap Your App with `CaslProvider`

```dart
import 'package:casl_dart/casl_dart.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(
    CaslProvider(
      casl: CaslDart(),
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Casl Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Casl Demo Home Page'),
    );
  }
}
```

---

### 2️⃣ Define and Update Rules

Casl Dart uses `Rule` objects to define permissions.

```dart
final casl = CaslProvider.of(context);

final rules = [
  Rule(actions: ["create"], subject: ["Vehicle"]),
  Rule(actions: ["read"], subject: ["CustomerPlan"]),
  Rule(actions: ["delete"], subject: ["Trip"]),
];

casl.updateRules(rules); // Automatically rebuilds widgets using `CaslProvider.of(context)`.
```

#### ⚡ Initializing Rules Without Triggering a Rebuild

To avoid unnecessary widget rebuilds when setting initial permissions, use `initRules`:

```dart
casl.initRules(rules);
```

🔹 **Use `updateRules` for dynamic updates that should rebuild the UI.**  
🔹 **Use `initRules` to set rules once without triggering a rebuild.**

#### 🔄 Updating Rules from a Raw List

Convert raw permission lists into `Rule` objects using `unpackRules`:

```dart
final rawRules = [
  ["create", "Vehicle"],
  ["read", "CustomerPlan"],
  ["delete", "Trip"],
];

casl.updateRules(casl.unpackRules(rawRules));
```

---

### 3️⃣ Declarative Permission Handling with `Can` Widget

#### ✅ Rendering UI Based on Permissions

```dart
Can(
  I: 'create',
  a: 'Vehicle',
  child: Text(
    "Yes, you can create a vehicle! ;)",
    style: TextStyle(color: Colors.green),
  ),
),

Can(
  I: 'update',
  a: 'Trip',
  not: true, // "not: true" inverts the check
  child: Text(
    "You are not allowed to update a trip",
    style: TextStyle(color: Colors.red),
  ),
),
```

#### 🎭 Dynamic UI Updates with `Can.builder`

```dart
Can.builder(
  I: 'delete',
  a: 'Trip',
  abilityBuilder: (context, hasPermission) {
    return ElevatedButton(
      onPressed: hasPermission ? onDeleteTrip : null,
      child: Text("Delete Trip"),
    );
  },
),
```

🔹 Enables UI changes like disabling buttons based on access control.

---

### 4️⃣ Programmatic Permission Checks

```dart
final ability = CaslProvider.of(context);

if (ability.can("read", "CustomerPlan")) {
  Text("Yes, you can read CustomerPlan!", style: TextStyle(color: Colors.green));
}

if (!ability.can("update", "CustomerPlan")) {
  Text("You are not allowed to update CustomerPlan", style: TextStyle(color: Colors.red));
}
```

---

## 📜 License

This package is released under the MIT License.

