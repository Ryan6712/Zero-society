# AGENTS.md
 
Panduan untuk AI coding agent (Claude Code, Codex, Cursor, dan sejenisnya) yang bekerja di repo **Society Zero**. Ringkas dan wajib dibaca sebelum mengubah apa pun. Detail lengkap ada di dokumen yang ditautkan.
 
---
 
## 1. Proyek Ini
 
Society Zero adalah **simulator masyarakat buatan deterministik** (2D top-down, gaya Civilization) yang dibuat dengan **Godot 4.7.x** dan **GDScript**. NPC (*agent*) hidup sendiri berdasarkan needs, kepribadian, dan **Utility AI**. Pemain adalah pengamat.
 
Prinsip utama: *jangan menulis skrip cerita; bangun kondisi dan aturan agar masyarakat muncul sendiri.* Hasil simulasi harus **bisa diulang** (seed sama, hasil sama) dan **bisa dijelaskan** (setiap keputusan tercatat beserta alasannya).
 
**Status:** pra-alpha. Target rilis pertama `v0.1.0` ("Hidup di Desa"): 3-5 NPC yang lapar, capek, kerja, makan, dan tidur di peta kecil. Belum ada LLM.
 
---
 
## 2. Peta Dokumen
 
| Butuh apa | Baca |
|---|---|
| Gambaran proyek, stack, struktur repo | `README.md` |
| Rencana sprint, target, Definition of Done | `docs/sprint-plan.md` |
| Alur kerja, testing, rilis | `development.md` |
| Format commit, branching, PR | `committing.md` |
| Gaya kode, arsitektur, determinism | `code-quality.md` |
| Keputusan desain dan ADR | `docs/DESIGN.md` |
| Konsep lengkap (visi jangka panjang) | dokumen konsep Society Zero |
 
Jika dokumen ini bertentangan dengan dokumen di atas, **tanyakan ke maintainer**; jangan memilih sendiri.
 
---
 
## 3. Stack dan Perintah
 
| Komponen | Versi |
|---|---|
| Godot | 4.7.x (patch dipin di `GODOT_VERSION` pada `.github/workflows/ci.yml`) |
| GUT (unit test) | 9.7.x (rilis 9.7.1, di `addons/gut/`) |
| Lint/format | `gdtoolkit` 4.x |
| CI | GitHub Actions |
 
```bash
# import proyek (wajib sebelum tes headless)
godot --headless --import
 
# seluruh tes
godot --headless -s addons/gut/gut_cmdln.gd
 
# satu file tes (cek dokumentasi GUT jika opsi berubah)
godot --headless -s addons/gut/gut_cmdln.gd -gtest=res://tests/test_needs_system.gd
 
 
 
---
 
## 4. Struktur Repo
 
```text
autoload/   SimClock, EventLog (tipis, hanya penghubung)
sim/        simulasi, TANPA Node
  core/       state murni (WorldState, AgentState, ...)
  actions/    ActionDef, ActionLibrary, ActionValidator
  ai/         UtilityBrain, Curves
  systems/    needs, movement, action, world
view/       scene, kamera, AgentView, UI (hanya membaca state)
data/       konfigurasi dunia (JSON)
tests/      tes GUT
tools/      runner headless, skrip sweep seed
docs/       DESIGN.md, ADR, sprint-plan.md, tuning-log.md
addons/gut/ GUT (di-commit)
```
 
---
 
## 5. Aturan Keras (jangan dilanggar)
 
**Arsitektur**
1. `sim/` **tidak boleh** `extends Node`, memakai scene, atau mereferensikan `view/`.
2. State adalah **data murni**. View **tidak menulis state**; input UI masuk lewat command ke `Simulation`.
3. AI hanya **mengusulkan** aksi. `ActionValidator` memeriksa, engine yang mengubah state.
4. Logika simulasi berjalan **per tick** lewat `Simulation.step()`, bukan di `_process`.
**Determinism**
5. Dilarang memakai `randf()`, `randi()`, `randf_range()`, `randi_range()` global di `sim/`. Pakai `RandomNumberGenerator` milik simulasi (di-seed, dikirim sebagai parameter).
6. Iterasi agent berdasarkan `id` terurut.
7. Pengurutan kustom **wajib punya tie-breaker** (mis. bandingkan `id` jika skor sama), karena pengurutan di Godot tidak dijamin stabil.
8. Tidak ada sumber nondeterministik di `sim/`: waktu sistem, `delta` frame, thread, data bergantung platform.
 
**Kontrak dan data**
9. **Jangan mengubah** `AgentState`, `WorldState`, atau skema Event tanpa ADR yang disetujui maintainer.
10. **Jangan mengubah golden hash** tanpa alasan tertulis di commit. Commit `refactor` dan `perf` **tidak boleh** mengubah hasil simulasi.
11. Semua perubahan makanan/sumber daya melewati **satu jalur kode** agar konservasi bisa diaudit.
12. Data dari luar repo memakai **JSON**, bukan `.tres`/`.tscn` (Resource dapat memuat skrip).
 
**Integritas kerja**
13. **Jangan melonggarkan tes, invariant, atau ambang** supaya hasil jadi hijau. Jika tes gagal, perbaiki penyebabnya atau laporkan.
14. **Jangan menambah fitur di luar tiket**, dan jangan merapikan kode yang tidak terkait.
15. **Jangan commit rahasia** (API key, token, `.env`), folder `.godot/`, log di `user://`, atau hasil export.
16. Jangan memasang dependensi/addon baru tanpa PR `chore(deps)` tersendiri dan catatan lisensi.
 
