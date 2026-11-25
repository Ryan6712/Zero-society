# Society Zero: Struktur Minggu 1-2
 
**Fokus:** fondasi simulasi (state + utility AI), belum ada LLM.
**Engine:** Godot 4.3+ (butuh `TileMapLayer` dan `AStarGrid2D`), GDScript.
**Bentuk game:** 2D top-down, tile-based, gaya Civilization: pemain adalah pengamat (kamera bebas, pause, speed, klik NPC untuk inspect). NPC jalan sendiri.
 
---
 
## 1. Tujuan dan Batas Scope
 
### Target akhir minggu 2
Satu peta kecil dengan **3 sampai 5 NPC** yang hidup sendiri: lapar, capek, pergi kerja di ladang, makan di lumbung, tidur di rumah. Semua keputusan bisa ditelusuri lewat event log dan hasilnya **identik jika seed sama**.
 
### Masuk scope
- Simulation clock dan tick loop yang terpisah dari rendering.
- `WorldState` dan `AgentState` sebagai data murni.
- Needs system (lapar, energi, kesehatan).
- Aksi: `idle`, `move`, `eat`, `sleep`, `work_farm`.
- Utility AI untuk memilih aksi.
- Pathfinding `AStarGrid2D`.
- Event log dengan jejak keputusan (decision trace).
- Kamera, time controls, agent inspector sederhana.
- Seed dan tes reproducibility.
### Belum masuk scope (sengaja ditunda)
LLM, dialog, relasi sosial, memori kompleks, ekonomi/trade, kelompok, governance, save/load, UI mewah, banyak jenis tile. Semua itu minggu 3 ke atas.
 
---
 
## 2. Keputusan Arsitektur (jangan dilanggar)
 
1. **Sim core tidak boleh tahu soal Node/visual.** State dan sistem berupa `RefCounted`/`Resource`. Visual hanya membaca state dan menggambar. Ini sejalan dengan prinsip di dokumen konsep: presentation layer bukan tempat aturan simulasi.
2. **Logika simulasi jalan per tick, bukan per frame.** Jangan taruh logika keputusan di `_process`.
3. **Satu sumber randomness.** Hanya pakai `RandomNumberGenerator` milik simulasi yang di-seed. Dilarang memanggil `randf()`/`randi()` global di sim core.
4. **Urutan eksekusi agent harus tetap.** Iterasi berdasarkan `id` terurut, supaya hasil deterministik.
5. **Engine memvalidasi semua aksi.** Agent/AI hanya mengusulkan. Nanti saat LLM masuk, aturan ini tidak perlu diubah.
6. **Setiap keputusan dicatat beserta alasannya** (skor kandidat teratas), bukan dikarang setelah kejadian.
---
 
## 3. Struktur Folder
 
```
society_zero/
├─ project.godot
├─ autoload/
│  ├─ sim_clock.gd          # waktu nyata -> tick, pause/speed
│  └─ event_log.gd          # tulis event ke user://logs/*.jsonl
├─ sim/                     # TIDAK boleh extends Node
│  ├─ simulation.gd         # orkestrator: step() per tick
│  ├─ core/
│  │  ├─ world_state.gd
│  │  ├─ agent_state.gd
│  │  ├─ action_instance.gd
│  │  └─ grid_data.gd       # tile type, walkable, lokasi fungsional
│  ├─ actions/
│  │  ├─ action_def.gd
│  │  ├─ action_library.gd  # daftar aksi minggu 1-2
│  │  └─ action_validator.gd
│  ├─ ai/
│  │  ├─ utility_brain.gd
│  │  └─ curves.gd
│  └─ systems/
│     ├─ needs_system.gd
│     ├─ movement_system.gd
│     ├─ action_system.gd
│     └─ world_system.gd    # siang/malam, produksi ladang
├─ view/
│  ├─ world_view.tscn/.gd   # TileMapLayer + spawn AgentView
│  ├─ agent_view.tscn/.gd   # Sprite2D, ikuti AgentState
│  ├─ camera_controller.gd  # pan, zoom
│  └─ ui/
│     ├─ hud.tscn
│     ├─ time_controls.tscn
│     └─ agent_inspector.tscn
├─ data/
│  └─ default_world.json    # ukuran peta, posisi lokasi, jumlah agent, seed
├─ tests/
│  └─ determinism_test.gd   # jalankan 2x seed sama, bandingkan hash
└─ docs/
   └─ DESIGN.md             # catatan keputusan desain
```
 
