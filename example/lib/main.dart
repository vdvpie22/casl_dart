import 'dart:developer';

import 'package:casl_dart/abilities.dart';
import 'package:casl_dart/can.dart';
import 'package:casl_dart/provider.dart';
import 'package:example/rules_data.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(CaslProvider(casl: CaslDart(), child: const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Casl Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const IntroScreen(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final TextStyle canStyle = TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w500,
      color: const Color(0xff29DE92));
  final TextStyle cannotStyle = TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w500,
      color: const Color(0xffE33E5A));

  void updateRules(BuildContext context) {
    final rules = getNewRules();
    final casl = CaslProvider.of(context);
    casl.updateRules(casl.unpackRules(rules));
  }

  void onDeleteTrip() {
    log("Yes, you can delete a Trip! ;)");
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      floatingActionButton: FloatingActionButton(
          child: Icon(Icons.edit),
          onPressed: () {
            updateRules(context);
          }),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          spacing: 20,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Can(
              I: 'create',
              a: 'Vehicle',
              child: Text(
                "Yes, you can create a Vehicle! ;)",
                style: canStyle,
              ),
            ),
            Can(
              I: 'delete',
              a: 'Trip',
              not: true,
              child: Text(
                "You are not allowed to delete a trip",
                style: cannotStyle,
              ),
            ),
            Can.builder(
              I: 'delete',
              a: 'Trip',
              abilityBuilder: (hasPermission) {
                return ElevatedButton(
                    onPressed: hasPermission ? onDeleteTrip : null,
                    child: Text("Delete Trip"));
              },
            ),
            AbilitiesWidget(
              cannotStyle: cannotStyle,
              canStyle: canStyle,
            ),
          ],
        ),
      ),
    );
  }
}

class AbilitiesWidget extends StatelessWidget {
  final TextStyle canStyle;
  final TextStyle cannotStyle;

  const AbilitiesWidget(
      {super.key, required this.cannotStyle, required this.canStyle});

  @override
  Widget build(BuildContext context) {
    final ability = CaslProvider.of(context);

    return Column(
      spacing: 20,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (ability.can("read", "CustomerPlan"))
          Text(
            "Yes, you can do this! ;)",
            style: canStyle,
          ),
        if (!ability.can("update", "CustomerPlan"))
          Text(
            "You are not allowed to update a CustomerPlan",
            style: cannotStyle,
          ),
      ],
    );
  }
}

class IntroScreen extends StatefulWidget {
  const IntroScreen({super.key});

  @override
  State<IntroScreen> createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen> {
  void initRules(BuildContext context) {
    final rules = getRules();
    final casl = CaslProvider.of(context);
    casl.initRules(casl.unpackRules(rules));
  }

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      initRules(context);
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => MyHomePage(
                  title: 'Casl Demo Home Page',
                ),
              ));
            },
            child: Text("Home")),
      ),
    );
  }
}
