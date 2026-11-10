enum AnnouncementCategory {
  akademik('Akademik'),
  event('Event'),
  umum('Umum');

  const AnnouncementCategory(this.label);
  final String label;
}

class Announcement {
  const Announcement({
    required this.id,
    required this.title,
    required this.body,
    required this.category,
    required this.publishedAt,
    this.imageUrl,
    this.isRead = false,
  });

  final String id;
  final String title;
  final String body;
  final AnnouncementCategory category;
  final DateTime publishedAt;
  final String? imageUrl;
  final bool isRead;

  Announcement copyWith({bool? isRead}) {
    return Announcement(
      id: id,
      title: title,
      body: body,
      category: category,
      publishedAt: publishedAt,
      imageUrl: imageUrl,
      isRead: isRead ?? this.isRead,
    );
  }

  String get timeAgo {
    final diff = DateTime.now().difference(publishedAt);
    if (diff.inMinutes < 60) return '${diff.inMinutes} menit lalu';
    if (diff.inHours < 24) return '${diff.inHours} jam lalu';
    if (diff.inDays < 7) return '${diff.inDays} hari lalu';
    return '${(diff.inDays / 7).floor()} minggu lalu';
  }
}