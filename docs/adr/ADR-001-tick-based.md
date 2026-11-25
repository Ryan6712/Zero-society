# ADR-001: Simulasi Berbasis Tick

## Status
Diterima

## Konteks
Society Zero memerlukan simulasi yang deterministik dan bisa diulang. Simulasi berbasis frame (`_process`/`_physics_process`) bergantung pada delta time yang bervariasi, membuat reproduksi eksak tidak mungkin.

## Keputusan
Simulasi berjalan per **tick** lewat `Simulation.step()`. Satu tick merepresentasikan 10 menit waktu simulasi. `SimClock` yang memanggil `step()` berdasarkan waktu nyata, tapi logika simulasi tidak mengenal delta frame.

## Konsekuensi
- Hasil simulasi tidak bergantung pada FPS.
- Seed sama + tick sama = state identik.
- View harus interpolasi posisi antar tick untuk tampilan halus.
- Tidak ada logika simulasi di `_process` atau `_physics_process`.
