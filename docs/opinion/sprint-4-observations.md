# Observasi & Analisis Desain Sprint 4: View, Kontrol, Hardening, dan Rilis v0.1.0

Tanggal: 2026-11-25

## 1. Pemisahan View dan Sim Secara Mutlak (ADR-002)
- **Tantangan:** Saat membangun UI (HUD, Inspector, Tombol Debug), sangat mudah tergoda untuk langsung menulis ke state:
  ```gdscript
  # SALAH (Melanggar Arsitektur):
  sim.world.granary_food += 10
  ```
- **Solusi Bersih:** Menerapkan Command Pattern lewat `sim.enqueue_command(...)`:
  - `Simulation` memiliki antrian perintah `_command_queue: Array[Command]`.
  - Tombol debug di UI membuat `AddFoodCommand.new(10)` dan memasukkannya ke antrian.
  - Saat `Simulation.step()` berjalan, antrian diproses dan diverifikasi lewat jalur audit `modify_granary_food`.
  - Ini dibuktikan secara otomatis oleh tes SZ-407 (`test_view_does_not_alter_state.gd`): hash simulasi dengan atau tanpa UI harus identik 100%.

## 2. Rendering Tile & AgentView dengan Aset Sunnyside World
- Aset 16x16px `spr_tileset_sunnysideworld_16px.png` dan karakter `Human` sudah terpasang rapi di `assets/sunnyside_world/`.
- Koordinat simulasi berbasis tile integer `(x, y)` diterjemahkan ke koordinat piksel `(x * 16, y * 16)`.
- `AgentView` mengamati posisi `agent.position` setiap tick dan melakukan interpolasi halus (`Tween`) selama durasi 1 tick (`SimConst.SECONDS_PER_TICK / SimClock.speed`).
- Animasi karakter mencerminkan aksi saat ini:
  - `idle`: sprite diam / nafas
  - `move`: sprite berjalan (`WALKING`)
  - `work_farm`: sprite mencangkul / menyiram (`WATERING` / `AXE`)
  - `eat`: sprite memegang makanan
  - `sleep`: karakter berbaring / di dalam rumah

## 3. Explainability di Agent Inspector
- Agent Inspector di UI mengekspos:
  1. Needs bar (Hunger, Energy, Health) 0–100.
  2. Aksi saat ini & sisa tick.
  3. Sifat kepribadian (Conscientiousness, Risk Tolerance).
  4. **Jejak Keputusan (Decision Trace):** 3 aksi teratas yang dipertimbangkan `UtilityBrain` beserta skornya yang diambil langsung dari `agent.last_decision_trace`.
- Ini membuktikan prinsip utama Society Zero: *simulator yang bisa dijelaskan (explainable)*.

## 4. Hardening & Golden Replay
- Membekukan golden hash resmi untuk Seed 42 pada tick 1000 sebagai tolok ukur regresi determinisme di masa depan.
- Smoke test performa mengonfirmasi bahwa 1000 tick simulasi diselesaikan dalam waktu kurang dari 2 detik (kurang dari 2 ms per tick).
