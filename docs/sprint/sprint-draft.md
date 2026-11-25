
# Society Zero: Sprint Plan v0.1 ("Hidup di Desa")
 
Dokumen ini turunan dari `society-zero-week1-2-structure.md`. Isinya: pembagian sprint, tujuan tiap sprint, kriteria selesai (DoD), alur development, dan strategi testing yang menempel ke target tiap sprint. Ditulis supaya bisa dipakai tim (kontributor komunitas), bukan cuma satu orang.
 
---
 
## 1. Target Release v0.1
 
**Nama:** Hidup di Desa
**Pernyataan sukses:** 3-5 NPC hidup sendiri di peta kecil (lapar, capek, kerja, makan, tidur), semua keputusan bisa ditelusuri, dan hasil **identik untuk seed yang sama**.
 
Sumber kebenaran target ini adalah checklist penerimaan di dokumen struktur. Tiap sprint di bawah menurunkan sebagian checklist itu menjadi tes yang bisa dijalankan.
 
### Di luar scope v0.1
LLM, dialog, relasi sosial, memori kompleks, trade, kelompok, governance, save/load, UI mewah.
 
---
 
## 2. Catatan Realistis (baca dulu)
 
1. **Estimasi waktu.** Dokumen sebelumnya menulis 2 minggu. Itu asumsi fokus penuh. Dengan pekerjaan harian dan kontributor sukarela yang tidak selalu ada, rencanakan **sekitar 4,5 minggu**: Sprint 0 (3 hari) + Sprint 1-4 (1 minggu masing-masing). Jika ternyata lebih cepat, bagus. Jangan menjadikan 2 minggu sebagai janji ke orang lain.
2. **Jalur kritis dipegang satu orang dulu.** Sampai kontrak data (Sprint 0) dan inti sim (Sprint 1) stabil, sebaiknya satu-dua orang saja yang mengubah `sim/core`. Kalau 10 orang memodifikasi `AgentState` bersamaan di minggu pertama, hasilnya konflik, bukan kecepatan.
3. **Kontributor sukarela itu tidak terjadwal.** Karena itu tugas harus kecil, mandiri, dan jelas kriteria selesainya. Tiket yang butuh konteks seluruh proyek tidak cocok untuk mereka.
4. **Paralelisasi baru aman setelah kontrak dibekukan.** Setelah Sprint 0 selesai, track view/aset/dokumentasi bisa jalan paralel dengan track sim (lihat bagian 9).
5. **Soal over-engineering:** untuk proyek yang tujuannya memahami konsep dan terbuka untuk banyak kontributor, sedikit abstraksi di awal masuk akal. Karena itu rencana ini memakai aksi berbasis data (`Resource`), utility berbasis consideration, dan command queue untuk input dari luar. Tetap hindari ECS penuh atau event bus raksasa sebelum ada kebutuhan nyata.
---
 
## 3. Keputusan yang Harus Diambil di Sprint 0
 
| Keputusan | Default yang disarankan | Catatan |
|---|---|---|
| Versi Godot | Pin satu versi 4.3+ | Semua orang dan CI harus pakai versi sama |
| Framework tes | GUT | Cek dokumentasi GUT yang cocok dengan versi Godot |
| Lint/format | `gdtoolkit` (`gdlint`, `gdformat`) | Pasang di CI |
| Hosting dan board | GitHub + GitHub Projects | Cukup untuk issue, PR, board |
| Lisensi kode | Pilih sebelum menerima kontribusi pertama | MIT atau Apache-2.0 umum dipakai; konsultasikan jika ragu |
| Lisensi aset | Catat sumber dan lisensi tiap aset | Aset CC0 paling aman |
| Model branching | Trunk-based, branch pendek | `main` selalu hijau |
 
---
 
## 4. Alur Development
 
### 4.1 Siklus sprint (asinkron, ramah komunitas)
 
| Kegiatan | Kapan | Durasi | Hasil |
|---|---|---|---|
| Sprint planning | Awal sprint | 30-60 menit | Tiket terpilih, DoR terpenuhi, target sprint ditulis |
| Update harian | Harian, tertulis di chat | 2 menit | Kemarin / hari ini / hambatan |
| Review dan demo | Akhir sprint | 30 menit atau rekaman | Demo sesuai skrip demo sprint |
| Retro | Setelah review | 30 menit | 3 hal baik, 3 masalah, 1-2 aksi perbaikan |
 
