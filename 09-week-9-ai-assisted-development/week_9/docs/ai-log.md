# AI Log — Dokumentasi Eksperimen & Verifikasi Fitur Search Notes

**Nama:** Fifa Nuurun Halizah  
**NIM:** 244107020019  
**Mata Kuliah:** Pemrograman Mobile  
**Topik:** Minggu 9 — AI-Assisted Development (Vibe Coding)

---

## 1. Praktikum 1: Prompt & Context Engineering

### A. Formula 5 Slot (Prompt Utama)
Prompt disusun menggunakan kaidah 5 Slot (Peran, Konteks, Tugas, Batas, Output) agar AI menghasilkan kode yang terfokus, aman, dan dapat diuji:

| Slot | Isi Prompt |
| :--- | :--- |
| **Peran** | Senior Flutter Developer |
| **Konteks** | Proyek menggunakan arsitektur *feature-first* (`presentation -> domain <- data`), Riverpod untuk state management (tidak diimpor ke layer domain), kontrak model `Note { String id; String title; String body; }`, lokasi file `lib/features/notes/domain/filter_notes.dart`. Versi Flutter & Dart sesuai `pubspec.yaml`. |
| **Tugas** | Buat fungsi pure `filterNotes(List<Note> notes, String query)` untuk pencarian judul catatan (*case-insensitive*) dan siapkan struktur logika pendukung *empty state*. |
| **Batas** | Jangan ubah arsitektur; dilarang mengimpor Flutter, Dio, atau SQLite di domain; fungsi di bawah 40 baris; pure Dart tanpa side effect/IO; jangan ubah `note.dart` dan `note_repository.dart`. |
| **Output** | Kode `filter_notes.dart`, 3 unit test (cocok case-insensitive, query kosong, query tidak cocok), dan instruksi cara uji terminal. |

### B. Catatan Keamanan & Privasi
- **Zero Secrets Shared:** Tidak ada token FCM, JWT token, password database, maupun API key rahasia yang ditempel ke prompt.
- Semua data yang ditempel ke prompt menggunakan mock entity dan struktur data lokal.

---

## 2. Praktikum 2: Generate & Verifikasi Search

### A. Output Awal dari AI (`filter_notes.dart`)
```dart
import 'note.dart';

List<Note> filterNotes(List<Note> notes, String query) {
  final normalizedQuery = query.trim().toLowerCase();
  if (normalizedQuery.isEmpty) {
    return List<Note>.unmodifiable(notes);
  }

  return notes
      .where((note) => note.title.toLowerCase().contains(normalizedQuery))
      .toList(growable: false);
}
```

### B. Verifikasi 6 Langkah

1. **Baca Tiap Baris:**
   - Baris 4: Normalisasi query menggunakan `.trim()` dan `.toLowerCase()` untuk membersihkan spasi awal/akhir dan mengabaikan sensitivitas huruf.
   - Baris 5-7: *Early return* mengembalikan `List<Note>.unmodifiable(notes)` saat query kosong agar list awal tidak termutasi tanpa sengaja.
   - Baris 9-11: Penggunaan `.where()` dengan `.contains(normalizedQuery)` untuk pencarian substring judul catatan, dikonversi ke list unmodifiable (`growable: false`).
2. **Cek Import:**
   - **Lulus:** File `filter_notes.dart` hanya mengimpor `note.dart`. Layer domain 100% bebas dari library `flutter/material.dart`, `dio`, atau `sqflite`.
3. **Cek Validitas API:**
   - **Lulus:** Semua method (`trim()`, `toLowerCase()`, `contains()`, `toList(growable: false)`) adalah API resmi Dart SDK standar dan dapat diverifikasi melalui autocompletion IDE.
4. **Jalankan `flutter analyze`:**
   - Hasil: `No issues found!` (0 warning, 0 error).
