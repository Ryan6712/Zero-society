# Sprint 1 Plan: Inti Simulasi Headless

## Tujuan
Dunia berdetak tanpa tampilan. State berubah sesuai aturan, kejadian penting tercatat, hasil deterministik.

## Deliverables
- `godot --headless -s tools/run_sim.gd -- --seed 42 --ticks 1000` jalan tanpa error, cetak hash
- Seed sama → hash identik. Seed beda → hash beda.
- Agent tanpa makan → `need_critical` → starvation → `agent_died` di log
- Semua tes GUT hijau

---

## Tiket & Urutan Eksekusi

### Fase 1: Fondasi (SZ-101, SZ-103, SZ-104)

#### SZ-101: SimConst + SimClock
**File:** `sim/core/sim_const.gd`, `autoload/sim_clock.gd`

SimConst — konstanta sentral:
- `TICKS_PER_DAY = 144` (1 tick = 10 menit)
- `SECONDS_PER_TICK = 0.25`
- `MAX_TICKS_PER_FRAME = 20`
- Decay rates: `HUNGER_DECAY = 0.35`, `ENERGY_DECAY = 0.25`
- `STARVING_HEALTH_LOSS = 2.0`
- `HEALTH_REGEN_THRESHOLD = 50.0`, `HEALTH_REGEN_RATE = 0.1`

SimClock — autoload Node:
- `signal ticked(tick: int)`
- `speed: float` (0 = pause, 1 = normal, 2/4/8 = fast)
- `_process(delta)` accumulate → emit ticked
- Reference ke `Simulation` instance, panggil `step()` per tick

**Test:** `tests/test_sim_const.gd` — validasi konstanta masuk akal

---

#### SZ-103: WorldState, AgentState, ActionInstance, hash
**File:** expand existing `sim/core/agent_state.gd`, `sim/core/world_state.gd`, baru: `sim/core/action_instance.gd`

AgentState expand:
- Tambah `display_name: String`
- Pindahkan `health: float = 100.0` keluar dari needs dict
- Tambah `starving_ticks: int = 0`
- Tambah `home_tile: Vector2i`
- Tambah `personality: Dictionary` (conscientiousness, risk_tolerance, ambition)
- Ubah `current_action` dari StringName → `ActionInstance` nullable
- Tambah `path: Array[Vector2i]`
- Update `to_dict()` dan tambah `compute_hash() -> String`

ActionInstance baru:
- `def: ActionDef`
- `ticks_left: int`
- `target_tile: Vector2i`
- `started_tick: int`

WorldState expand:
- Tambah `next_event_id: int = 0`
- Tambah `sorted_agent_ids() -> Array[StringName]`
- Tambah `hour_of_day() -> float`
- Tambah `is_night() -> bool`
- Tambah `compute_hash() -> String` (SHA256 dari JSON serialisasi terurut)

**Test:** `tests/test_agent_state.gd`, `tests/test_world_state.gd`
- Serialisasi roundtrip
- Hash konsisten untuk state yang sama
- Hash berbeda untuk state yang berbeda

---

#### SZ-104: GridData + default_world.json
**File:** `sim/core/grid_data.gd`, `data/default_world.json`

GridData:
- `width: int`, `height: int`
- `tiles: Dictionary` (Vector2i → StringName tile type)
- Tile types: `GRASS`, `FARM`, `HOUSE`, `GRANARY`, `WATER`
- `is_walkable(pos: Vector2i) -> bool`
- `get_locations_of_type(type: StringName) -> Array[Vector2i]`
- `static func from_dict(data: Dictionary) -> GridData`

default_world.json:
- Peta kecil (16x12 tiles)
- 1 HOUSE, 1 FARM, 1 GRANARY, sisanya GRASS, beberapa WATER
- `seed: 42`, `agent_count: 3`, `granary_food: 20`

**Test:** `tests/test_grid_data.gd`
- Load dari dict, cek tile types, walkable

---

### Fase 2: Orkestrator (SZ-102)

#### SZ-102: Simulation.step()
**File:** `sim/simulation.gd`

- `extends RefCounted`
- `var world: WorldState`
- `var rng: RandomNumberGenerator`
- `_init(config: Dictionary)` — seed RNG, buat WorldState, spawn agents
- `step()`:
  1. `world.tick += 1`
  2. `WorldSystem.update(world, rng)`
  3. `NeedsSystem.update(world)`
  4. For agent in sorted order: skip dead, (nanti: ActionSystem, MovementSystem)
