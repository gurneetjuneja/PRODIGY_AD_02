import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/task_list_screen.dart'; // Import the TaskListScreen

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // Remove debug banner
      title: 'To-Do List App',
      theme: ThemeData(
        primarySwatch: Colors.green,
        textTheme: GoogleFonts.ralewayTextTheme(
          Theme.of(context).textTheme,
        ),
      ),
      home: TaskListScreen(), // Use the TaskListScreen as the home
    );
  }
}
