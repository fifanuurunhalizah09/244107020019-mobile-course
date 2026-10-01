import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/todo_provider.dart';

class StatsPage extends ConsumerWidget {
  const StatsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todos = ref.watch(todoListProvider);

    final total = todos.length;
    final selesai = todos.where((todo) => todo.done).length;
    final belumSelesai = todos.where((todo) => !todo.done).length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Statistik'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ListTile(
            leading: const Icon(Icons.list),
            title: const Text('Total tugas'),
            trailing: Text('$total'),
          ),
          ListTile(
            leading: const Icon(Icons.check_circle),
            title: const Text('Selesai'),
            trailing: Text('$selesai'),
          ),
          ListTile(
            leading: const Icon(Icons.pending),
            title: const Text('Belum selesai'),
            trailing: Text('$belumSelesai'),
          ),
        ],
      ),
    );
  }
}