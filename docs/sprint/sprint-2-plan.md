# Sprint 2 Plan: Aksi, Validasi, dan Gerak

## 1. Tujuan Sprint
Agent dapat melakukan aksi yang valid di dunia (`idle`, `move`, `eat`, `sleep`, `work_farm`), dan engine selalu menolak aksi yang tidak valid dengan kode alasan terstruktur (`RejectReason`). Semua perubahan makanan diaudit lewat satu jalur tunggal untuk menjaga konservasi sumber daya. Pathfinding grid deterministik dengan `AStarGrid2D`.

---

## 2. Rincian Tiket & Deliverables

### Fase 1: Definisi & Validasi Aksi (SZ-201, SZ-202)
- **SZ-201: `ActionDef` & `ActionLibrary` (`sim/actions/`)**
  - Perluas `ActionDef`: `id`, `display_name`, `duration_ticks`, `interruptible`, `required_location`, `min_energy`, `energy_cost_per_tick`, `hunger_cost_per_tick`.
  - Buat `ActionLibrary`: singleton/static catalog untuk 5 aksi v0.1:
    - `&"idle"`: durasi 1 tick, tanpa syarat lokasi.
    - `&"move"`: durasi 1 tick per tile, tanpa syarat lokasi khusus.
    - `&"eat"`: durasi 2 tick, lokasi `GridData.TILE_GRANARY`, butuh granary_food > 0, efek: hunger +40, food -1.
    - `&"sleep"`: durasi dinamis/per tick, lokasi `GridData.TILE_HOUSE`, efek: energy +1.2 per tick.
    - `&"work_farm"`: durasi 6 tick, lokasi `GridData.TILE_FARM`, min_energy 20.0, efek: energy turun, saat selesai +1 food ke lumbung.
  - *Tes:* `tests/test_action_library.gd`

- **SZ-202: `ActionValidator` (`sim/actions/action_validator.gd`)**
  - Enum `RejectReason`:
    `OK`, `NOT_ALIVE`, `ALREADY_ACTING`, `NOT_AT_LOCATION`, `NO_STOCK`, `LOW_ENERGY`, `NO_PATH`, `INVALID_TARGET`, `UNKNOWN_ACTION`.
  - Fungsi `can_start(agent: AgentState, def: ActionDef, world: WorldState, target_tile: Vector2i) -> RejectReason`.
  - Validasi ketat prasyarat (apakah agent hidup, apakah di lokasi yang tepat, apakah energi cukup, apakah stok lumbung cukup untuk makan).
  - *Tes:* `tests/test_action_validator.gd` (uji semua cabang penolakan dan jalur sukses).

---

### Fase 2: Pathfinding & Movement (SZ-203)
- **SZ-203: `MovementSystem` & `AStarGrid2D` (`sim/systems/movement_system.gd`)**
  - Pembangun `AStarGrid2D` dari `GridData`:
    - Ukuran grid sesuai `grid_data.width` x `grid_data.height`.
    - Set solid pada tile yang tidak walkable (seperti `water` atau di luar batas).
    - `diagonal_mode = AStarGrid2D.DIAGONAL_MODE_NEVER` (orthogonal 4 arah saja).
  - Fungsi `find_path(from_pos: Vector2i, to_pos: Vector2i, grid_data: GridData) -> Array[Vector2i]`.
  - Fungsi `update(agent: AgentState, world: WorldState) -> void`:
    - Jika `agent.path` tidak kosong: ambil tile berikutnya, perbarui `agent.position`.
    - Jika target tercapai: kosongkan path.
  - *Tes:* `tests/test_movement_system.gd` (jalur normal, jalur terhalang, target sama dengan posisi, target di luar peta).

---

### Fase 3: Siklus Hidup Aksi & Konservasi Makanan (SZ-204, SZ-205, SZ-207)
- **SZ-205: Konservasi Makanan di `WorldState` (`sim/core/world_state.gd`)**
  - Tambah pelacakan audit di `WorldState`:
    `var total_food_produced: int = 0`
    `var total_food_consumed: int = 0`
    `var initial_granary_food: int = 20`
  - Fungsi tunggal audit:
    `modify_granary_food(delta: int, reason: StringName, events: Array[Dictionary]) -> bool`
    - Memastikan stok tidak negatif.
    - Mencatat delta ke akumulator audit dan emit event `food_produced` / `food_consumed`.

