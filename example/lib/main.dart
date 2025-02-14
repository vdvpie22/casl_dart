import 'package:casl_dart/abilities.dart';
import 'package:casl_dart/can.dart';
import 'package:casl_dart/provider.dart';
import 'package:example/rules_data.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return CaslProvider(
      casl: CaslDart(),
      child: MaterialApp(
        title: 'Casl Demo',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: const MyHomePage(title: 'Casl Demo Home Page'),
      ),
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
    final rules = getRules();
    final casl = CaslProvider.of(context);
    casl.updateRules(casl.unpackRules(rules));
  }

  @override
  void didChangeDependencies() {
    updateRules(context);
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    final ability = CaslProvider.of(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
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
                "Yes, you can do this! ;)",
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
        ),
      ),
    );
  }
}
