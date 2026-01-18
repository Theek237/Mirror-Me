import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/di/injection.dart';
import '../../features/style_quiz/presentation/bloc/style_quiz_bloc.dart';
import '../../features/style_quiz/presentation/bloc/style_quiz_event.dart';
import '../../features/style_quiz/presentation/bloc/style_quiz_state.dart';

class StyleQuizScreen extends StatefulWidget {
  const StyleQuizScreen({super.key});

  @override
  State<StyleQuizScreen> createState() => _StyleQuizScreenState();
}

class _StyleQuizScreenState extends State<StyleQuizScreen> {
  final _auth = sl<FirebaseAuth>();

  final List<String> _styles = const [
    'Casual',
    'Streetwear',
    'Minimal',
    'Vintage',
    'Formal',
    'Sporty',
    'Creative',
  ];

  final List<String> _occasions = const [
    'Work',
    'Party',
    'Weekend',
    'Date Night',
    'Travel',
  ];

  @override
  Widget build(BuildContext context) {
    final user = _auth.currentUser;
    if (user == null) {
      return const Scaffold(
        body: Center(child: Text('Sign in to view style quiz.')),
      );
    }

    return BlocProvider(
      create: (_) => sl<StyleQuizBloc>()..add(StyleQuizStarted(uid: user.uid)),
      child: BlocConsumer<StyleQuizBloc, StyleQuizState>(
        listenWhen: (previous, current) =>
            previous.message != current.message && current.message != null,
        listener: (context, state) {
          final message = state.message;
          if (message == null) return;
          final isError = state.status == StyleQuizStatus.failure;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(message),
              backgroundColor: isError ? Colors.redAccent : Colors.green,
            ),
          );
          context.read<StyleQuizBloc>().add(const StyleQuizMessageCleared());
        },
        builder: (context, state) {
          final isSaving = state.status == StyleQuizStatus.saving;
          return Scaffold(
            appBar: AppBar(title: const Text('Style Quiz')),
            body: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Pick your vibe',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: _styles.map((style) {
                      final selected = state.styles.contains(style);
                      return FilterChip(
                        label: Text(style),
                        selected: selected,
                        onSelected: (value) {
                          context.read<StyleQuizBloc>().add(
                            StyleSelected(style: style, selected: value),
                          );
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Occasions you dress for',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: _occasions.map((occasion) {
                      final selected = state.occasions.contains(occasion);
                      return FilterChip(
                        label: Text(occasion),
                        selected: selected,
                        onSelected: (value) {
                          context.read<StyleQuizBloc>().add(
                            OccasionSelected(
                              occasion: occasion,
                              selected: value,
                            ),
                          );
                        },
                      );
                    }).toList(),
                  ),
                  const Spacer(),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: isSaving
                          ? null
                          : () => context.read<StyleQuizBloc>().add(
                              StyleQuizSaved(uid: user.uid),
                            ),
                      child: isSaving
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Save Preferences'),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
