# DaunKu --- Rancangan Pengembangan Fitur dan Instruksi AI Agent

> **Tujuan dokumen:** Menjadi sumber instruksi utama bagi AI coding
> agent yang mengembangkan aplikasi DaunKu. Agent wajib membaca dokumen
> ini sebelum mengubah kode, mengikuti urutan prioritas, mempertahankan
> desain yang sudah ada, dan memverifikasi setiap perubahan.

-   **Platform:** Android, menggunakan Flutter dan Dart.
-   **Backend:** Supabase Auth, PostgreSQL, dan Supabase Storage.
-   **Bahasa antarmuka:** Bahasa Indonesia.
-   **Prioritas pengerjaan:** Backend dan fitur inti non-AI terlebih
    dahulu. Fitur diagnosis berbasis AI dikembangkan setelah alur akun,
    marketplace, pesanan, dan penjual stabil.
-   **Prinsip utama:** Kembangkan kode yang ada; jangan membuat ulang
    aplikasi dari nol.

------------------------------------------------------------------------

## 1. Gambaran proyek

DaunKu adalah aplikasi mobile untuk membantu pengguna merawat tanaman
melalui informasi/diagnosis tanaman dan marketplace tanaman serta
perlengkapan perawatan. Pengguna dapat menjelajahi produk, menyimpan
produk ke wishlist, memasukkan produk ke keranjang, melakukan checkout,
dan melihat pesanan. Pengguna yang memenuhi ketentuan dapat menjadi
penjual serta mengelola produknya sendiri.

### Peran pengguna

1.  **Pengunjung** --- dapat melihat layar publik yang diizinkan;
    tindakan yang membutuhkan akun akan meminta pengguna login.
2.  **Pembeli** --- memiliki profil, wishlist, keranjang, alamat,
    checkout, pesanan, dan riwayat diagnosis.
3.  **Penjual** --- pembeli yang memiliki profil toko dan dapat membuat
    serta mengelola produk miliknya.
4.  **Admin** --- bukan fokus implementasi awal. Jangan membuat
    dashboard admin tanpa persetujuan pemilik proyek.

Satu akun dapat menjadi pembeli dan penjual. Jangan mengasumsikan bahwa
menjadi penjual berarti pengguna kehilangan kemampuan membeli.

------------------------------------------------------------------------

## 2. Kondisi repository dan aturan membaca kode

Repository: `nirvanaguys/IF2514503`

File yang sudah diperiksa pada saat dokumen ini disusun:

-   `lib/main.dart` --- telah menginisialisasi Supabase, tetapi URL
    perlu diverifikasi.
-   `lib/app.dart` --- `MaterialApp`, tema `AppTheme.lightTheme`, dan
    `MainNavigationScreen`.
-   `lib/navigation/main_navigation_screen.dart` --- navigasi utama
    menggunakan `IndexedStack`.
-   `lib/features/home/screens/home_screen.dart` --- layar beranda
    menggunakan beberapa data demo.
-   `lib/features/marketplace/screens/marketplace_screen.dart` ---
    pencarian/kategori dan kartu produk sudah ada; data dan keranjang
    masih lokal/demo.
-   `lib/features/profile/screens/profile_screen.dart` --- profil dan
    sejumlah aksi masih berupa demo.
-   `pubspec.yaml` --- sudah memuat `supabase_flutter` dan
    `image_picker`.

Struktur direktori bisa berubah. Daftar ini adalah titik awal, bukan
alasan untuk memaksakan struktur lama jika repository sudah berkembang.

### Wajib dilakukan agent sebelum mulai

1.  Baca file `README.md`, `pubspec.yaml`, `analysis_options.yaml`,
    `lib/main.dart`, dan `lib/app.dart`.
2.  Periksa seluruh struktur `lib/`, khususnya `core/`, `navigation/`,
    dan `features/`.
3.  Cari rancangan UI, komponen, model, service, serta data demo yang
    sudah tersedia.
4.  Periksa status Git dan perubahan lokal. **Jangan menimpa atau
    menghapus perubahan yang belum di-commit.**
5.  Jalankan `flutter pub get`, `flutter analyze`, dan test yang relevan
    jika environment tersedia. Catat error yang sudah ada sebelum
    perubahan.
6.  Sesuaikan implementasi dengan komponen dan pola yang memang ada di
    repository.

### Aturan menjaga UI

-   Pertahankan identitas visual, warna, tipografi, spacing, bentuk
    kartu, ikon, bottom navigation, dan tata letak yang telah dibuat.
-   Jangan mengganti tampilan seluruh aplikasi hanya karena sedang
    menghubungkan backend.
-   Jangan menghapus data/demo widgets yang masih diperlukan oleh layar
    lain tanpa memeriksa dependensinya.
-   Ganti sumber data demo secara bertahap menggunakan
    repository/service, bukan dengan menulis query Supabase langsung di
    setiap widget.
-   Semua teks UI untuk pengguna menggunakan Bahasa Indonesia dan
    memiliki loading, empty, error, serta success state yang layak.
-   Jangan menampilkan pesan sukses jika operasi backend sebenarnya
    gagal.

------------------------------------------------------------------------

## 3. Konfigurasi Supabase dan keamanan

### 3.1 Konfigurasi aplikasi

`Supabase.initialize()` harus menggunakan:

-   `url`: Project URL utama dari dashboard Supabase, misalnya
    `https://<project-ref>.supabase.co` --- bukan URL yang ditambah
    `/rest/v1/`.
-   `publishableKey`: publishable/anon client key yang memang ditujukan
    untuk aplikasi klien.

Jangan menyalin key atau URL dari dokumen ini secara buta. Periksa nilai
konfigurasi yang benar dari environment proyek. Jangan meminta atau
menuliskan secret milik pengguna ke file kode.

Untuk konfigurasi lokal, pilih pendekatan yang cocok dengan repository,
misalnya `--dart-define` atau file environment yang tidak masuk Git.
Dokumentasikan cara menjalankannya. Jangan memasukkan kredensial rahasia
ke repository. Publishable key bukan pengganti Row Level Security (RLS).

### 3.2 Larangan keamanan

-   **Dilarang** memasukkan `service_role` key, secret API payment
    gateway, private key, atau kredensial server ke aplikasi Flutter.
-   Aktifkan RLS pada semua tabel yang berisi data pengguna, keranjang,
    alamat, pesanan, dan data penjual.
-   Jangan mengandalkan validasi UI untuk izin akses. Aturan akses harus
    ditegakkan di database dan/atau backend.
-   Jangan mempercayai harga, total belanja, diskon, role penjual,
    status pembayaran, atau `user_id` dari klien tanpa validasi
    server/database.
-   Jangan menyimpan nomor kartu, CVV, atau kredensial pembayaran
    sensitif.
-   Jangan menghapus atau mengubah data produksi ketika menjalankan
    test.
-   Gunakan data uji dan sandbox untuk integrasi pembayaran.

------------------------------------------------------------------------

## 4. Arsitektur yang diharapkan

Gunakan struktur yang konsisten dengan proyek yang ada. Jika belum
tersedia, pola berikut disarankan:

``` text
lib/
  core/
    config/
    errors/
    theme/
    utils/
    widgets/
  features/
    auth/
      data/
      models/
      screens/
      services/
      widgets/
    home/
    marketplace/
      data/
      models/
      repositories/
      screens/
      services/
      widgets/
    cart/
    checkout/
    orders/
    profile/
    seller/
    diagnosis/
    notifications/
  navigation/
```

Jangan membuat semua folder kosong sekaligus. Tambahkan folder/file saat
fitur terkait mulai dikerjakan.

### Pedoman kode

