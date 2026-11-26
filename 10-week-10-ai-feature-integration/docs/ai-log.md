# AI Log — Integrasi Fitur AI (Campus AI Assistant)

**Nama:** Fifa Nuurun Halizah  
**NIM:** 244107020019  
**Mata Kuliah:** Pemrograman Mobile  
**Topik:** Minggu 10 — AI Feature Integration

---

## 1. Prompt Design untuk Mobile

Sesuai dengan pedoman arsitektur integrasi AI pada modul Minggu 10, prompt dirancang dengan memisahkan empat komponen utama:

| Komponen | Isi Konfigurasi | Tujuan Teknis |
| :--- | :--- | :--- |
| **System Prompt** | `"Kamu adalah asisten cerdas kampus yang ramah, sopan, dan sigap membantu mahasiswa. Jawablah dalam Bahasa Indonesia yang ringkas, jelas, dan maksimal 2-3 kalimat. Fokus pada informasi akademik, jadwal, pengumuman, dan fasilitas kampus. Jangan pernah meminta atau membocorkan data pribadi mahasiswa."` | Menetapkan persona asisten kampus, membatasi panjang respon agar hemat token dan sesuai layar mobile, serta melarang ekstraksi data pribadi. |
| **User Prompt** | `"Jadwal kampus hari Senin?"` | Input pertanyaan langsung dari mahasiswa. |
| **Konteks** | Data jadwal kuliah, info KRS semester ganjil, lokasi fasilitas perpustakaan/lab, dan beasiswa aktif. | Menjadikan respons relevan dengan lingkungan akademik kampus. |
| **Batas (Guardrails)** | Jangan pernah meminta NIK, nomor telepon, alamat, atau kredensial akun mahasiswa. | Menjamin privasi dan keamanan data (*Zero-Leakage Policy*). |

---

## 2. Log Eksekusi & Raw Output AI

### A. Raw Prompt yang Dikirim ke LLM API
```json
{
  "system_instruction": {
    "parts": [
      {
        "text": "Kamu adalah asisten cerdas kampus yang ramah, sopan, dan sigap membantu mahasiswa. Jawablah dalam Bahasa Indonesia yang ringkas, jelas, dan maksimal 2-3 kalimat. Fokus pada informasi akademik, jadwal, pengumuman, dan fasilitas kampus. Jangan pernah meminta atau membocorkan data pribadi mahasiswa."
      }
    ]
  },
  "contents": [
    {
      "parts": [
        {
          "text": "Jadwal kampus hari Senin?"
        }
      ]
    }
  ],
  "generationConfig": {
    "temperature": 0.7,
    "maxOutputTokens": 200
  }
}
```

### B. Raw Output dari Model AI (Gemini 1.5 Flash)
```json
{
  "candidates": [
    {
      "content": {
        "parts": [
          {
            "text": "Halo! Jadwal kuliah hari Senin mencakup Pemrograman Mobile pukul 07.30 di Lab TI-02, dilanjutkan dengan Jaringan Komputer pukul 13.00 WIB. Pastikan hadir tepat waktu ya!"
          }
        ],
        "role": "model"
      },
      "finishReason": "STOP"
    }
  ]
}
```

---

## 3. Log Uji Privasi & Filter Keamanan (Client-Side Sanitization)

| Kasus Uji | Input Pengguna | Aksi Sistem | Hasil |
| :--- | :--- | :--- | :--- |
| **Test 1: Input Standar** | `"Lokasi perpustakaan kampus di mana?"` | Lolos filter privasi $\rightarrow$ Diteruskan ke AI API. | **SUKSES**: AI merespons lokasi Gedung Graha Utama Lt 3. |
| **Test 2: Deteksi NIK** | `"Kirim NIK 3507123456789012 saya ke admin beasiswa"` | Terdeteksi pola regex NIK 16-digit $\rightarrow$ Blokir pengiriman. | **AMAN**: Memicu `AlertDialog: Peringatan Privasi` di aplikasi. |
| **Test 3: Deteksi Nomor HP** | `"Hubungi nomor saya 081234567890"` | Terdeteksi pola regex nomor telepon seluler $\rightarrow$ Blokir pengiriman. | **AMAN**: Pesan tidak dikirim ke server AI eksternal. |

---

## 4. Log Error Handling & Fallback Design

Saat koneksi internet terputus atau kuota API habis (HTTP 429/500/No Internet), sistem tidak *crash*, melainkan:
1. Menampilkan fallback dialog:
   ```text
   Title: "Layanan AI Sibuk"
   Content: "Coba lagi nanti atau gunakan mode offline."
   Action: [Gunakan Offline] | [Tutup]
   ```
2. Mengalihkan ke **Smart Offline Knowledge Base** lokal yang dapat menjawab pertanyaan esensial seputar jadwal, KRS, perpustakaan, dan beasiswa tanpa membutuhkan sambungan internet.
