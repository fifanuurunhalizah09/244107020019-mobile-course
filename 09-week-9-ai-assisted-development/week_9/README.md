# Laporan Praktikum Minggu 9 - AI-Assisted Development (Vibe Coding)

**Nama:** Fifa Nuurun Halizah  
**NIM:** 244107020019  
**Kelas / Jurusan:** Teknologi Informasi - Politeknik Negeri Malang  

---

## Tujuan Pembelajaran

Setelah menyelesaikan praktikum ini, mahasiswa mampu:
1. Menjelaskan workflow *AI-assisted development* (`prompt`, `generate`, `verify`, `test`, `refactor`, `explain`);
2. Menulis prompt dan konteks yang efektif untuk fitur Flutter kecil menggunakan Formula 5 Slot;
3. Mengenali halusinasi dan keterbatasan AI pada kode Flutter (seperti method fiktif, package kadaluarsa, dan logika keliru);
4. Melakukan debugging dan refactoring kode hasil AI agar tetap mematuhi prinsip arsitektur yang bersih;
5. Menguji kode hasil AI menggunakan `flutter analyze` dan unit test otomatis hingga bersih;
6. Mendokumentasikan prompt, hasil AI, keputusan terima/tolak, dan bukti uji secara sistematis pada `docs/ai-log.md`.

---

## Praktikum 1: Prompt dan Context Engineering

Berikut adalah prompt yang dirancang menggunakan **Formula 5 Slot** (Peran, Konteks, Tugas, Batas, Output) sesuai panduan codelab.

### 1. Prompt Mentah (Raw Prompt) yang Diberikan ke AI

**Peran:** Senior Flutter Dev

**Konteks:** 
- Proyek menggunakan arsitektur feature-first (presentation->domain<-data).
- State management: Riverpod.
- Model kontrak: `Note { String id; String title; String body; }`
- Struktur folder: `lib/features/notes/domain/` (fokus pada file `filter_notes.dart`).
- Versi package Flutter sesuai `pubspec.yaml` standar.

**Tugas:**
Tambahkan fitur search judul notes (filter) pada file `filter_notes.dart` dan sertakan empty state (logika jika data kosong).

**Batas:**
- Jangan ubah arsitektur.
- Jangan panggil SQLite/Dio dari dalam file ini (harus pure function).
- Maksimal 80 baris kode.
- Sertakan empty state + 1 widget test (opsional untuk logika domain).

**Output:**
- Kode `filter_notes.dart`
- 3 test case
- Cara uji (perintah terminal)

*(Log prompt lengkap dan catatan privasi dapat dilihat di [`docs/ai-log.md`](docs/ai-log.md)).*

---
---

## Praktikum 2: Generate dan Verifikasi Search

### 1. Output Kode AI (`filter_notes.dart`)
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
### 2. Verifikasi 6 Langkah
Berikut adalah bukti bahwa kode AI telah diverifikasi sesuai instruksi codelab:

1. Baca tiap baris: Seluruh logika fungsi filterNotes telah dibaca dan dipahami. AI menggunakan .trim() untuk membuang spasi, .toLowerCase() untuk mengabaikan huruf besar/kecil, dan .contains() untuk mencocokkan kata.

2. Cek import: LULUS. File filter_notes.dart di layer domain bersih, hanya meng-import note.dart (bebas dari dependensi Flutter, Dio, atau SQLite).

3. Cek API: LULUS. Method .trim(), .toLowerCase(), dan .contains() adalah API bawaan Dart yang valid (dibuktikan lewat autocomplete IDE, bukan method fiktif/halusinasi).

4. Jalankan flutter analyze: LULUS. Perintah dijalankan dan menghasilkan No issues found! (nol warning).

5. Tulis test: LULUS. Dibuat 3 unit test di test/filter_notes_test.dart (menguji sukses case-insensitive, query kosong, dan query tidak cocok).
``
### 3.  Bukti Halusinasi AI & Perbaikan
Halusinasi yang ditemukan: Saat AI diminta membuat unit test, AI menggunakan placeholder nama package (your_app_name). Ini terjadi karena AI tidak memiliki konteks nama package proyek sebenarnya.

Bukti & Perbaikan: Placeholder tersebut ditolak dan diperbaiki secara manual di file test menjadi nama package yang sesuai: week_09_ai_assisted_development. Ini dibuktikan dengan hilangnya error merah saat flutter analyze dijalankan ulang.