Aset: cukup tileset kecil CC0 (mis. Kenney.nl) dan satu sprite NPC. Jangan habiskan waktu di aset.
 
---
 
## 4. Waktu dan Tick Loop
 
- `TICKS_PER_DAY = 144` (1 tick = 10 menit simulasi). Bisa diubah lewat config.
- `SimClock` (autoload) mengubah waktu nyata menjadi tick, lalu memancarkan signal.
- Beri batas maksimum tick per frame agar tidak "spiral of death" saat speed tinggi.
```gdscript
# autoload/sim_clock.gd
extends Node
 
signal ticked(tick: int)
 
const SECONDS_PER_TICK := 0.25   # pada speed 1x
const MAX_TICKS_PER_FRAME := 20
 
var tick: int = 0
var speed: float = 1.0           # 0 = pause
var _accum: float = 0.0
 
func _process(delta: float) -> void:
    if speed <= 0.0:
        return
    _accum += delta * speed
    var n := 0
    while _accum >= SECONDS_PER_TICK and n < MAX_TICKS_PER_FRAME:
        _accum -= SECONDS_PER_TICK
        tick += 1
        n += 1
        ticked.emit(tick)
```
 
Orkestrator simulasi:
 
```gdscript
# sim/simulation.gd
class_name Simulation
extends RefCounted
 
var world: WorldState
var rng := RandomNumberGenerator.new()
 
func _init(config: Dictionary) -> void:
    rng.seed = config.seed
    world = WorldState.from_config(config)
 
func step() -> void:
    world.tick += 1
    WorldSystem.update(world, rng)          # siang/malam, produksi
    NeedsSystem.update(world)               # decay lapar/energi
    for id in world.sorted_agent_ids():     # urutan tetap!
        var agent: AgentState = world.agents[id]
        if not agent.alive:
            continue
        ActionSystem.update(agent, world, rng)   # lanjut/pilih/eksekusi aksi
        MovementSystem.update(agent, world)
```
 
---
 
## 5. State
 
### Konvensi penting
**Semua need berskala 0-100 dengan arti: 100 = terpenuhi penuh, 0 = kritis.** (Dokumen konsep memakai angka need tanpa arah yang jelas. Tetapkan ini sekarang supaya tidak terbalik di tengah jalan.)
 
### AgentState (data murni)
 
```gdscript
# sim/core/agent_state.gd
class_name AgentState
extends RefCounted
 
var id: StringName
var display_name: String
var alive: bool = true
var tile: Vector2i
 
var needs := {"hunger": 100.0, "energy": 100.0}
var health: float = 100.0
var starving_ticks: int = 0
 
var inventory := {"food": 0}
var home_tile: Vector2i
 
# personality minggu 1-2: cukup 3, pengaruhnya harus terlihat
var personality := {
    "conscientiousness": 50,   # dorongan bekerja
    "risk_tolerance": 50,      # toleransi menunda makan/tidur
    "ambition": 50,            # cadangan, belum dipakai
}
 
var current_action: ActionInstance = null
var path: Array[Vector2i] = []
```
 
### ActionInstance
 
```gdscript
# sim/core/action_instance.gd
class_name ActionInstance
extends RefCounted
 
var def: ActionDef
var ticks_left: int
var target_tile: Vector2i
var started_tick: int
```
 
### WorldState
 
