# AGENTS.md — Instruksi Proyek DaunKu

Dokumen ini berisi aturan kerja untuk coding agent yang mengerjakan proyek Flutter DaunKu.

## 1. Baca rancangan sebelum mengubah kode

Sebelum melakukan pekerjaan yang mengubah kode, baca file berikut dari root proyek:

- `DaunKu_Rancangan_Modularisasi.md`

Gunakan dokumen itu sebagai acuan arsitektur, struktur folder, cakupan halaman, prioritas, dan urutan implementasi. Jangan menganggap semua file yang disebut di rancangan sudah dibuat; periksa kondisi proyek yang sebenarnya terlebih dahulu.

Jika file rancangan tidak ditemukan, jangan mengarang isi atau menganggap sudah membacanya. Beri tahu pengguna dan minta file ditempatkan di root proyek.

## 2. Konteks proyek

- Nama aplikasi: DaunKu.
- Framework: Flutter.
- Target saat ini: Android.
- Bahasa percakapan dan penjelasan kepada pengguna: Bahasa Indonesia yang jelas dan bertahap.
- Pengguna masih membangun pemahaman tentang modularisasi; jelaskan perubahan dengan istilah sederhana.
- Fitur yang perlu diprioritaskan: Beranda, Diagnosis, dan Marketplace.
- Model AI diagnosis tetap masuk rancangan, tetapi implementasi AI ditunda sampai fondasi aplikasi stabil dan pilihan model/API ditetapkan.

## 3. Aturan sebelum mengerjakan

Sebelum mengedit:
1. Periksa struktur direktori dan file yang benar-benar ada.
2. Baca file terkait yang akan diubah.
3. Jalankan atau periksa status Git jika tersedia; jangan menganggap Git sudah dikonfigurasi.
4. Identifikasi error yang ada sebelum perubahan.
5. Buat rencana singkat dan kerjakan perubahan kecil yang dapat diverifikasi.

Jangan langsung menulis ulang seluruh aplikasi atau memindahkan banyak file sekaligus tanpa persetujuan pengguna.

## 4. Prioritas pengembangan

Ikuti urutan umum ini, kecuali pengguna secara eksplisit meminta prioritas lain:

1. Pulihkan dan stabilkan kode yang sudah ada.
2. Selesaikan modularisasi UI Diagnosis tanpa menghilangkan perilaku yang sudah bekerja.
3. Buat navigasi utama untuk Beranda, Diagnosis, Marketplace, dan Profil.
4. Implementasikan Beranda dengan fungsi navigasi dan data lokal yang jelas ditandai sebagai demo bila sesuai.
5. Implementasikan Marketplace bertahap: katalog data lokal, pencarian, filter kategori, detail produk, lalu keranjang lokal jika diminta/layak.
6. Siapkan model dan service diagnosis sebagai struktur arsitektur, tanpa berpura-pura menjalankan prediksi AI.
7. Kerjakan riwayat, penyimpanan, dan integrasi AI setelah kebutuhan dan desainnya ditentukan.

## 5. Aturan modularisasi

- `lib/main.dart` hanya menangani entry point aplikasi jika memungkinkan.
- `lib/app.dart` mengatur konfigurasi aplikasi tingkat atas.
- Tema global dikelola di `lib/core/theme/app_theme.dart`.
- Navigasi utama dikelola di modul navigasi, bukan diduplikasi pada setiap halaman.
- Setiap fitur memiliki tanggung jawab sendiri; letakkan halaman di `screens/`, widget khusus fitur di `widgets/`, bentuk data di `models/`, data contoh di `data/`, dan logika akses/proses di `services/` bila memang diperlukan.
- Komponen yang hanya digunakan satu fitur tetap berada di fitur itu. Pindahkan ke `core/widgets/` hanya jika benar-benar digunakan lintas fitur.
- Hindari membuat file kosong atau abstraksi berlebihan hanya untuk memenuhi struktur folder.
- Gunakan nama file dan class yang konsisten, serta import yang benar.
- Saat memindahkan widget, pertahankan tampilan, callback, state, dan perilaku yang sudah ada kecuali pengguna meminta perubahan.

## 6. Aturan fungsional dan kejujuran UI

- Tombol yang ditampilkan sebagai aksi harus menjalankan aksi yang sesuai atau dengan jelas diberi label belum tersedia.
- Data produk contoh harus diperlakukan sebagai data demo, bukan produk toko sungguhan.
- Jangan membuat hasil diagnosis tanaman, nama penyakit, confidence score, atau rekomendasi seolah-olah berasal dari AI jika model belum terintegrasi.
- Selama AI belum ada, tombol analisis harus menjelaskan bahwa analisis belum tersedia atau masih demo.
- Jangan menambahkan login, backend, database, pembayaran, atau dependency baru tanpa alasan yang jelas dan persetujuan pengguna bila perubahan itu berdampak besar.

## 7. Aturan menjaga proyek tetap stabil

