import 'package:coop_assistant/data/network/coop_api.dart';
import 'package:coop_assistant/presentation/common/messages.dart';
import 'package:coop_assistant/presentation/session/session_cubit.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// First launch: which cooperative does the member belong to?
class ServerScreen extends StatefulWidget {
  const ServerScreen({super.key});

  @override
  State<ServerScreen> createState() => _ServerScreenState();
}

class _ServerScreenState extends State<ServerScreen> {
  final _address = TextEditingController(text: kDebugMode ? 'http://localhost:8069' : '');
  var _busy = false;
  String? _error;

  @override
  void dispose() {
    _address.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_address.text.trim().isEmpty) {
      setState(() => _error = "Saisissez l'adresse du site de votre coopérative.");
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await context.read<SessionCubit>().chooseServer(_address.text);
    } on CoopApiException catch (e) {
      if (mounted) {
        setState(() {
          _busy = false;
          _error = errorMessage(e.code);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Votre coopérative')),
    body: Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: ListView(
          padding: const EdgeInsets.all(24),
          shrinkWrap: true,
          children: [
            const Text(
              "Saisissez l'adresse du site de votre coopérative, celle où vous consultez votre espace membre.",
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _address,
              keyboardType: TextInputType.url,
              autocorrect: false,
              decoration: InputDecoration(
                labelText: 'Adresse du site',
                hintText: 'membres.macoop.fr',
                errorText: _error,
                errorMaxLines: 3,
                border: const OutlineInputBorder(),
              ),
              onSubmitted: (_) => _submit(),
            ),
            const SizedBox(height: 16),
            FilledButton(onPressed: _busy ? null : _submit, child: const Text('Continuer')),
          ],
        ),
      ),
    ),
  );
}
