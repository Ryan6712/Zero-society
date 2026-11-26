# Catatan Revisi 2: Review Repo Society Zero (kondisi v0.1.0)
 
Tanggal review: 2026-11-26
Sumber: `Zero-society-main_d800ac.zip` (Sprint 0-4 diklaim selesai; README menyatakan rilis `v0.1.0`)
Pendahulu: `docs/revision-1.md`
 
> **Batasan review:** Godot dan gdtoolkit tidak tersedia di lingkungan review, jadi **tes, runner, sweep, lint, dan CI tidak dijalankan**. Semua temuan berasal dari pembacaan kode dan dokumen, plus uji grep pada sampel. Angka di devlog (100 tes lulus, hash golden, waktu perf) adalah klaim dari hasil lokalmu dan **tidak diverifikasi ulang**. Temuan bertanda **[kode eksplisit]** terlihat langsung dari baris kode; **[analisis]** adalah kesimpulan dari membaca alur dan perlu dikonfirmasi dengan tes.
 
**Legenda prioritas:** P0 = risiko serius. P1 = bug atau celah yang membuat klaim v0.1.0 belum sepenuhnya benar. P2 = rapikan segera. P3 = minor.
 
---
 
## 1. Ringkasan
 
Kualitas keseluruhan jauh di atas rata-rata proyek awal: sim/view terpisah bersih, tie-breaker pengurutan ada, RNG ber-seed dipakai dengan benar, konservasi makanan lewat satu jalur, command queue, golden replay, tes isolasi view, dan fuzz. Yang "bolong" bukan arsitekturnya, melainkan: **beberapa bug logika yang lolos dari tes**, **bukti perilaku yang terlalu mudah lulus**, dan **klaim rilis yang belum didukung bukti**.
 
| ID | Prioritas | Area | Temuan | Lokasi |
|---|---|---|---|---|
| N-01 | P1 | Logika | Aksi `eat` memulihkan hunger walau stok sudah habis (return `modify_granary_food` diabaikan) | `action_system.gd:149-158` |
| N-02 | P1 | Logika | Survival interrupt membatalkan `move` menuju makanan/rumah tiap tick | `utility_brain.gd:65-80` |
| N-03 | P1 | Fitur | Kepribadian tidak pernah diisi dari config; semua agent identik | `simulation.gd:24-34`, `default_world.json` |
| N-04 | P1 | Bukti | Sweep tidak menekan sistem: survival 100% dan sisa lumbung 209 dari 20 | `docs/tuning-log.md:36` |
| N-05 | P1 | Rilis | Klaim `v0.1.0` belum didukung playtest manual, catatan rilis, dan bukti CI | README, `docs/devlog/sprint-4.md` |
| N-06 | P2 | Event | Event hanya di memori, tak terbatas, `EventLog` tidak terhubung ke game/runner | `simulation.gd:7`, `event_log.gd` |
| N-07 | P2 | Metrik | `action_percentages` menghitung jumlah start, bukan porsi waktu | `behavior_metrics.gd:40-47` |
---
 
## 2. Status Catatan Revisi 1
 
| ID | Status | Catatan |
|---|---|---|
| R-02, R-03, R-04 (CI) | Selesai | `ci.yml` tidak berubah sejak review lalu |
| R-05 (CI terbukti jalan) | Tidak diketahui | Belum ada bukti run GitHub Actions di repo |
| R-06 (hash) | Selesai | `rng_state` dan presisi penuh dipakai; golden hash dibekukan |
| R-07, R-08, R-10, R-12, R-13, R-14 | Selesai | Dikonfirmasi pada review sebelumnya |
| R-01 (aset) | **Belum** | Lihat bagian 4 |
| R-09 (event) | Belum | Tes ada, tetapi `EventLog` belum dipakai (N-06) |
| R-11 (AGENTS) | Belum | Duplikat di dua lokasi, baris perintah masih hilang |
| R-15 | Sebagian | `user://` masih di `.gitignore` |
 
---
 
## 3. Temuan Baru
 
### N-01 (P1) `eat` memulihkan hunger walau stok sudah habis
 