Setelah setiap perubahan bermakna:
1. Jalankan `flutter analyze`.
2. Jalankan test yang relevan jika tersedia.
3. Jika memungkinkan, jalankan aplikasi pada target Android yang tersedia.
4. Perbaiki error yang diperkenalkan oleh perubahan sebelum lanjut ke tahap berikutnya.
5. Bedakan error yang menghalangi build dari warning/info seperti API deprecated.
6. Jangan mengklaim pemeriksaan berhasil jika perintah tidak benar-benar dijalankan.

Jika perintah gagal karena lingkungan, dependency, emulator, atau tool tidak tersedia, laporkan pesan pentingnya dan jelaskan langkah berikutnya.

## 8. Aturan perubahan file

- Jangan mengganti `pubspec.yaml`, konfigurasi Android, atau dependency tanpa kebutuhan yang jelas.
- Jangan menghapus file atau fitur yang sudah ada hanya karena tidak sesuai dengan rancangan target.
- Sebelum perubahan besar, jelaskan file yang akan dibuat, diubah, dipindahkan, atau dihapus.
- Hindari mengubah banyak bagian yang tidak berkaitan dalam satu langkah.
- Pertahankan kompatibilitas dengan versi Flutter dan dependency yang digunakan proyek; periksa konfigurasi aktual sebelum memakai API baru.
- Jangan mengasumsikan nama class aplikasi seperti `MyApp` atau `DaunKuApp`; periksa kode aktual dan sesuaikan test berdasarkan kondisi proyek.

## 9. Cara berkomunikasi dan melaporkan hasil

Gunakan Bahasa Indonesia. Setelah menyelesaikan satu tahap, laporkan:
- Tujuan tahap.
- File yang dibuat/diubah.
- Fungsi yang sekarang bisa digunakan.
- Perintah pemeriksaan yang benar-benar dijalankan dan hasilnya.
- Error atau warning yang masih tersisa.
- Langkah berikutnya yang disarankan.

Kerjakan satu tahap pada satu waktu. Jangan menganggap pengguna menyetujui perubahan besar hanya karena pernah menyetujui rancangan umum.

## 10. Kriteria selesai

Satu tahap dinyatakan selesai jika:
- File dan import konsisten.
- Tidak ada error analisis baru yang belum dijelaskan.
- Alur utama yang berubah sudah diuji sejauh lingkungan memungkinkan.
- Aplikasi tidak kehilangan fitur yang sebelumnya bekerja.
- Placeholder dan data demo diberi keterangan yang jujur.
- Ringkasan perubahan disampaikan kepada pengguna.

## 11. Mulai setiap tugas baru dengan pemeriksaan

Saat menerima tugas baru:
1. Baca instruksi ini.
2. Baca `DaunKu_Rancangan_Modularisasi.md`.
3. Periksa kondisi kode terkini.
4. Tentukan tahap rancangan yang relevan.
5. Lakukan perubahan paling kecil yang menyelesaikan permintaan.
6. Verifikasi hasil sebelum melanjutkan.

## REFERENSI DESAIN VISUAL WAJIB DAUNKU

Sumber acuan desain:
- `design_reference/beranda.html`
- `design_reference/marketplace.html`
- `design_reference/profil.html`

Ketiga file tersebut merupakan referensi visual utama untuk halaman yang bersangkutan.

### Aturan implementasi
1. Baca file HTML referensi sebelum membuat atau mengubah halaman terkait.
2. Pertahankan layout, urutan section, warna, tipografi, ukuran relatif, spacing, bentuk kartu, ikon, dan navigasi semirip mungkin dengan referensi.
3. Gunakan Flutter native widgets. Jangan mengubah proyek menjadi aplikasi web atau menanam seluruh halaman HTML di WebView hanya demi menyalin desain.
4. Pertahankan identitas visual yang konsisten: Plus Jakarta Sans, warna utama `#125238`, latar `#F7F9F6`, permukaan putih, dan palet hijau lembut dari referensi.
5. Pertahankan navigasi bawah empat tab: Beranda, Diagnosis, Marketplace, dan Profil.
6. Jangan melakukan redesign atau menghilangkan section tanpa persetujuan pengguna.
7. Modularisasi kode tanpa mengubah tampilan yang sudah disetujui.
8. Untuk halaman Diagnosis, pertahankan implementasi yang saat ini berjalan. Jika referensi visual Diagnosis belum tersedia, jangan mengarang desain baru; periksa tampilan aplikasi yang ada terlebih dahulu.
9. Data contoh seperti nama pengguna, cuaca, rating, harga, kuota, dan riwayat tidak boleh dianggap sebagai data nyata. Tandai sebagai data demo atau hubungkan ke sumber data yang benar jika tersedia.
10. Setelah implementasi, jalankan aplikasi di emulator dan bandingkan setiap halaman dengan referensinya. Laporkan bagian yang belum cocok dan jangan mengklaim hasil identik sebelum diperiksa.

Sebelum mulai coding, laporkan pemahaman terhadap ketiga desain dan rencana implementasinya. Jangan langsung mengubah kode.