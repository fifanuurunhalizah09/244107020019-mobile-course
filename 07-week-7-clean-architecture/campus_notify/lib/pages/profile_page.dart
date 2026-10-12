import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/auth_provider.dart';
import '../providers/theme_provider.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil'),
        automaticallyImplyLeading: false,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Header profil
          Center(
            child: Column(
              children: [
                CircleAvatar(
                  radius: 44,
                  backgroundColor: scheme.primaryContainer,
                  child: Icon(
                    Icons.person,
                    size: 48,
                    color: scheme.onPrimaryContainer,
                  ),
                ),
                const SizedBox(height: 14),
                const Text(
                  'Mahasiswa',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'test@campus.ac.id',
                  style: TextStyle(
                    fontSize: 14,
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // Section: Pengaturan
          _sectionTitle('Pengaturan', scheme),
          const SizedBox(height: 8),
          Card(
            child: Column(
              children: [
                // Dark mode toggle
                SwitchListTile(
                  value: themeMode == ThemeMode.dark,
                  onChanged: (_) =>
                      ref.read(themeProvider.notifier).toggle(),
                  secondary: Icon(
                    themeMode == ThemeMode.dark
                        ? Icons.dark_mode
                        : Icons.light_mode,
                    color: scheme.primary,
                  ),
                  title: const Text('Mode Gelap'),
                  subtitle: Text(
                    themeMode == ThemeMode.dark ? 'Aktif' : 'Nonaktif',
                  ),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: Icon(Icons.notifications_outlined,
                      color: scheme.primary),
                  title: const Text('Debug FCM'),
                  subtitle: const Text('Lihat status notifikasi & token'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.push('/debug-fcm'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Section: Info akun
          _sectionTitle('Informasi Akun', scheme),
          const SizedBox(height: 8),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: Icon(Icons.school_outlined, color: scheme.primary),
                  title: const Text('NIM'),
                  subtitle: const Text('244107020191'),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: Icon(Icons.class_outlined, color: scheme.primary),
                  title: const Text('Kelas'),
                  subtitle: const Text('TI 3G'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Logout
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              icon: const Icon(Icons.logout),
              label: const Text('Logout'),
              style: OutlinedButton.styleFrom(
                foregroundColor: scheme.error,
                side: BorderSide(
                  color: scheme.error.withValues(alpha: 0.5),
                ),
                minimumSize: const Size.fromHeight(50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () =>
                  ref.read(authStateProvider.notifier).logout(),
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: Text(
              'Campus Notify v1.0.0',
              style: TextStyle(
                fontSize: 12,
                color: scheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String text, ColorScheme scheme) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: scheme.onSurfaceVariant,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}