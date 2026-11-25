# Devlog: Sprint 4 — View, Kontrol, Hardening, dan Rilis v0.1.0

- **Tanggal:** 2026-11-25
- **Status:** Selesai
- **Tiket:** SZ-401 s/d SZ-411

## 1. Ringkasan Sprint
Mengintegrasikan seluruh subsistem simulasi ke antarmuka visual Godot: `WorldView`, `AgentView` dengan interpolasi tween gerak halus, panel `TimeControls` (pause, 1x s/d 8x), `HUD` global, `AgentInspector` dengan visualisasi *decision trace*, command pattern untuk debug, pembuktian isolasi state (view vs headless), smoke test performa, pembekuan golden replay, dan finalisasi rilis `v0.1.0`.

## 2. Yang Dikerjakan
- **Antarmuka Visual (`view/`):**
  - `WorldView`: Render kisi tile 16x16px (`grass`, `farm`, `house`, `granary`, `water`) berdasarkan `GridData`.
  - `AgentView`: Menampilkan sprite karakter Sunnyside World, modulasi warna pembeda per agent, dan interpolasi tween posisi antar-tile.
  - `CameraController`: Navigasi pan drag mouse tengah dan zoom scroll.
- **Panel Kontrol & HUD (`view/ui/`):**
  - `TimeControls`: Tombol kecepatan simulasi (Pause, 1x, 2x, 4x, 8x) dan shortcut keyboard (Space, 1-4).
  - `HUD`: Informasi dinamis siklus hari, jam, fase hari, status populasi hidup, dan stok lumbung.
  - `AgentInspector`: Rincian mendalam saat agent diklik (nama, status, progress bar needs 0-100, aksi aktif, kepribadian, dan 3 kandidat teratas dari `decision_trace`).
- **Command Queue (`sim/core/`):**
  - `Command` & `AddFoodCommand`: Memungkinkan tombol UI debug mengirim permintaan manipulasi stok tanpa melanggar prinsip ADR-002 (view tidak menulis state langsung).
- **Hardening & Testing:**
  - `test_view_state_isolation.gd`: Membuktikan bahwa hash simulasi dengan view aktif identik 100% dengan eksekusi headless.
  - `test_perf_smoke.gd`: Mengukur 1000 tick pada 5 agent selesai dalam 224 ms (0.224 ms/tick).
  - `test_golden_replay.gd`: Membekukan golden hash resmi `c874cbf4d7170a66ff406e19f7d63513330af028ba49d7d4b37048205bc80e01` untuk seed 42 pada tick 1000.

## 3. Hasil Pengujian & Benchmark
- **GUT Unit Test:** 22 script, 100 tests, **100 passed (100% green)**, 141.621 asserts.
- **Linter & Formatter:** `gdformat` & `gdlint` bersih (0 issues).
- **Aturan Arsitektur:** 0 `extends Node`, 0 RNG global, 0 `Time`/`OS` di `sim/`.
- **Smoke Perf:** 0.224 ms/tick (< 2.0 ms ambang batas).
- **Golden Hash Replay (Seed 42, Tick 1000):** PASS.

## 4. Status Rilis v0.1.0 ("Hidup di Desa")
Target milestone v0.1.0 tercapai secara lengkap: 3-5 NPC hidup mandiri, bekerja di ladang, makan di lumbung, tidur di rumah, menolak aksi tidak valid, semua keputusan dapat dijelaskan dan ditelusuri lewat inspector, serta hasil simulasi identik 100% untuk seed yang sama.
