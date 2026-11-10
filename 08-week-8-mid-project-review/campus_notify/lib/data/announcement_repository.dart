import '../models/announcement.dart';

class AnnouncementRepository {
  Future<List<Announcement>> fetchAll() async {
    // Simulasi delay network
    await Future.delayed(const Duration(milliseconds: 800));

    final now = DateTime.now();
    return [
      Announcement(
        id: '1',
        title: 'Jadwal UAS Semester Ganjil 2025/2026',
        body:
            'Ujian Akhir Semester akan dilaksanakan pada tanggal 15-20 Desember 2025. '
            'Silakan cek jadwal masing-masing mata kuliah di portal akademik. '
            'Pastikan tidak ada tunggakan administrasi sebelum ujian.',
        category: AnnouncementCategory.akademik,
        publishedAt: now.subtract(const Duration(hours: 2)),
      ),
      Announcement(
        id: '2',
        title: 'Seminar Nasional: AI untuk Indonesia',
        body:
            'Ikuti seminar nasional dengan tema "AI untuk Indonesia Emas 2045" '
            'yang akan diadakan di Auditorium Utama. Pembicara: Dr. Ir. Budi Santoso. '
            'Pendaftaran gratis untuk 100 peserta pertama.',
        category: AnnouncementCategory.event,
        publishedAt: now.subtract(const Duration(hours: 5)),
      ),
      Announcement(
        id: '3',
        title: 'Jadwal kuliah berubah',
        body:
            'Kelas Mobile pindah ke Ruang A2 jam 13.00 mulai pekan depan. '
            'Mohon diperhatikan perubahan jadwal ini.',
        category: AnnouncementCategory.akademik,
        publishedAt: now.subtract(const Duration(days: 1)),
      ),
      Announcement(
        id: '4',
        title: 'Pembayaran UKT Semester Genap',
        body:
            'Batas akhir pembayaran UKT Semester Genap adalah 30 November 2025. '
            'Pembayaran dapat dilakukan melalui bank partner atau virtual account. '
            'Keterlambatan akan dikenakan denda.',
        category: AnnouncementCategory.umum,
        publishedAt: now.subtract(const Duration(days: 2)),
      ),
      Announcement(
        id: '5',
        title: 'Workshop Flutter untuk Pemula',
        body:
            'Workshop Flutter akan diadakan pada tanggal 25 November 2025 di Lab Komputer. '
            'Materi: dasar Flutter, widget, state management, dan deploy ke Play Store. '
            'Kuota terbatas!',
        category: AnnouncementCategory.event,
        publishedAt: now.subtract(const Duration(days: 3)),
      ),
      Announcement(
        id: '6',
        title: 'Libur Nasional Hari Guru',
        body:
            'Kegiatan perkuliahan diliburkan pada tanggal 25 November 2025 '
            'dalam rangka Hari Guru Nasional. Perkuliahan akan dilanjutkan '
            'pada tanggal 26 November 2025.',
        category: AnnouncementCategory.umum,
        publishedAt: now.subtract(const Duration(days: 4)),
      ),
    ];
  }

  Future<Announcement?> findById(String id) async {
    final all = await fetchAll();
    try {
      return all.firstWhere((a) => a.id == id);
    } catch (_) {
      return null;
    }
  }
}