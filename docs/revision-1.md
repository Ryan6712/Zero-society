# Catatan Revisi: Review Repo Society Zero
 
Tanggal review: 2026-11-25
Sumber: `Zero-society-main.zip` (kondisi: Sprint 0 selesai, Sprint 1 hampir selesai)
 
> **Batasan review ini:** Godot dan gdtoolkit tidak tersedia di lingkungan review, sehingga **tes GUT, runner, lint, dan workflow GitHub tidak dijalankan**. Semua temuan berasal dari pembacaan kode dan dokumen, serta uji grep pada sampel kode. Temuan bertanda **[terbukti]** sudah diuji langsung; **[dari bacaan]** belum dijalankan.
 
**Legenda prioritas:** P0 = perbaiki sebelum lanjut / risiko serius. P1 = perbaiki sebelum Sprint 2. P2 = rapikan segera. P3 = minor.
 
---
 
## 1. Ringkasan
 
| ID | Prioritas | Area | Temuan | Lokasi |
|---|---|---|---|---|
| R-01 | P0 | Aset | Lisensi aset melarang redistribusi, tetapi aset ada di repo | `Assets/read_me.txt` |
| R-02 | P0 | CI | Grep RNG salah tangkap `rng.randf()` (false positive) | `ci.yml:54` |
| R-03 | P1 | CI | Tes determinism lewat runner belum dijalankan di CI | `ci.yml` (tidak ada langkahnya) |
| R-04 | P2 | CI | Aturan arsitektur belum menutup `shuffle`, `pick_random`, `Time`, `OS` | `ci.yml:50-56` |
| R-05 | P1 | CI | Workflow belum pernah terbukti jalan (unduh Godot, import, GUT) | `ci.yml:35-47` |
| R-06 | P1 | Determinism | Hash lemah: `seed_value` masuk hash, RNG state tidak, presisi float terbatas | `world_state.gd:47,55` |
| R-07 | P2 | Tes | Tes determinism hanya 200 dan 500 tick (rencana: 1000) | `test_determinism.gd:6-19` |
| R-08 | P1 | Aset/Scene | Path `res://assets/...` tidak cocok dengan folder `Assets/` | `main.tscn:4`, `Chicken.png.import:13` |
| R-09 | P1 | Event | `EventLog` tanpa tes dan event tersimpan di dua tempat | `event_log.gd:5`, `simulation.gd:7,38` |
| R-10 | P1 | Data | `granary_food` bertipe float, padahal sumber daya diskret | `world_state.gd:9`, `sim_const.gd:28` |
| R-11 | P1 | Dokumen | `AGENTS.md` rusak (code fence) dan berada di `.agents/` | `.agents/AGENTS.md:42-71` |
| R-12 | P2 | Dokumen | File konsep/sprint duplikat di beberapa folder | `docs/` |
| R-13 | P2 | Konsistensi | Nama proyek tidak seragam | `project.godot:13` dan lainnya |
| R-14 | P3 | Tools | `run_sim.gd` crash jika flag tanpa nilai | `run_sim.gd:15-27` |
| R-15 | P3 | Rapikan | Beberapa hal kecil (tes hello, `.gitignore`, Jolt, README) | lihat detail |
 
**Yang sudah baik (dipertahankan):** `sim/` bebas `Node` dan RNG global; pemisahan sim/view jelas; 4 ADR tertulis; `SimConst` sebagai satu tempat konstanta; urutan agent terurut; static typing konsisten; `.uid` dan `.import` ikut di-commit; `.gutconfig.json` benar; PR template dan issue template tersedia.
 
---
 
## 2. Panduan Membaca Error CI
 
Gunakan tabel ini saat CI merah. Cari **job**, lalu **langkah (step)** yang gagal, lalu cocokkan gejalanya.
 
### 2.1 Peta job dan langkah (ci.yml saat ini)
 
| Job | Langkah | Memeriksa apa |
|---|---|---|
| `lint` | `gdformat --check` | Format kode |
| `lint` | `gdlint` | Gaya dan aturan lint |
| `test` | Pasang Godot | Mengunduh binary Godot `GODOT_VERSION` |
| `test` | Import proyek | `godot --headless --import` |
| `test` | Tes unit (GUT) | Seluruh tes di `tests/` |
| `test` | Pemeriksaan aturan arsitektur | Grep `extends Node` dan RNG global di `sim/` |
 
### 2.2 Gejala, penyebab, tindakan
| Langkah | Gejala di log | Kemungkinan penyebab | Tindakan |
|---|---|---|---|

| `gdformat --check` | `would reformat <file>` | File belum diformat | Jalankan `gdformat <file>` lalu commit |

| `gdlint` | `<file>:<baris>: Error: ... (nama-aturan)` | Pelanggaran aturan lint | Perbaiki sesuai nama aturan; jangan mematikan lint tanpa alasan tertulis |

