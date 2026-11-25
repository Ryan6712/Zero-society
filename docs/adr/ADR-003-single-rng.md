# ADR-003: Satu Sumber RNG Ber-seed

## Status
Diterima

## Konteks
Determinisme mengharuskan semua keacakan berasal dari sumber yang sama dan bisa diulang. Godot menyediakan `randf()`/`randi()` global yang tidak ber-seed, serta `RandomNumberGenerator` yang bisa di-seed.

## Keputusan
- Hanya `RandomNumberGenerator` milik `Simulation` yang dipakai di `sim/`.
- `randf()`, `randi()`, `randf_range()`, `randi_range()` global **dilarang** di `sim/`.
- RNG dikirim sebagai parameter ke fungsi yang membutuhkan keacakan.
- CI memeriksa pelanggaran ini dengan grep otomatis.

## Konsekuensi
- Seed sama = hasil sama, di semua platform (dengan Godot versi sama).
- Semua fungsi yang butuh randomness harus menerima RNG sebagai parameter.
- Tes bisa mengontrol keacakan sepenuhnya.