5. **Uji Unit Test:**
   - Dibuat test case di `test/filter_notes_test.dart` dan `test/search_filter_test.dart` yang menguji:
     - Pencarian cocok secara *case-insensitive* (`'belanja'` cocok dengan `'Belanja Bulanan'`).
     - Query tidak cocok menghasilkan list kosong (`[]`).
     - Query kosong (`''`) atau spasi (`'   '`) mengembalikan seluruh catatan.
6. **Uji Manual:**
   - Dilakukan verifikasi rendering UI pada 3 skenario:
     - Query kosong -> Menampilkan seluruh daftar 5 catatan default.
     - Query cocok (`'flutter'`) -> Menampilkan catatan judul terkait.
     - Query tak cocok (`'zzz-tak-ada'`) -> Menampilkan *Empty State* (Icon `Icons.search_off` dan teks `"Catatan tidak ditemukan"`).

---

## 3. Praktikum 3: Debug & Refactoring

### A. Siklus Debug dengan Test Merah (Red-to-Green)

1. **Reproduksi:**
   - Ketika AI pertama kali diminta membuat unit test, AI mengimpor package fiktif:
     ```dart
     import 'package:your_app_name/features/notes/domain/filter_notes.dart';
     ```
   - Input pemicu: Menjalankan `flutter test` atau `flutter analyze` pada template test yang digenerate AI.
2. **Isolasi Masalah:**
   - AI mengasumsikan nama package generik `your_app_name` karena tidak diberikan nama package dari `pubspec.yaml`.
3. **Test Merah (Gagal):**
   - Perintah `flutter test` gagal saat kompilasi dengan pesan:
     ```text
     Error: Target of URI doesn't exist: 'package:your_app_name/features/notes/domain/filter_notes.dart'.
     ```
4. **Perbaikan Kecil (Refactor ke Hijau):**
   - Memperbaiki URI import menjadi package yang tepat sesuai `pubspec.yaml` (`package:week_9/...`).
   - Membersihkan typo penutup kurung kelas (`}g`) pada file presentasi.
5. **Verifikasi Ulang:**
   - Menjalankan `flutter analyze` -> `No issues found!`.
   - Menjalankan `flutter test` -> `All tests passed!`.

### B. Refactoring ke Clean Architecture (Layer Isolation)
Struktur layer dipisahkan dengan tegas:
- **Presentation Layer (`notes_page.dart`):**
  - Hanya mengelola UI dan interaksi input.
  - Memecah method berukuran besar menjadi sub-komponen modular berukuran < 30 baris:
    - `_buildSearchField()`
    - `_buildEmptyState()`
    - `_buildNotesList()`
  - Bebas dari pemanggilan database langsung maupun logika bisnis.
- **Domain Layer (`filter_notes.dart`, `note.dart`):**
  - Logika filter dan representasi model entity murni Dart.
  - Tidak bergantung pada layer presentation atau data.
- **Data Layer / Abstraction (`note_repository.dart`):**
  - Menyediakan kontrak antarmuka (`interface NoteRepository`) untuk persistensi data di masa depan.

---

## 4. AI Challenge: Senior Dev Code Review & Verification

### A. Prompt Review
```text
Review kode search Flutter ini sebagai senior dev.
Konteks: feature-first (presentation->domain<-data), Riverpod, SQLite + Dio.
Fokus: kebenaran, arsitektur, test. Abaikan style.
Beri 3 temuan + level blocker/saran + alasan.
```

### B. Hasil Temuan AI & Evaluasi Mahasiswa

