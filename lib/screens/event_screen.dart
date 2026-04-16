import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/game_state_provider.dart';

class EventScreen extends ConsumerStatefulWidget {
  const EventScreen({super.key});

  @override
  ConsumerState<EventScreen> createState() => _EventScreenState();
}

class _EventScreenState extends ConsumerState<EventScreen> {
  int _dialogIndex = 0;

  final List<_DialogLine> _cyrusDialog = const [
    _DialogLine('???', 'ここは...どこだ...'),
    _DialogLine('ソフィ', 'あなたは...！ サイラスさん！'),
    _DialogLine('サイラス', 'ソフィ...か？ すまない、頭がぼんやりして...何も思い出せない。'),
    _DialogLine('ソフィ', '私も同じです。でも、ここから出る方法を探さないと。'),
    _DialogLine('サイラス', '...そうだな。この剣はまだ握れる。君を守ることくらいはできるだろう。'),
    _DialogLine('', 'サイラスが仲間になった！'),
  ];

  @override
  Widget build(BuildContext context) {
    final line = _cyrusDialog[_dialogIndex];

    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTap: _advance,
        child: Column(
          children: [
            // Scene area
            const Expanded(
              child: Center(
                child: Text(
                  '...',
                  style: TextStyle(color: Colors.white38, fontSize: 48),
                ),
              ),
            ),
            // Dialog box
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.black87,
                border: Border.all(color: Colors.white24),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (line.speaker.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Text(
                        line.speaker,
                        style: const TextStyle(
                          color: Colors.amber,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  Text(
                    line.text,
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  const Align(
                    alignment: Alignment.bottomRight,
                    child: Text(
                      '▼',
                      style: TextStyle(color: Colors.white38, fontSize: 14),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _advance() {
    if (_dialogIndex < _cyrusDialog.length - 1) {
      setState(() => _dialogIndex++);
    } else {
      ref.read(gameStateProvider.notifier).completeCyrusEvent();
    }
  }
}

class _DialogLine {
  final String speaker;
  final String text;
  const _DialogLine(this.speaker, this.text);
}