### 4.2 Alur satu tiket
 
```
Issue (memenuhi DoR)
   -> branch  feat/SZ-xxx-slug
   -> tulis tes dulu (untuk kode sim: wajib)
   -> implementasi
   -> jalankan lint + tes lokal
   -> PR kecil (usahakan < 400 baris diff)
   -> CI: lint + format check + tes unit + tes determinism
   -> review (min. 1 approver sesuai CODEOWNERS)
   -> squash merge ke main
   -> tiket pindah ke Done (memenuhi DoD)
```
 
### 4.3 Alur bug
 
Bug di simulasi ini bisa direproduksi persis karena ada seed. Format laporan wajib:
 
```
Seed:
Versi/commit:
Konfigurasi dunia:
Tick terjadi:
Yang diharapkan:
Yang terjadi:
Potongan event log:
```
 
Langkah perbaikan: reproduksi dengan seed dan tick -> tulis tes regresi yang gagal -> perbaiki -> tes hijau -> merge. **Tidak ada bug fix tanpa tes regresi.**
 
### 4.4 Definition of Ready (tiket boleh masuk sprint jika)
 
- Ada tujuan satu kalimat dan kriteria selesai yang bisa diuji.
- Ada daftar file/area yang disentuh.
- Ada ketergantungan yang jelas (tiket lain yang harus selesai dulu).
- Estimasi ukuran: S (< 0,5 hari), M (0,5-1,5 hari), L (> 1,5 hari; sebaiknya dipecah).
### 4.5 Definition of Done (tiket dianggap selesai jika)
 
- [ ] Kriteria selesai tiket terpenuhi.
- [ ] Tes baru ditulis dan lulus; semua tes lama tetap lulus.
- [ ] Lint dan format lulus.
- [ ] Tidak ada `extends Node` atau referensi scene di `sim/`.
- [ ] Tidak ada `randf()`/`randi()` global di `sim/`.
- [ ] Dokumentasi diperbarui (komentar kontrak, `DESIGN.md`, atau ADR jika ada keputusan baru).
- [ ] PR direview dan di-merge.
---
 
## 5. Strategi Testing
 
### 5.1 Lapisan tes
 
| Lapisan | Apa yang diuji | Alat | Dijalankan di |
|---|---|---|---|
| **Unit** | Fungsi/kelas kecil: kurva, rumus decay, validator | GUT | Setiap PR |
| **Sistem** | Satu sistem dengan state buatan: `NeedsSystem`, `ActionSystem` | GUT | Setiap PR |
| **Skenario** | Situasi lengkap dengan agent scripted: "lapar, ada lumbung, harus makan" | GUT + harness headless | Setiap PR |
| **Invariant** | Aturan yang tidak boleh dilanggar kapan pun | GUT, dijalankan lintas banyak seed | Setiap PR (seed sedikit), nightly (seed banyak) |
| **Determinism** | Seed sama -> hash state sama | Skrip headless | Setiap PR |
| **Golden replay** | Hash state seed tertentu di tick tertentu dibekukan | Skrip headless | Setiap PR; ubah golden hanya dengan alasan tertulis |
| **Behavior/metrik** | Distribusi perilaku agregat (survival, switch aksi, pembagian waktu) | Kolektor metrik + skrip sweep seed | Akhir Sprint 3 dan 4, lalu nightly |
| **Performa (smoke)** | Waktu tick tidak meledak | Skrip headless | Sprint 4, lalu nightly |
| **Manual playtest** | Pengalaman menonton, inspector, kontrol | Checklist manual | Review tiap sprint |
 
### 5.2 Invariant yang wajib ada
 
Cek setelah setiap tick dalam mode tes:
 
1. Tidak ada nilai negatif pada inventori atau stok lumbung.
2. Need selalu di rentang 0-100.
3. Setiap agent hidup berada tepat di satu tile yang walkable.
4. **Konservasi makanan:** total makanan yang diproduksi dikurangi yang dikonsumsi sama dengan perubahan stok (lumbung + inventori agent).
5. Agent mati tidak punya `current_action` dan tidak diproses lagi.
6. Setiap aksi yang berjalan lolos validator saat mulai.
7. Setiap `agent_died` memiliki sebab tercatat di event log.
### 5.3 Fuzz dengan agent acak
 
