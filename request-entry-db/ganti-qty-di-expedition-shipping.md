# Mengubah Kuantitas (Qty) pada Expedition Shipping

* **Tujuan Utama:** Menyesuaikan jumlah kuantitas (`qty`) pada pengiriman ekspedisi secara aman tanpa merusak integritas data dokumen turunannya.
* **Prinsip Dasar:** Menerapkan metode **"Bottom-to-Top Edit"** (mengedit dari level paling bawah/detail terlebih dahulu, baru kemudian memperbarui level atasnya/induk) untuk mencegah terjadinya selisih data.
* **Alur Bisnis Acuan:** `Buat DO` $\rightarrow$ `Buat Expedition` $\rightarrow$ `Buat Expedition Shipping` $\rightarrow$ `Buat use_DO / use_item`.

## Langkah-langkah Eksekusi

### Step 1: Pengecekan Data (Inspeksi Awal)

* Cari tahu **[ID Ekspedisi]** dan **[ID Expedition Shipping]** yang akan disesuaikan kuantitasnya.
* Periksa apakah `expedition_shipping` tersebut memiliki dokumen turunan berupa `use_item` atau `use_do`.

### Step 2: Validasi Alur Dokumen (Kondisional)

* **Kondisi A (Jika memiliki `use_item`):**
* Kuantitas pada tabel detail (`use_item`) harus diubah terlebih dahulu sebelum mengubah kuantitas induk (`expedition_shipping`).

* **Kondisi B (Jika memiliki `use_do`):**
* Pastikan kembali input kuantitas pada DO asli sudah benar dengan melakukan konfirmasi ulang kepada *user*. Jika sudah dipastikan benar, lakukan logika perubahan yang sama seperti pada `use_item` (ubah kuantitas detailnya terlebih dahulu).

### Step 3: Pembaruan Data (Bottom-to-Top Edit)

* Eksekusi perubahan kuantitas secara berurutan mulai dari tabel detail terbawah menuju tabel induk di atasnya menggunakan blok transaksi SQL yang aman.

```sql
-- ==============================================================================
-- STEP 1: INSPEKSI DAN PENGECEKAN KETERGANTUNGAN DATA
-- Memeriksa data induk ekspedisi, data pengiriman, serta detail item terkait.
-- ==============================================================================
SELECT * FROM expedition WHERE expedition_id = [id];
SELECT * FROM expedition_shipping WHERE expedition_shipping_id = [id];
SELECT * FROM expedition_shipping_use_item WHERE expedition_shipping_id = [id];

-- ==============================================================================
-- STEP 2 & 3: EKSEKUSI PERUBAHAN DENGAN METODE BOTTOM-TO-TOP
-- Memperbarui kuantitas secara berurutan dari level detail (bawah) ke level induk (atas).
-- ==============================================================================
BEGIN;

-- 1. Ubah kuantitas di level detail terlebih dahulu (Bottom)
-- Pastikan ini perlu diganti juga oleh user (di web -> qty_shipped)
UPDATE expedition_shipping_use_item
SET qty = [kuantitas_baru]
WHERE expedition_shipping_id = [id];

-- 2. Ubah kuantitas di level induk setelah detailnya selesai (Top)
UPDATE expedition_shipping
SET qty = [kuantitas_baru]
WHERE expedition_shipping_id = [id];

COMMIT;
```
