# Tuning Log Society Zero

Dokumen ini mencatat riwayat tuning parameter perilaku agent, hasil sweep seed, dan analisis metrik.
Protokol: ubah satu parameter per percobaan, jalankan sweep 20 seed yang sama, dan catat sebelum/sesudah.

---

## Entri: 2026-11-25 — Baseline Sprint 3 (Tuning Pass 1)

### 1. Konfigurasi Eksperimen
- **Dunia:** `data/default_world.json` (16x12 tiles: 1 House, 1 Farm, 1 Granary)
- **Agent:** 3 NPC (`agent_000`, `agent_001`, `agent_002`)
- **Durasi:** 720 tick (5 hari simulasi, 144 tick/hari)
- **Sweep:** Seed 1 s/d 20 (20 run)
- **Runner:** `godot --headless -s tools/sweep_seeds.gd -- --seeds 20 --ticks 720`

### 2. Parameter Aktif
| Parameter | Nilai | Modul |
|---|---|---|
| `HUNGER_DECAY` | 0.35 / tick | `SimConst` |
| `ENERGY_DECAY` | 0.25 / tick | `SimConst` |
| `ENERGY_DECAY_WORKING` | 0.50 / tick | `SimConst` |
| `EAT_HUNGER_RESTORE` | +40.0 | `SimConst` |
| `SLEEP_ENERGY_RESTORE` | +1.20 / tick | `SimConst` |
| `WORK_FARM_FOOD_PRODUCED` | +1 food | `SimConst` |
| `COMMIT_BONUS` | +0.15 | `UtilityBrain` |
| `NOISE` | 0.02 | `UtilityBrain` |
| `CRITICAL_HUNGER_THRESHOLD` | 15.0 | `UtilityBrain` |
| `CRITICAL_ENERGY_THRESHOLD` | 10.0 | `UtilityBrain` |

### 3. Hasil Sweep
| Metrik | Target Sprint Plan | Hasil Aktual (Pass 1) | Evaluasi |
|---|---|---|---|
| **Survival Rate** | >= 80% | **100.0%** (60/60 agent) | Lulus Sangat Baik |
| **Switch Aksi / Hari** | < 20 / hari | **15.5 / hari** | Stabil, Bebas Ping-Pong |
| **Stok Lumbung Akhir** | > 0 | **209.0** (surplus) | Berkelanjutan |
| **Determinisme** | 100% identik per seed | **PASS** | Valid |

### 4. Kesimpulan
Parameter awal memberikan ekosistem desa yang stabil: agent bekerja di ladang saat energi tinggi dan tidak lapar, makan di lumbung saat lapar naik, dan pulang tidur saat malam hari/energi rendah. Survival interrupt berhasil mencegah kelaparan tak terduga. Baseline ini dibekukan untuk Sprint 3.

---

## Entri: 2026-11-26 — Eksperimen Kelangkaan / Scarcity (N-04)

### 1. Konfigurasi Eksperimen
- **Dunia:** `data/scarcity_world.json` (Stok lumbung awal 3 food, 1 tile farm sempit, 4 agent dengan kepribadian kontras)
- **Agent:** 4 NPC (C=90 R=20, C=70 R=40, C=40 R=60, C=10 R=90)
- **Durasi:** 720 tick (5 hari simulasi)
- **Runner:** `godot --headless -s tools/sweep_seeds.gd -- --config res://data/scarcity_world.json --seeds 10 --ticks 720`

### 2. Hasil Sweep
| Metrik | Nilai | Evaluasi |
|---|---|---|
| **Survival Rate** | **100.0%** (40/40 agent) | Agent rajin segera bekerja dan menyelamatkan suplai desa |
| **Switch Aksi / Hari** | **10.8 / hari** | Lebih fokus bekerja karena dorongan kebutuhan tinggi |
| **Sisa Lumbung Akhir** | **239 food** | Ekosistem pulih dari krisis awal |
