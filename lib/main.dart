import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'providers/game_state_provider.dart';
import 'screens/title_screen.dart';
import 'screens/dungeon_screen.dart';
import 'screens/battle_screen.dart';
import 'screens/event_screen.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '記憶の夢',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: const GameRoot(),
    );
  }
}

class GameRoot extends ConsumerWidget {
  const GameRoot({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameState = ref.watch(gameStateProvider);

    switch (gameState.currentScreen) {
      case GameScreen.title:
        return const TitleScreen();
      case GameScreen.dungeon:
        return const DungeonScreen();
      case GameScreen.battle:
        return const BattleScreen();
      case GameScreen.event:
        return const EventScreen();
    }
  }
}