-   Pisahkan widget UI dari akses data dan logika bisnis.
-   Gunakan model Dart bertipe untuk data produk, profil, alamat,
    keranjang, dan pesanan.
-   Buat repository/service untuk query Supabase agar mudah diuji.
-   Hindari duplikasi query, validasi, dan komponen UI.
-   Kelola `TextEditingController`, stream subscription, dan resource
    lain dengan benar.
-   Tangani error Supabase dengan pesan yang aman dan mudah dipahami;
    jangan menampilkan stack trace atau detail internal ke pengguna.
-   Gunakan pagination untuk daftar yang berpotensi panjang.
-   Jangan menambahkan state management package baru tanpa kebutuhan
    yang jelas. Ikuti pola yang sudah digunakan repository; jika belum
    ada pola, pilih solusi sederhana dan konsisten.

------------------------------------------------------------------------

## 5. Ruang lingkup fitur

Status awal di bawah berdasarkan pemeriksaan source code yang tersedia,
bukan hasil pengujian langsung pada perangkat.

  -----------------------------------------------------------------------------------
  ID                Fitur                  Kondisi awal             Prioritas
  ----------------- ---------------------- ------------------------ -----------------
  F01               Konfigurasi Supabase   Inisialisasi sudah ada;  P0
                                           URL perlu diverifikasi   

  F02               Register, login,       Belum                    P0
                    logout, sesi           terkonfirmasi/terlihat   
                                           terimplementasi          

  F03               Profil dan edit profil UI demo                  P0

  F04               Katalog marketplace    UI ada, data demo        P0
                    dari database                                   

  F05               Detail produk,         Sebagian UI ada;         P0
                    pencarian, kategori,   data/filter perlu        
                    urutan                 integrasi                

  F06               Wishlist tersimpan     Lokal sementara          P1

  F07               Keranjang persisten    Counter lokal sementara  P0

  F08               Alamat dan checkout    Belum terimplementasi    P0
                                           penuh                    

  F09               Pesanan dan status     UI demo                  P0
                    pesanan                                         

  F10               Pembayaran sandbox     Belum terimplementasi    P1

  F11               Pendaftaran/aktivasi   UI demo                  P1
                    penjual                                         

  F12               CRUD produk penjual    Belum terimplementasi    P1
                                           penuh                    

  F13               Upload gambar produk   `image_picker` tersedia; P1
                                           alur Storage perlu       
                                           dibuat/ditinjau          

  F14               Riwayat diagnosis      UI demo                  P2

  F15               Diagnosis tanaman      Prioritas setelah fitur  P2
                    berbasis AI            inti stabil              

  F16               Notifikasi dan         UI demo                  P2
                    pengingat perawatan                             

  F17               Bantuan, FAQ,          UI demo/sebagian         P2
                    pengaturan dan hapus   placeholder              
                    akun                                            

  F18               Pengujian,             Dilakukan sepanjang      Semua fase
                    aksesibilitas,         pengerjaan               
                    hardening                                       
  -----------------------------------------------------------------------------------

P0 = fondasi dan alur inti; P1 = perlu sebelum marketplace dianggap
matang; P2 = tahap lanjutan. Pemilik proyek dapat mengubah prioritas.

------------------------------------------------------------------------

## 6. Spesifikasi fitur dan kriteria selesai

### F01 --- Konfigurasi Supabase

**Pekerjaan** - Pastikan package Supabase terpasang dan inisialisasi
hanya dilakukan sekali sebelum `runApp`. - Verifikasi Project URL, key
client, penanganan error inisialisasi, dan konfigurasi environment. -
Jangan menaruh konfigurasi server/secret di Flutter. - Tambahkan
petunjuk setup lokal ke dokumentasi tanpa mengungkap kredensial.

**Kriteria selesai** - Aplikasi dapat start dengan konfigurasi valid. -
URL menggunakan Project URL utama. - Konfigurasi invalid menghasilkan
error yang dapat dipahami developer, tanpa membocorkan rahasia. -
`flutter analyze` tidak menunjukkan error baru terkait perubahan ini.

### F02 --- Autentikasi

**Alur minimum** - Register dengan email dan password. - Login dengan
email dan password. - Validasi field kosong dan format email. -
Tampilkan loading saat permintaan berlangsung. - Tampilkan error
login/register dengan bahasa sederhana. - Tangani verifikasi email jika
fitur tersebut aktif pada Supabase. - Persistensi sesi melalui mekanisme
Supabase. - Logout dengan konfirmasi jika diperlukan. - Pulihkan sesi
ketika aplikasi dibuka kembali. - Lindungi layar yang membutuhkan akun;
arahkan pengguna tanpa sesi ke login.

**Kriteria selesai** - Register dan login berhasil pada project Supabase
yang benar. - Kredensial salah menampilkan error yang tepat. - Sesi
bertahan setelah aplikasi dibuka ulang sesuai konfigurasi Supabase. -
Logout mengakhiri sesi dan layar privat tidak lagi dapat diakses. -
Tidak ada password yang disimpan sendiri di database aplikasi.

### F03 --- Profil dan edit profil

**Data minimum** - Nama tampilan. - Email (sumber utama dari Supabase
Auth; jangan izinkan perubahan email tanpa alur verifikasi). - Foto
profil opsional. - Waktu pembuatan akun, bila diperlukan.

**Pekerjaan** - Ganti data demo dengan pengguna yang sedang login. -
Buat halaman edit profil. - Validasi dan simpan perubahan ke tabel
profil. - Sediakan loading, error, dan success state. - Tampilkan
keadaan akun belum login dengan benar.

**Kriteria selesai** - Profil pengguna A tidak dapat dibaca/diubah oleh
pengguna B. - Edit profil tersimpan dan tetap benar setelah layar dibuka
ulang. - Perubahan email, jika disediakan, mengikuti alur verifikasi
Supabase Auth.

### F04--F05 --- Marketplace, katalog, pencarian, filter dan detail produk

**Data produk minimum** - ID. - Nama dan deskripsi. - Harga dalam
integer unit terkecil yang konsisten untuk mata uang (misalnya rupiah
disimpan sebagai integer rupiah). - Kategori. - Stok. - Satu atau lebih
URL gambar. - ID penjual. - Status publikasi/aktif. - Waktu dibuat dan
diperbarui.

**Pekerjaan** - Ganti `MarketplaceDemoData.products` sebagai sumber
utama dengan data dari database. - Pertahankan desain kartu dan halaman
marketplace. - Buat detail produk yang menampilkan informasi lengkap,
gambar, harga, stok, penjual, dan tombol aksi. - Sambungkan pencarian ke
data yang tersedia. - Implementasikan filter kategori dan urutan dengan
perilaku yang nyata. - Tampilkan loading skeleton/indicator, empty
state, dan error state. - Produk tidak aktif atau belum dipublikasikan
tidak tampil di katalog publik.

**Kriteria selesai** - Perubahan produk di database tercermin pada
aplikasi. - Pencarian, kategori, dan sorting bekerja konsisten. - Produk
tanpa gambar memiliki placeholder. - Harga dan stok ditampilkan dengan
format yang benar. - Produk yang stoknya habis tidak dapat dibeli.

### F06 --- Wishlist

**Pekerjaan** - Simpan wishlist per pengguna yang login. - Tambah/hapus
wishlist dengan state UI yang konsisten. - Saat login ulang, wishlist
pengguna dipulihkan. - Pengunjung tanpa akun diarahkan login saat
mencoba menyimpan wishlist.

**Kriteria selesai** - Wishlist tidak hanya berada di memori widget. -
Pengguna tidak dapat mengubah wishlist pengguna lain. - Tap berulang
tidak membuat duplikasi data.

### F07 --- Keranjang belanja