```gdscript
# sim/core/world_state.gd
class_name WorldState
extends RefCounted
 
var tick: int = 0
var grid: GridData
var agents: Dictionary = {}        # id -> AgentState
var granary_food: int = 20         # stok bersama (lumbung)
var next_event_id: int = 0
 
func sorted_agent_ids() -> Array:
    var ids := agents.keys()
    ids.sort()
    return ids
 
func hour_of_day() -> float:
    return float(tick % SimConst.TICKS_PER_DAY) / SimConst.TICKS_PER_DAY * 24.0
 
func is_night() -> bool:
    var h := hour_of_day()
    return h >= 21.0 or h < 5.0
```
 
### Lokasi fungsional di grid
Cukup 4 tipe lokasi: `HOUSE`, `FARM`, `GRANARY`, `OPEN` (jalan). Disimpan di `GridData` sebagai `Dictionary` tile -> tipe, plus array `walkable`. Pathfinding memakai `AStarGrid2D` yang dibangun dari `GridData`.
 
---
 
## 6. Needs System
 
| Need | Turun | Pulih |
|---|---|---|
| `energy` | -0.25 per tick (lebih cepat saat `work_farm`) | `sleep`: +1.2 per tick |
| `health` | turun saat `hunger == 0` | pulih pelan jika hunger > 50 |
 
Angka di atas **titik awal tuning**, bukan kebenaran. Targetnya: agent normal butuh makan kira-kira 3x sehari simulasi dan tidur sekali.
- `health <= 0` -> `alive = false`, catat event `agent_died` dengan penyebab.
---
 
## 7. Aksi
 
| Aksi | Syarat (divalidasi engine) | Durasi | Efek |
|---|---|---|---|
| `idle` | selalu bisa | 1 tick | tidak ada |
| `eat` | berada di `GRANARY`, stok > 0 | 2 tick | stok -1, hunger +40 |
| `sleep` | berada di `HOUSE` | sampai energy penuh atau pagi | energy +1.2 per tick |
| `work_farm` | berada di `FARM`, energy > 20 | 6 tick | energy turun, +1 food ke lumbung saat selesai |
| `move` | ada jalur ke target | sesuai panjang jalur | pindah tile per tick |
 
Alur: utility memilih aksi -> jika agent belum di lokasi yang disyaratkan, `ActionSystem` menjadwalkan `move` dulu -> setelah tiba, aksi dieksekusi -> validator mengecek ulang syarat saat mulai dan saat selesai.
 
```gdscript
# sim/actions/action_def.gd
class_name ActionDef
extends Resource
 
@export var id: StringName
@export var duration_ticks: int = 1
@export var required_location: StringName = &""   # "" = di mana saja
@export var interruptible: bool = true
```
 
---
 
## 8. Utility AI
 
### Ide dasar
Setiap tick keputusan (bukan tiap tick simulasi), agent menghitung **skor** untuk setiap aksi yang valid, lalu memilih skor tertinggi. Skor berasal dari urgensi need, kepribadian, jarak, dan sedikit noise ber-seed.
 
### Kurva urgensi
 
```gdscript
# sim/ai/curves.gd
class_name Curves
 
# need 100 -> 0.0 (tenang), need 0 -> 1.0 (genting). Kuadratik: baru terasa saat sudah rendah.
static func urgency(need: float) -> float:
    var d := 1.0 - clampf(need / 100.0, 0.0, 1.0)
    return d * d
 
static func distance_factor(tiles: int) -> float:
    return 1.0 / (1.0 + 0.05 * tiles)
```
 
### Skor per aksi (versi sederhana)
 
| Aksi | Rumus skor |
|---|---|
| `eat` | `urgency(hunger) * distance_factor(jarak ke lumbung) * (stok > 0 ? 1 : 0)` |
| `sleep` | `urgency(energy) * (malam ? 1.5 : 1.0) * distance_factor(jarak ke rumah)` |
| `work_farm` | `kerja_drive * (1 - max(urgency semua need))` |
| `idle` | `0.05` (lantai) |
 
Dengan `kerja_drive = 0.3 + 0.5 * (conscientiousness / 100)`.
Risk tolerance mengubah ambang: agent berisiko tinggi menunda makan sedikit lebih lama (kalikan urgensi dengan `1.0 - 0.3 * risk_tolerance/100`).
 
