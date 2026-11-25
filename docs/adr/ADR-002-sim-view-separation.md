# ADR-002: Pemisahan Sim dan View

## Status
Diterima

## Konteks
Simulasi harus bisa dijalankan headless (tanpa tampilan) untuk testing dan sweep seed. Mencampurkan logika simulasi dengan Node/scene membuat hal ini tidak mungkin.

## Keputusan
- `sim/` berisi kelas `RefCounted`/`Resource`, **tidak boleh** `extends Node`.
- `view/` berisi scene dan Node yang **hanya membaca** state dari `sim/`.
- View tidak menulis state. Input UI masuk lewat command ke `Simulation`.
- Arah dependensi: `view -> sim`. `sim` tidak boleh mereferensikan `view`.

## Konsekuensi
- Simulasi bisa dites headless tanpa modifikasi.
- View bisa diganti (2D, 3D, CLI) tanpa mengubah logika.
- Perlu mekanisme notifikasi (signal/snapshot) agar view tahu state berubah.
