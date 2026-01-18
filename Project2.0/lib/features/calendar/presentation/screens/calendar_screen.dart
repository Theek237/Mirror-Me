import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:mirror_me/core/di/injection.dart';
import 'package:mirror_me/features/calendar/presentation/bloc/calendar_bloc.dart';
import 'package:mirror_me/features/calendar/presentation/bloc/calendar_event.dart';
import 'package:mirror_me/features/calendar/presentation/bloc/calendar_state.dart';

class OutfitCalendarScreen extends StatelessWidget {
  const OutfitCalendarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = sl<FirebaseAuth>().currentUser;
    if (user == null) {
      return const Scaffold(
        body: Center(child: Text('Sign in to manage calendar.')),
      );
    }

    return BlocProvider(
      create: (_) => sl<CalendarBloc>()..add(CalendarStarted(uid: user.uid)),
      child: BlocConsumer<CalendarBloc, CalendarState>(
        listenWhen: (previous, current) =>
            previous.message != current.message && current.message != null,
        listener: (context, state) {
          final message = state.message;
          if (message == null) return;
          final isError = state.status == CalendarStatus.failure;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(message),
              backgroundColor: isError ? Colors.redAccent : Colors.green,
            ),
          );
          context.read<CalendarBloc>().add(const CalendarMessageCleared());
        },
        builder: (context, state) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Outfit Calendar'),
              actions: [
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () => _addEvent(context, user.uid),
                ),
              ],
            ),
            body: state.status == CalendarStatus.loading
                ? const Center(child: CircularProgressIndicator())
                : state.events.isEmpty
                ? const Center(child: Text('No planned outfits yet.'))
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: state.events.length,
                    itemBuilder: (context, index) {
                      final item = state.events[index];
                      return Card(
                        child: ListTile(
                          title: Text(item.title),
                          subtitle: Text('Date: ${item.date}'),
                        ),
                      );
                    },
                  ),
          );
        },
      ),
    );
  }

  Future<void> _addEvent(BuildContext context, String uid) async {
    final controller = TextEditingController();
    DateTime? selectedDate;

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Plan Outfit'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: controller,
                    decoration: const InputDecoration(labelText: 'Event title'),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          selectedDate == null
                              ? 'Pick a date'
                              : selectedDate!
                                    .toIso8601String()
                                    .split('T')
                                    .first,
                        ),
                      ),
                      TextButton(
                        onPressed: () async {
                          final date = await showDatePicker(
                            context: context,
                            firstDate: DateTime.now().subtract(
                              const Duration(days: 1),
                            ),
                            lastDate: DateTime.now().add(
                              const Duration(days: 365),
                            ),
                            initialDate: DateTime.now(),
                          );
                          if (date != null) setState(() => selectedDate = date);
                        },
                        child: const Text('Select'),
                      ),
                    ],
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: () async {
                    final title = controller.text.trim();
                    if (title.isEmpty || selectedDate == null) return;
                    if (!context.mounted) return;
                    context.read<CalendarBloc>().add(
                      CalendarAddRequested(
                        uid: uid,
                        title: title,
                        date:
                            selectedDate?.toIso8601String().split('T').first ??
                            '',
                      ),
                    );
                    if (context.mounted) Navigator.pop(context);
                  },
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