- **SZ-204: `ActionSystem` (`sim/systems/action_system.gd`)**
  - Siklus hidup aksi:
    1. `start_action(agent, def, world, target_tile, events) -> RejectReason`
    2. `update(agent, world, rng, events) -> void`
       - Mengurangi `ticks_left`.
       - Menjalankan efek berkala per tick (seperti regenerasi energi saat `sleep`).
       - Saat selesai (`ticks_left == 0`), jalankan efek akhir (`eat` memulihkan hunger + konsumsi stok via jalur audit; `work_farm` memproduksi +1 makanan ke lumbung via jalur audit).
       - Emit event `action_started`, `action_completed`.
    3. `interrupt_action(agent, world, reason, events) -> bool`
       - Batalkan aksi yang sedang berjalan jika `def.interruptible == true`.
       - Emit event `action_interrupted`.

- **SZ-207: Pembersihan State Agent Mati (`NeedsSystem` & `ActionSystem`)**
  - Bila agent mati kelaparan: batalkan aksi yang sedang berjalan, kosongkan jalur gerak (`path.clear()`), dan jangan pernah diproses lagi di sistem aksi/gerak.
  - *Tes:* `tests/test_action_system.gd`

---

### Fase 4: Harness Scripted, Invariants, & Fuzzing (SZ-206, SZ-208, SZ-209)
- **SZ-206: Skenario Scripted (`tests/test_scripted_scenario.gd`)**
  - Skenario pengujian lengkap:
    1. Agent bergerak ke ladang (`FARM`).
    2. Agent bekerja (`work_farm`) selama 6 tick -> stok lumbung bertambah 1.
    3. Agent bergerak ke lumbung (`GRANARY`).
    4. Agent makan (`eat`) -> stok lumbung berkurang 1, hunger bertambah 40.
    5. Agent bergerak ke rumah (`HOUSE`) dan tidur (`sleep`) -> energi pulih.

- **SZ-208: Invariant Checker v2 (`tests/test_invariants.gd`)**
  - Verifikasi otomatis per tick:
    1. `granary_food >= 0`
    2. **Konservasi Makanan:** `initial_granary_food + total_food_produced - total_food_consumed == granary_food`
    3. Semua agent hidup berada di tile yang `is_walkable == true`
    4. Agent mati tidak memiliki `current_action` dan `path` kosong
    5. Nilai needs selalu berada pada rentang [0, 100]

- **SZ-209: Fuzz Testing Aksi Acak (`tests/test_fuzz.gd`)**
  - Jalankan simulasi dengan agent yang mengambil aksi acak ber-seed selama 2000 tick di beberapa seed berbeda.
  - Membuktikan bahwa validator dan sistem aksi tidak pernah crash, tidak mengalami deadlock, dan tidak melanggar satupun invariant sistem.

---

## 3. Rencana Commit Atomik (Conventional Commits)

1. `feat(actions): tambahkan ActionDef diperluas dan katalog ActionLibrary` (SZ-201)
2. `feat(actions): implementasi ActionValidator dengan enum RejectReason terstruktur` (SZ-202)
3. `feat(movement): implementasi MovementSystem dan AStarGrid2D 4-arah` (SZ-203)
4. `feat(core): tambahkan audit konservasi makanan satu jalur di WorldState` (SZ-205)
5. `feat(actions): implementasi ActionSystem siklus hidup, efek, dan interupsi` (SZ-204, SZ-207)
6. `test(scenarios): tambahkan tes skenario scripted gerak, kerja, makan, tidur` (SZ-206)
7. `test(invariants): perbarui Invariant Checker v2 dengan audit konservasi makanan` (SZ-208)
8. `test(fuzz): tambahkan fuzz test 2000 tick pada berbagai seed` (SZ-209)

---

## 4. Checklist Definition of Done Sprint 2
- [ ] Skenario scripted lulus tanpa kegagalan.
- [ ] Semua penolakan aksi mengembalikan kode `RejectReason` yang tepat.
- [ ] Konservasi makanan terbukti matematis lewat invariant checker.
- [ ] Fuzz test 2000 tick lulus pada berbagai seed tanpa pelanggaran invariant.
- [ ] `gdformat --check` dan `gdlint` bersih (0 error).
- [ ] Semua tes GUT unit & sistem lulus (100% green).
- [ ] Aturan arsitektur (`sim/` bebas `Node` dan bebas RNG global) tetap terpenuhi.
