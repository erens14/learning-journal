# Dokumen Spesifikasi Teknis & Arsitektur Sistem Pemesanan Dine-In QR

**Status:** Rancangan teknis, bukan laporan implementasi. Kontrol keamanan, skema, dan alur pembayaran di bawah belum diverifikasi melalui pengujian aplikasi.

Dokumen ini mendokumentasikan secara terpadu *tech stack*, lapisan keamanan, alur pelanggan (*customer flow*), serta integrasi pemrosesan pembayaran untuk sistem pemesanan *dine-in* berbasis QR code.

---

## 1. Spesifikasi Tech Stack

Rancangan menggunakan arsitektur monolitik modern yang responsif dan reaktif tanpa memisahkan repositori *frontend* dan *backend*.

* **Backend Framework:** Laravel 11.x (PHP 8.2+)
* **Frontend & Interaktivitas:** Laravel Livewire v3 + Alpine.js
* **Styling Framework:** Tailwind CSS v3 / v4
* **Database:** PostgreSQL
* **Real-time Engine:** Laravel Reverb (WebSocket server bawaan Laravel)
* **Thermal Printing Integration:** Local Network Print Server (ESC/POS Bridge) / Web Serial API

---

## 2. Lapisan Keamanan Aplikasi (Web Security Hardening)

Mengingat antarmuka pemesanan diakses secara publik oleh pelanggan, direncanakan beberapa proteksi wajib untuk mencegah pemesanan fiktif, *order spamming*, dan manipulasi data.

* **Dynamic QR & Session Binding:**
URL QR code dilengkapi token HMAC bertanda tangan:

Ilustrasi konstruksi token, bukan kode siap pakai:

```text
message = canonical_encode(table_id, expires_at, nonce)
signature = HMAC-SHA256(secret_key, message)
```

Server harus memvalidasi signature dengan perbandingan waktu konstan, masa berlaku, serta meja aktif sebelum menerbitkan cookie sesi. Cookie memerlukan `Secure`, `HttpOnly`, dan kebijakan `SameSite` yang sesuai. Token QR yang disalin tetap dapat dipakai selama masih valid; HMAC sendiri tidak membuktikan kehadiran fisik pelanggan.

* **Proteksi IDOR & Rate Limiting:**
Setiap pembacaan atau perubahan pesanan, termasuk otorisasi langganan kanal WebSocket, wajib memeriksa relasi sesi dengan meja dan pesanan yang diizinkan di sisi server. `table_id` atau UUID dari permintaan bukan bukti hak akses. Sesi pelanggan tidak boleh mengakses pesanan meja lain.

UUID v4 (`/order/status/9b1deb4d-...`) mengurangi kemudahan menebak ID; UUID tidak menggantikan pemeriksaan otorisasi. Batas pembuatan pesanan yang diusulkan adalah 3 kali per 5 menit. Kunci limiter per IP/sesi harus ditetapkan secara eksplisit; `throttle:3,5` saja tidak membuktikan kedua batas tersebut diterapkan.

* **Verifikasi Webhook Pembayaran:**
*Callback* dari Payment Gateway wajib melewati verifikasi *HMAC Signature*. Setelah itu, server harus memeriksa jenis event sukses final menurut kontrak penyedia, referensi transaksi, identitas pesanan, mata uang, dan nominal. Signature valid saja tidak membuktikan pembayaran berhasil.

Transisi `UNPAID` ke `PAID` harus atomik dan idempoten dengan penguncian atau pembaruan bersyarat. Callback duplikat tidak boleh mengulangi transisi atau efek pembayaran. Kirim event KDS/cetak setelah commit; konsumen harus mengabaikan event yang sudah diproses. Tentukan kebijakan retry agar kegagalan pengiriman tidak menghilangkan pekerjaan.
* **Role-Based Access Control (RBAC):**
Hak akses dibatasi ketat menggunakan paket `spatie/laravel-permission`:
* **Admin:** Akses penuh manajemen menu, harga, promo, karyawan, dan laporan.
* **Kasir:** Akses ke panel POS, verifikasi pembayaran Cash/Debit, dan cetak ulang struk.
* **Dapur:** Akses terbatas ke Kitchen Display System (KDS).
* **Customer:** Sesi sementara tanpa autentikasi login.

---

## 3. Alur Pelanggan & Pemrosesan Pembayaran Terpadu

```text
[Pelanggan Scan QR Meja]
       │
       ▼
[Validasi Token & Inisialisasi Sesi]
       │
       ▼
[Pilih Menu & Isi Keranjang (Livewire + Tailwind)]
       │
       ▼
[Pilih Metode Pembayaran]
       │
       ├───────────────────────────────┬───────────────────────────────┐
       ▼                               ▼                               ▼
[A. QRIS Online]               [B. Cash di Kasir]              [C. Debit di Kasir]
       │                               │                               │
[Request Charge Gateway]       [Order: PENDING_PAYMENT]        [Order: PENDING_PAYMENT]
       │                               │                               │
[Scan & Bayar e-Wallet]        [Pelanggan ke Kasir]            [Pelanggan ke Kasir]
       │                               │                               │
[Webhook Terverifikasi]        [Kasir Terima Uang Cash]        [Kasir Gesek Mesin EDC]
       │                               │                               │
       │                       [Input Nominal & Kembalian]     [Input Approval Code EDC]
       │                               │                               │
       └───────────────────────────────┴───────────────────────────────┘
                                       │
                                       ▼
                           [payment_status = PAID]
                                       │
                        [Trigger Event: Laravel Reverb]
                                       │
                       ┌───────────────┴───────────────┐
                       ▼                               ▼
            [Layar KDS Dapur Update]       [Thermal Printer Auto Print]
                       │
             [Dapur Ubah Status: READY]
                       │
       [WebSocket Broadcast Status ke Pelanggan]

```

