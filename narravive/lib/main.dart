import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'game_state.dart';
import 'game_room_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [ChangeNotifierProvider(create: (context) => GameState())],
      child: MaterialApp(
        title: 'Narravive',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          scaffoldBackgroundColor: Color.fromARGB(
              255, 234, 234, 248), // Set global background color here
          appBarTheme: const AppBarTheme(
            backgroundColor:
                Colors.lightBlueAccent, // Set global app bar color here
          ),
        ),
        home: const GameRoomPage(),
      ),
    );
  }
}
