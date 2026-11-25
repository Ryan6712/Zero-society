# Pedoman Devlog & Update README

Dokumen ini mengatur tata cara penulisan catatan pengembangan (devlog) dan aturan pembaruan status pada `README.md`.

---

## 1. Prinsip Pemisahan

- **`README.md`**: Etalase publik & dokumentasi pengguna. **Bukan buku harian**. Harus tetap bersih, ringkas, dan fokus pada cara instalasi/penggunaan.
- **`docs/devlog/`** atau `DEVLOG.md`: Tempat catatan teknis mendalam per sprint / per milestone.

---

## 2. Kapan Waktu Update `README.md`?

| Kejadian | Update README? | Yang Diupdate |
|---|---|---|
| Commit tiket kecil (`feat`, `fix`, `test`) | **TIDAK** | Cukup di git commit message |
| PR di-merge | **TIDAK** | Kecuali PR tersebut menutup satu sprint |
| **Akhir Sprint** (DoD tercapai) | **YA** | Status sprint di tabel Roadmap, ringkasan capaian terbaru |
| **Tag Rilis** (`v0.1.0`, dst) | **YA** | Nomor versi, fitur baru, status proyek |
| Perubahan dependensi / cara install | **YA** | Section Tech Stack / Memulai |

> **Aturan:** Update README hanya dilakukan pada akhir sprint atau rilis versi. Jangan mengotori git history dengan update README per commit.

---

## 3. Format Penulisan Devlog

Setiap entri devlog (disimpan di `docs/devlog/sprint-<N>.md` atau `DEVLOG.md`) memakai struktur tetap:

```markdown
# Devlog: Sprint <N> — <Nama Sprint>
Tanggal: YYYY-MM-DD
Penulis: <nama/agent>

## 1. Ringkasan Sprint
- Target: <1 kalimat tujuan>
- Status: Selesai / Sedang Berjalan
- Tiket tertutup: SZ-xxx, SZ-yyy

## 2. Yang Dikerjakan
- **[Modul/Fitur]**: Apa yang dibuat dan alasan desain.
- **[Sistem]**: Perubahan perilaku atau penambahan sistem baru.

## 3. Hasil Pengujian & Determinism
- Unit test: X passed, 0 failed (GUT 9.7.1)
- Linter & format: `gdformat` & `gdlint` bersih
- Golden hash benchmark:
  - Seed: 42
  - Ticks: 1000
  - Hash: `<sha256>`
  - Determinism check: PASS / FAIL

## 4. Masalah & Solusi (Technical Insights)
- Kendala teknis yang dihadapi dan cara menyelesaikannya (mis. sorting StringName di GDScript).

## 5. Next Steps
- Target sprint berikutnya.
```

---

## 4. Format Update pada `README.md`

Saat sprint selesai, update bagian:

1. **Status Proyek**: mis. `Status: pra-alpha (Sprint 1 selesai: simulasi headless deterministik jalan).`
2. **Roadmap Sprint**: beri centang `[x]` pada sprint yang selesai.
3. **Bagian Devlog**: tabel ringkas berisi tanggal, sprint, dan link ke file devlog terkait.
