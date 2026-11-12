# Review Checklist - Minggu 8

## 3. Perbaikan Pesan Commit (Simulasi)

Berikut adalah tabel perbaikan 3 pesan commit lama yang tidak konvensional dari riwayat repository saya, diubah menjadi format `tipe(scope): deskripsi`.

| Sebelum (Buruk) | Sesudah (Konvensional) | Alasan |
| :--- | :--- | :--- |
| `perbaikan format` | `chore(format): rapikan indentasi dan hapus spasi berlebih` | Tipe `chore` digunakan untuk pekerjaan rutin non-fitur. Scope `format` menjelaskan area yang diubah, dan deskripsi menjelaskan secara spesifik apa yang diperbaiki. |
| `mini assigment` | `feat(ui): tambahkan halaman detail pengumuman` | Pesan lama tidak informatif. Diganti dengan tipe `feat` (fitur baru) dan scope `ui` karena menambahkan halaman baru, serta deskripsi yang jelas apa yang ditambahkan. |
| `update` | `fix(auth): perbaiki validasi email kosong pada form login` | Pesan `update` terlalu umum. Jika yang diubah adalah perbaikan bug validasi, gunakan tipe `fix`. Scope `auth` memperjelas fiturnya. |