---
 
## 6. Gaya Kode (ringkas)
 
* Nama dalam **Bahasa Inggris**. File/fungsi/variabel `snake_case`, `class_name` `PascalCase`, konstanta `UPPER_SNAKE_CASE`, signal `snake_case` bentuk lampau, anggota privat berawalan `_`.
* **Static typing wajib di `sim/`** (parameter, nilai kembalian, array bertipe).
* Tidak ada magic number: pakai konstanta (`SimConst`) atau data.
* Key JSON dan event log memakai `snake_case` (contoh: `decision_trace`, `action_started`).
* Indentasi **tab**. Fungsi pendek, file di bawah sekitar 300 baris, komentar menjelaskan "kenapa".
* Penolakan aksi dikembalikan sebagai **kode alasan** (enum), bukan string bebas.
Detail: `code-quality.md`.
 
---
 
## 7. Alur Kerja Satu Tiket
 
1. Baca tiket (`SZ-xxx`): tujuan, kriteria selesai, area yang disentuh. Jika tidak jelas, **tanyakan**.
2. Buat branch dari `main`: `feature/SZ-xxx-slug` atau `fix/SZ-xxx-slug`.
3. **Tulis tes dulu** (wajib untuk kode `sim/`; untuk bug, tes regresi).
4. Implementasikan sampai tes lulus.
5. Jalankan format, lint, dan seluruh tes (perintah di bagian 3).
6. Commit atomik dengan **Conventional Commits** (`committing.md`), mis. `feat(actions): tambahkan aksi work_farm`.
7. Buka PR kecil (idealnya di bawah sekitar 400 baris diff) dengan judul Conventional Commits dan `Refs: SZ-xxx`. Jelaskan **dampak ke hasil simulasi**.
### Bug
Reproduksi dengan **seed dan tick**, tulis tes regresi yang gagal, lalu perbaiki. Cantumkan seed/tick di commit.
 
### Tuning perilaku
Tulis target sebelum melihat hasil, ubah **satu parameter per percobaan**, jalankan sweep seed yang sama, catat di `docs/tuning-log.md`. Perubahan parameter dan pembaruan golden hash dipisah ke commit berbeda.
 
---
 
## 8. Definition of Done
 
- [ ] Kriteria selesai tiket terpenuhi.
- [ ] Tes baru lulus dan semua tes lama tetap lulus (benar-benar dijalankan).
- [ ] `gdformat --check` dan `gdlint` lulus.
- [ ] Tidak ada `extends Node` atau RNG global di `sim/`.
- [ ] Dampak ke hasil simulasi dijelaskan di PR.
- [ ] Dokumentasi/ADR diperbarui bila perlu.
---
 
## 9. Kapan Berhenti dan Bertanya
 
Berhenti dan minta arahan maintainer jika:
* tiket menuntut perubahan kontrak data atau skema event;
* hash determinism berubah dan penyebabnya tidak jelas;
* tes gagal dan satu-satunya "perbaikan" adalah melonggarkan tes;
* instruksi di tiket bertentangan dengan aturan keras di atas;
* perilaku Godot/GUT di versi yang dipin tidak bisa diverifikasi.
Lebih baik satu pertanyaan singkat daripada PR besar yang harus dibuang.
 
---
 
## 10. Di Luar Scope v0.1
 
LLM, dialog, relasi sosial, memori kompleks, ekonomi/trade, kelompok, governance, save/load. Jangan memulai pekerjaan ini kecuali ada tiket eksplisit.
  
Jangan mengarang perintah, flag, atau versi. Jika ragu, periksa dokumentasi resmi atau jalankan percobaan kecil. Jangan mengklaim tes lulus tanpa benar-benar menjalankannya.
```
# runner simulasi headless (tersedia mulai Sprint 1)
godot --headless -s tools/run_sim.gd -- --seed 42 --ticks 1000
# format dan lint
gdformat autoload sim view tests tools
gdlint autoload sim view tests tools
```

---

## 11. Checklist Wajib Sebelum Commit

Jalankan semua langkah berikut **sebelum** setiap commit. Jangan commit jika ada yang gagal.

```bash
# 1. Format
gdformat autoload sim view tests tools

# 2. Lint
gdlint autoload sim view tests tools

# 3. Import + tes
godot --headless --import
godot --headless -s addons/gut/gut_cmdln.gd

# 4. Pemeriksaan arsitektur (sim/ tidak boleh extends Node atau pakai RNG global)
grep -rnE "^extends Node" sim/ && echo "GAGAL: extends Node di sim/" && exit 1
grep -rnE "\b(randf|randi|randf_range|randi_range)\(" sim/ && echo "GAGAL: RNG global di sim/" && exit 1
```

Jika `gdformat`/`gdlint` belum terpasang lokal, pasang dengan:
```bash
pip install "gdtoolkit==4.*"
```











