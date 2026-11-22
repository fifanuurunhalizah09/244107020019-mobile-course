# 09-week-9-ai-assisted-development

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