- **Lokasi:** `sim/systems/action_system.gd` baris 149-158 (`_complete_action`); `sim/actions/action_validator.gd` (`can_start` mengecek stok hanya saat mulai).
- **Temuan [kode eksplisit]:** pada penyelesaian `eat`, hunger ditambah 40 **lebih dulu**, lalu `world.modify_granary_food(-1, ...)` dipanggil dan **nilai kembaliannya diabaikan**. `modify_granary_food` mengembalikan `false` dan tidak mengubah stok jika stok tidak cukup. Validator hanya memeriksa stok saat aksi dimulai, sedangkan stok baru berkurang saat aksi selesai (durasi 2 tick).
- **Skenario [analisis]:** stok = 1, dua agent berada di lumbung pada tick yang sama. Keduanya lolos `can_start` (stok masih 1). Agent pertama selesai dan stok menjadi 0. Agent kedua selesai: `modify_granary_food(-1)` mengembalikan `false`, tetapi hunger-nya tetap naik 40. **Nilai makanan tercipta tanpa biaya.**
- **Mengapa tes tidak menangkapnya:** invariant `is_food_conserved()` tetap hijau karena stok dan penghitung tidak berubah. Konservasi hanya melindungi angka stok, bukan efek aksi.
- **Perbaikan:**
```gdscript
elif def.id == ActionLibrary.ID_EAT:
	if world.modify_granary_food(-1, &"eat", agent.id, events):
		agent.needs[&"hunger"] = clampf(
			agent.needs[&"hunger"] + SimConst.EAT_HUNGER_RESTORE, 0.0, 100.0
		)
	else:
		# stok habis saat aksi selesai: catat sebagai kegagalan, bukan keberhasilan
		_emit_event(events, world, agent, EventSchema.EventType.ACTION_FAILED, {
			"action_id": "eat",
			"reject_reason": "no_stock",
		})
		agent.current_action = null
		return
```
  Alternatif yang lebih adil: kurangi stok saat aksi **dimulai** (reservasi), sehingga agent kedua ditolak oleh validator.
- **Tes yang perlu ditambah:** dua agent di tile lumbung, stok 1, keduanya `eat` bersamaan. Harapan: total hunger yang dipulihkan sama dengan total makanan yang dikonsumsi × 40. Tambahkan juga invariant: setiap `action_completed(eat)` harus berpasangan dengan `food_consumed` di tick yang sama.
- **Commit yang disarankan:** `fix(actions): jangan pulihkan hunger jika stok lumbung habis saat eat selesai`
  (perilaku berubah: perbarui golden hash di commit terpisah)
---
 
### N-02 (P1) Survival interrupt membatalkan `move` yang sedang menuju makanan atau rumah
 
- **Lokasi:** `sim/ai/utility_brain.gd` baris 65-80 (`check_survival_interrupt`), dipanggil di baris 87 setiap tick sebelum keputusan.
- **Temuan [kode eksplisit]:** interrupt dikecualikan hanya jika aksi saat ini adalah `eat` atau `sleep`. `move` tidak dikecualikan dan `interruptible = true`. Jadi saat `hunger < 15` atau `energy < 10`, agent yang **sedang berjalan menuju lumbung/rumah** dibatalkan tiap tick.
- **Dampak [analisis]:**
  1. Setiap tick selama kondisi kritis terjadi rantai `action_interrupted` -> `decision_made` -> `action_started(move)` -> pencarian jalur ulang. Event log membengkak dan RNG terpakai terus-menerus.
  2. Perilaku tampak benar (agent tetap bergerak karena memilih ulang tujuan yang sama), sehingga tes tidak menangkapnya.
  3. Dokumentasi (`sprint-3-observations.md`) menyebut interrupt hanya membatalkan aksi non-kritis seperti `work_farm`; implementasinya lebih luas dari yang didokumentasikan.
  4. Saat dua kebutuhan kritis bersamaan, tujuan bisa berganti tiap tick karena commitment bonus tidak berlaku (aksi sudah dihapus).
- **Perbaikan:** tambahkan `intent: StringName` pada `ActionInstance` (aksi yang dilayani `move`), isi saat `move` dimulai dari `decide_and_act`, lalu lewati interrupt jika `intent` adalah `eat` atau `sleep`.
- **Tes yang perlu ditambah:** agent dengan `hunger = 10` berjarak 6 tile dari lumbung. Hitung event `action_interrupted` selama perjalanan; harapan: 0 (atau paling banyak 1 untuk membatalkan `work_farm` awal).
- **Commit yang disarankan:** `fix(ai): jangan batalkan move yang melayani eat atau sleep saat survival interrupt`
---
 
### N-03 (P1) Kepribadian tidak pernah diisi dari config
 
