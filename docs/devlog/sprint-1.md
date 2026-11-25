# Devlog: Sprint 1 — Inti Simulasi Headless

- **Tanggal:** 2026-11-25
- **Status:** Selesai
- **Tiket:** SZ-101 s/d SZ-109

## 1. Ringkasan Sprint
Membangun fondasi logika simulasi tanpa visual: waktu tick, state penuh, siklus siang/malam, peluruhan kebutuhan (needs decay), starvation, event log ber-skema, runner CLI, serta pembuktian determinisme eksak.

## 2. Yang Dikerjakan
- **`SimConst` (`sim/core/sim_const.gd`):** Konstanta sentral untuk tick per hari (144), laju peluruhan kebutuhan, dan ambang waktu.
- **`SimClock` (`autoload/sim_clock.gd`):** Pengubah waktu nyata ke tick simulasi dengan akumulator delta dan pembatas tick per frame.
- **Data State (`sim/core/`):**
  - `AgentState`: Memisahkan `health` dari `needs`, menambahkan `personality`, `home_tile`, pelacakan `starving_ticks`, dan hash state.
  - `WorldState`: Pengurutan deterministik ID agent, query waktu/fase hari, dan fungsi serialisasi hash state SHA256.
  - `ActionInstance`: Model runtime aksi yang berjalan untuk persiapan Sprint 2.
  - `GridData`: Representasi tile peta dan status walkability.
- **Orkestrator & Sistem (`sim/`):**
  - `Simulation.step()`: Eksekusi berurutan per tick menggunakan RNG ter-seed.
  - `NeedsSystem`: Peluruhan hunger/energy per tick, logika regenerasi health, dan starvation yang memicu kematian agent.
  - `WorldSystem`: Transisi fase hari (`night`, `dawn`, `day`, `dusk`) berbasis jam simulasi.
- **Event Log (`autoload/event_log.gd`):** Pencatatan event tervalidasi skema ke format JSONL (`.jsonl`).
- **Runner Headless (`tools/run_sim.gd`):** CLI runner untuk menjalankan simulasi headless dengan opsi `--seed`, `--ticks`, dan verifikasi ganda `--check-twice`.

## 3. Hasil Pengujian & Determinisme
- **GUT Unit Test:** 10 script, 46 tests, **46 passed** (0 failed).
- **Linter & Formatter:** `gdformat` & `gdlint` bersih (0 issues).
- **Aturan Arsitektur:** 0 `extends Node` di `sim/`, 0 RNG global.
- **Benchmark Determinisme:**
  - Perintah: `godot --headless -s tools/run_sim.gd -- --seed 42 --ticks 1000 --check-twice`
  - Seed 42 Hash: `22c6754ff237521a9ccc1646ceae8a7574dae35e2eb289f1358b0f15f758817d` (identik di 2x run berurutan).
  - Seed 99 Hash: `68dcad0b0a00a452907cf8a2e3567b471675e571dc41d9c4d956d0ad51284b5b` (berbeda sesuai ekspektasi).
  - Seed 1337 Hash: `6a829f67c6d7cc084a676ba6414b7815dff8ed11c4d92260f486f2edbca16ad7`.

## 4. Masalah & Solusi (Technical Insights)
- **Pengurutan `StringName` di Godot 4.7:**
  - *Masalah:* Pemanggilan `Array[StringName].sort()` tidak mengurutkan berdasarkan abjad string, melainkan pointer/hash internal Godot. Ini menyebabkan urutan iterasi agent tidak alfabetis.
  - *Solusi:* Menggunakan `sort_custom(func(a, b): return String(a) < String(b))` untuk menjamin urutan leksikografis yang deterministik di semua platform.

## 5. Next Steps
- Masuk ke Sprint 2: Aksi, Validasi, dan Gerak (`ActionDef`, `ActionValidator`, `MovementSystem` A*, `ActionSystem`).
