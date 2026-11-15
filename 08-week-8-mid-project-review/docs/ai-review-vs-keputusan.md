# AI Review vs Keputusan

## 1. Peran AI pada Codelab

Pada codelab Week 8, AI digunakan sebagai reviewer awal untuk membantu menemukan kemungkinan masalah pada Pull Request. AI digunakan untuk memberikan sudut pandang tambahan terhadap kebenaran kode, arsitektur, dan testing.

Hasil review AI tidak langsung diterapkan. Setiap temuan diverifikasi terlebih dahulu berdasarkan kode, hasil testing, static analysis, dan kebutuhan project. Keputusan akhir tetap dilakukan oleh developer berdasarkan kondisi project yang sebenarnya.

---

## 2. Prompt AI

Prompt yang digunakan pada Pull Request adalah:

> Review PR Flutter ini sebagai senior Flutter dev.  
> Konteks: feature-first Clean Architecture (presentation -> domain <- data), Riverpod, GoRouter, SQLite + Dio.  
> Fokus: kebenaran, arsitektur, dan test. Abaikan style.  
> Berikan 5 temuan teratas + level (blocker/saran)  
> + alasan + usulan potongan kode perbaikan.

---

## 3. Output Awal AI

Berdasarkan review terhadap diff PR, AI memberikan 5 temuan berikut:

| No | Level | Temuan |
|---|---|---|
| 1 | Saran | Validasi `title` dan `body` dilakukan langsung di presentation. |
| 2 | Saran | Belum terlihat test untuk kasus data kosong. |
| 3 | Saran | `trim()` dipanggil di UI dan hasil normalisasinya tidak digunakan. |
| 4 | Saran | Pesan `"Data pengumuman tidak lengkap"` terlalu umum. |
| 5 | Saran | Perubahan hanya menangani data yang sudah berhasil masuk ke `data` state. |

AI menyimpulkan bahwa tidak terdapat blocker pada perubahan yang terlihat. Perubahan secara fungsional dianggap masuk akal, tetapi AI menyarankan perbaikan pada penempatan aturan validasi dan penambahan automated test.

---

## 4. Verifikasi Temuan AI

### Temuan 1 — Validasi Dilakukan di Presentation

**Saran AI:**

Validasi `title` dan `body` dilakukan langsung di presentation. Jika kondisi pengumuman tidak lengkap merupakan aturan domain, validasi sebaiknya berada di domain atau use case.

**Verifikasi:**

Pada perubahan `announcement_page.dart`, kondisi validasi dilakukan secara langsung pada layer presentation:

```dart
if (a.title.trim().isEmpty || a.body.trim().isEmpty) {
  return const Center(
    child: Text('Data pengumuman tidak lengkap'),
  );
}
```

Dari kode tersebut terlihat bahwa aturan `title` dan `body` kosong memang diperiksa di presentation.

**Keputusan: Diterima sebagai saran perbaikan.**

**Alasan:**

Temuan AI benar secara konsep Clean Architecture. Jika aturan bahwa pengumuman harus memiliki `title` dan `body` merupakan aturan yang berlaku pada data domain, validasi sebaiknya tidak hanya bergantung pada UI.

Namun, perubahan ini tidak dianggap sebagai blocker karena fitur masih dapat berjalan dan validasi pada presentation tetap mencegah data kosong ditampilkan.

**Bukti:**  
Pemeriksaan dilakukan pada perubahan file `announcement_page.dart` pada Pull Request.

---

### Temuan 2 — Belum Ada Test untuk Data Kosong

**Saran AI:**

Perubahan menambahkan behavior baru sehingga seharusnya terdapat automated test untuk kondisi `title` kosong, `body` kosong, dan data valid.

**Verifikasi:**

Perubahan pada PR menambahkan behavior validasi pengumuman. Oleh karena itu, behavior tersebut sebaiknya memiliki test agar dapat dipastikan tetap berjalan ketika kode dikembangkan lebih lanjut.

Test yang disarankan meliputi:

```dart
test('announcement tidak valid jika title kosong', () {
  final announcement = Announcement(
    title: '   ',
    body: 'Isi pengumuman',
  );

  expect(announcement.isValid, false);
});

test('announcement tidak valid jika body kosong', () {
  final announcement = Announcement(
    title: 'Judul',
    body: '   ',
  );

  expect(announcement.isValid, false);
});

test('announcement valid jika title dan body terisi', () {
  final announcement = Announcement(
    title: 'Judul',
    body: 'Isi pengumuman',
  );

  expect(announcement.isValid, true);
});
```

**Keputusan: Diterima.**

**Alasan:**

Temuan ini relevan karena perubahan menambahkan behavior baru berupa validasi. Automated test diperlukan untuk memastikan behavior tersebut tetap berjalan dan tidak rusak akibat perubahan kode berikutnya.

**Bukti:**

Test dijalankan menggunakan:

```text
flutter test
```

Hasil test didokumentasikan sebagai bukti pada folder/screenshots pengerjaan Week 8.

---

### Temuan 3 — `trim()` di UI

**Saran AI:**

`trim()` dipanggil di UI, tetapi hasil normalisasinya tidak digunakan. AI menyarankan agar normalisasi dilakukan sebelum data sampai ke presentation.

**Verifikasi:**

Kode menggunakan:

```dart
a.title.trim().isEmpty
```

dan:

```dart
a.body.trim().isEmpty
```

Penggunaan tersebut digunakan untuk memeriksa apakah string hanya berisi whitespace. Hasil `trim()` memang tidak disimpan kembali ke data.

