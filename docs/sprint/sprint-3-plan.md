# Sprint 3 Plan: Utility AI dan Explainability

## 1. Tujuan Sprint
Agent secara otonom memilih aksinya sendiri berdasarkan kondisi kebutuhan internal (`needs`), faktor jarak, waktu (siang/malam), dan kepribadian (`personality`). Setiap keputusan tercatat dan dapat dijelaskan (`decision_trace`). Mekanisme commitment bonus dan survival interrupt mencegah ping-pong dan kematian konyol. Tersedia alat ukur metrik perilaku dan sweep seed.

---

## 2. Rincian Tiket & Deliverables

### Fase 1: Kurva Matematis & Pertimbangan (SZ-301)
- **SZ-301: `Curves` (`sim/ai/curves.gd`)**
  - `urgency(need: float) -> float`: kuadratik `(1.0 - clampf(need / 100.0, 0.0, 1.0)) ** 2` (need 100 -> 0.0, need 0 -> 1.0).
  - `distance_factor(tiles: int) -> float`: `1.0 / (1.0 + 0.05 * tiles)`.
  - `manhattan_distance(a: Vector2i, b: Vector2i) -> int`: `abs(a.x - b.x) + abs(a.y - b.y)`.
  - `nearest_tile(from_pos: Vector2i, tiles: Array[Vector2i]) -> Vector2i`.
  - *Tes:* `tests/test_curves.gd`.

---

### Fase 2: Otak Keputusan & Kepribadian (SZ-302, SZ-303, SZ-304, SZ-305)
- **SZ-302 & SZ-304: `UtilityBrain` (`sim/ai/utility_brain.gd`)**
  - Scoring fungsi untuk setiap kandidat aksi:
    - `eat`: `urgency(hunger) * distance_factor(jarak ke lumbung) * (stok > 0 ? 1.0 : 0.0)`
    - `sleep`: `urgency(energy) * (is_night ? 1.5 : 1.0) * distance_factor(jarak ke rumah)`
    - `work_farm`: `kerja_drive * (1.0 - max(urgency(hunger), urgency(energy))) * distance_factor(jarak ke ladang)`
      - `kerja_drive = 0.3 + 0.5 * (conscientiousness / 100.0)`
    - `idle`: lantai skor `0.05`.
  - Toleransi risiko (`risk_tolerance`): memodifikasi penundaan makan.
  - Penambahan noise ber-seed: `rng.randf() * NOISE` (menggunakan RNG simulasi, bukan global).
  - Pengurutan skor dengan tie-breaker deterministik `sort_custom(_compare_scored)`.

- **SZ-303: Commitment Bonus & Survival Interrupt**
  - `COMMIT_BONUS = 0.15`: Menambahkan skor pada aksi yang sedang berjalan.
  - `check_survival_interrupt(agent, world, events) -> bool`:
    - Jika `hunger < 15.0` atau `energy < 10.0`, interupsi aksi non-survival (`work_farm`, `idle`).

- **SZ-305: Explainability & `decision_trace`**
  - `agent.last_decision_trace: Array[Dictionary]` disimpan di `AgentState`.
  - Setiap keputusan menghasilkan event `decision_made` dengan `action_id`, `target_tile`, dan `decision_trace` (3 kandidat teratas).
  - Integrasi ke `Simulation.step()`: agent yang tidak memiliki aksi akan otomatis memanggil `UtilityBrain.decide_and_act(agent, world, rng, events)`.
  - *Tes:* `tests/test_utility_brain.gd`.

---

### Fase 3: Skenario Perilaku & Pengujian (SZ-306)
- **SZ-306: Skenario Perilaku Otonom (`tests/test_behavior_scenarios.gd`)**
  - Skenario 1: Agent lapar (hunger < 30) otomatis memilih pergi ke lumbung dan makan.
  - Skenario 2: Malam hari (night) + energi rendah memprioritaskan tidur di atas bekerja.
  - Skenario 3: Stok lumbung 0 -> `eat` tidak dipilih -> agent memilih bekerja di ladang.
  - Skenario 4: Dua agent dengan `conscientiousness` berbeda (90 vs 10) dievaluasi pada kondisi awal sama; agent rajin memiliki skor kerja lebih tinggi.

---

### Fase 4: Alat Metrik, Sweep Seed, & Tuning Log (SZ-307, SZ-308, SZ-309)
- **SZ-307: Kolektor Metrik Perilaku (`tools/behavior_metrics.gd`)**
  - Menghitung metrik per run:
    - Survival rate (%)
    - Rata-rata switch aksi per hari (deteksi ping-pong)
    - Persentase waktu yang dihabiskan per jenis aksi (`work_farm`, `eat`, `sleep`, `move`, `idle`).

- **SZ-308: Skrip Sweep Seed Headless (`tools/sweep_seeds.gd`)**
  - Menjalankan sweep 20 seed (seed 1 s/d 20) x 3 agent x 5 hari simulasi (720 tick).
  - Menghasilkan ringkasan agregat survival dan rata-rata switch/hari.

- **SZ-309: Tuning Pass 1 & `docs/tuning-log.md`**
  - Dokumentasi baseline metrik awal, penyesuaian parameter bila perlu, dan pencatatan hasil.

---

## 3. Rencana Commit Atomik (Conventional Commits)

1. `feat(ai): tambahkan Curves dan fungsi pertimbangan matematis` (SZ-301)
2. `feat(ai): implementasi UtilityBrain dengan scoring, tie-breaker, dan noise ber-seed` (SZ-302, SZ-304)
3. `feat(ai): tambahkan commitment bonus dan survival interrupt` (SZ-303)
4. `feat(ai): integrasi decision_trace ke AgentState dan Simulation.step()` (SZ-305)
5. `test(ai): tambahkan tes unit untuk Curves dan UtilityBrain`
6. `test(behavior): tambahkan skenario perilaku otonom deterministik` (SZ-306)
7. `feat(tools): tambahkan kolektor behavior_metrics dan runner sweep_seeds` (SZ-307, SZ-308)
8. `docs(tuning): buat tuning-log.md dan catat baseline tuning pass 1` (SZ-309)
9. `docs(devlog): tambahkan devlog sprint 3 dan perbarui README`

---

## 4. Checklist Definition of Done Sprint 3
- [x] Agent otonom memilih aksi tanpa intervensi skrip tes luar.
- [x] Trace keputusan (`decision_trace`) tercatat di event log dan `AgentState`.
- [x] Survival interrupt berhasil membatalkan aksi non-survival saat butuh makan/tidur kritis.
- [x] Sweep 20 seed membuktikan tingkat survival stabil (target >= 80% pada kondisi normal; aktual: 100%).
- [x] Ping-pong aksi berada di bawah ambang wajar (< 20 switch/hari; aktual: 15.5 switch/hari).
- [x] `gdformat --check` dan `gdlint` bersih (0 issues).
- [x] Semua tes GUT unit, sistem, skenario, dan determinisme 100% lulus.
- [x] Aturan arsitektur (`sim/` bebas `Node` dan bebas RNG global) tetap terjaga.