**Pekerjaan** - Buat halaman keranjang yang berisi produk, gambar, harga
terkini, kuantitas, subtotal, dan total sementara. - Tambah item, ubah
kuantitas, hapus item, dan kosongkan keranjang. - Simpan keranjang untuk
pengguna yang login. - Periksa stok dan status produk sebelum
checkout. - Tangani produk yang dihapus, tidak aktif, atau kehabisan
stok. - Jangan hanya menambah angka `_cartCount`; simpan item dan jumlah
sebenarnya.

**Kriteria selesai** - Keranjang tetap tersedia setelah navigasi dan
aplikasi dibuka ulang. - Total dihitung dari harga/kuantitas yang
tervalidasi. - Kuantitas tidak bisa kurang dari 1 atau melebihi stok
yang tersedia. - Item tidak bisa dibeli jika produk tidak aktif atau
stok tidak cukup.

### F08 --- Alamat dan checkout

**Pekerjaan** - Pengguna dapat menambah, mengedit, menghapus, dan
memilih alamat pengiriman. - Validasi penerima, nomor telepon, alamat
lengkap, kota/kabupaten, provinsi, kode pos bila relevan. - Halaman
checkout menampilkan item, kuantitas, harga, subtotal, ongkos kirim jika
ada, dan total. - Validasi ulang harga dan stok pada proses pembuatan
pesanan di sisi tepercaya. - Hindari membuat pesanan duplikat saat
tombol checkout ditekan berulang. - Simpan snapshot nama produk dan
harga saat pesanan dibuat supaya riwayat lama tidak berubah ketika data
katalog berubah.

**Kriteria selesai** - Checkout tidak bisa dilakukan tanpa alamat dan
item valid. - Total akhir dihitung ulang menggunakan data tepercaya,
bukan angka total yang dikirim klien. - Kegagalan pembuatan pesanan
tidak meninggalkan pesanan setengah jadi tanpa status yang jelas. - Stok
ditangani secara konsisten dan tidak menjadi negatif.

### F09 --- Pesanan dan riwayat pesanan

**Status yang disarankan** - `pending_payment` - `paid` - `processing` -
`shipped` - `delivered` - `cancelled` - `payment_failed` - `refunded`
bila refund benar-benar didukung.

Gunakan transisi status yang jelas. Jangan mengizinkan aplikasi klien
mengubah pesanan menjadi `paid` hanya dengan update langsung.

**Pekerjaan** - Daftar pesanan pengguna, detail pesanan, item, total,
alamat snapshot, status, dan waktu. - Filter/tab status jika desain
menggunakannya. - Penjual hanya dapat melihat pesanan yang terkait
dengan produk tokonya, sesuai aturan bisnis yang ditetapkan. - Sediakan
empty state dan refresh.

**Kriteria selesai** - Pembeli hanya dapat melihat pesanan miliknya. -
Penjual tidak dapat melihat data pembeli/penjual lain di luar izin yang
diperlukan. - Status di UI berasal dari data pesanan, bukan data demo. -
Riwayat tetap ada setelah logout dan login kembali.

### F10 --- Pembayaran sandbox

**Pekerjaan** - Tentukan penyedia pembayaran setelah disetujui pemilik
proyek. - Gunakan sandbox/test mode terlebih dahulu. - Simpan ID
transaksi provider, nominal, mata uang, status, dan waktu yang
relevan. - Buat alur backend/Edge Function/server yang aman untuk
membuat transaksi dan memvalidasi callback/webhook. - Verifikasi
signature webhook sesuai dokumentasi provider. - Jangan pernah
mempercayai redirect sukses dari aplikasi sebagai bukti pembayaran. -
Jangan simpan data kartu atau secret provider di aplikasi.

**Kriteria selesai** - Pembayaran sukses, gagal, dibatalkan, dan pending
dapat diuji di sandbox. - Status pesanan diperbarui hanya setelah
verifikasi tepercaya. - Callback/webhook berulang tidak memproses
transaksi ganda. - Ada petunjuk konfigurasi environment dan test case.

**Catatan:** Jangan memilih provider atau mengaktifkan pembayaran
produksi tanpa persetujuan pemilik proyek.

### F11--F13 --- Menjadi penjual, manajemen produk, dan gambar

**Alur penjual** - Pengguna membuka menu "Jadi Penjual". - Pengguna
mengisi data toko minimum, seperti nama toko dan deskripsi. - Status
pengajuan disimpan secara eksplisit, misalnya `pending`, `active`, atau
`rejected` jika persetujuan admin memang diterapkan. - Hanya penjual
aktif yang dapat menerbitkan produk.

**CRUD produk** - Buat produk. - Lihat daftar produk milik toko. - Edit
produk. - Nonaktifkan/hapus produk dengan aturan yang tidak merusak
riwayat pesanan. - Atur stok, kategori, deskripsi, harga, dan gambar. -
Pastikan `seller_id` diambil/ditentukan dari sesi dan izin tepercaya,
bukan bebas dari input pengguna.

**Gambar** - Gunakan `image_picker` jika cocok dengan platform. - Upload
ke Supabase Storage melalui bucket yang sesuai. - Tetapkan batas ukuran,
tipe file yang diizinkan, nama file yang aman, dan aturan akses. -
Simpan path/URL gambar di database. - Tangani upload gagal dan
pembersihan file yatim bila aman.

**Kriteria selesai** - Penjual A tidak dapat mengedit produk penjual
B. - Pengguna biasa tidak dapat membuat produk sebagai penjual tanpa hak
yang benar. - Gambar yang dipilih muncul setelah upload dan tetap
tersedia. - Produk yang sudah memiliki riwayat transaksi tidak menghapus
snapshot pesanan lama.

### F14--F15 --- Riwayat dan diagnosis tanaman berbasis AI

**Tahap riwayat lebih dahulu** - Simpan riwayat diagnosis per pengguna
dengan waktu, gambar referensi bila diizinkan, hasil, dan rekomendasi. -
Beri loading/error/empty state. - Hormati privasi gambar dan batasi
akses ke pemiliknya.

**Tahap AI berikutnya** - Sebelum memilih model/API, tetapkan cakupan
diagnosis: jenis tanaman, penyakit/masalah yang didukung, format hasil,
batasan, biaya, dan cara menangani prediksi tidak yakin. - Jangan
menanam secret API AI di Flutter. Gunakan backend/Edge Function untuk
kredensial dan validasi. - Hasil harus menyebutkan ketidakpastian dan
tidak menyatakan diagnosis sebagai kepastian jika model tidak yakin. -
Sediakan opsi untuk mengambil foto baru, memilih gambar, meninjau hasil,
dan menyimpan riwayat. - Jangan mengklaim AI sudah bekerja jika hanya
memakai data dummy.

**Kriteria selesai** - Riwayat terhubung ke akun yang benar. - Kegagalan
jaringan/model ditangani dengan aman. - API key tidak terlihat di
aplikasi klien. - Hasil, waktu, dan gambar yang ditampilkan sesuai
dengan hasil yang tersimpan.

### F16 --- Notifikasi dan pengingat perawatan

**Tahap awal** - Rancang data pengingat: tanaman, jenis aktivitas,
tanggal/waktu, frekuensi, status aktif. - Pengguna dapat membuat,
mengubah, menandai selesai, dan menghapus pengingat. - Jangan
menampilkan notifikasi yang diklaim terkirim bila mekanisme notifikasi
belum aktif.

**Tahap lanjutan** - Tentukan apakah notifikasi lokal atau push
notification diperlukan. - Minta izin notifikasi sesuai platform. -
Untuk push notification, jangan mengirim dari klien dengan kredensial
server.

