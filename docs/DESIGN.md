# DESIGN.md — Keputusan Arsitektur Society Zero

Dokumen ini merangkum keputusan arsitektur utama proyek. Detail tiap keputusan ada di folder `adr/`.

## Daftar ADR

| ADR | Judul | Status |
|-----|-------|--------|
| [ADR-001](adr/ADR-001-tick-based.md) | Simulasi berbasis tick | Diterima |
| [ADR-002](adr/ADR-002-sim-view-separation.md) | Pemisahan sim dan view | Diterima |
| [ADR-003](adr/ADR-003-single-rng.md) | Satu sumber RNG ber-seed | Diterima |
| [ADR-004](adr/ADR-004-action-validator.md) | Validasi aksi oleh engine | Diterima |

## Prinsip Utama

1. **Sim core = data murni.** `sim/` tidak boleh `extends Node`.
2. **Per tick, bukan per frame.** Logika simulasi di `Simulation.step()`.
3. **Deterministic.** Seed sama = hasil sama.
4. **Explainable.** Setiap keputusan tercatat beserta alasannya.