Agent memilih aksi acak (dari RNG ber-seed) selama ribuan tick di banyak seed. Tujuannya bukan perilaku bagus, melainkan membuktikan engine tidak bisa dirusak oleh aksi aneh. Kalau invariant bisa dilanggar, itu bug di engine/validator.
 
### 5.4 Cara menetapkan ambang metrik
 
Angka target perilaku (mis. persentase survival) di bawah ini adalah **angka awal yang ditetapkan saat sprint planning**, bukan kebenaran. Aturannya: tuliskan target sebelum melihat hasil, ukur, lalu jika perlu ubah target atau parameter **dengan alasan tertulis** di `DESIGN.md`. Jangan mengubah ambang diam-diam supaya tes hijau.
 
### 5.5 Protokol tuning
 
1. Ubah **satu** parameter per percobaan.
2. Jalankan sweep seed yang sama (mis. seed 1-20).
3. Catat parameter, hasil metrik, dan kesimpulan di `docs/tuning-log.md`.
4. Lanjut hanya jika hasil dipahami, bukan sekadar membaik.
---
 
## 6. Rencana Sprint
 
Ringkasan:
 
| Sprint | Nama | Durasi | Tujuan satu kalimat |
|---|---|---|---|
| 0 | Fondasi dan Kontrak | 3 hari | Repo siap dikontribusi, kontrak data dibekukan |
| 1 | Inti Simulasi Headless | 1 minggu | Dunia berdetak, state berubah, tercatat, deterministik |
| 2 | Aksi, Validasi, Gerak | 1 minggu | Agent menjalankan aksi valid; engine menolak yang tidak valid |
| 3 | Utility AI dan Explainability | 1 minggu | Agent memilih aksi sendiri, bisa dijelaskan, kepribadian terlihat |
| 4 | View, Kontrol, Hardening, Rilis | 1 minggu | Bisa ditonton dan diperiksa manusia; rilis v0.1.0 |
 
---
 
### Sprint 0: Fondasi dan Kontrak (3 hari)
 
**Tujuan:** siapa pun bisa meng-clone repo, menjalankan tes, dan memahami aturan main. Kontrak data v0 dibekukan sehingga track lain bisa mulai.
 
| ID | Tiket | Ukuran |
|---|---|---|
| SZ-001 | Buat repo, struktur folder, `.gitignore` Godot, LICENSE | S |
| SZ-002 | CI: gdlint, gdformat --check, GUT headless | M |
| SZ-003 | `CONTRIBUTING.md`, template PR dan issue, CODEOWNERS, label | S |
| SZ-004 | `DESIGN.md` dan ADR-001 sampai 004 (tick-based, pemisahan sim/view, satu RNG, validator) | M |
| SZ-005 | Kontrak data v0: stub `AgentState`, `WorldState`, `ActionDef`, skema Event (dengan komentar semantik tiap field) | M |
| SZ-006 | Proyek Godot kosong: scene peta statis + kamera pan/zoom | S |
| SZ-007 | Satu tes "hello" jalan di CI | S |
 
**Alur kerja:** SZ-001 -> SZ-002 dan SZ-007 -> SZ-003; SZ-004 dan SZ-005 paralel; SZ-006 independen.
 
**Definisi selesai sprint:**
- [ ] Orang yang belum pernah menyentuh proyek (uji dengan satu teman komunitas) bisa clone, install Godot versi yang dipin, dan menjalankan tes sampai hijau mengikuti README saja.
- [ ] CI hijau di PR dummy dan merah di PR yang sengaja merusak lint/tes.
- [ ] Kontrak data direview minimal satu orang selain penulis, lalu ditag `contracts-v0`.
- [ ] Konvensi need (100 = terpenuhi) dan satuan waktu (1 tick = 10 menit simulasi) tertulis.
**Testing sprint ini:** verifikasi CI (merah/hijau yang disengaja) dan uji "fresh clone". Belum ada tes perilaku.
 
**Demo:** tunjukkan PR yang gagal CI karena lint, lalu diperbaiki hingga hijau; tunjukkan kamera di peta.
 
**Risiko:** perdebatan gaya kode yang menyita waktu. Mitigasi: serahkan ke `gdformat`, jangan diskusikan manual.
 
---
 
### Sprint 1: Inti Simulasi Headless (1 minggu)
 
**Tujuan:** dunia berdetak tanpa tampilan. State berubah sesuai aturan, kejadian penting tercatat, dan hasil deterministik.
 
