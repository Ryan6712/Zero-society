# Devlog: Sprint 2 — Aksi, Validasi, dan Gerak

- **Tanggal:** 2026-11-25
- **Status:** Selesai
- **Tiket:** SZ-201 s/d SZ-209

## 1. Ringkasan Sprint
Menerapkan sistem aksi modular (`ActionDef`, `ActionLibrary`), validasi prasyarat aksi dengan kode alasan terstruktur (`RejectReason`), pathfinding grid 4-arah deterministik dengan `AStarGrid2D`, audit konservasi makanan satu jalur di `WorldState`, siklus hidup aksi di `ActionSystem`, skenario scripted terintegrasi, dan fuzz testing 2000 tick.

## 2. Yang Dikerjakan
- **Aksi & Library (`sim/actions/`):**
  - `ActionDef`: Resource definisi aksi data-driven (`id`, `duration_ticks`, `interruptible`, `required_location`, `min_energy`, `energy_cost_per_tick`, `hunger_cost_per_tick`).
  - `ActionLibrary`: Katalog statis 5 aksi v0.1 (`idle`, `move`, `eat`, `sleep`, `work_farm`).
- **Validasi Terstruktur (`sim/actions/action_validator.gd`):**
  - Enum `RejectReason`: `OK`, `NOT_ALIVE`, `ALREADY_ACTING`, `NOT_AT_LOCATION`, `NO_STOCK`, `LOW_ENERGY`, `NO_PATH`, `INVALID_TARGET`, `UNKNOWN_ACTION`.
  - Pengecekan ketat status hidup, lokasi required tile, kecukupan energi, dan ketersediaan stok lumbung.
- **Pathfinding & Gerak (`sim/systems/movement_system.gd`):**
  - Integrasi `AStarGrid2D` mode orthogonal `DIAGONAL_MODE_NEVER` (4 arah) berbasis `GridData`.
  - Gerak 1 tile per tick secara deterministik.
- **Konservasi Sumber Daya (`sim/core/world_state.gd`):**
  - Satu jalur audit: `modify_granary_food(delta, reason, agent_id, events)`.
  - Invariant: `initial_granary_food + total_food_produced - total_food_consumed == granary_food`.
- **Siklus Hidup Aksi (`sim/systems/action_system.gd`):**
  - Siklus penuh: `start_action` -> `update` -> `_complete_action` atau `interrupt`.
  - Konsumsi dan efek (mis. `work_farm` menghasilkan +1 makanan, `eat` mengonsumsi 1 makanan dan memulihkan 40 hunger, `sleep` memulihkan energi).
- **Pengujian & Fuzzing (`tests/`):**
  - `test_scripted_scenario.gd`: Pengujian skenario gerak ke ladang -> kerja -> gerak ke lumbung -> makan -> tidur di rumah.
  - `test_invariants.gd`: Invariant checker v2 memastikan konservasi makanan, posisi walkable, dan status agent mati.
  - `test_fuzz.gd`: Stress test 2000 tick aksi acak pada seed 42, 99, 1337 (total 72.000+ asserts).

## 3. Hasil Pengujian & Determinisme
- **GUT Unit Test:** 16 script, 82 tests, **82 passed** (0 failed).
- **Linter & Formatter:** `gdformat` & `gdlint` bersih (0 issues).
- **Aturan Arsitektur:** 0 `extends Node`, 0 RNG global, 0 `Time`/`OS` di `sim/`.
- **Benchmark Determinisme:**
  - Seed 42: `42e1a2be5fd131eaab06369b5666034fdc34a150993b5efbea5b50c47c457fce`
  - Seed 99: `30a294f4d2aa1ca9d79b1ee4f30a3af4ce0992d8a7521921f5019b7bcfc40137`
  - Seed 1337: `39a21ae2bb98e8134a287112855a69e45dacca3b75bee09c9489a52f03b55006`

## 4. Masalah & Solusi (Technical Insights)
- **Bug Pembersihan State Agent Mati:**
  - *Masalah:* Fuzz test mendeteksi bahwa jika agent mati kelaparan saat sedang bergerak, `agent.path` tidak dikosongkan.
  - *Solusi:* Menambahkan `agent.path.clear()` di `NeedsSystem._decay` saat `health <= 0`.

## 5. Next Steps
- Masuk ke Sprint 3: Utility AI dan Explainability (`Curves`, `UtilityBrain.choose()`, commitment bonus, survival interrupt, personality weighting, `decision_trace`).