| No | Usulan / Temuan AI | Level | Keputusan Mahasiswa | Alasan Teknis & Bukti |
|:---|:---|:---|:---|:---|
| 1 | **Pisahkan sub-widget presentation agar fungsi `build` tidak menumpuk lebih dari 40 baris** | Saran Arsitektur | **DITERIMA** | Fungsi `build()` awal berukuran lebih dari 60 baris. Dipecah menjadi `_buildSearchField()`, `_buildEmptyState()`, dan `_buildNotesList()`. Kode menjadi lebih deklaratif, mudah dirawat, dan mematuhi batas < 40 baris codelab. |
| 2 | **Gunakan `List<Note>.unmodifiable(...)` atau `toList(growable: false)` pada return fungsi filter** | Blocker Keamanan State | **DITERIMA** | Menjaga immutability agar komponen UI tidak memodifikasi list hasil filter secara langsung yang dapat menyebabkan *side effects* tidak terduga pada state management. Terbukti lulus uji immutability. |
| 3 | **AI menyarankan memindahkan filter langsung ke query SQL `LIKE %query%` di database SQLite sekarang juga** | Saran Teknis | **DITOLAK** | Untuk dataset catatan lokal yang berukuran kecil hingga menengah, filter in-memory murni di domain layer jauh lebih cepat, hemat resource I/O disk, dan memungkinkan unit testing murni tanpa perlu mocking koneksi SQLite. Database abstraction tetap terjaga di repository. |

### C. Keputusan Tiap File

| File | Jalur Layer | Keputusan | Catatan |
|:---|:---|:---|:---|
| `lib/features/notes/domain/filter_notes.dart` | Domain | **Terima + Refactor** | Pure function Dart, immutable list output, < 15 baris. |
| `lib/features/notes/domain/note.dart` | Domain | **Terima** | Immutable entity dengan `const` constructor. |
| `lib/features/notes/domain/note_repository.dart` | Domain | **Terima** | Abstract interface murni tanpa import luar. |
| `lib/features/notes/presentation/notes_page.dart` | Presentation | **Terima + Refactor** | Memisahkan method build ke widget kecil < 30 baris, memperbaiki typo syntax, dan menampilkan empty state responsif. |
| `test/filter_notes_test.dart` | Testing | **Terima + Refactor** | Memperbaiki import package rill `week_9`. |
| `test/search_filter_test.dart` | Testing | **Tulis Manual** | Menambahkan pengujian case-insensitive, whitespace, dan partial matching sesuai jobsheet. |
| `test/widget_test.dart` | Testing | **Tulis Manual** | Membuat widget test untuk validasi empty state dan TextField pencarian. |

---

## 5. Bukti Mesin Hijau (Green Engine Verification)

### A. Output `flutter analyze`
```text
$ flutter analyze
Analyzing week_9...
No issues found! (ran in 5.1s)
```

### B. Output `flutter test`
```text
$ flutter test
00:00 +0: test/filter_notes_test.dart: filterNotes mengembalikan note yang cocok secara case-insensitive
00:00 +1: test/filter_notes_test.dart: filterNotes mengembalikan semua notes jika query kosong atau hanya whitespace
00:00 +2: test/filter_notes_test.dart: filterNotes mengembalikan list kosong jika tidak ada title yang cocok
00:00 +3: test/search_filter_test.dart: search_filter_test - Pengujian Fungsi filterNotes filter abaikan huruf besar/kecil
00:00 +4: test/search_filter_test.dart: search_filter_test - Pengujian Fungsi filterNotes query tak cocok kembalikan kosong
00:00 +5: test/search_filter_test.dart: search_filter_test - Pengujian Fungsi filterNotes query kosong kembalikan semua notes
00:00 +6: test/search_filter_test.dart: search_filter_test - Pengujian Fungsi filterNotes query hanya whitespace kembalikan semua notes
00:00 +7: test/search_filter_test.dart: search_filter_test - Pengujian Fungsi filterNotes filter cocok sebagian kata di tengah judul
00:00 +8: test/widget_test.dart: NotesPage Widget Test menampilkan daftar catatan awal saat query kosong
00:01 +9: test/widget_test.dart: NotesPage Widget Test menampilkan hasil pencarian saat query cocok
00:01 +10: test/widget_test.dart: NotesPage Widget Test menampilkan empty state saat query tidak cocok
00:02 +11: All tests passed!
```

### C. Output `dart format`
```text
$ dart format --output=none --set-exit-if-changed .
Formatted 9 files (0 changed) in 0.06 seconds.
```