| ID | Tiket | Ukuran |
|---|---|---|
| SZ-101 | `SimConst` dan `SimClock` (tick, pause, speed, batas tick per frame) | S |
| SZ-102 | `Simulation.step()` dengan satu RNG ber-seed dan urutan agent terurut | M |
| SZ-103 | Implementasi `WorldState` dan `AgentState`, serialisasi ke Dictionary, fungsi hash state | M |
| SZ-104 | `GridData` dan loader `default_world.json` (peta, lokasi, jumlah agent, seed) | M |
| SZ-105 | `NeedsSystem` (decay lapar/energi, health, starvation) | M |
| SZ-106 | `EventLog` ke `.jsonl` dengan validasi skema | M |
| SZ-107 | `WorldSystem` (siang/malam) | S |
| SZ-108 | Runner CLI headless: `seed`, `jumlah tick`, cetak hash dan ringkasan | S |
| SZ-109 | Tes determinism v1 dan invariant checker v1 (nilai negatif, rentang need) | M |
 
**Alur kerja:** SZ-103 dan SZ-104 dulu -> SZ-102 -> SZ-105, SZ-107 -> SZ-106 -> SZ-108 -> SZ-109.
 
**Definisi selesai sprint:**
- [ ] `run --seed 42 --ticks 1000` berjalan tanpa error dan mencetak hash.
- [ ] Dua kali run seed sama -> hash identik; seed beda -> hash berbeda.
- [ ] Unit test `NeedsSystem` membuktikan laju decay sesuai rumus untuk beberapa kasus (termasuk batas 0 dan 100).
- [ ] Agent tanpa makan akhirnya `need_critical`, lalu starvation, lalu `agent_died` di log (dengan agent yang tidak bertindak).
- [ ] Event log valid terhadap skema; file tidak berisi log per tick.
- [ ] Cakupan: setiap sistem punya minimal satu tes sistem; tidak ada `randf()` global di `sim/` (diperiksa otomatis dengan grep di CI).
**Testing sprint ini:**
- Unit + sistem untuk needs dan clock.
- Determinism test jadi bagian CI.
- Invariant checker aktif dalam mode tes.
**Demo:** jalankan runner dua kali dengan seed sama dan tunjukkan hash identik; tunjukkan log kematian agent yang dibiarkan pasif.
 
**Risiko:** serialisasi/hash tidak stabil karena iterasi Dictionary. Mitigasi: serialisasi selalu dengan kunci terurut.
 
---
 
### Sprint 2: Aksi, Validasi, Gerak (1 minggu)
 
**Tujuan:** agent dapat melakukan aksi yang valid di dunia, dan engine selalu menolak aksi yang tidak valid dengan alasan yang jelas. Belum ada AI pemilih aksi; aksi diberikan oleh tes/skrip.
 
| ID | Tiket | Ukuran |
|---|---|---|
| SZ-201 | `ActionDef` (Resource) dan `ActionLibrary`: idle, move, eat, sleep, work_farm | M |
| SZ-202 | `ActionValidator` dengan alasan penolakan terstruktur (kode alasan, bukan string bebas) | M |
| SZ-203 | Pembangun `AStarGrid2D` dari `GridData` dan `MovementSystem` | M |
| SZ-204 | `ActionSystem`: siklus hidup aksi (start, progress, complete, fail, interrupt) | L (pecah jika perlu) |
| SZ-205 | Efek aksi dan produksi lumbung (food dihitung lewat satu jalur kode) | M |
| SZ-206 | Harness agent scripted: tes dapat memberi urutan aksi ke agent | M |
| SZ-207 | Kematian karena kelaparan dan pembersihan state agent mati | S |
| SZ-208 | Invariant checker v2 (konservasi makanan, satu tile per agent, aksi lolos validator) | M |
| SZ-209 | Fuzz test: agent aksi acak, banyak seed, 2000 tick | M |
 
**Alur kerja:** SZ-201 -> SZ-202 dan SZ-203 paralel -> SZ-204 -> SZ-205, SZ-207 -> SZ-206 -> SZ-208 -> SZ-209.
 
