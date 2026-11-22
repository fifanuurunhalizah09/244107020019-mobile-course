# AI Log — Fitur Search Notes

## Praktikum 1: Prompt dan Context Engineering

### 1. Prompt Awal (Iterasi 1)
**Peran:** senior Flutter developer
**Konteks:**
- Arsitektur: feature-first, presentation -> domain <- data
- State management: Riverpod (belum dipakai di file target)
- Domain layer harus murni Dart: TIDAK boleh import Flutter / Dio / SQLite
- Model kontrak: `Note { String id; String title; String body; }`
- File target: `lib/features/notes/domain/filter_notes.dart`
- Repository kontrak: `NoteRepository.getAllNotes()` (jangan diubah)

**Tugas:**
Implementasikan fungsi `filterNotes(List<Note> notes, String query)`:
1. Kembalikan notes yang `title`-nya mengandung `query`.
2. Case-insensitive (abaikan huruf besar/kecil).
3. Jika `query` kosong atau hanya whitespace -> kembalikan semua notes.
4. Tidak memanggil database/IO apa pun (pure function).

**Batas:**
- Jangan ubah `note.dart`, `note_repository.dart`, atau `pubspec.yaml`.
- Jangan tambah dependency baru.
- Maksimal 30 baris kode.
- Hanya edit file `filter_notes.dart`.

**Output yang diminta:**
1. Kode final `filter_notes.dart`.
2. 3 unit test: (a) match case-insensitive, (b) query kosong -> semua, (c) query tidak cocok -> kosong.
3. Perintah untuk menjalankan test.

---

### 2. Prompt Iterasi 2 (Sesuai Formula 5 Slot Codelab)
*(Disempurnakan berdasarkan gambar modul)*

**Peran:** senior Flutter dev
**Konteks:** 
- Arsitektur: feature-first, presentation->domain<-data.
- Riverpod, SQLite + Dio (hanya untuk konteks luar, tidak dipakai di domain).
- Struktur folder: `lib/features/notes/domain/`.
- Model: `Note { id, title, body }`.

**Tugas:** tambah search judul notes + empty state (logika jika data tidak ditemukan).

**Batas:** jangan ubah arsitektur, maks 80 baris, jangan panggil SQLite dari widget.

**Output:** kode + 3 test case + cara uji.

*(Catatan Privasi: Saya tidak menempelkan token FCM, JWT, atau API key apa pun sesuai instruksi keamanan).*
---

## Praktikum 2: Generate dan Verifikasi Search

### 1. Output Awal AI
Kode `filter_notes.dart` yang dihasilkan:
(terlampir di file project)

### 2. Bukti Halusinasi AI & Perbaikan
- **Halusinasi:** AI menggunakan placeholder `your_app_name` pada file test karena tidak tahu nama package proyek.
- **Bukti & Perbaikan:** Diperbaiki secara manual menjadi `week_09_ai_assisted_development`. (Dibuktikan dengan hilangnya error import saat `flutter analyze`).

### 3. Verifikasi 6 Langkah
- **Import:** LULUS. Layer domain bersih (hanya import `note.dart`).
- **API:** LULUS. Method `.trim()`, `.toLowerCase()`, `.contains()` valid.
- **Unit Test:** 3 test dibuat di `test/filter_notes_test.dart`.

### 4. Bukti Mesin Hijau
- `flutter analyze` : No issues found!
- `flutter test` : All tests passed! (+3 test lulus)