**Kriteria selesai** - Pengingat tersimpan dan hanya dapat dikelola
pemiliknya. - Zona waktu dan jadwal ditangani dengan jelas. - Pengguna
bisa menonaktifkan pengingat.

### F17 --- Bantuan, pengaturan, dan hapus akun

-   Ganti placeholder dengan halaman FAQ/bantuan yang benar-benar dapat
    digunakan.
-   Sediakan pengaturan akun dasar yang memang disetujui.
-   Implementasikan hapus akun melalui alur tepercaya; hapus atau
    anonimisasi data sesuai kebijakan proyek dan kebutuhan audit
    transaksi.
-   Minta konfirmasi sebelum tindakan destruktif.
-   Jangan menghapus data pesanan yang diwajibkan untuk audit/legal
    tanpa kebijakan yang jelas.

------------------------------------------------------------------------

## 7. Rancangan database awal

Ini adalah rancangan awal untuk ditinjau dan disesuaikan dengan
kebutuhan proyek. Jangan langsung menjalankan migration di project
produksi tanpa persetujuan dan backup. Buat migration SQL yang dapat
ditinjau dan gunakan environment development bila tersedia.

### Tabel yang disarankan

1.  `profiles`
    -   `id uuid` --- primary key dan foreign key ke `auth.users.id`
    -   `display_name text`
    -   `avatar_path text nullable`
    -   `created_at timestamptz`
    -   `updated_at timestamptz`
2.  `seller_profiles`
    -   `id uuid`
    -   `user_id uuid`
    -   `store_name text`
    -   `description text nullable`
    -   `status text` --- dibatasi ke status yang disepakati
    -   `created_at`, `updated_at`
3.  `categories`
    -   `id uuid`
    -   `name text`
    -   `slug text`
    -   `is_active boolean`
4.  `products`
    -   `id uuid`
    -   `seller_id uuid`
    -   `category_id uuid nullable`
    -   `name text`
    -   `description text`
    -   `price integer` --- satuan rupiah yang konsisten
    -   `stock integer`
    -   `image_paths text[]` atau tabel gambar terpisah
    -   `is_published boolean`
    -   `created_at`, `updated_at`
5.  `wishlist_items`
    -   `id uuid`
    -   `user_id uuid`
    -   `product_id uuid`
    -   `created_at`
    -   unique constraint pada pasangan `(user_id, product_id)`
6.  `cart_items`
    -   `id uuid`
    -   `user_id uuid`
    -   `product_id uuid`
    -   `quantity integer`
    -   `created_at`, `updated_at`
    -   unique constraint pada pasangan `(user_id, product_id)`
7.  `addresses`
    -   `id uuid`
    -   `user_id uuid`
    -   `recipient_name text`
    -   `phone text`
    -   `address_line text`
    -   `city text`
    -   `province text`
    -   `postal_code text nullable`
    -   `is_default boolean`
    -   `created_at`, `updated_at`
8.  `orders`
    -   `id uuid`
    -   `buyer_id uuid`
    -   `status text`
    -   `subtotal integer`
    -   `shipping_cost integer`
    -   `total integer`
    -   snapshot alamat pengiriman
    -   `payment_provider text nullable`
    -   `payment_reference text nullable`
    -   `created_at`, `updated_at`
9.  `order_items`
    -   `id uuid`
    -   `order_id uuid`
    -   `product_id uuid nullable`
    -   `seller_id uuid`
    -   `product_name_snapshot text`
    -   `unit_price integer`
    -   `quantity integer`
    -   `line_total integer`
10. `payments`
    -   `id uuid`
    -   `order_id uuid`
    -   `provider text`
    -   `provider_transaction_id text nullable`
    -   `amount integer`
    -   `status text`
    -   `created_at`, `updated_at`
11. `diagnosis_history`
    -   `id uuid`
    -   `user_id uuid`
    -   `image_path text nullable`
    -   `plant_name text nullable`
    -   `result_summary text`
    -   `confidence numeric nullable`
    -   `created_at timestamptz`
12. `care_reminders` (tahap lanjutan)
    -   `id uuid`
    -   `user_id uuid`
    -   `title text`
    -   `scheduled_at timestamptz`
    -   `repeat_rule text nullable`
    -   `is_active boolean`
    -   `created_at`, `updated_at`

### Catatan desain database

-   Gunakan foreign key, index, constraint, dan default timestamp yang
    sesuai.
-   Status sebaiknya dibatasi menggunakan enum atau check constraint
    sesuai keputusan desain.
-   Harga harus integer, bukan floating point.
-   Gunakan transaksi database atau fungsi server-side untuk pembuatan
    pesanan dan pengurangan stok yang harus atomik.
-   Pertimbangkan kebijakan pembatalan/refund dan pengembalian stok
    sebelum implementasi.
-   Jangan mempercayai `seller_id`, harga, status pembayaran, atau total
    dari payload klien.
-   Buat migration SQL yang bisa ditinjau, bukan mengandalkan perubahan
    manual yang tidak terdokumentasi.

------------------------------------------------------------------------

## 8. RLS dan aturan akses minimum

RLS harus dirancang bersama schema, bukan ditambahkan setelah semua
fitur selesai.

-   **Profiles:** pengguna dapat membaca/mengubah profil miliknya
    sendiri. Pengecualian untuk data publik harus dibatasi pada field
    yang memang aman.
-   **Seller profiles:** pemilik dapat mengubah data toko sendiri;
    status aktivasi tidak boleh dinaikkan sendiri jika proses
    persetujuan digunakan.
-   **Products:** katalog publik hanya membaca produk yang
    dipublikasikan dan aktif; penjual hanya dapat membuat/mengubah
    produk miliknya.
-   **Wishlist/cart/addresses:** hanya pemilik data yang dapat membaca,
    menambah, mengubah, atau menghapus.
-   **Orders:** pembeli dapat membaca pesanannya; penjual hanya dapat
    mengakses bagian pesanan yang memang diperlukan untuk memenuhi
    order. Jangan membuka data alamat lengkap kepada penjual yang tidak
    terkait.
-   **Payments:** pengguna hanya boleh membaca ringkasan pembayaran
    miliknya. Update status pembayaran hanya melalui jalur tepercaya.
-   **Diagnosis/reminders:** hanya pemilik data yang dapat mengakses
    data privat tersebut.
-   **Storage:** tetapkan kebijakan bucket/path yang membatasi akses
    berdasarkan pemilik atau status publikasi yang benar.

Setiap kebijakan harus diuji dengan setidaknya dua akun berbeda untuk
memastikan pengguna A tidak dapat membaca atau memodifikasi data
pengguna B.

------------------------------------------------------------------------

## 9. Urutan implementasi

### Fase 0 --- Audit dan fondasi

1.  Audit repository dan status Git.
2.  Verifikasi konfigurasi Supabase.
3.  Pastikan aplikasi dapat start.
4.  Siapkan struktur service/repository yang mengikuti pola proyek.
5.  Rancang migration schema dan RLS untuk fase awal.
6.  Jalankan analyzer dan tes baseline.

**Gate:** tidak melanjutkan ke fitur database jika konfigurasi Supabase
masih salah atau aplikasi tidak dapat start.

### Fase 1 --- Akun dan profil

1.  Register/login.
2.  Session restore dan logout.
3.  Proteksi layar yang memerlukan akun.
4.  Profil dari database.
5.  Edit profil.

**Gate:** alur akun lulus tes manual dasar dan RLS profil diuji dengan
dua akun.

### Fase 2 --- Marketplace dan wishlist

1.  Kategori dan produk dari database.
2.  Detail produk.
3.  Pencarian, filter, sorting.
4.  Wishlist persisten.
5.  Loading/empty/error state.

