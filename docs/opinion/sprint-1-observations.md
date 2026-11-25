# Opini Sprint 1: Inti Simulasi Headless

Tanggal: 2026-11-25

## Observasi

### 1. Stub kontrak data dari Sprint 0 perlu di-expand signifikan

Stub `AgentState` yang dibuat di Sprint 0 terlalu sederhana dibanding referensi di `version_0.1_concept.md`. Field yang belum ada:
- `display_name`, `starving_ticks`, `home_tile`, `personality`, `path`, `health` sebagai field terpisah (sekarang di dalam `needs` dict).

**Saran:** expand `AgentState` di tiket SZ-103, bukan buat file baru. Ini sesuai scope Sprint 1 karena tiket SZ-103 memang "implementasi WorldState dan AgentState".

### 2. Health: field terpisah vs bagian dari needs dict

Concept doc menyimpan `health` sebagai field terpisah (`var health: float = 100.0`) bukan di dalam `needs` dict. Alasan masuk akal: health bukan "kebutuhan" yang di-decay tiap tick, melainkan **konsekuensi** dari need lain (hunger = 0 → health turun). Menyatukannya di needs dict akan membuat NeedsSystem decay health tiap tick, yang salah.

**Saran:** pindahkan health keluar dari `needs` dict, jadikan field terpisah.

### 3. `WorldState.agents` — Array vs Dictionary

Stub sekarang pakai `Array[AgentState]`. Concept doc pakai `Dictionary` (id → AgentState). Array memaksa linear search untuk `get_agent()`. Dictionary O(1) tapi iterasi order tidak dijamin di Godot.

**Saran:** tetap pakai Array (urutan deterministik), tapi tambahkan `_agent_index: Dictionary` sebagai cache internal yang di-rebuild saat agent ditambahkan. Atau cukup Array karena agent hanya 3-5 di v0.1 — linear search tidak masalah.

### 4. `ActionInstance` belum ada

Concept doc punya `ActionInstance` (data aksi yang sedang berjalan: def, ticks_left, target_tile, started_tick). Ini dibutuhkan Sprint 2 tapi `current_action` di AgentState sekarang hanya StringName. 

**Saran:** buat `ActionInstance` stub di Sprint 1 (SZ-103), set `current_action` tipenya jadi `ActionInstance` nullable. Ini mencegah breaking change di Sprint 2.

### 5. `GridData` — class tersendiri vs Dictionary

Concept doc punya `GridData` sebagai class tersendiri dengan tile types dan walkable info. Stub sekarang cuma `grid: Dictionary` di WorldState.

**Saran:** buat `GridData` class di Sprint 1 (SZ-104) karena dibutuhkan pathfinding di Sprint 2.

### 6. SimConst — centralized constants

Banyak angka tersebar: `TICKS_PER_DAY`, `SECONDS_PER_TICK`, decay rates. Perlu satu tempat.

**Saran:** `sim/core/sim_const.gd` di SZ-101.

### 7. Event log format: concept vs current schema

Concept doc pakai `id`, `type`, `actors` (array), `context`. Current EventSchema pakai `tick`, `event_type`, `agent_id` (singular). 

**Saran:** ikuti concept doc karena lebih fleksibel (event bisa melibatkan >1 agent di masa depan). Tapi rename `type` → `event_type` untuk menghindari clash dengan GDScript keyword.

### 8. Urutan eksekusi tiket

Sprint plan bilang: SZ-103 dan SZ-104 dulu → SZ-102 → SZ-105, SZ-107 → SZ-106 → SZ-108 → SZ-109.

Tapi `SimConst` (SZ-101) dibutuhkan oleh hampir semua tiket. Jadi urutan realistis:

```
SZ-101 (SimConst + SimClock)
  ↓
SZ-103 (AgentState, WorldState, ActionInstance, hash) + SZ-104 (GridData, default_world.json)
  ↓
SZ-102 (Simulation.step())
  ↓
SZ-105 (NeedsSystem) + SZ-107 (WorldSystem siang/malam)
  ↓
SZ-106 (EventLog)
  ↓
SZ-108 (Runner CLI headless)
  ↓
SZ-109 (Tes determinism + invariant checker)
```