- **Lokasi:** `sim/simulation.gd` baris 24-34; `data/default_world.json` (tidak ada field kepribadian); `sim/core/agent_state.gd` baris 20-24.
- **Temuan [kode eksplisit]:** setiap `AgentState` memakai nilai default 50/50/50. `Simulation._init` tidak membaca kepribadian dari config. Satu-satunya tempat kepribadian berbeda dibuat adalah di dalam tes (menyetel `personality[...]` manual). `ambition` tidak dipakai di mana pun.
- **Dampak:** di game dan di sweep, ketiga NPC punya parameter identik. Target Sprint 3 ("kepribadian terlihat" dan "dua agent berbeda menunjukkan perbedaan perilaku di sweep") baru dibuktikan di level **skor satu keputusan** (`test_personality_impacts_work_decision`), belum di level perilaku sepanjang waktu. Inspector menampilkan "Rajin=50, Berani=50" untuk semua agent.
- **Perbaikan:**
  1. Izinkan config memberi kepribadian per agent, mis. `"agent_personalities": [{"conscientiousness": 90, "risk_tolerance": 30}, ...]` dengan default 50 bila tidak ada. Validasi rentang 0-100.
  2. Tambahkan config sweep dengan dua agent berbeda jauh dan laporkan porsi **waktu** kerja per agent (lihat N-07).
  3. Putuskan nasib `ambition`: pakai atau hapus.
- **Commit yang disarankan:** `feat(data): dukung kepribadian per agent dari config`
---
 
### N-04 (P1) Sweep tidak menekan sistem sehingga "lulus" tidak informatif
 
- **Lokasi:** `docs/tuning-log.md` baris 30-38; `data/default_world.json`.
- **Temuan [analisis dari angka di tuning log]:** survival 100% (60/60) dan sisa lumbung **209** dari stok awal 20 setelah 5 hari. Dengan konsumsi sekitar 6 kali makan per agent per 720 tick (kira-kira 19 makanan untuk 3 agent), produksi kira-kira sepuluh kali lipat konsumsi. Ekosistemnya sangat surplus, jadi ambang "survival >= 80%" tidak pernah terancam. Entri bernama "Tuning Pass 1" adalah baseline: tidak ada parameter yang diubah.
- **Dampak:** angka hijau tidak membuktikan keseimbangan, hanya bahwa dunia default terlalu mudah. Skenario yang menguji perilaku di bawah tekanan (kelangkaan) belum ada.
- **Perbaikan:**
  1. Tambahkan konfigurasi sweep yang menekan: stok awal rendah (0-3), ladang jauh dari lumbung, 5 agent dengan satu tile ladang, produksi per kerja dikurangi.
  2. Laporkan sebaran (min/median/maks), bukan hanya rata-rata, dan tampilkan hari kematian pertama serta penyebab.
  3. Catat target **sebelum** melihat hasil (aturan tuning log sendiri), dan pisahkan "baseline" dari "tuning" pada judul entri.
- **Commit yang disarankan:** `feat(tools): tambahkan config sweep kelangkaan`
---
 
### N-05 (P1) Klaim rilis `v0.1.0` belum didukung bukti
 
- **Lokasi:** `README.md` baris 9; `docs/devlog/sprint-4.md` bagian 4.
- **Temuan:** README menyatakan "Rilis `v0.1.0`" dan Sprint 4 "Selesai", tetapi tidak ada di repo:
  - bukti **playtest manual 10 langkah** (Definition of Done Sprint 4),
  - **catatan rilis** (fitur, batasan yang diketahui, cara mereproduksi eksperimen),
  - tautan hasil **CI GitHub Actions** yang hijau (R-05),
  - bukti tag `v0.1.0` (arsip zip tidak memuat metadata git, jadi tidak bisa dicek di sini).
- **Dampak:** klaim "tercapai secara lengkap" melampaui bukti yang tertulis.
- **Perbaikan:** tulis `docs/release-notes-v0.1.0.md` berisi fitur, batasan yang diketahui (termasuk N-01 sampai N-04 jika belum diperbaiki), seed dan config untuk mereproduksi, serta hasil playtest 10 langkah. Tag rilis setelah CI hijau di `main`.
- **Commit yang disarankan:** `docs(docs): tambahkan catatan rilis v0.1.0`
---
 
### N-06 (P2) Event hanya di memori, tak terbatas, dan `EventLog` tidak dipakai
 
- **Lokasi:** `sim/simulation.gd` baris 7 (`var events`); `autoload/event_log.gd`; `project.godot` baris 21.
- **Temuan [kode eksplisit]:**
  1. `Simulation.events` tumbuh tanpa batas. Tiap keputusan menghasilkan `decision_made`, `action_started`, dan `action_completed`; agent yang idle menghasilkan itu **setiap tick**.
  2. Tidak ada pemanggil `EventLog.log_event` atau `save_to_file` di game maupun runner; file `.jsonl` tidak pernah ditulis.
  3. Dokumen menyatakan keputusan "tercatat di event log"; faktanya hanya ada di memori selama proses berjalan.
