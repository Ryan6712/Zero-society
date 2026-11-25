# Society Zero
 
**An Artificial Society Research Simulator.** *Observe. Experiment. Discover.*
 
Society Zero adalah simulator masyarakat buatan: individu virtual (*agent*) hidup di dunia yang punya waktu, sumber daya, dan aturan. Kita tidak menulis cerita yang harus terjadi. Kita membangun kondisi dan aturan, lalu mengamati apa yang muncul.
 
> *Do not script the society. Build the conditions that allow society to emerge.*
 
**Status:** pra-alpha (Sprint 0, 1, & 2 selesai: aksi, validasi, gerak A*, dan audit konservasi makanan aktif). Target rilis pertama: `v0.1.0` ("Hidup di Desa").

---

## Daftar Isi

1. [Konsep](#konsep)
2. [Prinsip Desain](#prinsip-desain)
3. [Scope v0.1](#scope-v01)
4. [Tech Stack](#tech-stack)
5. [Struktur Repo](#struktur-repo)
6. [Memulai](#memulai)
7. [Testing](#testing)
8. [CI (GitHub Actions)](#ci-github-actions)
9. [Alur Development](#alur-development)
10. [Roadmap Sprint](#roadmap-sprint)
11. [Catatan Development (Devlog)](#catatan-development-devlog)
12. [Kontribusi](#kontribusi)
13. [Referensi](#referensi)
14. [Lisensi](#lisensi)
---
 
## Konsep
 
Bentuk game: **2D top-down, tile-based, bergaya Civilization.** Pemain adalah pengamat atau peneliti: memantau dunia, mengatur kecepatan waktu, menginspeksi agent, dan (di versi mendatang) mengubah variabel eksperimen. Agent berjalan sendiri berdasarkan kondisi internalnya.
 
Setiap agent memiliki:
- **Needs** (lapar, energi, kesehatan) yang berubah seiring waktu.
- **Kepribadian** yang memengaruhi kecenderungan keputusan.
- **Keputusan** yang dipilih oleh **Utility AI**, bukan skrip cerita.
- **Riwayat** kejadian yang tercatat dan bisa ditelusuri.
Society Zero bukan sekadar kumpulan chatbot. Dunia, sumber daya, dan konsekuensi dikelola oleh *simulation engine* yang konsisten. LLM (di tahap mendatang) hanya boleh **mengusulkan** aksi atau menghasilkan dialog; engine yang memutuskan apa yang benar-benar terjadi.
 
---
 
## Prinsip Desain
 
1. **Sim core tidak mengenal visual.** Logika simulasi berupa data dan sistem murni (`RefCounted`/`Resource`), bukan `Node`. Tampilan hanya membaca state.
2. **Per tick, bukan per frame.** Simulasi berdetak dengan jam internal sendiri, terpisah dari FPS.
3. **Satu sumber randomness ber-seed.** Seed sama menghasilkan hasil sama. Tidak ada `randf()`/`randi()` global di `sim/`.
4. **Engine memvalidasi semua aksi.** Agent (dan kelak LLM) hanya mengusulkan.
5. **Explainability.** Setiap keputusan penting dicatat beserta alasannya (skor kandidat), bukan dikarang setelah kejadian.
6. **Eksperimen harus bisa diulang.** Seed, konfigurasi, dan versi aturan menentukan hasil.
---
 
## Scope v0.1
 
**Target:** 3-5 NPC hidup sendiri di peta kecil (lapar, capek, kerja di ladang, makan di lumbung, tidur di rumah), semua keputusan bisa ditelusuri, hasil identik untuk seed yang sama.
 
**Masuk:** sim clock, `WorldState`/`AgentState`, needs, aksi (`idle`, `move`, `eat`, `sleep`, `work_farm`), pathfinding `AStarGrid2D`, Utility AI, event log dengan `decision_trace`, kamera, kontrol waktu, agent inspector, tes determinism.
 
**Belum masuk:** LLM, dialog, relasi sosial, memori kompleks, ekonomi/trade, kelompok, governance, save/load.
 
---
 
## Tech Stack
 
| Komponen | Pilihan | Catatan |
|---|---|---|
| Engine | **Godot 4.7.x** | Pin satu versi patch untuk semua orang dan CI (lihat `GODOT_VERSION` di workflow) |
| Bahasa | GDScript | Static typing dianjurkan |
| Unit test | **GUT 9.7.x** | Pakai rilis `9.7.1` (cabang `godot_4_7`, untuk Godot 4.7.x) |
| CI | **GitHub Actions** | Lint + tes unit + tes determinism |
| Lint/format | `gdtoolkit` (`gdlint`, `gdformat`) | Opsional tapi disarankan; lihat catatan di bagian CI |
 
> **Kompatibilitas GUT:** tiap versi GUT terikat ke versi minor Godot tertentu. GUT 9.7.x untuk Godot 4.7.x, 9.6.x untuk 4.6.x, 9.5.x untuk 4.5.x. Jangan menaikkan Godot tanpa memeriksa versi GUT yang cocok.
 
---
 
## Struktur Repo
 
```
society-zero/
├─ project.godot
├─ .gutconfig.json            # konfigurasi GUT
├─ .github/workflows/ci.yml   # CI
├─ addons/gut/                # GUT 9.7.1 (di-commit ke repo)
├─ autoload/
│  ├─ sim_clock.gd            # waktu nyata -> tick, pause/speed
│  └─ event_log.gd            # tulis event ke user://logs/*.jsonl
├─ sim/                       # TIDAK boleh extends Node
│  ├─ simulation.gd           # orkestrator: step() per tick
│  ├─ core/                   # world_state, agent_state, grid_data, ...
│  ├─ actions/                # action_def, action_library, action_validator
│  ├─ ai/                     # utility_brain, curves
│  └─ systems/                # needs, movement, action, world
├─ view/                      # scene, kamera, agent_view, UI
├─ data/                      # default_world.json (peta, seed, jumlah agent)
├─ tests/                     # tes GUT (unit, sistem, skenario, determinism)
├─ tools/                     # runner headless (mis. run_sim.gd)
└─ docs/                      # DESIGN.md, ADR, tuning-log.md
```
 
---
 
## Memulai
 
### Prasyarat
- **Godot 4.7.x** (versi patch sesuai yang di-pin di repo).
- Git.
- (Opsional) Python 3.12+ untuk `gdtoolkit`.
### Langkah
1. Clone repo.
```bash
git clone <url-repo>
cd society-zero
```
2. Buka folder dengan Godot 4.7.x (Import project), lalu tunggu proses import selesai.
3. `addons/gut` sudah ada di repo. Aktifkan plugin lewat **Project > Project Settings > Plugins** jika ingin memakai panel GUT di editor.
4. Jalankan tes lewat command line (lihat bagian Testing).
### Memasang GUT dari nol (hanya untuk maintainer)
1. Unduh GUT 9.7.1: `https://github.com/bitwes/Gut/archive/refs/tags/v9.7.1.zip`
2. Salin folder `addons/gut` dari zip ke repo.
3. Commit `addons/gut` agar CI dan kontributor tidak perlu mengunduhnya terpisah.
---
 
## Testing
 
### Menjalankan tes (lokal)
 
```bash
# import sekali agar class_name dan resource terdaftar
godot --headless --import
 
# jalankan seluruh tes GUT
godot --headless -s addons/gut/gut_cmdln.gd
```
 
GUT membaca `res://.gutconfig.json` secara default. Contoh isinya:
 
```json
{
  "dirs": ["res://tests/"],
  "include_subdirs": true,
  "should_exit": true,
  "log_level": 1
}
```
 
### Lapisan tes
 
| Lapisan | Yang diuji |
|---|---|
| Unit | Fungsi kecil: kurva urgensi, rumus decay, validator |
| Sistem | Satu sistem dengan state buatan |
| Skenario | Situasi lengkap dengan agent scripted |
| Invariant | Aturan yang tidak boleh dilanggar (tidak ada nilai negatif, konservasi makanan, satu tile per agent) |
| Determinism | Seed sama menghasilkan hash state yang sama |
| Golden replay | Hash state seed tertentu di tick tertentu dibekukan |
| Metrik perilaku | Survival, pergantian aksi, pembagian waktu lintas banyak seed |
| Performa (smoke) | Waktu tick tidak meledak |
 
### Catatan penting
- **Tes determinism adalah tes terpenting proyek ini.** Jika gagal, hasil simulasi tidak bisa dipercaya.
- **Hash golden terikat pada versi Godot dan platform.** CI (Linux) adalah sumber kebenaran. Menaikkan versi Godot bisa mengubah hash; perubahan itu harus disengaja dan dijelaskan di PR.
- **Perubahan di GUT 9.7:** Godot 4.7 memperketat pengecekan tipe nilai kembalian. *Doubles* GUT kini mengembalikan nilai default sesuai tipe (bukan `null`), dan `stub(...).to_do_nothing()` mengembalikan nilai default tersebut. Ini bisa menimbulkan positif/negatif palsu pada tes yang memakai doubles; baca dokumentasi *Doubles* GUT sebelum menulis tes dengan stub.
---
 
## CI (GitHub Actions)
 
Workflow berada di `.github/workflows/ci.yml`. Isi awal yang disarankan:
 
```yaml
name: CI
 
on:
  push:
	branches: [main]
  pull_request:
	branches: [main]
 
concurrency:
  group: ci-${{ github.ref }}
  cancel-in-progress: true
 
env:
  GODOT_VERSION: "4.7.2"   # pin satu versi 4.7.x; ubah di sini saja
 
jobs:
  lint:
	runs-on: ubuntu-latest
	steps:
	  - uses: actions/checkout@v4
	  - uses: actions/setup-python@v5
		with:
		  python-version: "3.12"
	  - run: pip install "gdtoolkit==4.*"
	  - run: gdformat --check autoload sim view tests tools
	  - run: gdlint autoload sim view tests tools
 
  test:
	name: Tes (GUT)
	runs-on: ubuntu-latest
	steps:
	  - uses: actions/checkout@v4
 
	  - name: Pasang Godot
		run: |
		  URL="https://github.com/godotengine/godot/releases/download/${GODOT_VERSION}-stable/Godot_v${GODOT_VERSION}-stable_linux.x86_64.zip"
		  wget -q "$URL" -O godot.zip
		  unzip -q godot.zip
		  chmod +x "Godot_v${GODOT_VERSION}-stable_linux.x86_64"
		  sudo mv "Godot_v${GODOT_VERSION}-stable_linux.x86_64" /usr/local/bin/godot
		  godot --version
 
	  - name: Import proyek
		run: godot --headless --import
 
	  - name: Tes unit, sistem, skenario (GUT)
		run: godot --headless -s addons/gut/gut_cmdln.gd
 
	  # Aktifkan setelah runner tersedia (Sprint 1):
	  # - name: Tes determinism
	  #   run: godot --headless -s tools/run_sim.gd -- --seed 42 --ticks 1000 --check-twice
 
	  - name: Pemeriksaan aturan arsitektur
		run: |
		  if grep -rnE "^extends Node" sim/; then
			echo "sim/ tidak boleh extends Node"; exit 1
		  fi
		  if grep -rnE "\b(randf|randi|randf_range|randi_range)\(" sim/; then
			echo "sim/ tidak boleh memakai RNG global"; exit 1
		  fi
```
 
### Catatan CI
- **Versi Godot dipin lewat `GODOT_VERSION`.** Memakai versi lain di mesin lokal bisa memberi hasil berbeda dari CI.
- **Alternatif:** image Docker `barichello/godot-ci` (rilis `4.7.2-stable` tersedia) bisa dipakai sebagai container job. Skema di atas mengunduh binary resmi supaya langkahnya transparan dan mudah dipelajari.
- **Lint:** `gdtoolkit` 4.x bisa saja belum mengenali sintaks baru dari versi Godot yang sangat baru. Jika `gdlint`/`gdformat` gagal mem-parse file yang valid di Godot, laporkan ke tracker gdtoolkit dan jangan matikan job tanpa alasan tertulis.
- **Langkah `--import`:** diperlukan agar `class_name` dan resource terdaftar sebelum tes berjalan. Jika di lingkungan tertentu langkah ini bermasalah, catat penyebabnya di `docs/`.
- **Branch protection:** aktifkan agar `main` hanya bisa menerima PR yang lulus job `lint` dan `test`.
> Semua versi dan URL di atas wajib diverifikasi saat Sprint 0 (jalankan sekali di CI dan pastikan hijau) sebelum dianggap final.
 
---
 
## Alur Development
 
Singkatnya:
 
```
Issue -> branch feat/SZ-xxx-slug -> tulis tes dulu -> implementasi
	  -> lint + tes lokal -> PR kecil -> CI hijau -> review -> squash merge
```
 
- **Bug:** laporan wajib memuat `seed`, versi/commit, konfigurasi, tick, dan potongan event log. Perbaikan selalu disertai tes regresi.
- **Perubahan kontrak data** (`AgentState`, `WorldState`, skema Event) wajib lewat ADR yang disetujui maintainer.
- Detail lengkap ada di `docs/sprint-plan.md` dan `CONTRIBUTING.md`.
---
 
## Roadmap Sprint

| Sprint | Durasi | Tujuan | Status |
|---|---|---|---|
| [0: Fondasi dan Kontrak](docs/devlog/sprint-0.md) | 3 hari | Repo siap dikontribusi, CI jalan, kontrak data dibekukan | [x] Selesai |
| [1: Inti Simulasi Headless](docs/devlog/sprint-1.md) | 1 minggu | Dunia berdetak, state berubah, tercatat, deterministik | [x] Selesai |
| [2: Aksi, Validasi, Gerak](docs/devlog/sprint-2.md) | 1 minggu | Aksi valid berjalan, aksi tidak valid ditolak dengan alasan | [x] Selesai |
| 3: Utility AI dan Explainability | 1 minggu | Agent memilih aksi sendiri, bisa dijelaskan, kepribadian terlihat | [ ] Direncanakan |
| 4: View, Kontrol, Hardening, Rilis | 1 minggu | Bisa ditonton dan diperiksa; rilis `v0.1.0` | [ ] Direncanakan |

Estimasi total sekitar 4,5 minggu dengan asumsi pengembangan paruh waktu.

**Setelah v0.1:** memori dan relasi antar agent, dialog berbasis template lalu antarmuka `DialogueProvider` (nanti dengan `LLMProvider`), need sosial, save/load, builder eksperimen.

---

## Catatan Development (Devlog)

Catatan teknis mendalam didokumentasikan per sprint:

- [Devlog Sprint 0: Fondasi dan Kontrak](docs/devlog/sprint-0.md) — Setup CI, GUT 9.7.1, kontrak data v0, ADR 001-004.
- [Devlog Sprint 1: Inti Simulasi Headless](docs/devlog/sprint-1.md) — SimClock, NeedsSystem, WorldSystem, 46 tes GUT, benchmark determinisme eksak.
- [Devlog Sprint 2: Aksi, Validasi, Gerak](docs/devlog/sprint-2.md) — ActionLibrary, ActionValidator, MovementSystem A*, ActionSystem, 82 tes GUT, konservasi makanan.
- [Pedoman Devlog](docs/opinion/devlog-guidelines.md) — Aturan penulisan devlog dan jadwal pembaruan README.

---
 
## Kontribusi
 
Kontribusi sangat diterima, terutama di area `view/`, aset, dokumentasi, dan tes tambahan. Area `sim/core` dan skema event dijaga ketat karena memengaruhi reproducibility.
 
Sebelum mengirim PR:
- [ ] Tes baru ditulis dan seluruh tes lulus.
- [ ] Lint dan format lulus.
- [ ] Tidak ada `extends Node` atau RNG global di `sim/`.
- [ ] Dokumentasi/ADR diperbarui bila ada keputusan baru.
Cari issue berlabel `good-first-issue` dan `help-wanted`.
 
---
 
## Referensi
 
- Park et al., *Generative Agents: Interactive Simulacra of Human Behavior*. https://dl.acm.org/doi/10.1145/3586183.3606763
- Dokumentasi GUT: https://gut.readthedocs.io/
- Repo GUT dan tabel kompatibilitas versi: https://github.com/bitwes/Gut
- Dokumentasi Godot: https://docs.godotengine.org/
- GDScript Toolkit (gdtoolkit): https://github.com/Scony/godot-gdscript-toolkit
---
 
## Lisensi
 
Belum ditetapkan. Pilih lisensi kode (dan catat lisensi tiap aset) sebelum menerima kontribusi pertama.
 