**Gate:** data demo tidak lagi menjadi sumber utama katalog aktif.

### Fase 3 --- Keranjang, alamat, checkout, dan pesanan

1.  Keranjang persisten.
2.  CRUD alamat.
3.  Checkout dengan validasi stok/harga tepercaya.
4.  Pembuatan order dan order items.
5.  Riwayat/detail pesanan.

**Gate:** tidak ada total harga yang hanya dipercaya dari klien; akses
pesanan dan stok diuji.

### Fase 4 --- Penjual dan produk

1.  Pengajuan/aktivasi penjual sesuai kebijakan proyek.
2.  CRUD produk.
3.  Upload gambar ke Storage.
4.  Validasi ownership dan stok.
5.  Uji isolasi data antar penjual.

### Fase 5 --- Pembayaran sandbox

1.  Konfirmasi provider.
2.  Integrasi backend/Edge Function.
3.  Webhook dan verifikasi status.
4.  Uji sukses/gagal/pending/cancel dan callback berulang.

### Fase 6 --- Diagnosis dan fitur pendukung

1.  Riwayat diagnosis.
2.  Evaluasi dan integrasi model AI melalui backend.
3.  Pengingat perawatan dan notifikasi.
4.  FAQ, pengaturan, dan hapus akun.
5.  Pengujian regresi serta perbaikan UX.

------------------------------------------------------------------------

## 10. Protokol kerja AI agent

Untuk setiap tugas:

1.  **Audit:** baca file yang relevan dan identifikasi alur saat ini.
2.  **Rencana singkat:** sebutkan file yang akan dibuat/diubah dan
    alasan.
3.  **Implementasi kecil:** kerjakan satu fitur atau satu sub-fitur
    dalam satu tahap.
4.  **Keamanan:** periksa RLS, ownership, validasi input, dan secret.
5.  **Verifikasi:** jalankan formatter, analyzer, dan test yang relevan.
6.  **Review:** periksa diff untuk memastikan desain dan fitur lain
    tidak rusak.
7.  **Laporan:** tulis apa yang berubah, apa yang diuji, hasilnya, serta
    langkah manual yang masih dibutuhkan.

### Agent dilarang

-   Mengimplementasikan semua fase sekaligus dalam satu perubahan besar.
-   Menghapus atau merombak UI yang sudah ada tanpa alasan dan
    persetujuan.
-   Mengganti data demo seluruh aplikasi secara sekaligus tanpa migrasi
    bertahap.
-   Membuat klaim fitur selesai hanya karena tombol terlihat.
-   Menambahkan secret ke source code, log, commit, atau screenshot.
-   Menonaktifkan RLS untuk "memudahkan development".
-   Membuat status `paid` dari klien tanpa verifikasi backend.
-   Mengubah schema/database produksi tanpa konfirmasi.
-   Mengubah file yang tidak relevan atau menimpa perubahan lokal yang
    belum di-commit.
-   Menambahkan package besar tanpa menjelaskan kebutuhan dan dampaknya.

### Format laporan akhir setiap tugas

``` text
Fitur:
- ...

File yang dibuat/diubah:
- ...

Perilaku yang sudah diimplementasikan:
- ...

Pengujian:
- Perintah yang dijalankan:
- Hasil:

Keamanan/RLS:
- ...

Yang masih belum selesai:
- ...

Langkah manual yang perlu dilakukan pemilik proyek:
- ...
```

------------------------------------------------------------------------

## 11. Checklist Definition of Done

Fitur hanya dapat dinyatakan selesai jika semua poin yang relevan
terpenuhi:

-   [ ] Implementasi sesuai tujuan dan alur pengguna.
-   [ ] Desain UI yang ada tetap terjaga.
-   [ ] Data berasal dari backend yang benar jika fitur membutuhkan
    backend.
-   [ ] Loading, empty, error, dan success state tersedia.
-   [ ] Validasi input dilakukan.
-   [ ] RLS/ownership diuji untuk data privat.
-   [ ] Tidak ada secret di aplikasi klien.
-   [ ] Tidak ada data demo yang diam-diam dipakai sebagai data nyata.
-   [ ] `dart format` dijalankan pada file yang berubah.
-   [ ] `flutter analyze` dijalankan jika environment tersedia.
-   [ ] Test terkait dijalankan atau alasan jika tidak bisa dijalankan
    dituliskan.
-   [ ] Diff diperiksa untuk perubahan yang tidak sengaja.
-   [ ] Laporan akhir menjelaskan batasan dan pekerjaan tersisa.

------------------------------------------------------------------------

## 12. Perintah verifikasi yang umum

Jalankan dari root proyek, jika Flutter SDK tersedia:

``` bash
flutter pub get
dart format lib test
flutter analyze
flutter test
```

Jika ada test yang belum tersedia, buat test untuk logika penting sesuai
scope. Jangan mengklaim semua test lulus bila perintah tidak dijalankan.
Catat juga bila kegagalan sudah ada sebelum perubahan.

------------------------------------------------------------------------

## 13. Keputusan yang membutuhkan konfirmasi pemilik proyek

AI agent harus berhenti dan bertanya sebelum mengambil keputusan yang
berdampak besar berikut:

-   Memilih payment gateway untuk integrasi produksi.
-   Mengaktifkan pembayaran produksi atau mengubah kredensial provider.
-   Mengubah desain besar atau alur navigasi yang sudah disetujui.
-   Menghapus data, tabel, storage bucket, atau migration yang sudah
    dipakai.
-   Menetapkan biaya layanan, ongkos kirim, diskon, kebijakan refund,
    atau komisi penjual.
-   Memilih model AI berbayar atau layanan pihak ketiga yang menimbulkan
    biaya.
-   Mengubah aturan persetujuan penjual atau kebijakan privasi data.
-   Melakukan operasi database yang berpotensi menghapus atau mengubah
    data produksi.

Untuk keputusan kecil yang mudah dibalik dan tidak menyangkut keamanan,
biaya, atau kebijakan bisnis, agent boleh memilih solusi paling
sederhana lalu mendokumentasikannya.

------------------------------------------------------------------------

## 14. Instruksi awal untuk AI agent

Mulai dari **Fase 0 --- Audit dan fondasi**. Baca seluruh kode yang
relevan di repository dan periksa status perubahan sebelum mengedit apa
pun. Verifikasi konfigurasi Supabase, terutama bahwa `url` adalah
Project URL utama dan bukan endpoint REST `/rest/v1/`. Setelah itu,
laporkan temuan audit, daftar file yang akan diubah, kebutuhan
migration/RLS, serta hasil pemeriksaan baseline.

Jangan langsung mengerjakan seluruh fitur. Selesaikan Fase 0 terlebih
dahulu, laporkan hasilnya, lalu lanjutkan ke Fase 1 secara bertahap.
Pertahankan UI DaunKu yang sudah ada dan gunakan dokumen ini sebagai
acuan kerja sampai pemilik proyek memberikan instruksi baru.


------------------------------------------------------------------------

## 15. Penyelarasan dengan dokumen resmi SRS dan SDD

Bagian ini ditambahkan setelah dokumen SRS dan SDD DaunKu diterima.
**SRS dan SDD menjadi acuan kebutuhan dan rancangan sistem.** Bagian
sebelumnya tetap digunakan sebagai panduan implementasi repository,
tetapi jika terdapat perbedaan, agent wajib mencatatnya dan tidak boleh
diam-diam mengabaikan kebutuhan SRS/SDD.

### 15.1 Acuan dokumen

- `SRS_DaunKu.pdf` — Software Requirements Specification, 33 halaman.
- `SDD_DaunKu.pdf` — Software Design Document, 31 halaman.
- `DaunKu_Rancangan_Pengembangan_Fitur.md` — instruksi implementasi
  untuk AI coding agent.

