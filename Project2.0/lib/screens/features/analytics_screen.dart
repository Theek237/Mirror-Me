import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/di/injection.dart';
import '../../features/analytics/presentation/bloc/analytics_bloc.dart';
import '../../features/analytics/presentation/bloc/analytics_event.dart';
import '../../features/analytics/presentation/bloc/analytics_state.dart';

class ClosetAnalyticsScreen extends StatelessWidget {
  const ClosetAnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = sl<FirebaseAuth>().currentUser;
    if (user == null) {
      return const Scaffold(
        body: Center(child: Text('Sign in to view analytics.')),
      );
    }

    return BlocProvider(
      create: (_) => sl<AnalyticsBloc>()..add(AnalyticsStarted(uid: user.uid)),
      child: BlocBuilder<AnalyticsBloc, AnalyticsState>(
        builder: (context, state) {
          if (state.status == AnalyticsStatus.loading) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          final summary = state.analytics;
          if (summary == null ||
              (summary.categoryCounts.isEmpty && summary.colorCounts.isEmpty)) {
            return const Scaffold(
              body: Center(child: Text('Add wardrobe items to see analytics.')),
            );
          }

          return Scaffold(
            appBar: AppBar(title: const Text('Closet Analytics')),
            body: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const Text(
                  'Top Categories',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                ...summary.categoryCounts.entries.map(
                  (entry) => Card(
                    child: ListTile(
                      title: Text(entry.key),
                      trailing: Text(entry.value.toString()),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Color Palette',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                ...summary.colorCounts.entries.map(
                  (entry) => Card(
                    child: ListTile(
                      title: Text(entry.key),
                      trailing: Text(entry.value.toString()),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
