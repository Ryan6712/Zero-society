# Devlog: Sprint 3 — Utility AI dan Explainability

- **Tanggal:** 2026-11-25
- **Status:** Selesai
- **Tiket:** SZ-301 s/d SZ-309

## 1. Ringkasan Sprint
Membangun sistem kecerdasan buatan berbasis utilitas (`UtilityBrain`, `Curves`), pemilihan aksi otonom berdasar kebutuhan, jarak, dan kepribadian, tie-breaker deterministik, mekanisme anti ping-pong (`COMMIT_BONUS`), interupsi kebutuhan kritis (`survival interrupt`), pencatatan jejak keputusan (`decision_trace`), serta instrumen pengukuran perilaku (`behavior_metrics`, `sweep_seeds`, dan `tuning-log.md`).

## 2. Yang Dikerjakan
- **Kurva Matematis (`sim/ai/curves.gd`):**
  - Kurva kuadratik urgensi `(1.0 - need/100)^2` untuk kebutuhan hunger dan energy.
  - Faktor diskon jarak `1.0 / (1.0 + 0.05 * tiles)` dan helper jarak Manhattan.
- **Otak Keputusan (`sim/ai/utility_brain.gd`):**
  - Evaluasi skor untuk aksi `eat`, `sleep`, `work_farm`, dan `idle`.
  - Bobot kepribadian: `conscientiousness` memengaruhi dorongan kerja, `risk_tolerance` memodifikasi toleransi lapar.
  - Penambahan noise ber-seed dari `rng.randf()` milik `Simulation` (tanpa RNG global).
  - Pengurutan skor stabil dengan tie-breaker deterministik `sort_custom(_compare_scored)`.
- **Anti Ping-Pong & Survival Interrupt:**
  - `COMMIT_BONUS = 0.15`: Bonus skor bagi aksi yang sedang berjalan.
  - `check_survival_interrupt`: Interupsi otomatis aksi non-survival saat hunger < 15.0 atau energy < 10.0.
- **Explainability (`decision_trace`):**
  - Setiap keputusan menyimpan 3 kandidat teratas di `agent.last_decision_trace` dan memancarkan event `decision_made`.
  - Terintegrasi langsung di `Simulation.step()`.
- **Instrumen Sweep & Tuning (`tools/`):**
  - `tools/behavior_metrics.gd`: Menghitung survival rate, switch/hari, dan distribusi waktu aksi.
  - `tools/sweep_seeds.gd`: CLI runner untuk sweep 20 seed x 720 ticks (5 hari simulasi).
  - `docs/tuning-log.md`: Dokumentasi baseline pass 1 (100% survival, 15.5 switch/hari).

## 3. Hasil Pengujian & Determinisme
- **GUT Unit Test:** 19 script, 96 tests, **96 passed (100% green)**.
- **Linter & Formatter:** `gdformat` & `gdlint` bersih (0 issues).
- **Aturan Arsitektur:** 0 `extends Node`, 0 RNG global, 0 `Time`/`OS` di `sim/`.
- **Hasil Sweep 20 Seed (5 hari simulasi):**
  - Rata-rata Survival: **100.0%**
  - Rata-rata Pergantian Aksi: **15.5 / hari**
  - Rata-rata Sisa Stok Lumbung: **209.0 food** (surplus berkelanjutan)

## 4. Next Steps
- Masuk ke Sprint 4: View, Kontrol, Hardening, Rilis (`world_view`, `AgentView`, time controls, HUD, Agent Inspector dengan tampilan decision trace, dan rilis `v0.1.0`).