**Definisi selesai sprint:**
- [ ] Skenario scripted lulus: agent berjalan ke ladang, bekerja, makanan masuk lumbung, agent berjalan ke lumbung, makan, hunger naik.
- [ ] Aksi tidak valid ditolak dengan kode alasan (mis. `NOT_AT_LOCATION`, `NO_STOCK`, `LOW_ENERGY`, `NO_PATH`) dan tidak mengubah state.
- [ ] Fuzz: seed yang ditentukan di CI (mis. 20 seed x 2000 tick) tidak melanggar satu pun invariant. Sweep lebih besar dijalankan nightly.
- [ ] Interrupt bekerja: aksi yang `interruptible` bisa dibatalkan tanpa merusak state.
- [ ] Semua perubahan makanan terjadi lewat satu fungsi (supaya konservasi bisa diaudit).
**Testing sprint ini:**
- Skenario (jalur sukses dan jalur gagal) per aksi.
- Invariant + fuzz sebagai jaring pengaman utama.
- Tes pathfinding: jalur ada, tidak ada, terhalang.
**Demo:** skrip skenario berjalan di headless dan mencetak event log berurutan; tunjukkan satu aksi ditolak beserta alasannya.
 
**Risiko:** `ActionSystem` membengkak. Mitigasi: wajib pecah tiket SZ-204 menjadi sub-tiket (lifecycle, interrupt, efek) bila melewati 1,5 hari.
 
---
 
### Sprint 3: Utility AI dan Explainability (1 minggu)
 
**Tujuan:** agent memilih aksi sendiri dari kondisi internalnya, keputusan bisa dijelaskan, dan kepribadian terbukti memengaruhi perilaku.
 
|---|---|---|
| SZ-301 | `Curves` dan antarmuka consideration (kurva urgensi, jarak, waktu) | M |
| SZ-302 | `UtilityBrain.choose()` dengan keluaran `best` dan `trace` | M |
| SZ-303 | Commitment bonus dan survival interrupt | M |
| SZ-304 | Bobot kepribadian (conscientiousness, risk tolerance) | M |
| SZ-305 | `decision_trace` masuk ke event log | S |
| SZ-306 | Tes skenario perilaku: lapar, malam, stok habis, ladang jauh | M |
| SZ-307 | Kolektor metrik perilaku (switch aksi per hari, persentase waktu per aksi, survival) | M |
| SZ-308 | Skrip sweep seed dan laporan ringkas | S |
| SZ-309 | Tuning pass 1 dan `docs/tuning-log.md` | M |
 
**Alur kerja:** SZ-301 -> SZ-302 -> SZ-303, SZ-304 -> SZ-305 -> SZ-306 -> SZ-307 -> SZ-308 -> SZ-309.
- [x] Skenario: malam hari dan energi rendah menaikkan skor `sleep` di atas `work_farm`.
- [x] Skenario: stok habis -> `eat` tidak valid -> agent bekerja di ladang atau akhirnya kelaparan dengan sebab tercatat.
- [x] Sweep: pada kondisi dunia "normal" (ditentukan di config), sebagian besar agent bertahan 5 hari simulasi. Contoh target awal: >= 90% survival dari 20 seed x 3 agent (aktual: 100%).
- [x] Ping-pong: rata-rata pergantian aksi per hari di bawah ambang yang ditetapkan (aktual: 15.5 per hari simulasi).
- [x] Kepribadian: dua agent dengan conscientiousness berbeda jauh menunjukkan perbedaan persentase waktu `work_farm` yang konsisten di sweep (terbukti di test_personality_impacts_work_decision).
- [x] Setiap keputusan di log punya `decision_trace` minimal 3 kandidat.
- [x] Hasil tuning pass 1 tercatat: parameter yang diubah, alasan, hasil (di docs/tuning-log.md).
**Testing sprint ini:**
- Skenario perilaku deterministik (satu keputusan, satu hasil).
- Sweep seed untuk metrik agregat.
- Golden replay pertama dibuat di akhir sprint (seed tetap, 1000 tick) setelah perilaku cukup stabil.
**Demo:** tampilkan event log dengan `decision_trace` untuk satu agent sepanjang hari, jelaskan kenapa ia berganti aksi; bandingkan dua agent berkepribadian berbeda dari data sweep.
 
**Risiko terbesar proyek:** tuning memakan waktu tak terbatas. Mitigasi: time-box tuning maksimal 2 hari; sisanya dicatat sebagai backlog.
 
---
 
### Sprint 4: View, Kontrol, Hardening, Rilis (1 minggu)
 
