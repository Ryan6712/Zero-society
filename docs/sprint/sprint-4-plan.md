# Sprint 4 Plan: View, Kontrol, Hardening, dan Rilis v0.1.0

## 1. Tujuan Sprint
Membangun antarmuka visual (`WorldView`, `AgentView`, kamera, kontrol waktu, HUD, Agent Inspector), command queue debug yang aman, membuktikan bahwa view tidak pernah mengubah state simulasi, smoke test performa, pembekuan golden replay, dan finalisasi rilis `v0.1.0`.

---

## 2. Rincian Tiket & Deliverables

### Fase 1: Visualisasi Peta & Agent (SZ-401, SZ-402)
- **SZ-401: `WorldView` (`view/world_view.gd` / `view/world_view.tscn`)**
  - Menggambar peta 16x16px dari data `GridData`.
  - Menginstansiasi `AgentView` untuk setiap agent di `world.agents`.
- **SZ-402: `AgentView` (`view/agent_view.gd` / `view/agent_view.tscn`)**
  - Menampilkan sprite karakter Sunnyside World.
  - Interpolasi posisi (`Tween`) antar-tile saat bergerak.
  - Pemilihan frame/animasi berdasarkan `agent.current_action` (`idle`, `move`, `work_farm`, `eat`, `sleep`).
  - Area klik mouse untuk membuka inspector pada agent terkait.

---

### Fase 2: Kontrol Waktu, HUD, & Inspector (SZ-403, SZ-404, SZ-405, SZ-406)
- **SZ-403: Time Controls (`view/ui/time_controls.gd`)**
  - Tombol: Pause (0x), 1x, 2x, 4x, 8x.
  - Shortcut keyboard: Space (toggle pause), 1, 2, 3, 4.
  - Mengatur `SimClock.speed`.
- **SZ-404: HUD (`view/ui/hud.gd`)**
  - Menampilkan: Hari (`Day X`), Waktu (`HH:MM`), Fase Hari (`Day/Night/Dawn/Dusk`), Stok Lumbung, Populasi Hidup.
- **SZ-405: Agent Inspector (`view/ui/agent_inspector.gd`)**
  - Panel rincian saat agent diklik:
    - Nama, ID, Status hidup/mati.
    - Progress Bar: Hunger, Energy, Health (0-100).
    - Aksi saat ini & sisa tick.
    - Kepribadian: Conscientiousness, Risk Tolerance.
    - **Decision Trace:** 3 kandidat aksi teratas beserta skor numeriknya dari `agent.last_decision_trace`.
- **SZ-406: Command Pattern untuk Debug (`sim/core/command.gd`)**
  - `Simulation.enqueue_command(cmd: Command)` & `_process_commands()`.
  - `AddFoodCommand`: menambah makanan ke lumbung via jalur audit `world.modify_granary_food`.
  - Tombol debug di UI hanya mengirim command, tidak pernah menyentuh state langsung.

---

### Fase 3: Hardening, Invarian View, & Golden Replay (SZ-407, SZ-408, SZ-409)
- **SZ-407: Tes View Tidak Mengubah State (`tests/test_view_state_isolation.gd`)**
  - Jalankan 500 tick headless tanpa view -> simpan Hash A.
  - Jalankan 500 tick dengan WorldView dan UI aktif membaca state -> simpan Hash B.
  - Verifikasi: `Hash A == Hash B`.
- **SZ-408: Performance Smoke Test (`tests/test_perf_smoke.gd`)**
  - Ukur eksekusi 1000 tick pada 5 agent.
  - Verifikasi waktu eksekusi total di bawah 2.0 detik (< 2ms per tick).
- **SZ-409: Golden Replay (`tests/test_golden_replay.gd`)**
  - Membekukan golden hash resmi untuk Seed 42 pada tick 1000.
  - Mencegah regresi determinisme di masa depan.

---

### Fase 4: Dokumentasi & Rilis v0.1.0 (SZ-410, SZ-411)
- **SZ-410 & SZ-411: Finalisasi & Rilis**
  - Perbarui `DESIGN.md` final.
  - Siapkan instruksi jalankan game interaktif di `README.md`.
  - Catat `docs/devlog/sprint-4.md`.
  - Tag rilis semver `v0.1.0`.

---

## 3. Rencana Commit Atomik (Conventional Commits)

1. `feat(core): implementasi Command queue untuk input dari luar` (SZ-406)
2. `feat(view): implementasi WorldView dan AgentView dengan interpolasi gerak` (SZ-401, SZ-402)
3. `feat(ui): implementasi TimeControls, HUD, dan AgentInspector dengan explainability trace` (SZ-403, SZ-404, SZ-405)
4. `test(view): tambahkan tes isolasi bahwa view tidak pernah mengubah state sim` (SZ-407)
5. `test(perf): tambahkan performance smoke test tick execution` (SZ-408)
6. `test(golden): bekukan golden replay hash seed 42 tick 1000` (SZ-409)
7. `docs(release): finalisasi DESIGN.md, devlog sprint 4, dan README untuk v0.1.0` (SZ-410, SZ-411)

---

## 4. Checklist Definition of Done Sprint 4
- [x] Game visual dapat dijalankan di Godot editor (`main.tscn`) dengan kamera, HUD, time controls, dan agent inspector.
- [x] Klik NPC membuka inspector yang menampilkan data akurat dan `decision_trace`.
- [x] Command queue debug bekerja tanpa melanggar jalur audit konservasi makanan.
- [x] Tes isolasi view membuktikan hash identik 100% antara run dengan view vs headless.
- [x] Smoke test performa membuktikan tick loop sangat cepat (< 2ms per tick; aktual: 0.224 ms/tick).
- [x] Golden replay hash seed 42 tick 1000 terverifikasi dan dibekukan.
- [x] `gdformat --check` dan `gdlint` bersih (0 issues).
- [x] Seluruh unit test GUT 100% lulus (100 tes).
- [x] Aturan arsitektur (`sim/` bebas `Node` dan bebas RNG global) tetap terjaga.
- [x] Tag `v0.1.0` dibuat.
