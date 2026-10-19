# DaunKu — Rancangan Modularisasi dan Pengembangan Aplikasi

> Dokumen panduan kerja untuk proyek Flutter DaunKu.
> Fokus saat ini: membuat struktur kode yang rapi dan membuat fungsi dasar **Beranda, Diagnosis, dan Marketplace** dapat digunakan lebih dahulu.
> Model AI diagnosis tetap masuk dalam rancangan, tetapi implementasinya ditunda.

---

## 1. Tujuan dan prinsip pengerjaan

DaunKu adalah aplikasi Android berbasis Flutter untuk membantu pengguna mengenali dan merawat tanaman. Untuk tahap sekarang, prioritasnya bukan langsung membangun semua fitur canggih, melainkan membuat fondasi aplikasi yang stabil, mudah dipahami, dan bisa dikembangkan.

Prinsip kerja:

1. **Pertahankan aplikasi tetap bisa dijalankan** setiap selesai satu tahap.
2. Pisahkan kode berdasarkan tanggung jawab: halaman, widget, model, dan service.
3. Jangan membuat semua folder dan file sekaligus tanpa isi yang jelas.
4. Fitur yang belum dibuat harus diberi label *demo* atau *belum tersedia*; jangan menampilkan hasil palsu seolah-olah hasil AI sungguhan.
5. Gunakan data contoh lokal untuk fungsi awal Marketplace dan Beranda. Integrasi database/backend bisa menyusul.
6. Simpan salinan cadangan sebelum memindahkan kode.
7. Setelah setiap tahap, jalankan `flutter analyze` dan tes alur yang berubah.

## 2. Status awal proyek

Berdasarkan percakapan saat dokumen ini dibuat:

- Proyek menggunakan Flutter dan ditujukan untuk Android.
- Aplikasi sudah pernah berjalan di emulator.
- Tema aplikasi berada di `lib/core/theme/app_theme.dart`.
- `lib/main.dart` dan `lib/app.dart` sudah menjadi bagian dari pemisahan awal.
- Halaman diagnosis awal berisi pemilihan foto kamera/galeri, preview, kategori tanaman, tips foto, banner kuota demo, dan bottom navigation.
- Pemilihan gambar memakai package `image_picker`.
- Analisis tanaman masih berupa pesan demo; model AI belum dibuat.
- Beranda, Marketplace, dan Profil belum menjadi halaman fitur penuh.
- Dalam proses memisahkan widget diagnosis, muncul error import file widget yang belum ditemukan serta error sintaks `Expected to find ']'`. Karena itu, **perbaiki dan validasi kode yang sedang ada sebelum meneruskan modularisasi**.

Catatan: status di atas berasal dari konteks kerja percakapan, bukan hasil pemeriksaan langsung terhadap seluruh isi folder proyek saat ini.

---

## 3. Struktur folder target

Struktur berikut adalah target bertahap. File yang belum dibutuhkan boleh dibuat ketika tahapnya dimulai.

