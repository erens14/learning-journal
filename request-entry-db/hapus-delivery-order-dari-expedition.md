# Menghapus Delivery Order (DO) dari Ekspedisi

* **Tujuan Utama:** Melepas ikatan/relasi DO dari suatu jadwal ekspedisi karena alasan tertentu (misal: batal jalan).
* **Prinsip Dasar:** Sama seperti membatalkan DO yang mengharuskan pengembalian stok, membatalkan DO dari ekspedisi mengharuskan kita me-reset status pengambilannya agar dokumen tersebut tidak "menggantung" di sistem ekspedisi.

## Langkah-langkah Eksekusi

### Step 1: Pengecekan Data (Inspeksi Awal)

* Cari tahu **[ID Ekspedisi]** yang terkait dengan masalah ini.
* Cek tabel `expedition` dan `expedition_shipping_use_do` menggunakan **[ID Ekspedisi]** untuk memastikan kebenaran data jadwal ekspedisinya.
* Cek tabel `expedition_take_do` untuk memastikan **[ID DO]** benar-benar terikat di ekspedisi tersebut.
* Cek tabel `direct_order` menggunakan **[Nomor DO]** untuk memverifikasi data dan kuantitas awal sebelum dilakukan perubahan.

### Step 2: Lepas Relasi / Reset Status Pengambilan

* Masuk ke tabel `expedition_take_do`.
* Cari data berdasarkan **[ID DO]** yang bersangkutan.
* Ubah kolom `status` menjadi `0` (Reset status menjadi batal / belum diambil oleh ekspedisi tersebut).
* *(Note: Langkah ini secara otomatis membebaskan DO dari jadwal ekspedisi).*

### Step 3: Penyesuaian Kuantitas Riil DO (Jika Diperlukan)

* Masuk ke tabel `direct_order`.
* Cari data berdasarkan **[Nomor DO]**.
* Lakukan update kuantitas sesuai dengan barang yang benar-benar dikirim (misal jika dikirim langsung ke customer):
* Ubah `actual_qty` (Kuantitas total) menjadi angka yang sebenarnya.
* Ubah `actual_zak` (Jumlah per zak) menjadi angka yang sebenarnya.

* *(Note: Selalu gunakan blok transaksi `BEGIN;` dan `COMMIT;` di SQL saat melakukan update ini agar data tetap aman jika terjadi kesalahan).*

```sql
-- ==============================================================================
-- STEP 1: INSPEKSI DATA AWAL
-- Memeriksa seluruh riwayat pengiriman, jadwal ekspedisi, dan DO yang terikat.
-- ==============================================================================
SELECT * FROM expedition_shipping_use_do WHERE expedition_shipping_id = [id];
SELECT * FROM expedition WHERE expedition_id = [id];
SELECT * FROM expedition_take_do where expedition_id = [id];

-- ==============================================================================
-- STEP 2: LEPAS RELASI / RESET STATUS PENGAMBILAN
-- Memutus ikatan DO dari ekspedisi agar statusnya tidak menggantung.
-- ==============================================================================
BEGIN;
UPDATE expedition_take_do
SET `status` = [0] -- Reset status menjadi 0 (Batal / Belum diambil oleh ekspedisi)
WHERE direct_order_id = [id];
COMMIT;

-- ==============================================================================
-- STEP 3: INSPEKSI & PENYESUAIAN KUANTITAS RIIL DO
-- Menghitung ulang stok/qty riil dan mengembalikannya ke rekam data DO utama.
-- ==============================================================================

-- 3a. Cek data awal Direct Order sebelum diperbarui
SELECT * FROM direct_order WHERE direct_order_no = '[number]';

-- 3b. Perbarui jumlah total kuantitas (qty) dan zak yang valid ke dalam database
BEGIN;
UPDATE direct_order
SET actual_qty = [kuantitas_sisa + kuantitas_take_do_yang_dihapus] -- Akumulasi stok sisa + stok yang batal diangkut
WHERE direct_order_no = '[number]';

UPDATE direct_order
SET actual_zak = [kuantitas_sisa + kuantitas_take_do_yang_dihapus] -- Akumulasi jumlah zak sisa + zak yang batal diangkut
WHERE direct_order_no = '[number]';
COMMIT;
```
