import 'package:coop_assistant/data/network/coop_api.dart';
import 'package:coop_assistant/domain/model/coop_server.dart';
import 'package:coop_assistant/presentation/common/messages.dart';
import 'package:coop_assistant/presentation/session/session_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({required this.server, super.key});

  final CoopServer server;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _login = TextEditingController();
  final _password = TextEditingController();
  var _busy = false;
  String? _error;

  @override
  void dispose() {
    _login.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_login.text.trim().isEmpty || _password.text.isEmpty) {
      setState(() => _error = 'Saisissez votre identifiant et votre mot de passe.');
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await context.read<SessionCubit>().login(login: _login.text.trim(), password: _password.text);
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
    appBar: AppBar(title: Text(widget.server.name)),
    body: Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: AutofillGroup(
          child: ListView(
            padding: const EdgeInsets.all(24),
            shrinkWrap: true,
            children: [
              const Text('Connectez-vous avec vos identifiants habituels du site de la coopérative.'),
              const SizedBox(height: 16),
              TextField(
                controller: _login,
                keyboardType: TextInputType.emailAddress,
                autocorrect: false,
                autofillHints: const [AutofillHints.username],
                decoration: const InputDecoration(labelText: 'Identifiant', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _password,
                obscureText: true,
                autofillHints: const [AutofillHints.password],
                decoration: const InputDecoration(labelText: 'Mot de passe', border: OutlineInputBorder()),
                onSubmitted: (_) => _submit(),
              ),
              if (_error case final error?) ...[
                const SizedBox(height: 12),
                Text(error, style: TextStyle(color: Theme.of(context).colorScheme.error)),
              ],
              const SizedBox(height: 16),
              FilledButton(onPressed: _busy ? null : _submit, child: const Text('Se connecter')),
              TextButton(
                onPressed: _busy ? null : () => context.read<SessionCubit>().forgetServer(),
                child: const Text('Changer de coopérative'),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