```text
lib/
├── main.dart
├── app.dart
│
├── core/
│   ├── theme/
│   │   └── app_theme.dart
│   ├── constants/
│   │   └── app_constants.dart
│   ├── utils/
│   │   └── formatters.dart
│   └── widgets/
│       ├── app_button.dart
│       ├── app_section_title.dart
│       ├── empty_state.dart
│       └── loading_view.dart
│
├── navigation/
│   └── main_navigation_screen.dart
│
└── features/
    ├── home/
    │   ├── screens/
    │   │   └── home_screen.dart
    │   ├── widgets/
    │   │   ├── welcome_header.dart
    │   │   ├── quick_action_card.dart
    │   │   ├── featured_plant_card.dart
    │   │   └── recent_diagnosis_section.dart
    │   └── data/
    │       └── home_demo_data.dart
    │
    ├── diagnosis/
    │   ├── screens/
    │   │   └── diagnosis_screen.dart
    │   ├── widgets/
    │   │   ├── diagnosis_stepper.dart
    │   │   ├── diagnosis_quota_banner.dart
    │   │   ├── plant_category_selector.dart
    │   │   ├── image_picker_section.dart
    │   │   ├── image_preview_card.dart
    │   │   └── photography_tips.dart
    │   ├── models/
    │   │   ├── diagnosis_request.dart
    │   │   └── diagnosis_result.dart
    │   └── services/
    │       └── diagnosis_service.dart
    │
    ├── marketplace/
    │   ├── screens/
    │   │   ├── marketplace_screen.dart
    │   │   └── product_detail_screen.dart
    │   ├── widgets/
    │   │   ├── marketplace_search_bar.dart
    │   │   ├── product_category_filter.dart
    │   │   ├── product_card.dart
    │   │   └── product_grid.dart
    │   ├── models/
    │   │   └── product.dart
    │   ├── data/
    │   │   └── product_demo_data.dart
    │   └── services/
    │       └── product_service.dart
    │
    ├── history/
    │   ├── screens/
    │   │   ├── history_screen.dart
    │   │   └── diagnosis_history_detail_screen.dart
    │   ├── models/
    │   │   └── diagnosis_history_item.dart
    │   └── services/
    │       └── history_service.dart
    │
    ├── profile/
    │   ├── screens/
    │   │   └── profile_screen.dart
    │   └── widgets/
    │       └── profile_menu_item.dart
    │
    └── notifications/
        └── screens/
            └── notifications_screen.dart

test/
├── widget_test.dart
├── features/
│   ├── home_screen_test.dart
│   ├── diagnosis_screen_test.dart
│   └── marketplace_screen_test.dart
```

### Penjelasan struktur

- `screens/`: halaman penuh yang dirender pengguna.
- `widgets/`: bagian tampilan yang dipakai oleh halaman fitur tersebut.
- `models/`: bentuk data, misalnya produk dan hasil diagnosis.
- `services/`: tempat logika akses data atau proses bisnis. Untuk tahap demo, service bisa menggunakan data lokal.
- `data/`: data contoh statis untuk pengembangan awal.
- `core/`: komponen umum yang digunakan lintas fitur.
- `navigation/`: mengatur perpindahan antarhalaman utama.

Jangan memindahkan semua kode ke file baru hanya demi membuat banyak file. Buat file ketika ada tanggung jawab yang jelas.

---

## 4. Rancangan navigasi aplikasi

Navigasi utama menggunakan empat tab:

1. **Beranda**
2. **Diagnosis**
3. **Marketplace**
4. **Profil**

`MainNavigationScreen` bertanggung jawab menampilkan tab yang dipilih dan bottom navigation bar. Halaman fitur tidak seharusnya membuat bottom navigation sendiri-sendiri.

Rancangan perilaku:

- Beranda menjadi halaman awal.
- Tab Diagnosis membuka halaman pemilihan foto.
- Tab Marketplace membuka katalog produk.
- Tab Profil membuka profil dan menu pengaturan.
- Halaman detail produk dibuka dari Marketplace, lalu pengguna dapat kembali ke katalog.
- Halaman Riwayat dapat dibuka dari Beranda atau Profil.
- Notifikasi bisa tetap menjadi halaman sederhana atau placeholder sampai kebutuhan notifikasi ditentukan.

Untuk tahap awal, gunakan navigasi Flutter sederhana (`Navigator`) atau pengelolaan tab dengan `IndexedStack`. Jangan menambahkan package routing baru sebelum memang diperlukan.

---

## 5. Rancangan halaman Beranda

### Tujuan

Beranda menjadi titik awal pengguna dan memberi akses cepat ke fitur utama.

### Susunan UI yang disarankan

1. Header sapaan dan identitas DaunKu.
2. Kartu ajakan diagnosis, misalnya “Periksa kondisi daun tanamanmu”.
3. Tombol utama “Mulai Diagnosis”.
4. Akses cepat ke Marketplace.
5. Bagian rekomendasi atau tips tanaman.
6. Bagian riwayat diagnosis terbaru.
7. Bottom navigation yang dikelola `MainNavigationScreen`.