SRS menetapkan aplikasi Android untuk diagnosis penyakit/kondisi tanaman
berbasis AI dan marketplace produk perawatan tanaman. SDD menerjemahkan
kebutuhan tersebut menjadi rancangan client-server, layanan AI terpisah,
database relasional, object storage, payment gateway, dan komponen
pendukung.

### 15.2 Kebutuhan fungsional SRS yang wajib dilacak

Agent wajib menggunakan ID berikut ketika membuat issue, task, test,
atau laporan implementasi.

| ID SRS | Kebutuhan | Bagian Markdown yang menangani | Status cakupan dokumen |
|---|---|---|---|
| KF-01 | Registrasi email dan kata sandi | F02 | Sudah tercakup |
| KF-02 | Login pengguna | F02 | Sudah tercakup |
| KF-03 | Ambil foto atau pilih dari galeri | F14–F15 | Perlu dibuat lebih eksplisit sebagai alur diagnosis |
| KF-04 | Analisis foto dengan AI dan tampilkan diagnosis | F14–F15 | Sudah tercakup, tetapi perlu mengikuti alur server-side SRS/SDD |
| KF-05 | Rekomendasi perawatan berdasarkan diagnosis | F14–F15 | Perlu ditegaskan sebagai keluaran diagnosis wajib |
| KF-06 | Simpan dan tampilkan riwayat diagnosis | F14 | Sudah tercakup |
| KF-07 | Daftar produk perawatan | F04–F05 | Sudah tercakup |
| KF-08 | Cari produk dan lihat detail | F04–F05 | Sudah tercakup |
| KF-09 | Tambah produk ke keranjang | F07 | Sudah tercakup |
| KF-10 | Checkout dan pembayaran | F08, F10 | Sudah tercakup |
| KF-11 | Lihat status pesanan | F09 | Sudah tercakup |
| KF-12 | Rating dan ulasan setelah pesanan selesai | Belum ada fitur khusus | **Harus ditambahkan** |
| KF-13 | Aktifkan akun penjual | F11–F13 | Sudah tercakup |
| KF-14 | Penjual menambahkan produk | F11–F13 | Sudah tercakup |
| KF-15 | Penjual mengubah produk miliknya | F11–F13 | Sudah tercakup |
| KF-16 | Penjual menghapus produk miliknya | F11–F13 | Sudah tercakup; gunakan soft delete |
| KF-17 | Penjual memperbarui status pesanan | F09 dan F11–F13 | **Perlu alur penjual/pesanan masuk yang eksplisit** |
| KF-18 | Batasi kuota diagnosis gratis | F14–F15 | **Harus ditambahkan sebagai fitur kuota** |
| KF-19 | Berlangganan paket premium | Belum ada fitur khusus | **Harus ditambahkan** |
| KF-20 | Admin memoderasi produk yang dilaporkan | Belum ada fitur khusus | **Harus ditambahkan** |
| KF-21 | Admin melihat data transaksi | Belum ada fitur khusus | **Harus ditambahkan** |

Selain daftar KF-01 sampai KF-21, SRS juga memiliki use case
`UC-020 Menghapus Akun Pengguna`. Fitur ini telah disebut dalam F17,
tetapi harus dijadikan alur yang dapat diuji: konfirmasi berlapis,
konfirmasi teks `HAPUS`, penghapusan/nonaktifkan akun melalui jalur
tepercaya, pengakhiran sesi, dan kebijakan retensi data transaksi.

### 15.3 Use case SRS yang harus menjadi skenario pengujian

SRS mendeskripsikan use case berikut. Setiap use case harus memiliki
minimal satu skenario sukses dan skenario gagal/alternatif yang relevan.

| Use case | Nama | Skenario minimum yang perlu diuji |
|---|---|---|
| UC-001 | Membuat Akun | Data valid; field kosong; email tidak valid; email sudah terdaftar; penyimpanan gagal |
| UC-002 | Login ke Aplikasi | Login valid; field kosong; kredensial salah; koneksi gagal |
| UC-003 | Mendiagnosis Tanaman | Ambil foto; pilih galeri; preview; kuota habis; koneksi gagal; foto tidak dikenali; AI gagal |
| UC-004 | Melihat Riwayat Diagnosis | Ada riwayat; belum ada riwayat; gagal memuat |
| UC-005 | Melihat Produk | Ada produk aktif; katalog kosong; gagal memuat |
| UC-006 | Mencari Produk | Hasil ditemukan; kata kunci kosong; tidak ada hasil |
| UC-007 | Menambahkan Produk ke Keranjang | Stok cukup; jumlah melebihi stok; produk tidak tersedia; penyimpanan gagal |
| UC-008 | Membeli Produk | Pembayaran berhasil; stok berubah; pembayaran dibatalkan; pembayaran gagal/pending |
| UC-009 | Melihat Status Pesanan | Ada pesanan; tidak ada pesanan; gagal memuat |
| UC-010 | Memberikan Ulasan | Pesanan selesai; rating belum dipilih; ulasan gagal disimpan |
| UC-011 | Mengaktifkan Akun Penjual | Data valid; data tidak lengkap/tidak valid; aktivasi gagal |
| UC-012 | Menambahkan Produk | Data valid; field wajib kosong; format gambar salah; penyimpanan gagal |
| UC-013 | Mengedit Data Produk | Perubahan valid; data tidak valid; produk tidak tersedia; penyimpanan gagal |
| UC-014 | Menghapus Produk | Konfirmasi; batal; penghapusan gagal; produk tetap aman dalam riwayat transaksi |
| UC-015 | Melihat Pesanan Masuk | Ada pesanan; belum ada pesanan; gagal memuat |
| UC-016 | Memperbarui Status Pesanan | Transisi status valid; transisi tidak valid; penyimpanan gagal |
| UC-017 | Berlangganan Premium | Pembayaran sukses; dibatalkan; gagal; pending |
| UC-018 | Melihat Transaksi | Ada transaksi; belum ada transaksi; gagal memuat |
| UC-019 | Memoderasi Produk | Ada laporan; tidak ada laporan; admin membatalkan; tindakan gagal |
| UC-020 | Menghapus Akun Pengguna | Konfirmasi benar; konfirmasi salah; batal; proses gagal; sesi berakhir |

### 15.4 Kebutuhan nonfungsional SRS

Angka berikut berasal dari SRS dan harus diperlakukan sebagai target
penerimaan yang dapat diuji, bukan sekadar saran.

| ID | Kategori | Kriteria penerimaan |
|---|---|---|
| NFR-01 | Performance | Halaman utama tampil maksimal 3 detik pada koneksi internet stabil |
| NFR-02 | Response Time | Hasil pencarian produk tampil maksimal 5 detik setelah permintaan diterima |
| NFR-03 | AI Response | Hasil diagnosis tampil maksimal 15 detik setelah foto berhasil dikirim, selama server dan koneksi tersedia |
| NFR-04 | Security | Komunikasi aplikasi-server menggunakan HTTPS |
| NFR-05 | Security | Password disimpan dalam bentuk hash, bukan teks biasa |
| NFR-06 | Usability | Bahasa Indonesia dan pesan kesalahan mudah dipahami pengguna umum |
| NFR-07 | Compatibility | Aplikasi berjalan pada Android 8.0 atau lebih baru |
| NFR-08 | Reliability | Kegagalan diagnosis/pembayaran menampilkan status gagal tanpa menghapus data pengguna atau membuat transaksi ganda |
| NFR-09 | Data | Riwayat diagnosis dan transaksi tersimpan serta dapat ditampilkan kepada pengguna berwenang |
| NFR-10 | Maintainability | Diagnosis AI, marketplace, dan autentikasi dipisahkan agar perubahan satu komponen tidak mengharuskan perubahan seluruh aplikasi |