### Detail Langkah Transaksi

1. **Inisialisasi Sesi:** Pelanggan memindai QR code di meja. Middleware memvalidasi token signature, membakar sesi cookie, dan menampilkan katalog menu berbasis Livewire.
2. **Penyusunan Pesanan:** Pelanggan memilih item, varian, dan catatan khusus (*less sugar*, *no ice*), lalu masuk ke halaman *checkout*.
3. **Eksekusi Pembayaran:**

* **Opsi A (QRIS Online):**

1. Sistem memanggil API Payment Gateway dan merender *Dynamic QRIS* dengan batas waktu pembayaran.
2. Pelanggan membayar via e-wallet / m-banking.
3. Payment Gateway mengirim *HTTP Webhook* $\rightarrow$ Controller memverifikasi signature dan seluruh kondisi pembayaran di atas $\rightarrow$ Transisi atomik ke `PAID` hanya untuk pembayaran sukses yang sesuai.

* **Opsi B (Cash di Kasir):**

1. Pesanan tersimpan dengan `payment_status = UNPAID` dan `order_status = PENDING_PAYMENT`.
2. Layar pelanggan menampilkan nomor meja dan instruksi pembayaran.
3. Pelanggan menuju kasir. Kasir membuka panel kasir Livewire, memilih nomor meja, memasukkan jumlah uang tunai yang diterima, dan sistem menghitung kembalian.
4. Kasir menekan **[Konfirmasi Cash]** $\rightarrow$ Status berubah menjadi `PAID`.

* **Opsi C (Debit di Kasir):**

1. Pesanan tersimpan dengan status `UNPAID`.
2. Pelanggan menuju kasir. Kasir memproses transaksi menggunakan mesin EDC fisik.
3. Kasir memasukkan nomor *approval code* dari struk EDC ke panel kasir sebagai jejak audit.
4. Kasir menekan **[Konfirmasi Debit]** $\rightarrow$ Status berubah menjadi `PAID`.

5. **Pemrosesan Dapur (KDS) & Cetak Struk:**

* Hanya transisi pembayaran pertama yang berhasil di-commit ke `PAID` boleh menerbitkan `OrderPaidEvent`. Penanganan event duplikat wajib idempoten.
* **Laravel Reverb** menyiarkan sinyal secara *real-time* ke layar Dapur (KDS) untuk memunculkan kartu pesanan baru (FIFO) beserta notifikasi suara.
* Servis pencetak (*print bridge*) otomatis mencetak struk dapur dan struk konsumen.

1. **Penyajian & Pelacakan:** Staf dapur memperbarui status pesanan dari `IN_PREPARATION` menjadi `READY`. Perubahan status terdorong otomatis ke layar browser pelanggan via WebSocket.

---

## 4. Skema Database Utama (PostgreSQL)

Contoh skema ini mengasumsikan tabel `users` sudah tersedia dari migrasi aplikasi dan fungsi `gen_random_uuid()` tersedia pada PostgreSQL yang digunakan. Skema belum dijalankan.

```sql
CREATE TABLE tables (
    id BIGSERIAL PRIMARY KEY,
    table_number VARCHAR(20) UNIQUE NOT NULL,
    qr_token VARCHAR(255) NOT NULL,
    is_active BOOLEAN DEFAULT TRUE
);

CREATE TABLE categories (
    id BIGSERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    slug VARCHAR(100) UNIQUE NOT NULL
);

CREATE TABLE menus (
    id BIGSERIAL PRIMARY KEY,
    category_id BIGINT REFERENCES categories(id) ON DELETE CASCADE,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    price NUMERIC(12, 2) NOT NULL,
    image_path VARCHAR(255),
    is_available BOOLEAN DEFAULT TRUE
);

CREATE TABLE orders (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    order_number VARCHAR(50) UNIQUE NOT NULL,
    table_id BIGINT REFERENCES tables(id),
    cashier_id BIGINT REFERENCES users(id) NULL,
    
    order_status VARCHAR(50) DEFAULT 'PENDING_PAYMENT', -- PENDING_PAYMENT, IN_PREPARATION, READY, COMPLETED, CANCELLED
    payment_status VARCHAR(50) DEFAULT 'UNPAID', -- UNPAID, PAID, FAILED, EXPIRED
    payment_method VARCHAR(50) NOT NULL, -- QRIS_ONLINE, CASH, DEBIT
    payment_reference VARCHAR(255) NULL, -- Gateway TxID / EDC Approval Code
    
    subtotal NUMERIC(12, 2) NOT NULL,
    discount_amount NUMERIC(12, 2) DEFAULT 0,
    total_amount NUMERIC(12, 2) NOT NULL,
    cash_paid NUMERIC(12, 2) DEFAULT 0,
    cash_change NUMERIC(12, 2) DEFAULT 0,
    
    paid_at TIMESTAMP WITH TIME ZONE NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE order_items (
    id BIGSERIAL PRIMARY KEY,
    order_id UUID REFERENCES orders(id) ON DELETE CASCADE,
    menu_id BIGINT REFERENCES menus(id),
    quantity INT NOT NULL CHECK (quantity > 0),
    price_at_time NUMERIC(12, 2) NOT NULL,
    notes TEXT NULL
);

```