### Fungsi yang bisa dibuat lebih dahulu

- Tombol “Mulai Diagnosis” berpindah ke tab Diagnosis.
- Tombol Marketplace membuka tab Marketplace.
- Tips tanaman ditampilkan dari data contoh lokal.
- Bagian riwayat menampilkan empty state yang jelas jika belum ada data.
- Jika memakai data contoh, beri penanda bahwa konten tersebut adalah konten demo.

### Belum perlu pada tahap awal

- Personalisasi berbasis akun.
- Rekomendasi berdasarkan cuaca atau lokasi.
- Sinkronisasi cloud.
- Notifikasi otomatis.

### Kriteria selesai

- Halaman Beranda bisa dibuka dari tab navigasi.
- Tombol Diagnosis dan Marketplace benar-benar berpindah ke tab terkait.
- Tidak ada tombol yang terlihat aktif tetapi tidak melakukan apa pun.
- Tampilan tetap baik di ukuran layar emulator yang digunakan.

---

## 6. Rancangan halaman Diagnosis

### Tujuan

Menyediakan alur pengambilan/pemilihan foto dan menyiapkan tempat untuk model diagnosis tanaman di masa depan.

### Alur pengguna

1. Pengguna membuka tab Diagnosis.
2. Memilih kategori tanaman (opsional).
3. Mengambil foto dengan kamera atau memilih foto dari galeri.
4. Aplikasi menampilkan preview.
5. Pengguna dapat menghapus atau mengganti foto.
6. Pengguna menekan tombol analisis.
7. **Untuk versi sekarang:** tampilkan pesan bahwa analisis AI belum tersedia. Jangan menampilkan nama penyakit atau tingkat keyakinan yang dibuat-buat.
8. **Untuk versi mendatang:** kirim gambar dan kategori ke `DiagnosisService`, kemudian tampilkan hasil dari model yang benar-benar diintegrasikan.

### Pembagian tanggung jawab

- `diagnosis_screen.dart`: mengatur state alur layar dan menghubungkan widget.
- `diagnosis_stepper.dart`: tampilan tahapan foto, analisis, dan hasil.
- `diagnosis_quota_banner.dart`: banner kuota demo/upgrade.
- `plant_category_selector.dart`: pilihan kategori tanaman.
- `image_picker_section.dart`: tombol kamera/galeri dan indikator loading.
- `image_preview_card.dart`: preview gambar, tombol hapus, dan tombol analisis.
- `photography_tips.dart`: tips mengambil foto.
- `diagnosis_request.dart`: data masukan untuk proses diagnosis.
- `diagnosis_result.dart`: format hasil diagnosis yang direncanakan.
- `diagnosis_service.dart`: kontrak dan proses pemanggilan model di masa depan.

### Rancangan model diagnosis — belum diimplementasikan

Model AI dilewati dahulu dari sisi implementasi, tetapi tetap menjadi bagian arsitektur.

Data permintaan yang mungkin diperlukan:

- path atau bytes gambar;
- kategori tanaman pilihan pengguna;
- identitas permintaan jika dibutuhkan;
- waktu permintaan.

Data hasil yang direncanakan:

- nama tanaman (jika model mendukung);
- kondisi/penyakit yang terdeteksi;
- skor keyakinan, jika disediakan dan tervalidasi oleh model;
- deskripsi gejala;
- rekomendasi perawatan;
- peringatan jika gambar tidak cukup jelas atau model tidak yakin.

Ini hanya rancangan field, bukan jaminan model akan bisa mengidentifikasi semua informasi tersebut. Skema final harus disesuaikan dengan model/API yang dipilih.

### Kriteria selesai untuk versi awal

- Kamera dan galeri bisa dibuka.
- Pembatalan pemilihan foto tidak merusak state.
- Error izin atau kegagalan memilih foto ditangani dengan pesan.
- Preview bisa ditampilkan dan dihapus.
- Kategori yang dipilih tampil konsisten.
- Tombol analisis tidak mengaku telah mendiagnosis tanaman.
- Widget diagnosis terpisah dari layar utama.

