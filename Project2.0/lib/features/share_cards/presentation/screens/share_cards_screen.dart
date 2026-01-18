import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:mirror_me/core/di/injection.dart';
import 'package:mirror_me/features/share_cards/presentation/bloc/share_cards_bloc.dart';
import 'package:mirror_me/features/share_cards/presentation/bloc/share_cards_event.dart';
import 'package:mirror_me/features/share_cards/presentation/bloc/share_cards_state.dart';

class ShareCardsScreen extends StatelessWidget {
  const ShareCardsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = sl<FirebaseAuth>().currentUser;
    if (user == null) {
      return const Scaffold(
        body: Center(child: Text('Sign in to share outfits.')),
      );
    }

    return BlocProvider(
      create: (_) =>
          sl<ShareCardsBloc>()..add(ShareCardsStarted(uid: user.uid)),
      child: BlocBuilder<ShareCardsBloc, ShareCardsState>(
        builder: (context, state) {
          return Scaffold(
            appBar: AppBar(title: const Text('Share Outfit Cards')),
            body: state.status == ShareCardsStatus.loading
                ? const Center(child: CircularProgressIndicator())
                : state.cards.isEmpty
                ? const Center(child: Text('No recommendations to share yet.'))
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: state.cards.length,
                    itemBuilder: (context, index) {
                      final item = state.cards[index];
                      final description = item.items.join(', ');
                      return Card(
                        child: ListTile(
                          title: Text(item.title),
                          subtitle: Text(description),
                          trailing: IconButton(
                            icon: const Icon(Icons.share),
                            onPressed: () {
                              Share.share(
                                'MirrorMe Outfit: ${item.title}\nItems: $description',
                              );
                            },
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
