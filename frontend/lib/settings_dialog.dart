import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'game_state.dart';

class SettingsDialog extends StatefulWidget {
  const SettingsDialog({super.key});

  @override
  SettingsDialogState createState() => SettingsDialogState();
}

class SettingsDialogState extends State<SettingsDialog> {
  final TextEditingController _apiKeyController = TextEditingController();
  final TextEditingController _modelController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final gameState = Provider.of<GameState>(context, listen: false);
    _apiKeyController.text = gameState.apiKey ?? '';
    _modelController.text = gameState.model ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Settings'),
      content: SingleChildScrollView(
        child: ListBody(
          children: <Widget>[
            TextField(
              controller: _apiKeyController,
              decoration: const InputDecoration(
                labelText: 'API Key',
              ),
            ),
            TextField(
              controller: _modelController,
              decoration: const InputDecoration(
                labelText: 'Model',
              ),
            ),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          child: const Text('Cancel'),
          onPressed: () {
            if (mounted) {
              Navigator.of(context).pop();
            }
          },
        ),
        ElevatedButton(
          child: const Text('Save'),
          onPressed: () async {
            final gameState = Provider.of<GameState>(context, listen: false);
            gameState.setApiKey(_apiKeyController.text);
            gameState.setModel(_modelController.text);
            await gameState.saveSettings();
            if (mounted) {
              // ignore: use_build_context_synchronously
              Navigator.of(context).pop();
            }
          },
        ),
      ],
    );
  }

  @override
  void dispose() {
    _apiKeyController.dispose();
    _modelController.dispose();
    super.dispose();
  }
}
