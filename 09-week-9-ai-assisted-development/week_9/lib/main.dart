import 'package:flutter/material.dart';

import 'features/notes/presentation/notes_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key}); // <--- UBAH BAGIAN INI

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Notes AI',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const NotesPage(),
    );
  }
}
