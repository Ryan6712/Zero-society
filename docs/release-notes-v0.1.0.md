# Catatan Rilis: Society Zero v0.1.0 ("Hidup di Desa")

- **Versi:** `v0.1.0`
- **Tanggal Rilis:** 2026-11-26
- **Tag:** `v0.1.0`
- **Engine:** Godot 4.7.x (pinned v4.7.2), GDScript dengan Static Typing

---

## 1. Fitur Utama

- **Pemisahan Sim/View Mutlak (ADR-002):**
  - `sim/` data murni turunan `RefCounted` dan `Resource`, tanpa `Node` atau dependensi scene tree.
  - `view/` hanya membaca state dari `Simulation` dan mengirim input melalui `CommandQueue`.
- **Deterministik Penuh (ADR-001 & ADR-003):**
  - Loop berbasis tick internal (144 tick/hari = 1 tick 10 menit).
  - Satu RNG ber-seed per simulasi tanpa ketergantungan pada `randf()` global, delta frame, atau waktu sistem.
- **Validasi Aksi Kuat & Konservasi Sumber Daya (ADR-004):**
  - Kode alasan penolakan terstruktur via enum `RejectReason`.
  - Manipulasi sumber daya lumbung melalui satu jalur audit `WorldState.modify_granary_food`.
  - Invariant konservasi makanan: `initial + produced - consumed == granary_food`.
- **Utility AI & Explainability:**
  - Evaluasi aksi otonom berbasis kurva urgensi kuadratik, jarak Manhattan, dan kepribadian (`conscientiousness`, `risk_tolerance`).
  - Mekanisme *Commitment Bonus* (+0.15) dan *Survival Interrupt* saat kebutuhan kritis.
  - Setiap keputusan mencatat `decision_trace` (3 kandidat teratas beserta skor numerik).
- **Antarmuka Interaktif:**
  - Render peta kisi 16x16px dengan aset Sunnyside World.
  - Interpolasi posisi halus (`Tween`) pada `AgentView`.
  - Kontrol waktu interaktif (Pause, 1x, 2x, 4x, 8x).
  - Panel HUD dan Agent Inspector visual dengan progress bar needs dan tampilan *decision trace*.

---

## 2. Hasil Checklist Playtest Manual 10 Langkah

1. **Jalankan game:** Peta dan 3 agent muncul pada koordinat awal. [PASS]
2. **Pause dan lanjutkan:** Tombol pause/space menghentikan akumulator tick seketika; play melanjutkan tanpa lonjakan. [PASS]
3. **Kecepatan 8x:** Simulasi berjalan cepat dan stabil tanpa memory leak atau error. [PASS]
4. **Klik satu agent:** Inspector terbuka menampilkan nama, kebutuhan, dan sifat kepribadian. [PASS]
5. **Amati satu hari penuh:** Agent bergerak ke ladang, bekerja, makan di lumbung, dan pulang tidur saat malam. [PASS]
6. **Bandingkan inspector dengan log:** 3 kandidat aksi di inspector cocok persis dengan event `decision_made` terakhir. [PASS]
7. **Debug tambah makanan:** Tombol `+5 Food` mengirim `AddFoodCommand` ke antrian; stok bertambah dan konservasi makanan tetap terpenuhi. [PASS]
8. **Stok habis & kelaparan:** Saat stok lumbung 0 dan ladang tidak bisa diakses, starvation ticks naik, kesehatan turun hingga event `agent_died` terpancar dengan cause `starvation`. [PASS]
9. **Restart seed sama:** Hash state akhir tick 1000 identik (`528cbd1ad359594ed518e05433a1b11c8f965388ef7d02ea49d960fe8ac019a4`). [PASS]
10. **Restart seed berbeda:** Menghasilkan riwayat dan hash yang berbeda. [PASS]

---

## 3. Cara Mereproduksi Eksperimen

Jalankan runner headless dari command line:

```bash
# Uji determinisme ganda 1000 tick:
godot --headless -s tools/run_sim.gd -- --seed 42 --ticks 1000 --check-twice

# Simpan log event lengkap ke JSONL:
godot --headless -s tools/run_sim.gd -- --seed 42 --ticks 1000 --log run_42.jsonl

# Jalankan sweep 20 seed selama 5 hari:
godot --headless -s tools/sweep_seeds.gd -- --seeds 20 --ticks 720
```

---

## 4. Batasan yang Diketahui (Known Limitations)

- v0.1 belum menyertakan interaksi sosial antarsesama agent (dialog, relasi, memori sosial).
- Aksi dan kebutuhan masih terbatas pada 3 kebutuhan primer (lapar, energi, kesehatan).
- Sistem perdagangan/ekonomi dan fitur save/load ditargetkan untuk versi rilis mendatang (v0.2+).
