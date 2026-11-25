# Aturan Development Workflow
 
Dokumen ini menjelaskan alur pengembangan fitur, lingkungan pengembangan, strategi pengujian, dan alur rilis untuk **Society Zero**.
 
Dokumen ini ditujukan untuk tiga jenis pelaku: **developer sendiri**, **AI agent** (mis. Claude Code atau asisten lain), dan **kontributor komunitas**. Aturannya sama untuk semuanya. Bagian 5 menambahkan panduan khusus bagi agent dan kontributor baru.
 
Dokumen terkait: `committing.md` (format commit dan PR), `README.md` (gambaran proyek), `docs/sprint-plan.md` (rencana sprint), `docs/DESIGN.md` (keputusan desain dan ADR).
 
---
 
## 1. Alur Kerja Pengembangan Fitur (Feature Workflow)
 
Setiap pekerjaan bermula dari **tiket** (`SZ-xxx`) yang memenuhi *Definition of Ready* di sprint plan.
 
1. **Sinkronisasi kode**
```bash
git checkout main
git pull origin main
```
2. **Buat branch kerja** (pola penamaan sesuai `committing.md`)
```bash
git checkout -b feature/SZ-204-action-lifecycle
```
3. **Tulis tes dulu** (wajib untuk kode di `sim/`): buat tes GUT yang menggambarkan perilaku yang diharapkan, pastikan gagal, lalu implementasikan sampai lulus.
4. **Pengembangan dan iterasi lokal**
   * Buka proyek di Godot 4.7.x (versi yang dipin), atau jalankan dari command line:
```bash
godot --path .
```
   * Untuk logika simulasi, utamakan menguji **headless** (tanpa tampilan) karena lebih cepat dan bisa diulang:
```bash
godot --headless -s tools/run_sim.gd -- --seed 42 --ticks 1000
```
   (runner tersedia mulai Sprint 1)
5. **Verifikasi lokal sebelum commit** (lihat bagian 3 untuk detail):
```bash
gdformat sim view autoload tests tools
gdlint sim view autoload tests tools
godot --headless --import
godot --headless -s addons/gut/gut_cmdln.gd
```
6. **Commit dan push**
   * Commit atomik dengan format Conventional Commits (`committing.md`).
   * Sinkronkan dengan `main` sebelum minta review:
```bash
git fetch origin
git rebase origin/main
```
   * Push dan buka Pull Request kecil (idealnya di bawah sekitar 400 baris diff).
7. **Review dan merge**: CI hijau, minimal 1 approval, squash merge. Hapus branch setelah merge.
### Alur khusus: memperbaiki bug
 
1. Reproduksi dengan **seed dan tick** yang dilaporkan.
2. Tulis tes regresi yang gagal.
3. Perbaiki, pastikan tes hijau dan tidak ada tes lain yang pecah.
4. Commit dengan `fix(<scope>)` dan cantumkan seed/tick di body.
### Alur khusus: mengubah perilaku atau tuning
 
1. Tulis target dan ambang **sebelum** melihat hasil.
2. Ubah **satu parameter per percobaan**.
3. Jalankan sweep seed yang sama dan catat hasil di `docs/tuning-log.md`.
4. Commit perubahan parameter dan pembaruan golden hash secara terpisah (lihat `committing.md` bagian 5).
---
 
## 2. Pengelolaan Environment & Dependensi
 
1. **Versi tool dipin dan harus sama di semua mesin dan CI:**
   * Godot **4.7.x** (patch tepatnya ditulis di `GODOT_VERSION` pada `.github/workflows/ci.yml` dan di `README.md`).
   * GUT **9.7.x** (rilis `9.7.1`), di-commit di `addons/gut/`.
   * `gdtoolkit` 4.x untuk lint dan format.
   * Memakai versi berbeda dapat menghasilkan hasil tes atau hash determinism yang berbeda dari CI.
2. **Rahasia dan konfigurasi lokal:**
   * Jangan pernah meng-commit API key, token, atau file `.env`.
   * Saat integrasi LLM ditambahkan di tahap mendatang, key dibaca dari environment atau file konfigurasi lokal di luar repo. Jika memakai file contoh, daftarkan nama variabelnya di `.env.example` (tanpa nilai).
3. **File yang dihasilkan Godot:**
   * Jangan commit folder `.godot/`, hasil export, atau log di `user://`.
   * File `.import` dan `.uid` yang dibuat Godot di samping aset/skrip **ikut di-commit**.
   * Jangan menyunting file di `.godot/` secara manual.