Target waktu perlu diuji pada kondisi yang dicatat (perangkat, jaringan,
ukuran data, dan environment server). Jangan menjamin NFR-03 jika
ketersediaan server AI atau jaringan berada di luar kendali aplikasi.

### 15.5 Batasan produk dan pengalaman pengguna dari SRS

Hal-hal berikut harus masuk ke implementasi dan pengujian:

- MVP berfokus pada dua kelompok: tanaman hias dalam ruangan/pot
  (contoh Aglaonema, Monstera, Anthurium, Philodendron, Pothos,
  Alocasia, Snake Plant) dan tanaman pekarangan umum (contoh mangga,
  jambu, cabai, tomat).
- Model AI hanya boleh menyatakan cakupan tanaman/kondisi yang memang
  didukung model. Untuk foto di luar cakupan, tampilkan informasi bahwa
  tanaman/kondisi belum dapat dikenali.
- Diagnosis membutuhkan internet dan tidak tersedia secara offline.
- Client MVP ditujukan untuk Android 8.0/API 26 ke atas; spesifikasi
  SRS menyebut RAM minimal 2 GB, ruang kosong 100 MB, kamera belakang,
  dan layar minimal 720 × 1280.
- Bahasa UI adalah Bahasa Indonesia.
- Navigasi utama menggunakan bottom bar; kedalaman navigasi maksimal
  tiga tingkat dari halaman utama.
- Tampilkan loading/progress pada proses yang memerlukan waktu,
  khususnya diagnosis AI.
- Tampilkan pesan error yang jelas di dekat field atau melalui
  snackbar/toast.
- Minta konfirmasi sebelum tindakan permanen, misalnya menghapus produk.
- SRS menyebut push notification/FCM untuk status pesanan, pencairan
  dana, dan kuota diagnosis. Fitur ini perlu direncanakan, tetapi
  integrasi provider dan kredensial server tidak boleh ditanam di Flutter.
- Dokumentasi pengguna mencakup User Manual PDF untuk Pembeli, Penjual,
  dan Admin; FAQ; panduan foto untuk diagnosis AI; serta Help Center
  yang dapat diakses dari aplikasi.

### 15.6 Rancangan teknis SDD yang wajib diperhatikan

SDD membagi sistem menjadi komponen berikut:

1. Aplikasi Android sebagai lapisan presentasi.
2. REST API sebagai penghubung client dengan backend.
3. Autentikasi untuk registrasi dan login.
4. Diagnosis Service untuk menerima dan mengatur permintaan diagnosis.
5. AI Service terpisah untuk analisis gambar.
6. Marketplace Service untuk produk dan pencarian.
7. Order & Payment Service untuk checkout dan pembayaran.
8. Database relasional untuk data aplikasi.
9. Object Storage untuk gambar diagnosis dan gambar produk.
10. Payment Gateway untuk pembayaran.
11. Push Notification untuk pemberitahuan.

SDD menjelaskan arsitektur tiga lapis: aplikasi Android, backend REST
API (contoh teknologi yang disebut adalah Node.js/Laravel), dan database
MySQL/PostgreSQL, dengan layanan inferensi AI Python/FastAPI yang
independen. SDD juga menyebut komunikasi client-server melalui HTTPS.

#### Catatan keselarasan dengan repository

Repository dan rancangan Markdown sebelumnya menggunakan Supabase
(Auth, PostgreSQL, Storage). Hal ini tidak otomatis bertentangan dengan
kebutuhan fungsional SRS, tetapi berbeda dari gambaran backend REST API
dan pembagian layanan pada SDD.

Sebelum implementasi backend lanjutan, pemilik proyek perlu menetapkan
keputusan arsitektur berikut:

- Apakah Supabase tetap menjadi backend utama (Auth, PostgreSQL,
  Storage, RLS, dan fungsi server-side/Edge Functions), atau akan
  dibangun backend REST API Node.js/Laravel terpisah?
- Jika Supabase dipertahankan, komponen mana yang bertindak sebagai
  REST API/order service dan bagaimana batas tanggung jawabnya?
- Apakah AI Service akan dibuat sebagai microservice Python/FastAPI
  terpisah sebagaimana SDD?
- Bagaimana autentikasi/otorisasi diteruskan secara aman dari backend
  ke AI Service?
- Di mana webhook payment gateway, validasi pembayaran, komisi,
  escrow, dan payout akan diproses?

**Keputusan sementara untuk agent:** jangan mengganti Supabase atau
menambahkan backend Node.js/Laravel secara sepihak. Pertahankan pola
repository yang ada untuk pekerjaan yang tidak mengunci keputusan
arsitektur. Sebelum membangun integrasi kritis (pembayaran, escrow,
payout, AI service), laporkan opsi dan minta persetujuan pemilik proyek.

### 15.7 Aturan keamanan dan transaksi tambahan dari SDD

Selain aturan keamanan pada bagian 3 dan 8, SDD secara eksplisit
mensyaratkan:

- Password menggunakan hash bcrypt/argon2 pada sistem autentikasi
  yang mengelolanya. Jika memakai Supabase Auth, jangan membuat
  penyimpanan password sendiri; gunakan mekanisme Auth yang disediakan.
- Produk yang dihapus menggunakan **soft delete** agar riwayat transaksi
  tetap utuh.
- Proses kritis checkout, pembayaran, komisi, dan payout menggunakan
  transaksi database/operasi atomik.
- Webhook payment gateway harus **idempotent**: event yang sama
  diproses berulang kali tidak boleh menggandakan pembayaran, order,
  komisi, atau payout.
- Data pembayaran sensitif tidak disimpan di server DaunKu.
- Gambar diagnosis dan produk divalidasi berdasarkan MIME/type file dan
  ukuran maksimum. Nilai batas ukuran perlu ditetapkan sebagai keputusan
  implementasi dan didokumentasikan.
- Kuota diagnosis harus diperiksa sebelum layanan AI dipanggil.
- Status pembayaran tidak boleh ditentukan hanya oleh redirect atau
  respons dari aplikasi client; gunakan verifikasi server-side.
- Aksi admin harus dibatasi ke akun admin yang terotorisasi dan
  dicatat untuk kebutuhan audit.

### 15.8 Perluasan rancangan data

Tabel pada bagian 7 merupakan rancangan awal, bukan ERD final SDD.
Agar seluruh kebutuhan SRS dapat didukung, evaluasi kebutuhan tabel
atau struktur tambahan berikut sebelum migration dibuat:

| Domain | Data/tabel yang perlu dipertimbangkan | Tujuan |
|---|---|---|
| Review | `product_reviews` | Rating dan ulasan; kaitkan ke pembeli, produk, dan item/pesanan yang telah selesai |
| Premium | `subscription_plans`, `user_subscriptions` | Daftar paket dan status langganan pengguna |
| Kuota | `diagnosis_quotas` atau ledger penggunaan | Menentukan kuota gratis/premium dan mencatat pemakaian diagnosis |
| Moderasi | `product_reports`, `moderation_actions` | Laporan produk, keputusan admin, dan jejak tindakan |
| Admin | Role/permission dan audit log | Membatasi transaksi dan moderasi untuk admin |
| Payout/escrow | `seller_balances`, `commissions`, `payouts` atau model ledger setara | Mendukung konsep komisi, dana tertahan, dan pencairan penjual yang disebut SDD |
| Notifikasi | `notifications` atau tabel token perangkat | Riwayat notifikasi dan hubungan dengan push notification |
| Akun | Status penghapusan/anonimisasi dan audit | Mendukung UC-020 tanpa merusak catatan transaksi |