- **Dampak:** durasi panjang menaikkan memori linear; penelusuran pasca-eksperimen (nilai utama proyek) belum mungkin. Keputusan R-09 (satu jalur event) masih menggantung.
- **Perbaikan:** putuskan satu jalur. Saran: `Simulation` menghasilkan event, penulis JSONL murni di `sim/` atau `tools/` (tanpa autoload) menuliskannya berkala dan mengosongkan buffer; tambahkan opsi `--log <path>` pada `run_sim.gd`. Pertimbangkan tidak mencatat keputusan idle yang tidak berubah.
- **Commit yang disarankan:** `feat(events): tulis event ke JSONL dan batasi buffer di memori`
---
 
### N-07 (P2) Metrik `action_percentages` bukan porsi waktu
 
- **Lokasi:** `tools/behavior_metrics.gd` baris 40-47; `tools/sweep_seeds.gd` (tidak mencetaknya).
- **Temuan [kode eksplisit]:** persentase dihitung dari **jumlah `action_started`**, sedangkan Definition of Done meminta "persentase waktu per aksi". Aksi idle berdurasi 1 tick dan `work_farm` 6 tick sehingga jumlah start tidak mencerminkan waktu. Sweep juga tidak mencetak metrik ini.
- **Perbaikan:** hitung porsi **tick** per aksi (jumlahkan durasi aktual dari `action_started` ke `action_completed`/`action_interrupted`), cetak di sweep, dan ganti nama bila tetap menghitung start.
- **Commit yang disarankan:** `fix(tools): hitung porsi waktu per aksi pada metrik perilaku`
---
 
### N-08 (P2) Field dan cache yang tidak dipakai
 
- **Lokasi:** `sim/actions/action_def.gd` (`hunger_cost_per_tick`); `sim/actions/action_library.gd` (move dengan biaya 0.05); `sim/systems/action_system.gd` baris 117 (hanya `work_farm` memakai `energy_cost_per_tick`); `sim/systems/movement_system.gd` baris 5 (`_astar_cache`).
- **Temuan [kode eksplisit]:** `hunger_cost_per_tick` tidak dipakai di mana pun. Biaya energi/hunger `move` (0.05) tidak pernah diterapkan, jadi data aksi menyatakan biaya yang tidak terjadi. `_astar_cache` dideklarasikan tetapi tidak dipakai; `build_astar` membangun grid baru setiap kali jalur dicari.
- **Dampak:** data yang menyesatkan bagi kontributor dan agent; state `static` yang tidak terpakai adalah sumber bug determinism bila kelak diisi tanpa kunci yang benar.
- **Perbaikan:** terapkan biaya `move` atau hapus fieldnya; hapus `_astar_cache` atau implementasikan dengan kunci berdasarkan grid dan pastikan tidak menyimpan state lintas simulasi.
- **Commit yang disarankan:** `refactor(actions): hapus field biaya yang tidak diterapkan`
---
 
### N-09 (P2) Pembanding skor memakai `is_equal_approx`
 
- **Lokasi:** `sim/ai/utility_brain.gd` baris 206.
- **Temuan [analisis]:** kesamaan "kira-kira" tidak transitif (a ≈ b, b ≈ c, tetapi a tidak ≈ c), sehingga pembanding bisa melanggar syarat urutan yang konsisten. Risiko praktisnya kecil karena noise acak (0,02) jarang menghasilkan selisih sekecil itu, tetapi bila terjadi, urutan hasil bisa bergantung implementasi sort.
- **Perbaikan:** kuantisasi skor sebelum diurutkan (mis. `snappedf(score, 0.0001)`) lalu bandingkan dengan `==`, tetap dengan tie-breaker `id`.
- **Commit yang disarankan:** `fix(ai): kuantisasi skor sebelum pengurutan`
---
 
### N-10 (P2) View: null deref dan akumulator tak terbatas
 
- **Lokasi:** `view/game_scene.gd` baris 19 dan 33-45; `autoload/sim_clock.gd` baris 16-18.
- **Temuan [kode eksplisit]:**
  1. Jika `_init_simulation()` gagal (config hilang atau JSON rusak), `simulation` tetap `null` dan `_ready` langsung memakai `simulation.world`, sehingga crash.
  2. `_accum` tidak dibatasi. Pada mesin lambat atau kecepatan 8x, setelah mencapai `MAX_TICKS_PER_FRAME` sisa akumulator menumpuk dan simulasi tertinggal terus.
- **Perbaikan:** keluar dari `_ready` dengan pesan jelas bila `simulation == null`; batasi `_accum` (mis. `minf(_accum, SECONDS_PER_TICK * MAX_TICKS_PER_FRAME)`).