**Tujuan:** simulasi bisa ditonton dan diperiksa manusia, sistem teruji ketahanan dan performanya, dan v0.1.0 dirilis.
 
| ID | Tiket | Ukuran |
|---|---|---|
| SZ-401 | `world_view`: `TileMapLayer` dari `GridData` | M |
| SZ-402 | `AgentView` dengan interpolasi gerak (tween) | M |
| SZ-403 | Kontrol waktu: pause, 1x, 2x, 4x, 8x | S |
| SZ-404 | HUD: jam, hari, populasi, stok lumbung | S |
| SZ-405 | Agent inspector: need, aksi, inventori, 3 skor teratas | M |
| SZ-406 | Command queue untuk input debug (tambah makanan) yang masuk lewat `Simulation` | M |
| SZ-407 | Tes "view tidak mengubah state": run dengan dan tanpa view, hash sama | M |
| SZ-408 | Perf smoke test (headless dan dengan view) | M |
| SZ-409 | Golden replay final dan sweep nightly | S |
| SZ-410 | README, GIF/video demo, `DESIGN.md` final, catatan rilis | M |
| SZ-411 | Retro, tag `v0.1.0` | S |
 
**Alur kerja:** SZ-401 -> SZ-402 -> SZ-403, SZ-404, SZ-405 paralel -> SZ-406 -> SZ-407 -> SZ-408 -> SZ-409 -> SZ-410 -> SZ-411.
 
**Definisi selesai sprint:**
- [ ] Checklist playtest manual (di bawah) lulus.
- [ ] SZ-407: hash state akhir identik dengan dan tanpa view untuk seed yang sama.
- [ ] Inspector menampilkan alasan keputusan terakhir yang sama dengan isi event log.
- [ ] Perf smoke: waktu `step()` untuk jumlah agent target dicatat sebagai baseline. Tetapkan ambang awal berdasarkan pengukuran (mis. headless 10.000 tick untuk 20 agent selesai dalam batas yang disepakati), lalu jadikan regresi perf sebagai peringatan.
- [ ] Semua checklist penerimaan di dokumen struktur centang.
- [ ] README memungkinkan orang baru menjalankan demo dalam kurang dari 15 menit.
- [ ] Tag `v0.1.0` dan catatan rilis memuat: fitur, batasan yang diketahui, cara reproduksi eksperimen (seed).
**Checklist playtest manual (10 langkah):**
1. Jalankan game; peta dan semua agent muncul.
2. Pause dan lanjutkan; sim benar-benar berhenti dan lanjut.
3. Naikkan ke 8x; tidak ada macet atau lonjakan error.
4. Klik satu agent; inspector terbuka dengan data benar.
5. Amati satu hari penuh; agent bekerja, makan, tidur.
6. Bandingkan isi inspector dengan event log untuk satu keputusan.
7. Tambah makanan lewat debug command; stok bertambah dan log mencatat.
8. Biarkan stok habis; kelaparan terjadi dan kematian tercatat dengan sebab.
9. Restart dengan seed sama; kejadian awal identik.
10. Restart dengan seed beda; kejadian awal berbeda.
**Testing sprint ini:** playtest manual, tes view-tidak-mengubah-state, perf smoke, golden replay, regresi penuh seluruh suite.
 
**Demo:** rekaman satu hari simulasi dengan inspector, ditutup dengan dua run seed sama yang menghasilkan hash identik.
 
**Risiko:** view mulai "mencuri" logika (mis. menghitung sendiri posisi tujuan). Mitigasi: aturan review: PR di `view/` yang menulis ke state wajib ditolak.
 
---
 
## 7. Peta Target -> Tes
 
| Target (dari checklist penerimaan) | Sprint | Dibuktikan oleh |
|---|---|---|
| Sim core bebas Node/scene | 0-4 | Pemeriksaan otomatis di CI (grep) + review |
| Tidak ada RNG global di sim | 0-4 | Pemeriksaan otomatis di CI (grep) |
| Seed sama -> hash sama | 1 | Tes determinism |
| Seed beda -> hasil beda | 1 | Tes determinism |
| Agent hidup 5 hari tanpa crash | 3 | Sweep seed + metrik survival |
| Agent makan/tidur/kerja sesuai kebutuhan tanpa ping-pong | 3 | Tes skenario + metrik switch aksi |
| Stok habis -> kelaparan -> `agent_died` dengan sebab | 1-2 | Tes sistem + skenario |
| Kepribadian berbeda -> perilaku berbeda | 3 | Sweep + perbandingan distribusi aksi |
| Inspector menunjukkan alasan keputusan | 4 | Playtest manual + perbandingan dengan log |
| Aksi tidak valid ditolak tanpa mengubah state | 2 | Tes skenario + fuzz |
 