---

## 7. Rancangan halaman Marketplace

### Tujuan

Menampilkan katalog produk terkait tanaman. Pada versi awal, katalog dapat memakai data demo lokal, tanpa pembayaran dan tanpa backend.

### Susunan UI yang disarankan

1. Header “Marketplace”.
2. Kolom pencarian.
3. Filter kategori.
4. Grid kartu produk.
5. Kartu berisi gambar/placeholder, nama, harga, dan kategori.
6. Halaman detail produk setelah kartu dipilih.
7. Tombol aksi seperti “Tambah ke Keranjang” hanya jika state keranjang benar-benar diimplementasikan.

### Fungsi prioritas

**M1 — Katalog demo**
- Menampilkan daftar produk dari `product_demo_data.dart`.
- Setiap produk memiliki ID, nama, kategori, harga, deskripsi singkat, dan aset gambar/placeholder.

**M2 — Pencarian**
- Pencarian lokal berdasarkan nama produk.
- Hasil diperbarui ketika teks pencarian berubah.
- Empty state muncul jika tidak ada hasil.

**M3 — Filter kategori**
- Pengguna dapat memilih kategori.
- Pencarian dan filter bekerja bersama, bukan saling menimpa.

**M4 — Detail produk**
- Menampilkan informasi produk terpilih.
- Tombol kembali mengembalikan pengguna ke katalog.

**M5 — Keranjang sederhana (opsional setelah katalog stabil)**
- Tambah/hapus produk dari keranjang lokal.
- Jumlah item dan subtotal dihitung dengan benar.
- Belum ada checkout/pembayaran sungguhan.

### Rancangan model `Product`

Field awal yang disarankan:

- `id`
- `name`
- `category`
- `price`
- `description`
- `imageAsset` atau `imageUrl` (pilih sesuai sumber gambar)
- `isAvailable` (opsional)

Gunakan tipe harga numerik, misalnya `int` dalam rupiah, bukan teks seperti `"Rp25.000"` sebagai nilai penyimpanan. Format menjadi teks hanya ketika ditampilkan.

### Kriteria selesai

- Katalog menampilkan beberapa produk contoh.
- Pencarian berdasarkan nama berfungsi.
- Filter kategori berfungsi.
- Detail produk terbuka untuk produk yang dipilih.
- Harga ditampilkan dalam format rupiah.
- Produk demo tidak disajikan sebagai listing toko sungguhan.
- Jika keranjang dibuat, jumlah dan subtotal diperbarui sesuai perubahan item.

### Belum perlu

- Payment gateway.
- Pesanan sungguhan.
- Pengelolaan stok real-time.
- Akun penjual.
- Integrasi marketplace eksternal.

---

## 8. Rancangan halaman Profil

### Fungsi awal

- Menampilkan avatar placeholder dan nama demo.
- Menu “Riwayat Diagnosis”.
- Menu pengaturan sederhana.
- Informasi aplikasi dan versi.
- Menu yang belum dibuat harus memberi keterangan “belum tersedia” atau tidak ditampilkan.

### Ditunda

- Login/registrasi.
- Edit profil yang disimpan ke server.
- Sinkronisasi antarperangkat.
- Pengaturan akun yang memerlukan backend.

---

## 9. Rancangan Riwayat Diagnosis

Riwayat menjadi berguna setelah alur diagnosis dan format hasil sudah jelas.

### Fungsi yang direncanakan

- Daftar diagnosis yang tersimpan.
- Tanggal dan gambar.
- Kategori tanaman.
- Ringkasan hasil diagnosis jika tersedia.
- Halaman detail riwayat.
- Empty state jika belum ada data.

### Strategi penyimpanan

Untuk tahap pertama, penyimpanan lokal dapat dipilih setelah kebutuhan datanya jelas. Jangan memilih database atau menambahkan dependency sebelum diputuskan apakah data hanya lokal atau perlu sinkronisasi cloud.

