# DESIGN.md — Keputusan Arsitektur Society Zero (v0.1.0)

Dokumen ini merangkum keputusan arsitektur utama proyek yang telah selesai diimplementasikan pada rilis `v0.1.0`.

## Daftar ADR

| ADR | Judul | Status |
|-----|-------|--------|
| [ADR-001](adr/ADR-001-tick-based.md) | Simulasi berbasis tick | Diterima & Terimplementasi |
| [ADR-002](adr/ADR-002-sim-view-separation.md) | Pemisahan sim dan view | Diterima & Terimplementasi |
| [ADR-003](adr/ADR-003-single-rng.md) | Satu sumber RNG ber-seed | Diterima & Terimplementasi |
| [ADR-004](adr/ADR-004-action-validator.md) | Validasi aksi oleh engine | Diterima & Terimplementasi |

## Prinsip Utama

1. **Sim Core = Data Murni.** Seluruh modul di `sim/` merupakan kelas turunan `RefCounted` atau `Resource` murni, bebas dari `Node` atau scene tree.
2. **Berbasis Tick, Bukan Frame.** Eksekusi simulasi hanya berjalan melalui `Simulation.step()`.
3. **Deterministik Eksak.** Hanya menggunakan `RandomNumberGenerator` simulasi yang ber-seed. Tiap loop agent terurut leksikografis dan pengurutan aksi menggunakan tie-breaker stabil.
4. **Explainability Penuh.** Setiap evaluasi aksi menghasilkan `decision_trace` yang tercatat di event log dan dapat langsung diinspeksi pemain.
5. **Konservasi Sumber Daya.** Manipulasi sumber daya (makanan) hanya memiliki satu jalur kode yang diaudit (`modify_granary_food`).
6. **Command Pattern untuk Interaksi Eksternal.** View hanya membaca state; segala intervensi eksternal masuk melalui `CommandQueue`.