4. **Manajemen dependensi (addon dan tool):**
   * Menambah atau menaikkan versi addon (termasuk GUT) dilakukan dalam PR tersendiri bertipe `chore(deps)`, dengan catatan kompatibilitas versi Godot.
   * Jangan menyalin addon dari sumber tidak jelas. Catat sumber dan lisensinya.
   * Aset (gambar, tileset, suara) harus mencatat sumber dan lisensi (utamakan CC0).
5. **`project.godot` dan scene sering konflik.** Ubah seperlunya, jangan merapikan file ini tanpa alasan. Jika editor Godot mengubah banyak baris sekaligus, periksa apakah perubahan itu memang disengaja.
---
## 3. Strategi Pengujian (Testing Strategy)
 
1. **Automated testing (GUT)**
   * Setiap sistem di `sim/` wajib punya tes. Tes berada di `tests/`.
   * Jalankan seluruh tes:
```bash
godot --headless --import
godot --headless -s addons/gut/gut_cmdln.gd
```
   * Menjalankan satu file atau satu tes (periksa dokumentasi GUT untuk versi yang dipakai jika opsi berubah):
```bash
godot --headless -s addons/gut/gut_cmdln.gd -gtest=res://tests/test_needs_system.gd
godot --headless -s addons/gut/gut_cmdln.gd -gtest=res://tests/test_needs_system.gd -gunit_test_name=test_hunger_decay
```
   * Hati-hati dengan *doubles* dan stub di GUT 9.7: Godot 4.7 mengembalikan nilai default sesuai tipe, bukan `null`.
2. **Lapisan tes dan kapan dijalankan**
   | Lapisan | Yang diuji | Kapan |
   |---|---|---|
   | Unit | Fungsi kecil (kurva, rumus, validator) | Setiap PR |
   | Sistem | Satu sistem dengan state buatan | Setiap PR |
   | Skenario | Situasi lengkap dengan agent scripted | Setiap PR |
   | Invariant | Aturan yang tidak boleh dilanggar | Setiap PR (seed sedikit), nightly (seed banyak) |
   | Determinism | Seed sama menghasilkan hash sama | Setiap PR |
   | Golden replay | Hash seed tertentu dibekukan | Setiap PR |
   | Metrik perilaku (sweep seed) | Survival, pergantian aksi, pembagian waktu | Akhir Sprint 3 dan 4, lalu nightly |
   | Performa (smoke) | Waktu tick tidak meledak | Sprint 4, lalu nightly |
   | Playtest manual | Tampilan, kontrol, inspector | Review tiap sprint |
3. **Invariant yang dicek tiap tick dalam mode tes**
   * Tidak ada nilai negatif pada inventori dan stok.
   * Need selalu di rentang 0-100.
   * Setiap agent hidup berada di tepat satu tile yang walkable.
   * Konservasi makanan: produksi dikurangi konsumsi sama dengan perubahan stok.
   * Agent mati tidak diproses lagi dan tidak punya aksi berjalan.
   * Setiap `agent_died` memiliki sebab tercatat.
4. **Aturan arsitektur yang diperiksa otomatis**
   * Tidak ada `extends Node` di `sim/`.
   * Tidak ada `randf()`, `randi()`, `randf_range()`, `randi_range()` global di `sim/`.
5. **Manual testing dan edge case**
   * Jalankan seed yang sama dua kali dan bandingkan hash; jalankan seed berbeda dan pastikan hasil berbeda.
   * Biarkan stok lumbung habis dan verifikasi kelaparan dan kematian tercatat dengan sebab.
   * Bandingkan isi agent inspector dengan event log untuk satu keputusan.
   * Uji kecepatan waktu (pause, 1x sampai 8x) tanpa error atau macet.
   * Pastikan view tidak mengubah state (hasil sama dengan atau tanpa tampilan).
---
 
## 4. Persiapan Rilis (Release)
 
Society Zero tidak memiliki server atau lingkungan deploy. "Rilis" berarti **tag versi di `main`** disertai catatan rilis. Build yang dapat dijalankan (export Godot) bersifat opsional dan akan diputuskan kemudian.
 
Sebelum membuat tag rilis (mis. `v0.1.0`):
 