Riwayat tidak boleh mengarang hasil diagnosis. Item hanya disimpan sebagai hasil diagnosis jika proses diagnosis benar-benar menghasilkan data yang valid.

---

## 10. Tema dan komponen umum

`AppTheme` menjadi satu sumber utama untuk warna dan tema aplikasi.

Komponen yang bisa dipindahkan ke `core/widgets/` jika benar-benar dipakai lintas fitur:

- tombol utama;
- judul bagian;
- empty state;
- indikator loading;
- dialog konfirmasi.

Jangan memindahkan widget yang hanya digunakan satu fitur ke `core/widgets/` tanpa alasan. Widget khusus Marketplace tetap berada di fitur Marketplace.

---

## 11. Rencana implementasi berurutan

### Tahap 0 — Stabilkan kondisi sekarang

1. Buat backup folder `lib`.
2. Pastikan kedua file widget diagnosis yang di-import benar-benar ada di lokasi yang tepat.
3. Perbaiki error kurung/sintaks di `diagnosis_screen.dart`.
4. Periksa import dan nama package.
5. Jalankan `flutter analyze`.
6. Jalankan aplikasi dan tes pemilihan foto serta preview.

**Output:** versi saat ini kembali stabil sebelum ada pemindahan berikutnya.

### Tahap 1 — Selesaikan modularisasi Diagnosis UI

1. Pisahkan pemilihan foto dan preview.
2. Pisahkan pemilih kategori tanaman.
3. Pisahkan stepper diagnosis.
4. Pisahkan banner kuota.
5. Pisahkan tips fotografi.
6. Biarkan layar utama mengelola state dan menghubungkan callback.
7. Tes setelah setiap pemindahan.

**Output:** layar diagnosis lebih ringkas, tetapi perilaku pengguna tetap sama.

### Tahap 2 — Buat navigasi utama

1. Buat `MainNavigationScreen`.
2. Pindahkan bottom navigation keluar dari `DiagnosisScreen`.
3. Buat tab Beranda, Diagnosis, Marketplace, dan Profil.
4. Pastikan tab yang dipilih tampil dengan benar.
5. Pastikan state tab tidak hilang tanpa sengaja saat berpindah halaman.

**Output:** semua tab utama dapat dibuka.

### Tahap 3 — Bangun Beranda fungsional

1. Buat `HomeScreen`.
2. Tambahkan kartu mulai diagnosis.
3. Tambahkan akses Marketplace.
4. Tambahkan tips dari data demo.
5. Tambahkan bagian riwayat dengan empty state.
6. Tes semua tombol navigasi.

**Output:** Beranda tidak lagi berupa placeholder.

### Tahap 4 — Bangun Marketplace dasar

1. Buat model `Product`.
2. Buat beberapa data produk demo.
3. Buat `ProductCard` dan grid produk.
4. Tambahkan pencarian.
5. Tambahkan filter kategori.
6. Buat halaman detail produk.
7. Tambahkan keranjang lokal hanya setelah katalog dan detail stabil.

**Output:** katalog dapat digunakan tanpa backend.

### Tahap 5 — Buat model dan service diagnosis (tanpa integrasi AI)

1. Tentukan bentuk `DiagnosisRequest`.
2. Tentukan bentuk `DiagnosisResult`.
3. Buat `DiagnosisService` sebagai batas logika diagnosis.
4. Tetap tampilkan status “belum tersedia” untuk analisis yang belum diimplementasikan.
5. Siapkan penanganan loading, error, dan hasil kosong.

**Output:** struktur siap menerima model AI nantinya, tetapi belum mengklaim melakukan prediksi.

### Tahap 6 — Riwayat dan penyimpanan lokal

1. Tentukan data yang benar-benar perlu disimpan.
2. Buat model item riwayat.
3. Tentukan strategi penyimpanan lokal.
4. Hubungkan riwayat dengan hasil diagnosis valid.
5. Tes data kosong, data terisi, dan kegagalan baca/tulis.

