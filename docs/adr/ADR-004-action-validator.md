# ADR-004: Validasi Aksi oleh Engine

## Status
Diterima

## Konteks
Agent (Utility AI, dan kelak LLM) memilih aksi. Jika aksi langsung dijalankan tanpa validasi, bug di AI atau input berbahaya dari LLM bisa merusak state simulasi.

## Keputusan
- AI hanya **mengusulkan** aksi. `ActionValidator` memeriksa prasyarat (lokasi, energi, stok, dsb).
- Penolakan dikembalikan sebagai **kode alasan** (enum `RejectReason`), bukan string bebas.
- `ActionSystem` yang menjalankan aksi yang lolos validasi dan mengubah state.
- Semua aksi — dari AI, tes, UI debug, atau LLM — melewati jalur validasi yang sama.

## Konsekuensi
- State simulasi tidak bisa dirusak oleh AI yang salah.
- Setiap penolakan bisa ditelusuri dan dites.
- Sedikit overhead per aksi, tapi mencegah bug kategori besar.