### Dua mekanisme anti-bug yang wajib ada
1. **Commitment bonus:** aksi yang sedang berjalan dapat bonus (+0.15) agar agent tidak ping-pong antar aksi tiap tick.
2. **Survival interrupt:** jika `hunger < 15` atau `energy < 10`, aksi non-survival langsung dibatalkan dan agent dipaksa ke kebutuhan itu. Ini menjaga hasil tetap masuk akal tanpa menghapus variasi di kondisi normal.
```gdscript
# sim/ai/utility_brain.gd
class_name UtilityBrain
extends RefCounted
 
const COMMIT_BONUS := 0.15
const NOISE := 0.02
 
static func choose(agent: AgentState, world: WorldState, rng: RandomNumberGenerator) -> Dictionary:
    var scored: Array = []
    for def in ActionLibrary.all():
        if not ActionValidator.can_start(agent, def, world):
            continue
        var s := _score(agent, def, world)
        s += rng.randf() * NOISE
        if agent.current_action and agent.current_action.def.id == def.id:
            s += COMMIT_BONUS
        scored.append({"id": def.id, "score": s})
    scored.sort_custom(func(a, b): return a.score > b.score)
    return {"best": scored[0].id, "trace": scored.slice(0, 3)}   # trace -> event log
```
 
Fungsi `_score` berisi `match def.id` sesuai tabel di atas. Untuk minggu 1-2 ini cukup. Refactor ke daftar "consideration" berbasis data baru dilakukan jika aksi sudah banyak.
 
---
 
## 9. Event Log dan Explainability
 
Format: satu JSON per baris (`.jsonl`) di `user://logs/run_<seed>.jsonl`. Skema mengikuti contoh Event di dokumen konsep, ditambah `decision_trace`.
 
```json
{
  "id": 42,
  "tick": 120,
  "type": "action_started",
  "actors": ["agent_001"],
  "context": {"tile": [12, 7], "hunger": 18.4, "energy": 55.0},
  "action": {"id": "eat"},
  "decision_trace": [
    {"id": "eat", "score": 0.71},
    {"id": "work_farm", "score": 0.12},
    {"id": "idle", "score": 0.05}
  ]
}
```
 
Event yang dicatat: `action_started`, `action_completed`, `action_failed`, `need_critical`, `agent_died`, `food_produced`.
 
Jangan log tiap tick. Hanya perubahan keputusan dan kejadian penting, supaya file tetap kecil.
 
---
 
## 10. Presentation (View)
 
- `world_view` membuat `TileMapLayer` dari `GridData` dan menaruh satu `AgentView` per agent.
- `AgentView` membaca `AgentState.tile` setiap tick dan menginterpolasi posisinya (tween) supaya gerak terlihat halus, padahal logikanya berbasis tile.
- Kamera: pan (WASD atau drag tengah), zoom (scroll), klik NPC untuk membuka inspector.
- Inspector menampilkan: needs, aksi saat ini, inventori, 3 skor teratas dari keputusan terakhir.
- Time controls: pause, 1x, 2x, 4x, 8x.
- View **tidak boleh** mengubah state. Kalau perlu tombol "tambah makanan" untuk debug, kirim sebagai command ke `Simulation`.
---
 
## 11. Rencana Kerja
 
### Minggu 1: inti simulasi (headless dulu)
| Hari | Tugas | Selesai jika |
|---|---|---|
| 1 | Setup proyek, struktur folder, TileMapLayer, kamera | Peta tampil, kamera bisa pan/zoom |
| 2 | `WorldState`, `AgentState`, `SimClock`, `Simulation.step()` | Tick berjalan, state berubah di log |
| 3 | `NeedsSystem` + `EventLog` | Lapar/energi turun, event kritis tercatat |
| 4 | `ActionLibrary`, `ActionValidator`, `MovementSystem` (A*) | Agent bisa dipaksa ke lumbung dan makan |
| 5 | `UtilityBrain` + commitment + survival interrupt | Agent memilih aksi sendiri |
| 6-7 | Buffer dan tuning angka | 1 hari simulasi berjalan tanpa error |
 
