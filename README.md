# Casl Dart

Casl Dart is a Dart implementation of [CASL.js](https://casl.js.org/), a flexible and intuitive access control library. It allows you to define, check, and enforce permissions in your Flutter applications.

## Features

- Define and update access control rules dynamically.
- Easily check user permissions.
- Declarative UI-based permission handling.

## Installation

Add `casl_dart` to your `pubspec.yaml`:

```yaml
dependencies:
  casl_dart: latest_version
```

Then, run:

```sh
flutter pub get
```

## Usage

### 1. Wrap Your App with `CaslProvider`

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

### 2. Define and Update Rules

Casl Dart uses `Rule` objects to define permissions.

```dart
final casl = CaslProvider.of(context);

// Define rules using the Rule class
final rules = [
  Rule(actions: ["create"], subject: ["Vehicle"]),
  Rule(actions: ["read"], subject: ["CustomerPlan"]),
  Rule(actions: ["delete"], subject: ["Trip"]),
];

// Update CaslDart with new rules
casl.updateRules(rules);
```

If your rules are represented as a `List<List<dynamic>>`, you can use the `unpackRules` function to convert them into `Rule` objects:

```dart
final rawRules = [
  ["create", "Vehicle"],
  ["read", "CustomerPlan"],
  ["delete", "Trip"],
];

casl.updateRules(casl.unpackRules(rawRules));
```

### 3. Declarative Permission Handling

Use the `Can` widget to conditionally render UI elements based on permissions.

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
  I: 'delete',
  a: 'Trip',
  not: true,
  child: Text(
    "You are not allowed to delete a trip",
    style: TextStyle(color: Colors.red),
  ),
),
```

### 4. Programmatic Permission Checks

```dart
final ability = CaslProvider.of(context);

if (ability.can("read", "CustomerPlan")) {
  Text(
    "Yes, you can read CustomerPlan!",
    style: TextStyle(color: Colors.green),
  );
}

if (!ability.can("update", "CustomerPlan")) {
  Text(
    "You are not allowed to update CustomerPlan",
    style: TextStyle(color: Colors.red),
  );
}
```

## License

This package is released under the MIT License.