Jangan membuat semua tabel tersebut secara otomatis. Detail seperti
rumus komisi, kapan escrow dilepas, jadwal payout, refund, masa aktif
premium, besaran kuota, dan kebijakan penghapusan data belum ditentukan
secara lengkap dalam dokumen yang tersedia. Minta keputusan pemilik
proyek sebelum mengunci aturan bisnis.

### 15.9 Perubahan prioritas fase implementasi

Urutan berikut menyelaraskan prioritas implementasi sebelumnya dengan
seluruh kebutuhan SRS. Fitur AI tetap dapat dikerjakan setelah fondasi
akun dan backend siap, tetapi desain kuota/premium perlu disiapkan
sebelum diagnosis diaktifkan untuk pengguna.

| Fase | Cakupan yang diselaraskan | Gate sebelum lanjut |
|---|---|---|
| 0 | Audit repo, konfigurasi Supabase, keputusan arsitektur, baseline test, rancangan schema/RLS | Aplikasi dapat start dan keputusan arsitektur dasar dicatat |
| 1 | KF-01, KF-02, profil, logout, sesi, UC-020 hapus akun | Auth, akses privat, dan kebijakan hapus akun diuji |
| 2 | KF-07, KF-08, katalog, pencarian, detail, kategori, gambar produk | Produk aktif tampil dari backend dan pencarian memenuhi target NFR-02 |
| 3 | KF-09, KF-10, KF-11, alamat, cart, checkout, order, status pesanan | Order dan stok atomik; tidak ada transaksi ganda |
| 4 | KF-13 sampai KF-17, toko penjual, CRUD produk, pesanan masuk, update status | Isolasi akses antar penjual dan transisi status diuji |
| 5 | KF-12, ulasan/rating setelah pesanan selesai | Hanya pembeli yang memenuhi syarat dapat mengulas |
| 6 | KF-18, KF-19, paket premium, langganan, kuota diagnosis | Kuota tervalidasi di server dan status premium berdasarkan pembayaran terverifikasi |
| 7 | KF-20, KF-21, admin, moderasi laporan produk, data transaksi | Akses admin aman dan tindakan tercatat |
| 8 | KF-03 sampai KF-06, diagnosis, rekomendasi, riwayat, AI service | Cakupan model jelas, kuota dicek sebelum inferensi, NFR-03 diuji |
| 9 | FCM/push notification, FAQ, Help Center, user manual, hardening, regresi | Pengujian lintas peran dan NFR selesai |

Fase dapat disesuaikan berdasarkan dependensi teknis, tetapi tidak boleh
menghilangkan kebutuhan SRS. Bila ada fitur yang sengaja ditunda dari
MVP, catat sebagai keputusan scope yang disetujui, bukan dianggap tidak
dibutuhkan.

### 15.10 Kriteria Definition of Done tambahan

Sebelum fitur dinyatakan selesai, agent harus:

- [ ] Menautkan implementasi ke ID KF atau UC yang relevan.
- [ ] Memiliki skenario sukses dan alternatif/gagal dari use case.
- [ ] Memenuhi NFR yang terkait atau mencatat hasil pengukurannya.
- [ ] Memastikan role Pembeli, Penjual, dan Admin memiliki izin yang tepat.
- [ ] Menggunakan soft delete untuk produk dan menjaga snapshot order.
- [ ] Memastikan review hanya dapat dibuat untuk pembelian yang selesai.
- [ ] Memastikan kuota diagnosis diperiksa sebelum pemanggilan AI.
- [ ] Memastikan premium aktif hanya setelah pembayaran terverifikasi.
- [ ] Memastikan webhook idempotent dan proses transaksi kritis atomik.
- [ ] Memvalidasi tipe dan ukuran file gambar.
- [ ] Memastikan push notification tidak menggunakan secret server di client.
- [ ] Memperbarui dokumentasi/test matrix ketika kebutuhan berubah.

------------------------------------------------------------------------

## 16. Daftar keputusan yang masih terbuka setelah membaca SRS/SDD

AI agent harus meminta keputusan pemilik proyek untuk hal-hal berikut
sebelum membuat implementasi yang mengunci kebijakan bisnis/arsitektur:

1. **Backend final:** Supabase saja dengan fungsi server-side, atau
   REST API Node.js/Laravel terpisah seperti gambaran SDD.
2. **AI service:** penyedia/model, hosting Python/FastAPI, daftar spesies
   dan penyakit yang benar-benar didukung, format confidence, dan
   perilaku untuk foto di luar cakupan.
3. **Paket premium:** nama paket, harga, masa berlaku, kuota tiap paket,
   apakah kuota gratis di-reset berkala, dan perilaku saat langganan
   berakhir.
4. **Pembayaran:** payment gateway, metode pembayaran, masa berlaku
   invoice, refund, dan aturan status pending/cancel.
5. **Escrow/komisi/payout:** persentase komisi, kapan dana dianggap
   selesai, syarat pencairan, jadwal payout, minimum payout, dan
   penanganan sengketa.
6. **Pengiriman:** perhitungan ongkos kirim, kurir, wilayah layanan,
   serta apakah MVP memakai biaya tetap/manual.
7. **Penjual:** apakah aktivasi langsung atau memerlukan verifikasi
   admin; data toko dan dokumen apa yang diwajibkan.
8. **Moderasi:** siapa dapat melaporkan produk, alasan laporan, SLA,
   jenis tindakan admin, dan mekanisme banding.
9. **Hapus akun:** data mana yang dihapus, dianonimkan, atau tetap
   disimpan demi integritas/audit transaksi.
10. **Notifikasi:** FCM atau alternatif, jenis event yang dikirim, dan
    apakah notifikasi wajib pada MVP.
11. **Gambar:** batas ukuran, format yang diterima, retensi gambar
    diagnosis, serta aturan privasi dan penghapusan.
12. **Dokumentasi bantuan:** siapa yang menulis dan memelihara User
    Manual, FAQ, dan Help Center.

Jangan mengarang nilai untuk keputusan tersebut. Gunakan placeholder
konfigurasi dan tandai sebagai `NEEDS_OWNER_DECISION` sampai pemilik
proyek menetapkannya.

------------------------------------------------------------------------

## 17. Instruksi pembuka agent setelah penyelarasan dokumen

Sebelum melakukan perubahan kode berikutnya:

1. Baca dokumen ini beserta SRS dan SDD.
2. Audit ulang repository terbaru; status yang tercatat pada bagian 2
   mungkin sudah berubah.
3. Buat matriks status setiap KF-01 sampai KF-21 dan UC-001 sampai
   UC-020: `belum ada`, `sebagian`, `sudah ada`, atau `perlu verifikasi`.
4. Catat bukti file/kode/test untuk setiap status. Jangan menyimpulkan
   fitur sudah selesai hanya dari keberadaan tombol atau halaman.
5. Catat gap terhadap NFR-01 sampai NFR-10.
6. Ajukan keputusan arsitektur dan bisnis pada bagian 15.6 dan 16.
7. Usulkan task terkecil untuk fase berikutnya, lengkap dengan file
   yang akan diubah dan test yang akan dijalankan.
8. Tunggu persetujuan untuk keputusan yang memengaruhi biaya,
   keamanan, pembayaran, data produksi, atau kebijakan bisnis.

**Prioritas akhir:** kesesuaian terhadap SRS/SDD, keamanan data dan
transaksi, kestabilan fitur inti, lalu penyempurnaan UI. Pertahankan
desain aplikasi yang sudah ada selama tidak bertentangan dengan
kebutuhan yang disetujui.

------------------------------------------------------------------------
