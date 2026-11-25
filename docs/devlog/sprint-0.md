# Devlog: Sprint 0 — Fondasi dan Kontrak

- **Tanggal:** 2026-11-25
- **Status:** Selesai
- **Tiket:** SZ-001 s/d SZ-007

## 1. Ringkasan Sprint
Menyiapkan struktur repositori, konfigurasi CI (GitHub Actions), pengujian otomatis (GUT 9.7.1), kontrak data awal v0, serta ADR arsitektur.

## 2. Yang Dikerjakan
- **Struktur Proyek:** Pemisahan ketat `sim/` (pure data, tanpa Node) dan `view/` (tampilan, scene).
- **Tooling & CI:**
  - Setup `.github/workflows/ci.yml` dengan job linting (`gdtoolkit` 4.x) dan unit test (`godot 4.7.2 headless`).
  - Pasang plugin GUT 9.7.1 di `addons/gut/` dan konfigurasi `.gutconfig.json`.
  - Pemeriksaan otomatis di CI untuk memastikan tidak ada `extends Node` dan `randf()` global di folder `sim/`.
- **Kontrak Data v0:**
  - Stub `AgentState`, `WorldState`, `ActionDef`, dan `EventSchema`.
- **Dokumentasi & Standar:**
  - `DESIGN.md` dan ADR-001 sampai ADR-004 (Tick-based, Pemisahan Sim/View, Single RNG, Action Validator).
  - Panduan AI agent di `.agents/AGENTS.md` dan checklist pre-commit.
  - Template PR dan Issue GitHub.
- **View Dasar:**
  - `view/main.tscn` dengan script `view/camera_controller.gd` (drag pan middle-mouse dan zoom scroll).

## 3. Hasil Pengujian
- Unit test hello: 2 passed, 0 failed.
- CI pipeline: Lint job & Test job terverifikasi.

## 4. Next Steps
- Masuk ke Sprint 1: Inti simulasi headless deterministik.
