import 'package:flutter/material.dart';

import '../messaging/push_service.dart';

class DebugFcmPage extends StatelessWidget {
  const DebugFcmPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Debug FCM')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            // Status (read-only)
            _section('Izin Notifikasi', permissionStatus),
            _section('FCM Token', fcmToken, shorten: true),
            _section('Sinkronisasi Backend', syncStatus),
            _section('Topik', topicStatus),
            _section('Notif Terakhir', lastNotif),

            const SizedBox(height: 24),

            // Aksi Subscribe / Unsubscribe
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.add_alert),
                    label: const Text('Subscribe'),
                    onPressed: () async {
                      final messenger = ScaffoldMessenger.of(context);
                      await subscribeTopic();
                      if (!context.mounted) return;
                      messenger.showSnackBar(
                        const SnackBar(
                          content: Text('Subscribed: pengumuman-kampus'),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.notifications_off),
                    label: const Text('Unsubscribe'),
                    onPressed: () async {
                      final messenger = ScaffoldMessenger.of(context);
                      await unsubscribeTopic();
                      if (!context.mounted) return;
                      messenger.showSnackBar(
                        const SnackBar(
                          content: Text('Unsubscribed: pengumuman-kampus'),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _section(
    String title,
    ValueNotifier<String?> notifier, {
    bool shorten = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          ValueListenableBuilder<String?>(
            valueListenable: notifier,
            builder: (_, value, __) {
              var text = value ?? '-';
              if (shorten && text.length > 12) {
                text = '${text.substring(0, 12)}...';
              }
              return Text(text, style: const TextStyle(fontSize: 15));
            },
          ),
          const Divider(),
        ],
      ),
    );
  }
}