Namun, tujuan perubahan pada PR adalah **validasi**, bukan mengubah atau membersihkan data yang ditampilkan.

**Keputusan: Ditolak untuk perubahan saat ini.**

**Alasan:**

Tidak menggunakan hasil `trim()` kembali bukan merupakan bug pada behavior validasi saat ini. `trim()` sudah berhasil digunakan untuk menentukan apakah nilai kosong atau hanya terdiri dari whitespace.

Jika normalisasi data diperlukan sebagai requirement tersendiri, hal tersebut dapat menjadi improvement pada fitur berikutnya. Untuk PR ini, perubahan tersebut tidak diperlukan.

---

### Temuan 4 — Pesan Error Terlalu Umum

**Saran AI:**

Pesan `"Data pengumuman tidak lengkap"` terlalu umum dan sebaiknya membedakan apakah `title` atau `body` yang bermasalah.

**Verifikasi:**

Pesan yang digunakan saat ini adalah:

```text
Data pengumuman tidak lengkap
```

Pesan tersebut memang tidak menjelaskan field mana yang kosong.

Namun, validasi pada perubahan ini hanya digunakan untuk mencegah data pengumuman yang tidak lengkap ditampilkan. Tidak terdapat requirement pada PR yang mengharuskan pesan error menampilkan field secara spesifik.

**Keputusan: Ditolak untuk perubahan saat ini.**

**Alasan:**

Pesan yang digunakan sudah cukup untuk memberikan informasi bahwa data pengumuman tidak lengkap. Mengubah pesan menjadi lebih spesifik merupakan peningkatan UX, tetapi bukan masalah kebenaran, arsitektur, atau testing yang menjadi fokus utama code review pada jobsheet ini.

---

### Temuan 5 — Validasi Data dari Repository/Use Case

**Saran AI:**

Jika `title` atau `body` kosong berasal dari SQLite/API, validasi juga sebaiknya dilakukan pada repository atau use case agar data invalid tidak dianggap sebagai data domain yang valid.

**Verifikasi:**

Perubahan pada PR berfokus pada penanganan data pengumuman yang diterima oleh halaman. AI tidak memiliki informasi lengkap mengenai seluruh implementasi repository, database, atau API karena review hanya berdasarkan diff `announcement_page.dart`.

Oleh karena itu, saran tersebut tidak dapat langsung dinyatakan sebagai bug berdasarkan diff yang tersedia.

**Keputusan: Ditolak sebagai temuan wajib pada PR ini.**

**Alasan:**

AI sendiri menyatakan bahwa review hanya berdasarkan diff yang terlihat. Tidak terdapat bukti bahwa repository atau use case saat ini menerima dan menyimpan data invalid sebagai data domain.

Saran tersebut dapat dipertimbangkan sebagai improvement apabila validasi memang merupakan aturan domain yang berlaku pada seluruh sumber data.

---

## 5. Ringkasan Usulan vs Keputusan Final

| No | Usulan AI | Keputusan | Alasan |
|---|---|---|---|
| 1 | Validasi dipindahkan ke domain/use case | Diterima sebagai saran | Sesuai prinsip Clean Architecture |
| 2 | Menambahkan test untuk data kosong | **Diterima** | Behavior baru perlu automated test |
| 3 | Normalisasi `trim()` dilakukan sebelum presentation | **Ditolak** | `trim()` sudah cukup untuk kebutuhan validasi saat ini |
| 4 | Pesan error dibuat lebih spesifik | **Ditolak** | Bukan masalah utama pada kebenaran/arsitektur/test |
| 5 | Validasi juga dilakukan pada repository/use case | **Ditolak sebagai wajib** | Tidak ada bukti dari diff bahwa repository menghasilkan data invalid |

---

## 6. Dependency Rule

Review juga mempertimbangkan dependency rule pada Clean Architecture:

```text
presentation -> domain <- data
```

Layer `domain` tidak seharusnya mengimpor atau bergantung langsung pada:

- Flutter
- Dio
- SQLite

Saran AI untuk memindahkan aturan validasi ke domain tidak diterapkan secara sembarangan. Jika validasi dipindahkan, implementasinya harus tetap menjaga dependency rule dan tidak membuat domain bergantung pada Flutter, Dio, atau SQLite.

---

## 7. Testing dan Static Analysis

Setelah perubahan dilakukan, project diperiksa menggunakan:

```text
flutter analyze
```

```text
dart format --set-exit-if-changed .
```

```text
flutter test
```

Hasil pemeriksaan digunakan untuk memastikan perubahan tidak menyebabkan error pada static analysis, formatting, maupun automated test.

### Hasil `flutter analyze`

```text
[Tempel hasil flutter analyze di sini]
```

### Hasil `dart format --set-exit-if-changed .`

```text
[Tempel hasil dart format di sini]
```

### Hasil `flutter test`

```text
[Tempel hasil flutter test di sini]
```

---

## 8. Kesimpulan AI Review

Berdasarkan hasil review AI dan verifikasi terhadap kode, tidak ditemukan blocker pada perubahan yang direview.

Dua temuan utama yang dianggap benar adalah perlunya mempertimbangkan penempatan validasi pada domain/use case dan perlunya automated test untuk behavior validasi. Sementara itu, beberapa saran AI ditolak karena tidak terbukti sebagai masalah pada implementasi saat ini atau hanya merupakan improvement yang belum menjadi requirement.

Dengan demikian, AI digunakan sebagai reviewer awal, sedangkan keputusan akhir tetap didasarkan pada bukti kode, kebutuhan project, prinsip Clean Architecture, dan hasil pengujian.