1. **Pastikan `main` hijau**: semua job CI (lint dan tes) lulus.
2. **Jalankan checklist penerimaan** untuk versi tersebut (lihat `docs/sprint-plan.md` dan `README.md`).
3. **Jalankan sweep seed** dan catat hasil metrik utama.
4. **Pastikan golden replay dan tes determinism lulus** di CI (Linux).
5. **Perbarui dokumentasi**: `README.md`, `docs/DESIGN.md`, catatan batasan yang diketahui.
6. **Tulis catatan rilis**: fitur, batasan, cara mereproduksi eksperimen (seed dan konfigurasi).
7. **Buat tag** dari `main`:
```bash
git checkout main
git pull origin main
git tag -a v0.1.0 -m "v0.1.0: Hidup di Desa"
git push origin v0.1.0
```
 
Jika kelak ada build/export: lakukan di job CI terpisah, jangan commit hasil build ke repo.
 
---
 
## 5. Panduan untuk AI Agent dan Kontributor
 
### 5.1 Sebelum mulai bekerja
* Baca `README.md`, dokumen ini, `committing.md`, dan `docs/DESIGN.md`.
* Pastikan tiket jelas: tujuan, kriteria selesai, area yang disentuh. Jika tidak jelas, tanyakan, jangan menebak.
* Periksa versi Godot dan GUT yang dipin sebelum menjalankan apa pun.
### 5.2 Aturan wajib
1. **Jangan mengubah kontrak data** (`AgentState`, `WorldState`, skema Event) tanpa ADR yang disetujui maintainer.
2. **Jangan mengubah golden hash** tanpa alasan tertulis di commit (lihat `committing.md` bagian 5).
3. **Jangan menyentuh `sim/` dengan `Node`, scene, atau RNG global.** Kode simulasi harus deterministik dan bisa dites headless.
4. **View tidak menulis ke state.** Input dari UI masuk lewat command ke `Simulation`.
5. **Satu tiket, satu PR kecil.** Jangan memperluas scope atau merapikan kode yang tidak terkait.
6. **Tulis tes untuk setiap perubahan perilaku**, dan tes regresi untuk setiap bug.
7. **Jangan mengarang versi, API, atau perintah.** Jika tidak yakin dengan perilaku Godot/GUT di versi yang dipin, periksa dokumentasi resmi atau jalankan percobaan kecil.
8. **Jangan menyunting hasil keluaran supaya tes hijau** (mengubah ambang, melonggarkan invariant, atau mematikan tes) tanpa alasan yang ditulis di PR dan disetujui reviewer.
9. **Jangan commit rahasia** atau file hasil run lokal.
### 5.3 Definisi "selesai" untuk sebuah tiket
- [ ] Kriteria selesai tiket terpenuhi.
- [ ] Tes baru lulus dan seluruh tes lama tetap lulus (perintah di bagian 1 langkah 5 dijalankan sungguh-sungguh, bukan diasumsikan).
- [ ] Lint dan format lulus.
- [ ] Dampak ke hasil simulasi dijelaskan di PR (tidak ada, atau ada beserta alasannya).
- [ ] Dokumentasi/ADR diperbarui bila perlu.
- [ ] PR berjudul sesuai Conventional Commits dan merujuk tiket (`Refs: SZ-xxx`).
### 5.4 Laporan bug yang baik
```text
Seed:
Versi/commit:
Versi Godot:
Konfigurasi dunia:
Tick terjadi:
Yang diharapkan:
Yang terjadi:
Potongan event log:
```
 
### 5.5 Tiket yang cocok untuk kontributor baru
Menambah tes unit, menulis dokumentasi sistem, menambah tile/aset (tanpa mengubah logika sim), memperbaiki HUD, menambah skenario tes dari template. Cari label `good-first-issue` dan `help-wanted`.
 
---
 
## 6. Troubleshooting Cepat
 
| Masalah | Langkah |
|---|---|
| `class_name` tidak dikenali saat tes headless | Jalankan `godot --headless --import` terlebih dahulu |
| Tes lulus lokal tapi gagal di CI | Samakan versi Godot dan GUT dengan CI; cek perbedaan platform |
| Hash determinism berbeda antar run | Cari iterasi `Dictionary` tanpa urutan, RNG global, atau float yang dibandingkan dengan `==` |
| Hash berubah setelah `refactor`/`perf` | Itu bug; jangan perbarui golden hash |
| Agent berganti aksi bolak-balik | Periksa commitment bonus dan survival interrupt di `UtilityBrain` |
| Lint gagal mem-parse file yang valid di Godot | Kemungkinan gdtoolkit belum mendukung sintaks tersebut; laporkan dan catat di `docs/` |
 
