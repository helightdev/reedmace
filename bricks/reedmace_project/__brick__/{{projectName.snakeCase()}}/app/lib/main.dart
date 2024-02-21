import 'package:flutter/material.dart';
import 'package:reedmace_client/reedmace_client.dart';
import 'package:shared/shared.dart';
{{#useDogs}}import 'package:{{projectName.snakeCase()}}/dogs.g.dart';{{/useDogs}}

Future<void> main() async {
  {{#useDogs}}await initialiseDogs();{{/useDogs}}
  await ReedmaceClient.configure(sharedLibrary: sharedLibrary);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: Placeholder(),
    );
  }
}