### Minggu 2: terlihat dan terukur
| Hari | Tugas | Selesai jika |
|---|---|---|
| 8 | `AgentView`, spawn dari config | NPC bergerak di layar |
| 9 | Time controls, HUD jam/hari | Pause dan speed berfungsi |
| 10 | Agent inspector + decision trace | Bisa lihat kenapa NPC memilih aksi |
| 11 | Seed dan `determinism_test` | Dua run seed sama menghasilkan hash identik |
| 12 | Kepribadian benar-benar berpengaruh, tuning | Agent berbeda berperilaku berbeda |
| 13-14 | Buffer, bersih-bersih, tulis `DESIGN.md` | Semua checklist di bawah centang |
 
Jika tertinggal, potong inspector dan kepribadian dulu. **Jangan potong determinism test.** Itu yang membuat proyek ini bisa disebut simulator, bukan sekadar animasi.
 
---
 
## 12. Checklist Penerimaan
 
- [ ] Sim core tidak mengandung `extends Node` atau referensi ke scene.
- [ ] Tidak ada `randf()`/`randi()` global di `sim/`.
- [ ] 3 agent hidup minimal 5 hari simulasi tanpa crash.
- [ ] Setiap agent makan, tidur, dan bekerja sesuai kebutuhan, tanpa ping-pong aksi.
- [ ] Stok lumbung habis -> agent kelaparan -> ada event `agent_died` dengan sebab jelas.
- [ ] Seed sama, 1000 tick, dua kali run -> hash state akhir identik.
- [ ] Seed beda -> hasil berbeda.
- [ ] Dua agent dengan kepribadian berbeda memilih aksi berbeda di kondisi yang sama (terbukti dari log).
- [ ] Inspector menunjukkan alasan keputusan terakhir.
### Cara tes determinism (ide)
Jalankan `Simulation` tanpa view, 1000 tick, lalu hash hasil serialisasi state (posisi, needs, inventori, stok lumbung) dengan `hash()` atau `String.sha256_text()`. Bandingkan antar run. Jalankan juga headless (`godot --headless`) agar bisa diulang cepat.
 
---
 
## 13. Jebakan Umum (baca sebelum coding)
 
1. **Logika di `_process`.** Bikin hasil bergantung FPS. Semua lewat tick.
2. **Menyimpan referensi Node di state.** Sim core jadi tidak bisa dites headless.
3. **Float yang menumpuk.** Cukup untuk sekarang, tapi jangan membandingkan float dengan `==`.
4. **Iterasi Dictionary tanpa urutan.** Selalu urutkan id.
5. **Agent selalu berebut hal sama.** Kalau 3 agent semua ke lumbung bersamaan, itu wajar. Tentukan aturan resolusi (urutan id) dan jangan panik.
6. **Over-engineering.** Jangan bikin sistem consideration generik, event bus raksasa, atau ECS sekarang. Hardcode dulu, refactor saat sakit.
7. **Tuning buta.** Ubah satu angka per percobaan, lihat log, baru lanjut.
8. **Tergoda menambah fitur.** Kalau minggu 2 sudah beres, baru tambah satu need baru (`social`) sebagai pemanasan ke minggu 3.
---
 
## 14. Gerbang Menuju Minggu 3-4
 
Lanjut hanya jika semua checklist penerimaan centang. Isi minggu 3-4:
- Memori episodik sederhana (siapa/apa/di mana/kapan) dan relasi terarah antar agent.
- Aksi `talk` dengan template teks (tanpa LLM).
- Interface `DialogueProvider` dengan dua implementasi: `TemplateProvider` dan nanti `LLMProvider`. Dengan begitu LLM bisa dicolok tanpa membongkar sim core.
  
Aturan konsekuensi:
- `hunger == 0` -> `starving_ticks += 1`, kesehatan turun.