| `gdlint` / `gdformat` | Error parse pada file yang valid di Godot | gdtoolkit belum mendukung sintaks Godot 4.7 | Laporkan ke tracker gdtoolkit; catat di `docs/` |
| Pasang Godot | `wget` error 404 | Versi `4.7.2` atau pola nama file rilis tidak ada | Periksa halaman rilis Godot, sesuaikan `GODOT_VERSION` |
| Pasang Godot | `godot --version` tidak keluar | File tidak terpasang/tidak executable | Periksa langkah `chmod` dan `mv` |
| Import proyek | Error resource/texture tidak ditemukan | Path huruf besar-kecil (R-08) atau `.import` rusak | Lihat R-08 |
| Tes unit (GUT) | `Parse Error` / `Identifier "X" not declared` | `class_name` belum terdaftar | Pastikan langkah import berjalan sebelum GUT |
| Tes unit (GUT) | Daftar tes `Failed` dengan nama dan baris | Tes memang gagal | Perbaiki kode atau tes; jangan melonggarkan tes |
| Tes unit (GUT) | Tes lulus lokal, gagal di CI | Beda versi Godot/GUT atau platform | Samakan versi dengan `GODOT_VERSION` |
| Pemeriksaan arsitektur | `sim/xxx.gd:NN:...` lalu `::error::sim/ tidak boleh extends Node` | Ada `extends Node` di `sim/` | Pindahkan ke `view/` atau ubah ke `RefCounted` |
| Pemeriksaan arsitektur | `sim/xxx.gd:NN: ... rng.randf()` lalu `::error::sim/ tidak boleh memakai RNG global` | **False positive R-02**, bukan pelanggaran | Terapkan perbaikan R-02 |
| Pemeriksaan arsitektur | Baris dengan `randf()` tanpa `rng.` | Pelanggaran asli ADR-003 | Ganti dengan `rng.randf()` dari `Simulation` |
| Determinism (setelah R-03) | `Determinism check: FAIL` dengan `Hash 1` dan `Hash 2` | Nondeterminism sungguhan | Lihat bagian troubleshooting di `development.md` |
 
---
 
## 3. Detail Temuan
 
### R-01 (P0) Lisensi aset melarang redistribusi
 
- **Lokasi:** `Assets/read_me.txt`; seluruh folder `Assets/`.
- **Temuan [terbukti, dari isi file]:** paket Cute Fantasy versi gratis boleh dipakai di proyek **non-komersial** dan boleh dimodifikasi, tetapi **tidak boleh didistribusikan ulang atau dijual, meskipun sudah dimodifikasi**.
- **Dampak:** meng-commit aset ke repo yang publik, atau yang dibagikan ke kontributor, dapat dianggap redistribusi.
- **Perbaikan (pilih satu):**
  1. Jadikan repo privat dan batasi akses.
  2. Keluarkan `Assets/` dari git (tambahkan ke `.gitignore`), dokumentasikan cara mengunduh paket dari sumbernya.
  3. Ganti dengan aset berlisensi CC0 (mis. Kenney.nl) dan catat sumbernya.
- **Catatan:** konfirmasi persyaratan langsung di halaman resmi paket, karena versi lisensi bisa berubah.
- **Commit yang disarankan:** `chore(assets): keluarkan aset berlisensi terbatas dari repo`
---
 
### R-02 (P0) CI: grep RNG menangkap `rng.randf()`
 
- **Lokasi:** `.github/workflows/ci.yml` baris 54.
- **Kode saat ini:**
```bash
if grep -rnE "\b(randf|randi|randf_range|randi_range)\(" sim/; then
```
- **Masalah [terbukti]:** `\b` cocok di antara `.` dan `r`, sehingga `rng.randf()` ikut tertangkap padahal itulah cara yang benar. Diuji pada sampel kode: `rng.randf()` terdeteksi sebagai pelanggaran.
- **Dampak:** saat ini tidak ada kode yang memakai `rng.randf()`, jadi CI belum merah. **CI akan merah tepat ketika Utility AI mulai memakai RNG ber-seed** di Sprint 3 (atau Sprint 2 bila ada noise), dan pesan errornya menyesatkan.
- **Perbaikan:**
```bash
grep -rnP --include='*.gd' "(?<![.\w])(randf|randi|randf_range|randi_range|randfn|randomize|rand_from_seed)\(" sim/
```
- **Hasil uji pola baru [terbukti]:**
  - `rng.randf()` dan `rng.randi_range()` lolos.
  - `randf()` global tertangkap.
  - Kode `sim/` yang ada sekarang tidak menghasilkan temuan.
- **Commit yang disarankan:** `ci(ci): perbaiki grep RNG agar tidak menangkap rng.randf()`
---
 
### R-03 (P1) CI: tes determinism lewat runner belum dijalankan
 
- **Lokasi:** `ci.yml` (langkahnya tidak ada).
- **Temuan:** `tools/run_sim.gd` sudah mendukung `--check-twice` dan keluar dengan kode 1 jika hash berbeda, tetapi CI hanya menjalankan GUT.
- **Perbaikan:** tambahkan langkah di job `test` setelah GUT:
```yaml
- name: Tes determinism (runner headless)
  run: |
    for seed in 42 99 1337; do
      echo "=== seed $seed ==="
      godot --headless -s tools/run_sim.gd -- --seed "$seed" --ticks 1000 --check-twice
    done
```
- **Catatan:** langkah ini baru bermakna penuh setelah ada kode yang memakai RNG (lihat R-06).
- **Commit yang disarankan:** `ci(ci): jalankan tes determinism lewat run_sim.gd`
---
 