**Output:** riwayat dapat menyimpan dan menampilkan data yang tersedia.

### Tahap 7 — Integrasi model AI (pekerjaan mendatang)

1. Pilih model atau API.
2. Pastikan format input dan output.
3. Buat implementasi service yang sebenarnya.
4. Tangani jaringan, timeout, kegagalan, dan respons tidak pasti.
5. Validasi hasil sebelum menampilkannya.
6. Uji dengan dataset yang sesuai dan jelaskan batasan model.

**Output:** diagnosis sungguhan setelah teknologi dan sumber data dipilih serta diuji.

---

## 12. Perintah pemeriksaan Flutter

Jalankan perintah dari direktori proyek, bukan dari folder ZIP atau folder lain.

```powershell
flutter pub get
flutter analyze
flutter test
flutter run -d emulator-5554
```

Kegunaan:

- `flutter pub get`: mengambil dependency yang tercantum di `pubspec.yaml`.
- `flutter analyze`: menemukan masalah sintaks, import, tipe, dan lint.
- `flutter test`: menjalankan pengujian yang tersedia.
- `flutter run -d emulator-5554`: menjalankan aplikasi di emulator tersebut.

Jika `widget_test.dart` masih memakai `MyApp` sedangkan aplikasi sekarang menggunakan `DaunKuApp`, sesuaikan test dengan struktur terbaru. Jangan mengabaikan kegagalan test tanpa memeriksa penyebabnya.

Peringatan deprecated seperti `withOpacity` berbeda dari error sintaks atau import yang mencegah kompilasi. Perbaiki error penghalang terlebih dahulu; rapikan warning setelah aplikasi stabil.

---

## 13. Definition of Done (kriteria selesai)

Sebuah tahap dianggap selesai jika:

- [ ] File berada di folder sesuai rancangan.
- [ ] Import dan nama class benar.
- [ ] `flutter analyze` tidak memiliki error yang belum diselesaikan.
- [ ] Aplikasi bisa dibuka di emulator.
- [ ] Alur utama yang disentuh sudah diuji manual.
- [ ] Tidak ada tombol yang mengklaim melakukan fungsi yang belum dibuat.
- [ ] Perubahan tidak merusak fitur yang sebelumnya berjalan.
- [ ] Catatan fitur demo dan fitur yang ditunda tetap jelas.

---

## 14. Keputusan yang belum ditetapkan

Hal-hal berikut belum diketahui dan tidak boleh diasumsikan:

- Model AI atau API yang akan dipakai.
- Apakah aplikasi memerlukan akun/login.
- Apakah data perlu tersimpan hanya di perangkat atau juga di cloud.
- Sumber gambar produk Marketplace.
- Apakah Marketplace hanya katalog atau benar-benar membutuhkan keranjang dan pembayaran.
- Dataset, bahasa model, dan batas akurasi diagnosis.

Keputusan tersebut dapat dibuat ketika tahap terkait dimulai. Tidak perlu menyelesaikannya semua sekarang.

---

## 15. Prioritas praktis saat ini

Urutan terdekat yang disarankan:

1. **Pulihkan kondisi kode Diagnosis** dari error import dan sintaks yang muncul.
2. Selesaikan modularisasi UI Diagnosis dan tes kamera, galeri, preview, hapus, serta kategori.
3. Buat navigasi utama yang menampilkan empat tab.
4. Buat Beranda dengan tombol navigasi yang benar-benar bekerja.
5. Buat Marketplace dengan data demo, pencarian, filter, dan detail produk.
6. Rancang model diagnosis tanpa menjalankan prediksi AI dahulu.
7. Lanjutkan ke riwayat, penyimpanan, dan integrasi AI ketika fondasi stabil.

Dengan urutan ini, DaunKu memperoleh fitur yang dapat didemokan lebih awal tanpa menunggu model AI selesai.

---

**Status dokumen:** rancangan dan rencana kerja; bukan bukti bahwa seluruh file atau fitur di atas sudah diimplementasikan atau diuji.
