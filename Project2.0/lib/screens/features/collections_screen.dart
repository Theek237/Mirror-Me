import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/di/injection.dart';
import '../../features/collections/presentation/bloc/collections_bloc.dart';
import '../../features/collections/presentation/bloc/collections_event.dart';
import '../../features/collections/presentation/bloc/collections_state.dart';

class CollectionsScreen extends StatelessWidget {
  const CollectionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = sl<FirebaseAuth>().currentUser;
    if (user == null) {
      return const Scaffold(
        body: Center(child: Text('Sign in to view collections.')),
      );
    }

    return BlocProvider(
      create: (_) =>
          sl<CollectionsBloc>()..add(CollectionsStarted(uid: user.uid)),
      child: BlocConsumer<CollectionsBloc, CollectionsState>(
        listenWhen: (previous, current) =>
            previous.message != current.message && current.message != null,
        listener: (context, state) {
          final message = state.message;
          if (message == null) return;
          final isError = state.status == CollectionsStatus.failure;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(message),
              backgroundColor: isError ? Colors.redAccent : Colors.green,
            ),
          );
          context.read<CollectionsBloc>().add(
            const CollectionsMessageCleared(),
          );
        },
        builder: (context, state) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Outfit Collections'),
              actions: [
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () => _showCreateDialog(context, user.uid),
                ),
              ],
            ),
            body: state.status == CollectionsStatus.loading
                ? const Center(child: CircularProgressIndicator())
                : state.collections.isEmpty
                ? const Center(child: Text('Create your first collection.'))
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: state.collections.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final item = state.collections[index];
                      return Card(
                        child: ListTile(
                          title: Text(item.name),
                          subtitle: Text('Created: ${item.createdAt}'),
                          trailing: const Icon(Icons.chevron_right),
                        ),
                      );
                    },
                  ),
          );
        },
      ),
    );
  }

  Future<void> _showCreateDialog(BuildContext context, String uid) async {
    final controller = TextEditingController();
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('New Collection'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(labelText: 'Collection name'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () async {
                final name = controller.text.trim();
                if (name.isEmpty) return;
                if (!context.mounted) return;
                context.read<CollectionsBloc>().add(
                  CollectionCreateRequested(uid: uid, name: name),
                );
                if (context.mounted) Navigator.pop(context);
              },
              child: const Text('Create'),
            ),
          ],
        );
      },
    );
  }
}
