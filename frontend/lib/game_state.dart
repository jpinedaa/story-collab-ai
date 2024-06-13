import 'package:flutter/material.dart';

class Player {
  final String name;
  final String role;
  String status;

  Player(this.name, this.role, this.status);
}

class Challenge {
  final String description;
  final int points;

  Challenge(this.description, this.points);
}

class GameState with ChangeNotifier {
  List<Player> players = [
    Player('Alice', 'Narrator', 'active'),
    Player('Bob', 'Player', 'active'),
    Player('Charlie', 'Player', 'inactive'),
  ];

  String currentSceneDescription = '''
    As you step into the ancient forest, a sense of wonder and trepidation fills your heart. The towering trees, with their thick trunks and sprawling branches, create a natural cathedral above you. Shafts of sunlight pierce through the dense canopy, illuminating patches of vibrant green moss that blanket the forest floor.

    The air is cool and damp, carrying the earthy scent of rich soil and decaying leaves. Every step you take is accompanied by the soft rustle of foliage and the distant calls of unseen creatures. The forest is alive with the sounds of nature—a chorus of chirping birds, the occasional rustle of small animals scurrying through the underbrush, and the gentle whisper of the wind through the leaves.

    In the heart of the forest, you come across a clearing. In the center stands an ancient stone altar, covered in intricate carvings and symbols that glow faintly with an otherworldly light. Surrounding the altar are large standing stones, each etched with runes that seem to pulse with hidden power.

    As you approach the altar, a sense of reverence washes over you. This place holds a deep, ancient magic, and you can feel the weight of countless rituals performed here over the centuries. The atmosphere is thick with the energy of the past, and you sense that this clearing is a focal point of mystical significance.

    Suddenly, a figure emerges from the shadows. It is a tall, hooded figure, their face obscured by the darkness of their cloak. They move with a grace that seems almost supernatural, their presence both imposing and ethereal. The figure raises a hand, and the runes on the standing stones begin to glow brighter.

    "Welcome, travelers," the figure intones in a voice that echoes with authority. "You have come to a place of great power. The trials you face here will test your strength, your wisdom, and your resolve. Only those who prove themselves worthy may unlock the secrets of the ancient forest."

    With a wave of the figure's hand, three challenges materialize before you. The first is a series of riddles inscribed on the stones, their meanings hidden in layers of cryptic language. The second is a trial of combat, where shadowy figures emerge from the forest, ready to test your physical prowess. The third is a test of heart, where you must confront your deepest fears and insecurities to move forward.

    The figure steps back, merging once more with the shadows, leaving you to face the challenges ahead. The forest seems to hold its breath, waiting to see if you have what it takes to unravel its mysteries and claim the power that lies within.

    Your journey has only just begun, and the path ahead is fraught with peril and discovery. Will you rise to the challenge and unlock the secrets of the ancient forest? The fate of your quest rests in your hands.
    ''';

  List<String> currentMoves = [
    'Player A decides to solve the riddles.',
    'Player B engages in combat with the shadowy figures.',
    'Player C confronts their deepest fears and insecurities.',
  ];

  List<Challenge> challenges = [
    Challenge('Solve the riddle of the stones', 3),
    Challenge('Defeat the shadowy figures', 5),
    Challenge('Confront your deepest fears', 4),
  ];

  bool isNarrator = false;

  void startNewScene() {
    currentSceneDescription = 'A new scene description goes here.';
    currentMoves = ['New move 1', 'New move 2', 'New move 3'];
    challenges = [
      Challenge('Find the hidden path', 3),
      Challenge('Navigate through the maze', 4),
    ];
    notifyListeners();
  }

  void makeMove(String move) {
    currentMoves.add(move);
    notifyListeners();
  }

  bool canMakeMove() {
    // Logic to determine if a move can be made
    return true;
  }
}
