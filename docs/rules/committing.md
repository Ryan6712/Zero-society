# Aturan Commit & Git Workflow

Dokumen ini berisi standar pengelolaan versi kode, format pesan commit, strategi percabangan (*branching*), dan penanganan Pull Request (PR) untuk proyek **Society Zero**.

Proyek ini adalah simulator deterministik, jadi ada beberapa aturan tambahan (bagian 5) yang tidak ada di proyek web biasa: perubahan kecil di logika simulasi bisa mengubah hasil seluruh eksperimen, dan itu harus terlihat jelas di riwayat git.

---

## 1. Spesifikasi Pesan Commit (Conventional Commits)

Setiap commit **wajib** mengikuti standar [Conventional Commits](https://www.conventionalcommits.org/).

### Format standar

```text
<type>(<scope>): <deskripsi singkat>

[opsional body]

[opsional footer]
```

### Tipe commit (`<type>`)

* **`feat`**: Menambahkan fitur baru (contoh: aksi baru, sistem baru, komponen UI baru).
* **`fix`**: Memperbaiki bug atau kesalahan logika.
* **`docs`**: Perubahan dokumentasi (`docs/`, `README.md`, ADR, `CONTRIBUTING.md`).
* **`style`**: Perubahan format kode tanpa mengubah logika (hasil `gdformat`, spasi, penamaan sesuai lint).
* **`refactor`**: Restrukturisasi kode tanpa menambah fitur atau memperbaiki bug. **Hasil simulasi tidak boleh berubah** (hash determinism tetap sama).
* **`perf`**: Peningkatan performa (optimasi tick, pathfinding, penjadwalan event) tanpa mengubah hasil simulasi.
* **`test`**: Menambah atau memperbaiki tes (GUT): unit, sistem, skenario, invariant, determinism, golden replay.
* **`chore`**: Pemeliharaan: struktur repo, `.gitignore`, `project.godot`, pembaruan versi Godot/GUT.
* **`ci`**: Perubahan konfigurasi CI (`.github/workflows/`).
* **`revert`**: Membatalkan commit sebelumnya (sebutkan hash yang dibatalkan di body).

### Scope terkait proyek (`<scope>`)

Gunakan scope yang mencerminkan modul yang diubah:

| Scope | Area |
|---|---|
| `core` | `sim/core`: `WorldState`, `AgentState`, `ActionInstance`, kontrak data |
| `clock` | `SimClock`, tick loop, `Simulation.step()` |
| `needs` | `NeedsSystem` (lapar, energi, kesehatan) |
| `actions` | `ActionDef`, `ActionLibrary`, `ActionValidator`, `ActionSystem` |
| `movement` | `MovementSystem`, pathfinding `AStarGrid2D` |
| `ai` | `UtilityBrain`, kurva, consideration, kepribadian |
| `world` | `WorldSystem`, siang/malam, produksi ladang, `GridData` |
| `events` | `EventLog`, skema event, `decision_trace` |
| `balance` | Tuning parameter perilaku (bobot, laju decay, ambang) |
| `view` | Scene, `AgentView`, kamera, tilemap |
| `ui` | HUD, kontrol waktu, agent inspector |
| `data` | `default_world.json`, konfigurasi dunia, seed |
| `tools` | Runner headless, skrip sweep seed |
| `ci` | GitHub Actions |
| `deps` | Versi Godot, GUT, gdtoolkit |

### Contoh pesan commit

```text
feat(actions): tambahkan aksi work_farm dengan validasi lokasi dan energi
fix(needs): perbaiki decay lapar yang melewati batas 0
docs(rules): sesuaikan aturan commit dengan proyek Society Zero
refactor(core): pisahkan serialisasi state ke fungsi terpisah
perf(movement): cache jalur AStarGrid2D untuk tujuan yang sama
test(clock): tambahkan tes determinism seed 42 selama 1000 tick
chore(deps): naikkan Godot ke 4.7.2
ci(ci): tambahkan job pemeriksaan aturan arsitektur sim/
feat(events): tambahkan decision_trace ke event action_started
```

---

## 2. Aturan Hygiene & Kebersihan Commit

1. **Atomic commits**: satu commit berisi satu perubahan logis. Jangan mencampur fitur, refactor, dan bugfix dalam satu commit.
2. **Bahasa**: gunakan Bahasa Indonesia atau Bahasa Inggris secara konsisten dalam seluruh pesan commit. Default proyek: **Bahasa Indonesia**. Istilah teknis (`tick`, `seed`, `agent`) tidak perlu diterjemahkan.
3. **Imperatif / present tense**: `feat(ai): tambahkan commitment bonus` bukan `feat(ai): menambahkan commitment bonus`.
4. **Huruf kecil dan tanpa titik** di akhir judul commit.
5. **Judul maksimal sekitar 72 karakter.** Detail panjang masuk ke body.
6. **Tidak ada secrets**: **DILARANG KERAS** memasukkan API key (termasuk key LLM di tahap mendatang), token, atau file `.env` ke commit.
7. **Jangan commit hasil run lokal**: file di `user://logs/`, hasil sweep sementara, dan folder `.godot/`. Pastikan `.gitignore` menutupnya.
8. **Commit file yang memang harus ikut**: file `.import` dan `.uid` yang dihasilkan Godot di samping aset/skrip, serta `addons/gut/`. Jika ragu, cek `git status` dan bandingkan dengan panduan Godot untuk versi yang dipin.
9. **Jangan commit build/export** (`build/`, `*.pck`, binary).

---

## 3. Strategi Percabangan (Branching Strategy)

Proyek ini memakai **trunk-based development**: satu branch utama `main` yang selalu hijau, ditambah branch pendek per tiket.

```text
main (selalu hijau, selalu bisa dijalankan)
  ├── feature/SZ-204-action-lifecycle
  ├── feature/SZ-302-utility-brain
  ├── fix/SZ-215-hunger-below-zero
  ├── docs/SZ-004-design-adr
  ├── chore/SZ-001-repo-structure
  └── ci/SZ-002-github-actions
```

* **`main`**: kode stabil. Semua tes (termasuk determinism) wajib lulus. Tidak ada commit langsung ke `main`.
* **`feature/<id-tiket>-<slug>`**: pengembangan fitur, dibuat dari `main`.
* **`fix/<id-tiket>-<slug>`**: perbaikan bug, dibuat dari `main`.
* **`docs/`, `chore/`, `ci/`, `test/`**: untuk perubahan non-fitur, dengan pola penamaan yang sama.

Aturan:
- **Branch berumur pendek** (idealnya selesai dalam beberapa hari). Branch yang menggantung lama akan konflik dengan `sim/core` yang aktif berubah.
- Sinkronkan dengan `main` (rebase) sebelum meminta review.
- Hapus branch setelah merge.

**Mengapa tanpa `develop`/staging:** proyek lama punya server staging dan produksi; Society Zero tidak punya lingkungan deploy. Branch `develop` hanya menambah pekerjaan merge tanpa manfaat. Jika nanti ada rilis versi (mis. build demo), cukup beri **tag** di `main`.

### Tagging dan versi

* Rilis memakai tag semver: `v0.1.0`, `v0.2.0`, dst.
* Titik penting sprint bisa diberi tag nama, mis. `contracts-v0` (kontrak data dibekukan).
* Tag hanya dibuat dari `main`.

---

## 4. Alur Pull Request (PR) & Code Review

1. Semua perubahan wajib masuk lewat **Pull Request** dari branch kerja ke `main`.
2. **Judul PR mengikuti format Conventional Commits.** Merge dilakukan dengan **squash merge**, sehingga judul PR menjadi pesan commit di `main`.
3. **PR kecil**: usahakan di bawah sekitar 400 baris diff. PR besar dipecah.
4. **Checklist PR**:
   - [ ] `godot --headless --import` lalu `godot --headless -s addons/gut/gut_cmdln.gd` dijalankan dan semua tes lulus.
   - [ ] `gdformat --check` dan `gdlint` lulus.
   - [ ] Tidak ada `extends Node` atau referensi scene di `sim/`.
   - [ ] Tidak ada `randf()`/`randi()` global di `sim/`.
   - [ ] Tes baru ditulis untuk perubahan ini (wajib untuk kode `sim/`; untuk bug fix, tes regresi).
   - [ ] Deskripsi PR menjelaskan perubahan, cara pengujian, dan tiket terkait.
   - [ ] Dokumentasi/ADR diperbarui jika ada keputusan baru.
   - [ ] Tidak ada file sementara, log, atau hasil run lokal yang ikut ter-commit.
5. **Persetujuan**: minimal 1 approval sebelum merge ke `main`. Perubahan di area terlindungi (`sim/core`, skema event; lihat `CODEOWNERS`) wajib disetujui maintainer.
6. **CI harus hijau** (job `lint` dan `test`) sebelum merge. Aktifkan branch protection agar ini ditegakkan otomatis.

### Template deskripsi PR

```markdown
## Ringkasan
<apa yang berubah dan kenapa>

## Tiket
Refs: SZ-xxx

## Cara menguji
<perintah / langkah>

- [ ] Tidak ada (hash determinism tetap)
- [ ] Ada (jelaskan, dan lihat aturan di bagian 5)
```

---

## 5. Aturan Khusus Simulasi

Karena hasil simulasi harus bisa diulang dan dibandingkan, perubahan perilaku harus tercatat.

1. **Refactor dan perf tidak boleh mengubah hasil.** Jika hash determinism berubah pada commit bertipe `refactor` atau `perf`, itu bug.
2. **Perubahan perilaku dipisah dari perubahan pembaruan golden hash.**
   - Commit pertama: perubahan logika (`feat`/`fix`/`balance`).
   - Commit kedua: pembaruan golden hash, dengan alasan di body.
   ```text
   test(golden): perbarui hash seed 42 tick 1000

   Hash berubah karena commit "fix(needs): perbaiki decay lapar".
   Perubahan disengaja: agent tidak lagi kelaparan di tick 640.
   ```
3. **Tuning parameter memakai scope `balance`** dan wajib dicatat di `docs/tuning-log.md` dalam PR yang sama. Ubah **satu parameter per commit** dan sertakan hasil sweep seed di body.
   ```text
   fix(balance): turunkan laju decay hunger dari 0.35 ke 0.30

   Sweep seed 1-20 x 3 agent x 5 hari:
   survival 82% -> 91%, switch aksi/hari tidak berubah signifikan.
   Lihat docs/tuning-log.md entri 2026-xx-xx.
   ```
4. **Perubahan kontrak data** (`AgentState`, `WorldState`, skema Event) wajib punya ADR dan memakai penanda breaking change:
   ```text
   feat(events)!: ganti field context menjadi snapshot pada event

   BREAKING CHANGE: log lama (.jsonl) tidak kompatibel dengan skema baru.
   Lihat ADR-007.
   ```
5. **Bug yang dilaporkan dengan seed** diperbaiki dengan dua commit atau satu commit atomik berisi tes regresi dan perbaikannya. Cantumkan seed dan tick di body:
   ```text
   fix(actions): tolak eat saat stok lumbung nol

   Seed 1337, tick 412: agent memakan stok yang sudah 0.
   Tes regresi ditambahkan di tests/test_action_validator.gd.
   ```
6. **Perubahan versi Godot/GUT** (`chore(deps)`) berdiri sendiri dalam satu PR dan memeriksa ulang hash determinism. Versi GUT harus cocok dengan versi minor Godot.

---

## 6. Footer yang Dianjurkan

```text
Refs: SZ-204          # tiket terkait
Closes: #37           # menutup issue GitHub
BREAKING CHANGE: ...  # untuk perubahan kontrak
Co-authored-by: Nama <email>   # jika berkolaborasi
```
