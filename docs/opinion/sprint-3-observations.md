# Observasi & Analisis Desain Sprint 3: Utility AI dan Explainability

Tanggal: 2026-11-25

## 1. Navigasi Aksi: Intention vs Execution (Menuju Lokasi Aksi)
- **Tantangan:** Agent memilih aksi tingkat tinggi (misal `eat` di Lumbung atau `work_farm` di Ladang), namun agent sedang berada di koordinat lain.
- **Solusi:**
  - `UtilityBrain` mengevaluasi aksi tingkat tinggi (`eat`, `sleep`, `work_farm`, `idle`).
  - Jarak ke lokasi target (`distance_factor`) dihitung dari posisi agent ke lokasi terdekat dari tipe tile yang dibutuhkan (`GridData.get_locations_of_type(...)`).
  - Jika aksi terpilih memerlukan lokasi tertentu dan agent belum berada di sana:
    - Agent secara otomatis menginisiasi aksi `move` menuju tile target tersebut.
    - Setelah sampai di tile tujuan (`ticks_left == 0`), di tick berikutnya `UtilityBrain` akan memilih aksi esensial (`eat`/`work_farm`/`sleep`) karena agent sudah di lokasi dan jaraknya 0!
  - Ini menjaga arsitektur tetap bersih tanpa perlu queue bertingkat yang rumit.

## 2. Pengurutan Skor dengan Tie-Breaker Deterministik
- Godot `sort_custom` tidak menjamin kestabilan jika skor sama.
- Kita wajib menyertakan tie-breaker:
  ```gdscript
  static func _compare_scored(a: Dictionary, b: Dictionary) -> bool:
      if not is_equal_approx(a.score, b.score):
          return a.score > b.score
      return String(a.id) < String(b.id)
  ```
- Ini mencegah divergensi deterministik lintas platform saat dua aksi memiliki skor identik.

## 3. Explainability (`decision_trace`)
- Setiap keputusan agent dicatat sebagai event `decision_made` yang menyertakan array 3 skor teratas:
  ```json
  "decision_trace": [
      {"id": "eat", "score": 0.74},
      {"id": "work_farm", "score": 0.32},
      {"id": "idle", "score": 0.05}
  ]
  ```
- Snapshot trace ini juga disimpan di `agent.last_decision_trace` sehingga saat pemain mengklik agent di UI/Inspector (Sprint 4), data langsung tersedia tanpa harus membaca ulang file log.

## 4. Mekanisme Anti Ping-Pong & Survival Interrupt
- **Commitment Bonus (+0.15):** Aksi yang sedang berjalan diberikan bonus skor agar agent tidak berganti pikiran di setiap tick akibat fluktuasi kecil.
- **Survival Interrupt:** Jika `hunger < 15.0` atau `energy < 10.0`, aksi non-kritis (seperti `work_farm` atau `idle`) langsung dibatalkan, memaksa agent memprioritaskan makanan atau tidur.
