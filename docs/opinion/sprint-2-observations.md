# Observasi & Analisis Desain Sprint 2: Aksi, Validasi, dan Gerak

Tanggal: 2026-11-25

## 1. Analisis Kritis & Keputusan Arsitektur

### A. Validasi Menggunakan Enum `RejectReason` (Bukan String)
- Sesuai aturan keras arsitektur dan ADR-004, validasi aksi **tidak boleh** mengembalikan string bebas atau boolean ambigu.
- Kita buat `class_name ActionValidator` yang mengekspos enum `RejectReason`:
  - `OK` (0)
  - `NOT_ALIVE`
  - `ALREADY_ACTING`
  - `NOT_AT_LOCATION`
  - `NO_STOCK`
  - `LOW_ENERGY`
  - `NO_PATH`
  - `INVALID_TARGET`
  - `UNKNOWN_ACTION`
- Ini memudahkan unit testing exact match (`assert_eq(reason, ActionValidator.RejectReason.NO_STOCK)`).

### B. Konservasi Sumber Daya: Satu Jalur Tunggal (`modify_granary_food`)
- Di Sprint 1, `granary_food` sudah diubah ke `int`.
- Di Sprint 2, perubahan makanan tidak boleh dilakukan langsung (`world.granary_food += 1` atau `-= 1` dilarang).
- Semua transaksi melewati `WorldState.modify_granary_food(delta: int, reason: StringName, events: Array[Dictionary]) -> bool`:
  - Mencegah stok menjadi negatif (`granary_food + delta >= 0`).
  - Menghitung total `total_food_produced` dan `total_food_consumed` di `WorldState` sehingga invariant konservasi:
    `initial_food + total_produced - total_consumed == granary_food`
    dapat diaudit otomatis di setiap tick!

### C. Pathfinding `AStarGrid2D`: Orthogonal vs Diagonal
- Peta 2D Society Zero berbasis tile top-down.
- `AStarGrid2D` di Godot 4 memiliki opsi `diagonal_mode`.
- **Keputusan:** Tetapkan `diagonal_mode = AStarGrid2D.DIAGONAL_MODE_NEVER` (hanya 4 arah mata angin).
  - Alasan: Gerak 4 arah konsisten dengan kisi tile, mencegah agent "memotong sudut" bangunan atau air diagonal, dan menjaga determinisme step per tile (1 tick = 1 tile).

### D. Siklus Hidup Aksi (`ActionSystem`)
Aksi memiliki 4 status:
1. `STARTED`: Lolos validasi, `ticks_left = def.duration_ticks`, event `action_started`. Jika aksi butuh konsumsi awal, dipotong di sini.
2. `IN_PROGRESS`: Berjalan tiap tick, `ticks_left -= 1`. Untuk aksi berkelanjutan seperti `sleep`, efek bertahap (regenerasi energi) terjadi per tick.
3. `COMPLETED`: Saat `ticks_left == 0`, efek akhir diaplikasikan (misal `work_farm` menghasilkan +1 makanan ke lumbung), event `action_completed`.
4. `INTERRUPTED`: Jika diinterupsi oleh survival interrupt (atau skrip tes), event `action_interrupted`.

### E. Integrasi Gerak Otomatis Menuju Lokasi Aksi
- Jika agent diminta `work_farm` tapi berada di luar farm:
  - Aksi `work_farm` membutuhkan agent di lokasi farm.
  - Alur: Agent menjadwalkan `move` ke tile target farm terlebih dahulu, baru kemudian aksi farm dimulai setelah tiba.
  - Untuk Sprint 2 (karena belum ada Utility AI), tes dan skrip dapat menguji `move` secara eksplisit maupun rangkaian `queue` aksi.
