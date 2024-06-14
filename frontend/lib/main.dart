import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'game_state.dart';
import 'game_room_page.dart';
import 'card_state.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => GameState()),
        ChangeNotifierProvider(create: (context) => CardState()),
      ],
      child: MaterialApp(
        title: 'Narravive',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          scaffoldBackgroundColor:
              Colors.lightBlue[50], // Set global background color here
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