---
 
## 8. Manajemen Risiko
 
| Risiko | Dampak | Mitigasi |
|---|---|---|
| Nondeterminism diam-diam (urutan Dictionary, float, RNG global) | Merusak seluruh nilai riset proyek | Determinism test di CI sejak Sprint 1; aturan DoD |
| Tuning tanpa batas | Sprint 3 molor | Time-box 2 hari; catat ke backlog |
| Kontributor mengubah kontrak sembarangan | Konflik, test pecah | CODEOWNERS pada `sim/core` dan skema event; perubahan kontrak lewat ADR |
| Kontributor hilang di tengah tiket | Tiket menggantung | Tiket kecil; batas waktu klaim (mis. 7 hari tanpa PR -> tiket dibuka lagi) |
| Scope creep ("sekalian tambah LLM/ekonomi") | v0.1 tidak pernah rilis | Daftar "di luar scope" di atas; fitur baru masuk backlog v0.2 |
| Bug yang tidak bisa direproduksi | Buang waktu | Format laporan wajib seed + tick |
| Perbedaan versi Godot antar orang | Hasil tes berbeda | Pin versi di README dan CI |
 
---
 
## 9. Kontribusi Komunitas
 
### Peran dan area
 
| Area | Pemilik awal | Kapan terbuka untuk kontributor |
|---|---|---|
| `sim/core`, skema event | Maintainer inti | Setelah Sprint 1, via ADR |
| `sim/actions`, `sim/systems` | Maintainer inti dan reviewer | Setelah Sprint 2 |
| `sim/ai` | Maintainer inti | Setelah Sprint 3 |
| `view/`, `ui/` | Terbuka | Setelah Sprint 0 (pakai snapshot palsu untuk dikembangkan terpisah) |
| Aset, dokumentasi, tes tambahan | Terbuka | Sejak Sprint 0 |
 
### Label issue
`good-first-issue`, `help-wanted`, `sim-core`, `view`, `docs`, `testing`, `balance`, `bug`, `blocked`, `needs-adr`.
 
### Contoh tiket cocok untuk pemula
- Menambah tes unit untuk fungsi kurva.
- Menulis dokumentasi satu sistem di `DESIGN.md`.
- Menambah satu tipe tile dan aset (tanpa mengubah logika sim).
- Memperbaiki teks/UI HUD.
- Menulis skenario tes baru berdasarkan template yang ada.
### Aturan kontrak untuk kontributor
Kontributor tidak mengubah skema `AgentState`, `WorldState`, atau Event tanpa ADR yang disetujui maintainer. Ini menjaga kompatibilitas log dan hasil eksperimen antar versi.
 
### Snapshot palsu untuk track view
Sediakan fixture `WorldState` statis (mis. file JSON) agar kontributor view bisa membangun dan menguji tampilan tanpa menunggu sim selesai.
 
---
 
## 10. Backlog Pasca v0.1 (belum dijadwalkan)
 
- Memori episodik dan relasi terarah.
- Aksi `talk` dengan template, lalu antarmuka `DialogueProvider` (`TemplateProvider`, kemudian `LLMProvider`).
- Need `social`.
- Save/load state.
- Eksperimen builder dan perbandingan hasil.
- Metrik tambahan dan dashboard.
---
 
## 11. Checklist Persiapan Sebelum Sprint 0 Mulai
 
- [ ] Versi Godot ditetapkan.
- [ ] Lisensi dipilih.
- [ ] Repo dan board dibuat.
- [ ] Satu orang teman disiapkan sebagai penguji "fresh clone".
- [ ] Angka target awal Sprint 3 dibaca ulang dan disepakati (atau diganti).
- [ ] Jadwal sprint dan waktu review/demo ditetapkan (asinkron boleh).
  
**Definisi selesai sprint:** (ambang berikut adalah **nilai awal** yang dikonfirmasi saat planning)
- [ ] Skenario: agent lapar dengan stok tersedia memilih `eat` dibanding `work_farm` (tes deterministik).

