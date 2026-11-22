# AI Log — Fitur Search Notes

## Prompt 1 — Implementasi search judul notes (Praktikum 1)

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
