# Dokumen Spesifikasi Teknis & Arsitektur Sistem Pemesanan Dine-In QR

Dokumen ini mendokumentasikan secara terpadu *tech stack*, lapisan keamanan, alur pelanggan (*customer flow*), serta integrasi pemrosesan pembayaran untuk sistem pemesanan *dine-in* berbasis QR code.

---

## 1. Spesifikasi Tech Stack

Sistem dibangun menggunakan arsitektur monolitik modern yang responsif dan reaktif tanpa memisahkan repositori *frontend* dan *backend*.

* **Backend Framework:** Laravel 11.x (PHP 8.2+)
* **Frontend & Interaktivitas:** Laravel Livewire v3 + Alpine.js
* **Styling Framework:** Tailwind CSS v3 / v4
* **Database:** PostgreSQL
* **Real-time Engine:** Laravel Reverb (WebSocket server bawaan Laravel)
* **Thermal Printing Integration:** Local Network Print Server (ESC/POS Bridge) / Web Serial API

---

## 2. Lapisan Keamanan Aplikasi (Web Security Hardening)

Mengingat antarmuka pemesanan diakses secara publik oleh pelanggan, diterapkan beberapa proteksi wajib untuk mencegah pemesanan fiktif, *order spamming*, dan manipulasi data.

* **Dynamic QR & Session Binding:**
URL QR code dilengkapi token HMAC bertanda tangan:

$$\text{URL} = \text{[app.cafe.com/order?table=M05](https://app.cafe.com/order?table=M05)\&token=hash(M05 + secret\_key + date)}$$

Saat QR dipindai, middleware Laravel memvalidasi token dan menerbitkan *Encrypted Cookie* berisi `table_id` dan `session_token`. Pelanggan tidak dapat mengubah nomor meja secara manual di URL untuk memanipulasi pesanan meja lain.

* **Proteksi IDOR & Rate Limiting:**
Seluruh ID transaksi publik menggunakan UUID v4 (`/order/status/9b1deb4d-...`). Pembuatan pesanan dibatasi maksimum 3 kali per 5 menit per IP/sesi (`throttle:3,5`).
* **Verifikasi Webhook Pembayaran:**
*Callback* dari Payment Gateway wajib melewati verifikasi *HMAC Signature* sebelum sistem memperbarui status pembayaran di database.
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
3. Payment Gateway mengirim *HTTP Webhook* $\rightarrow$ Controller memverifikasi signature $\rightarrow$ Mengubah `payment_status` menjadi `PAID`.

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

* Setiap kali `payment_status` berubah menjadi `PAID`, Laravel menembakkan `OrderPaidEvent`.
* **Laravel Reverb** menyiarkan sinyal secara *real-time* ke layar Dapur (KDS) untuk memunculkan kartu pesanan baru (FIFO) beserta notifikasi suara.
* Servis pencetak (*print bridge*) otomatis mencetak struk dapur dan struk konsumen.

1. **Penyajian & Pelacakan:** Staf dapur memperbarui status pesanan dari `IN_PREPARATION` menjadi `READY`. Perubahan status terdorong otomatis ke layar browser pelanggan via WebSocket.

---

## 4. Skema Database Utama (PostgreSQL)

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
    cashier_id BIGINT REFERENCES users(id) NULLABLE,
    
    order_status VARCHAR(50) DEFAULT 'PENDING_PAYMENT', -- PENDING_PAYMENT, IN_PREPARATION, READY, COMPLETED, CANCELLED
    payment_status VARCHAR(50) DEFAULT 'UNPAID', -- UNPAID, PAID, FAILED, EXPIRED
    payment_method VARCHAR(50) NOT NULL, -- QRIS_ONLINE, CASH, DEBIT
    payment_reference VARCHAR(255) NULLABLE, -- Gateway TxID / EDC Approval Code
    
    subtotal NUMERIC(12, 2) NOT NULL,
    discount_amount NUMERIC(12, 2) DEFAULT 0,
    total_amount NUMERIC(12, 2) NOT NULL,
    cash_paid NUMERIC(12, 2) DEFAULT 0,
    cash_change NUMERIC(12, 2) DEFAULT 0,
    
    paid_at TIMESTAMP WITH TIME ZONE NULLABLE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE order_items (
    id BIGSERIAL PRIMARY KEY,
    order_id UUID REFERENCES orders(id) ON DELETE CASCADE,
    menu_id BIGINT REFERENCES menus(id),
    quantity INT NOT NULL CHECK (quantity > 0),
    price_at_time NUMERIC(12, 2) NOT NULL,
    notes TEXT NULLABLE
);

```
