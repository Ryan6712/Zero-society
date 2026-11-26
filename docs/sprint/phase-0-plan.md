# Phase 0: Living Foundation — Master Plan

Dokumen perencanaan teknis untuk merealisasikan konsep `docs/concept/society-zero-phase-0-living-foundation.md`.

---

## 1. Analisis Kesenjangan (Gap Analysis)

| Aspek | Kondisi Saat Ini (v0.1.0) | Target Phase 0 (Living Foundation) | Kesenjangan / Pekerjaan Baru |
|---|---|---|---|
| **Aktivitas** | `idle`, `move`, `eat`, `sleep`, `work_farm` (5 aksi) | Tambah `wander`, `recover` | Buat ActionDef baru, validator, dan efek recovery/exploring |
| **Objek Dunia** | Hanya tipe tile (`GridData.tiles`) | Objek interaktif ber-state & berkapasitas | Tambah sistem slot penggunaan (Bed, Workplace/Farm, Storage) |
| **Kapasitas Lumbung** | Tak terbatas | Kapasitas penyimpanan makanan terbatas | Tambah batas kapasitas lumbung & penolakan simpan jika penuh |
| **Kepribadian** | `conscientiousness`, `risk_tolerance` | `industrious`, `cautious`, `adventurous`, `lazy` | Standarisasi 4 trait, integrasi ke skor wander & recover |
| **Pengambilan Keputusan** | Evaluasi per-tick jika aksi kosong | Event-driven / threshold re-evaluation | Evaluasi saat tiba di tujuan, selesai aksi, atau ambang kritis |
| **Skenario Pengujian** | Fuzz, scripted village lifecycle | Scenario A s/d E spesifik Phase 0 | Tambah Scenario A (Survival), B (Scarcity), C (Interruption), D (Personality), E (Replay) |

---

## 2. Pembagian Milestone & Tiket

### Milestone 0.1: Needs & Activity Expansion
Fokus: Menambah aktivitas `wander` dan `recover`, serta penyempurnaan need `health`.

| ID | Tiket | Deskripsi | File Disentuh |
|---|---|---|---|
| P0-101 | `feat(actions): tambah aktivitas wander` | Agent memilih tile acak walkable untuk jalan santai saat idle & bosan | `action_library.gd`, `action_def.gd`, `utility_brain.gd` |
| P0-102 | `feat(actions): tambah aktivitas recover` | Agent istirahat di rumah untuk memulihkan `health` saat terluka/kritis | `action_library.gd`, `action_system.gd`, `sim_const.gd` |
| P0-103 | `test(actions): unit test wander dan recover` | Uji prasyarat, eksekusi, dan efek wander & recover | `tests/test_action_system.gd`, `tests/test_action_validator.gd` |

---

### Milestone 0.2: Environment Objects & Resource Capacity
Fokus: Objek dunia dengan kapasitas & okupansi (Bed, Farm slots, Storage capacity).

| ID | Tiket | Deskripsi | File Disentuh |
|---|---|---|---|
| P0-201 | `feat(core): implementasi WorldObject & Occupancy` | Model objek interaktif dengan kapasitas (Bed max 1 agent, Farm max N pekerja) | `sim/core/world_object.gd`, `world_state.gd` |
| P0-202 | `feat(actions): validasi okupansi objek dunia` | ActionValidator menolak `sleep` jika semua bed penuh, menolak `work` jika farm penuh | `action_validator.gd`, `action_system.gd` |
| P0-203 | `feat(core): batasi kapasitas penyimpanan lumbung` | Granary memiliki `max_capacity`, `modify_granary_food` menolak surplus berlebih | `world_state.gd`, `sim_const.gd` |
| P0-204 | `test(core): uji kapasitas objek dan storage` | Tes perebutan bed, antrian kerja, dan batas stok lumbung | `tests/test_world_objects.gd` |

---

### Milestone 0.3: Personality Traits & Smart Re-evaluation
Fokus: Standarisasi 4 trait kepribadian dan re-evaluasi keputusan berbasis kondisi.

| ID | Tiket | Deskripsi | File Disentuh |
|---|---|---|---|
| P0-301 | `feat(ai): standarisasi 4 trait personality` | Petakan `industrious`, `cautious`, `adventurous`, `lazy` ke scoring UtilityBrain | `utility_brain.gd`, `agent_state.gd` |
| P0-302 | `feat(ai): skor utility untuk wander & recover` | Adventurous menaikkan skor wander; Cautious menaikkan skor recover & makan awal | `utility_brain.gd`, `curves.gd` |
| P0-303 | `feat(ai): evaluasi berbasis pemicu (event-triggered)` | Kurangi evaluasi membabi buta, picu re-eval saat aksi selesai/interupsi/tiba di target | `utility_brain.gd`, `simulation.gd` |
| P0-304 | `test(ai): tes variasi perilaku 4 traits` | Buktikan perbedaan perilaku jangka panjang antar-trait di kondisi identik | `tests/test_personality_traits.gd` |

---

### Milestone 0.4: Living Simulation & Skenario A–E (Finalisasi Phase 0)
Fokus: Integrasi penuh 5 NPC mandiri, skenario A–E, dan pembekuan golden hash Phase 0.

| ID | Tiket | Deskripsi | File Disentuh |
|---|---|---|---|
| P0-401 | `test(scenarios): scenario A — Basic Survival` | 1 NPC mengelola hunger & energy stabil berhari-hari | `tests/scenarios/test_scenario_a_survival.gd` |
| P0-402 | `test(scenarios): scenario B — Resource Scarcity` | Keterbatasan makanan, penolakan saat stok habis, pencarian alternatif | `tests/scenarios/test_scenario_b_scarcity.gd` |
| P0-403 | `test(scenarios): scenario C — Activity Interruption` | Interupsi kerja saat energi kritis, tanpa ping-pong | `tests/scenarios/test_scenario_c_interruption.gd` |
| P0-404 | `test(scenarios): scenario D — Personality Variation` | 2 NPC kondisi sama memilih tindakan berbeda sesuai trait | `tests/scenarios/test_scenario_d_personality.gd` |
| P0-405 | `test(scenarios): scenario E — Reproducibility` | Uji determinisme eksak lintas seed Phase 0 | `tests/scenarios/test_scenario_e_reproducibility.gd` |
| P0-406 | `feat(view): visualisasi okupansi & status baru` | Update HUD dan Inspector untuk menampilkan objek aktif dan trait baru | `view/ui/agent_inspector.gd`, `view/ui/hud.gd` |
| P0-407 | `docs(release): dokumentasi rilis Phase 0` | Catatan rilis, update devlog, update README, tag `phase-0-complete` | `docs/devlog/`, `README.md` |

---

## 4. Status Pelaksanaan & Checklist Phase 0

- [x] **Milestone 0.1:** Aktivitas `wander` & `recover` selesai dan teruji (100% test pass).
- [x] **Milestone 0.2:** Model `WorldObject`, kapasitas slot (Bed, Farm, Granary), dan okupansi tervalidasi.
- [x] **Milestone 0.3:** 4 Trait kepribadian (`industrious`, `cautious`, `adventurous`, `lazy`) aktif dan teruji di `UtilityBrain`.
- [x] **Milestone 0.4:** Skenario A–E diimplementasikan di `tests/scenarios/` dan 100% lulus.
- [x] UI visual (Inspector & HUD) mencerminkan sifat kepribadian baru dan aksi Phase 0.
- [x] Seluruh 117 tes GUT unit, sistem, skenario, dan determinisme 100% hijau.
