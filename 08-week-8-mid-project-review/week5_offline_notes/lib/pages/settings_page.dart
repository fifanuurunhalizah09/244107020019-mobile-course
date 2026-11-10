import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/prefs.dart';
import '../data/connectivity.dart';

final prefsRepositoryProvider = Provider((ref) => PrefsRepository());

final darkModeProvider =
    AsyncNotifierProvider<DarkModeNotifier, bool>(DarkModeNotifier.new);

class DarkModeNotifier extends AsyncNotifier<bool> {
  @override
  Future<bool> build() =>
      ref.watch(prefsRepositoryProvider).getDarkMode();

  Future<void> toggle() async {
    final next = !(state.value ?? false);
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(prefsRepositoryProvider).setDarkMode(next);
      return next;
    });
  }
}

final lastOpenedProvider = FutureProvider<String?>((ref) async {
  return ref.watch(prefsRepositoryProvider).getLastOpened();
});

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final darkMode = ref.watch(darkModeProvider);
    final lastOpened = ref.watch(lastOpenedProvider);
    final forceOffline = ref.watch(forceOfflineProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Pengaturan')),
      body: ListView(
        children: [
          SwitchListTile(
            title: const Text('Mode Gelap'),
            subtitle: const Text('Disimpan via SharedPreferences'),
            value: darkMode.value ?? false,
            onChanged: darkMode.isLoading
                ? null
                : (_) => ref.read(darkModeProvider.notifier).toggle(),
          ),
          SwitchListTile(
            title: const Text('Paksa Mode Offline'),
            subtitle: const Text('Simulasi offline untuk demo & testing'),
            value: forceOffline,
            onChanged: (v) =>
                ref.read(forceOfflineProvider.notifier).state = v,
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.access_time),
            title: const Text('Terakhir Dibuka'),
            subtitle: lastOpened.when(
              data: (v) => Text(v ?? 'Belum pernah'),
              loading: () => const Text('Memuat...'),
              error: (e, _) => Text('Error: $e'),
            ),
          ),
        ],
      ),
    );
  }
}