- Load config dari `default_world.json`

**Test:** `tests/test_simulation.gd`
- step() increments tick
- agents processed in sorted order

---

### Fase 3: Sistem (SZ-105, SZ-107)

#### SZ-105: NeedsSystem
**File:** `sim/systems/needs_system.gd`

- `static func update(world: WorldState) -> void`
- Per agent (alive):
  - hunger -= HUNGER_DECAY per tick
  - energy -= ENERGY_DECAY per tick
  - Clamp needs 0-100
  - If hunger <= 0: `starving_ticks += 1`, health -= STARVING_HEALTH_LOSS
  - If hunger > HEALTH_REGEN_THRESHOLD: health += HEALTH_REGEN_RATE
  - Clamp health 0-100
  - If health <= 0: `alive = false` (catat event agent_died)

**Test:** `tests/test_needs_system.gd`
- Decay rate sesuai rumus
- Hunger tidak turun di bawah 0
- Starvation → health turun → agent dies
- Energy clamp 0-100

---

#### SZ-107: WorldSystem (siang/malam)
**File:** `sim/systems/world_system.gd`

- `static func update(world: WorldState, _rng: RandomNumberGenerator) -> void`
- Hitung `hour_of_day()`, set `day_phase` → `day`, `night`, `dawn`, `dusk`

**Test:** `tests/test_world_system.gd`
- Phase transitions correct at right ticks

---

### Fase 4: Logging (SZ-106)

#### SZ-106: EventLog
**File:** `autoload/event_log.gd`

- Autoload Node
- `var events: Array[Dictionary]`
- `func log_event(event: Dictionary) -> void` — validate schema, assign id, append
- `func save_to_file(path: String) -> void` — write as JSONL
- `func get_events_for_agent(agent_id: StringName) -> Array[Dictionary]`

**Test:** `tests/test_event_log.gd`
- Event tanpa required field ditolak
- Event valid tersimpan
- JSONL output valid

---

### Fase 5: Runner + Tes (SZ-108, SZ-109)

#### SZ-108: Runner CLI headless
**File:** `tools/run_sim.gd`

- `extends SceneTree` atau `MainLoop`
- Parse args: `--seed`, `--ticks`
- Buat `Simulation`, jalankan N step
- Print hash dan ringkasan (tick, agents alive, granary food)
- Exit

---

#### SZ-109: Tes determinism + invariant checker
**File:** `tests/test_determinism.gd`, `tests/test_invariants.gd`

Determinism:
- Run seed 42, 1000 ticks, record hash
- Run seed 42, 1000 ticks again, compare hash → identical
- Run seed 99, 1000 ticks, compare hash → different

Invariant checker:
- After each tick: needs in [0, 100], health in [0, 100]
- granary_food >= 0
- Dead agents have no current_action

---

## Commit Plan (semua Conventional Commits)

1. `feat(core): tambahkan SimConst dengan konstanta simulasi` — SZ-101 part 1
2. `feat(clock): tambahkan SimClock autoload` — SZ-101 part 2
3. `feat(core): expand AgentState dan tambahkan ActionInstance` — SZ-103 part 1
4. `feat(core): expand WorldState dengan hash dan helper` — SZ-103 part 2
5. `feat(core): tambahkan GridData dan default_world.json` — SZ-104
6. `feat(core): tambahkan Simulation.step() orkestrator` — SZ-102
7. `feat(needs): tambahkan NeedsSystem decay dan starvation` — SZ-105
8. `feat(world): tambahkan WorldSystem siang/malam` — SZ-107
9. `feat(events): tambahkan EventLog autoload dengan validasi skema` — SZ-106
10. `feat(tools): tambahkan runner CLI headless` — SZ-108
11. `test(determinism): tambahkan tes determinism dan invariant checker` — SZ-109

## Definition of Done
- [ ] `run_sim.gd --seed 42 --ticks 1000` jalan, cetak hash
- [ ] Seed sama → hash identik
- [ ] Seed beda → hash beda
- [ ] NeedsSystem: decay sesuai rumus, starvation → death
- [ ] EventLog: event valid tersimpan, skema divalidasi
- [ ] Semua tes GUT hijau
- [ ] Tidak ada `extends Node` di sim/
- [ ] Tidak ada RNG global di sim/
- [ ] gdformat + gdlint lulus