### R-04 (P2) CI: aturan arsitektur belum lengkap
 
- **Lokasi:** `ci.yml` baris 50-56.
- **Temuan:** sumber nondeterminism yang dilarang di `code-quality.md` dan ADR-003 belum diperiksa: `Array.shuffle()` dan `pick_random()` (memakai RNG global), serta `Time.*` dan `OS.*`.
- **Perbaikan [pola sudah diuji pada sampel]:**
```bash
grep -rnE --include='*.gd' "\.(shuffle|pick_random)\(" sim/
grep -rnP --include='*.gd' "\b(Time|OS)\.[a-z_]+\(" sim/
```
- **Saran struktur:** pisahkan menjadi job `architecture` tersendiri agar hasilnya terlihat terpisah dari tes. Versi lengkap ada di berkas `ci.yml` hasil perbaikan.
- **Commit yang disarankan:** `ci(ci): lengkapi pemeriksaan aturan arsitektur sim/`
---
 
### R-05 (P1) CI: belum terbukti berjalan
 
- **Lokasi:** `ci.yml` baris 35-47 (unduh Godot, import, GUT).
- **Status:** **[dari bacaan]**. URL unduh Godot, nama file hasil unzip, `godot --headless --import`, dan kode keluar GUT belum pernah dijalankan di GitHub.
- **Yang harus dikonfirmasi pada run pertama:**
  - [ ] Versi `4.7.2-stable` ada dan URL unduh valid.
  - [ ] `godot --version` mencetak versi yang benar.
  - [ ] Langkah import selesai tanpa error fatal.
  - [ ] GUT mengembalikan kode keluar non-nol saat ada tes gagal (uji dengan satu tes yang sengaja gagal di PR percobaan).
  - [ ] Lint tidak gagal mem-parse sintaks Godot 4.7.
- **Cara uji cepat:** buka PR percobaan yang sengaja merusak satu tes, satu format, dan satu aturan arsitektur; pastikan masing-masing membuat CI merah di langkah yang benar, lalu perbaiki sehingga hijau.
---
 
### R-06 (P1) Hash determinism lemah
 
- **Lokasi:** `sim/core/world_state.gd` baris 47 (`seed_value` di `to_dict()`) dan 55 (`compute_hash()`); `tests/test_determinism.gd` baris 12-14.
- **Temuan [dari bacaan]:**
  1. Belum ada kode yang memakai RNG (parameter `_rng` di `WorldSystem.update` tidak dipakai, `Simulation.step()` tidak memakai RNG). Jadi "seed sama, hash sama" lulus dengan sendirinya.
  2. `test_different_seed_different_hash` lulus **hanya karena `seed_value` ikut di hash**, bukan karena perilaku berbeda.
  3. State RNG tidak masuk hash, sehingga perbedaan pemakaian RNG tidak terdeteksi bila state akhir kebetulan sama.
  4. `JSON.stringify(...)` dipanggil dengan presisi default; selisih float sangat kecil bisa tak terlihat.
- **Dampak:** tes terlihat hijau tetapi belum membuktikan determinism sesungguhnya. Risiko salah percaya diri.
- **Perbaikan yang disarankan:** hitung hash di `Simulation` agar bisa memasukkan state RNG, dengan presisi penuh:
```gdscript
# sim/simulation.gd
func compute_hash() -> String:
	var data: Dictionary = world.to_dict()
	data["rng_state"] = str(rng.state)
	return JSON.stringify(data, "", true, true).sha256_text()
```
  Lalu ganti pemanggilan `sim.world.compute_hash()` menjadi `sim.compute_hash()` di `tools/run_sim.gd` dan `tests/test_determinism.gd`. Pertahankan `WorldState.compute_hash()` bila masih dipakai tes lain.
- **Tes tambahan:** setelah RNG dipakai (Sprint 2-3), tambahkan tes bahwa seed berbeda menghasilkan **perilaku** berbeda (mis. urutan aksi), bukan hanya hash berbeda karena `seed_value`.
- **Commit yang disarankan:** `fix(core): sertakan rng state dan presisi penuh pada hash determinism`
  (jika ini mengubah hash golden, pisahkan commit pembaruan golden sesuai `committing.md`)
---
 
### R-07 (P2) Tes determinism terlalu pendek
 
- **Lokasi:** `tests/test_determinism.gd` baris 6-7, 12-13, 18-19.
- **Temuan:** durasi 200 dan 500 tick; `sprint-1-plan.md` meminta 1000 tick.
- **Perbaikan:** naikkan satu tes ke 1000 tick, dan tambahkan variasi seed lain. Lalu catat apakah waktu tes masih wajar.
- **Commit yang disarankan:** `test(determinism): jalankan seed 42 selama 1000 tick`
---

