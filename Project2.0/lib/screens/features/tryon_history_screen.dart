import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/di/injection.dart';
import '../../features/tryon_history/presentation/bloc/tryon_history_bloc.dart';
import '../../features/tryon_history/presentation/bloc/tryon_history_event.dart';
import '../../features/tryon_history/presentation/bloc/tryon_history_state.dart';

class TryOnHistoryScreen extends StatelessWidget {
  const TryOnHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = sl<FirebaseAuth>().currentUser;
    if (user == null) {
      return const Scaffold(
        body: Center(child: Text('Sign in to view history.')),
      );
    }

    return BlocProvider(
      create: (_) =>
          sl<TryOnHistoryBloc>()..add(TryOnHistoryStarted(uid: user.uid)),
      child: BlocBuilder<TryOnHistoryBloc, TryOnHistoryState>(
        builder: (context, state) {
          return Scaffold(
            appBar: AppBar(title: const Text('Try-On History')),
            body: state.status == TryOnHistoryStatus.loading
                ? const Center(child: CircularProgressIndicator())
                : state.items.isEmpty
                ? const Center(child: Text('No try-on history yet.'))
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: state.items.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final item = state.items[index];
                      return Card(
                        child: ListTile(
                          leading: const Icon(Icons.auto_awesome),
                          title: Text(item.itemName),
                          subtitle: Text(
                            'Status: ${item.status}\n${item.createdAt}',
                          ),
                        ),
                      );
                    },
                  ),
          );
        },
      ),
    );
  }
}
