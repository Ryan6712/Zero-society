# Devlog: Phase 0 — Living Foundation

- **Tanggal:** 2026-11-26
- **Status:** Selesai
- **Konsep Acuan:** `docs/concept/society-zero-phase-0-living-foundation.md`
- **Master Plan:** `docs/sprint/phase-0-plan.md`

## 1. Ringkasan
Phase 0: Living Foundation mentransformasikan agen dari sekadar pengulang 3 aksi sederhana menjadi entitas individual otonom yang hidup di dunia fisik dengan sumber daya nyata, kapasitas objek, variasi kepribadian 4 trait, dan kemampuan pulih serta menjelajah.

## 2. Yang Dikerjakan
- **Milestone 0.1 (Needs & Activities):**
  - Menambahkan aktivitas `wander` (berkeliling santai di area terbuka) dan `recover` (memulihkan darah/health di rumah).
  - Konstanta baru di `SimConst` (`RECOVER_DURATION`, `RECOVER_HEALTH_RESTORE`).
- **Milestone 0.2 (Objek Dunia & Okupansi):**
  - `WorldObject`: Model objek dunia interaktif dengan kapasitas dan pelacakan okupansi (`occupy`, `release`, `is_available`).
  - Validasi okupansi di `ActionValidator`: Penolakan `RejectReason.LOCATION_OCCUPIED` saat tempat tidur atau stasiun kerja penuh.
  - Batas kapasitas lumbung (`granary_capacity = 500`) mencegah overflow makanan.
- **Milestone 0.3 (Personality 4 Traits):**
  - Standarisasi 4 trait numerik (0–100): `industrious`, `cautious`, `adventurous`, `lazy`.
  - Integrasi ke skor utility: Adventurous gemar wander, Cautious makan lebih awal & istirahat saat terluka, Industrious gemar kerja.
- **Milestone 0.4 (Scenario A–E & Visual Polish):**
  - Skenario A (`test_scenario_a_survival.gd`): Basic survival hunger & energy.
  - Skenario B (`test_scenario_b_scarcity.gd`): Keterbatasan sumber daya dan adaptasi kerja.
  - Skenario C (`test_scenario_c_interruption.gd`): Interupsi kerja saat energi kritis.
  - Skenario D (`test_scenario_d_personality.gd`): Pembuktian perbedaan tindakan antar-kepribadian.
  - Skenario E (`test_scenario_e_reproducibility.gd`): Pembuktian determinisme eksak.
  - Visualisasi Inspector diperbarui menampilkan keempat sifat kepribadian.

## 3. Hasil Pengujian & Determinisme
- **GUT Tests:** 28 script, 117 tests, **117 passed (100% green)**.
- **Linter & Formatter:** `gdformat` & `gdlint` bersih (0 issues).
- **Aturan Arsitektur:** 0 `extends Node`, 0 RNG global, 0 `Time`/`OS` di `sim/`.
- **Golden Hash Replay (Seed 42, Tick 1000):** `a6e07c22465d66ac18231b4362593280b9750e1bf38d41e93c1077f0d5b50e2b`.
