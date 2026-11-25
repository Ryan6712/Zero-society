# Aturan Code Quality & Clean Code
 
Dokumen ini berisi standar penulisan kode, arsitektur simulasi (Godot 4.7.x + GDScript), kebersihan kode (Clean Code), serta praktik integritas dan keamanan untuk **Society Zero**.
 
Berlaku untuk developer sendiri, AI agent, dan kontributor. Dokumen terkait: `development.md` (alur kerja dan testing), `committing.md` (commit dan PR), `docs/DESIGN.md` (keputusan desain/ADR).
 
---
 
## 1. Arsitektur Simulasi & Pola Interaksi (Sim Core + View)
 
Proyek ini memisahkan **simulasi** dari **tampilan**. Simulasi adalah sumber kebenaran; tampilan hanya membaca dan menggambar.
 
```text
 view/  (Node, scene, UI)
   │  membaca state, mengirim command
   ▼
 autoload/  (SimClock, EventLog; tipis, hanya menghubungkan)
   │
   ▼
 sim/  (RefCounted / Resource, TANPA Node)
   ├─ core/      state murni
   ├─ actions/   definisi, validasi
   ├─ ai/        pemilihan aksi (Utility AI)
   └─ systems/   needs, movement, action, world
```
 
Arah dependensi: `view -> sim`. **`sim/` tidak boleh mengimpor atau mereferensikan `view/`.**
 
### Aturan utama
 
1. **State adalah data murni.**
   * **SALAH:** `AgentState` menyimpan referensi `Node2D` atau `Sprite2D`.
   * **BENAR:** `AgentState` hanya berisi data (posisi tile, needs, inventori). `AgentView` yang membaca state itu.
2. **View tidak menulis state. Input masuk lewat command.**
   * **SALAH:**
```gdscript
simulation.world.granary_food += 5
```
   * **BENAR:**
```gdscript
simulation.enqueue(AddFoodCommand.new(5))
```
3. **Engine menentukan kebenaran, AI hanya mengusulkan.**
   * Pemilih aksi (Utility AI, dan kelak LLM) mengembalikan **usulan** aksi.
   * `ActionValidator` memeriksa, `ActionSystem` menjalankan, engine mengubah state.
4. **Logika per tick, bukan per frame.** Tidak ada logika simulasi di `_process`/`_physics_process`. Satu-satunya jembatan adalah `SimClock` yang memanggil `Simulation.step()`.
5. **Notifikasi ke view lewat signal.** `sim/` memancarkan signal atau menyediakan snapshot; view yang berlangganan. Jangan memanggil method view dari `sim/`.
6. **Autoload tetap tipis.** Autoload hanya menghubungkan (clock, logging). Aturan simulasi tidak boleh tinggal di autoload.
7. **LLM (tahap mendatang) berada di balik antarmuka** (mis. `DialogueProvider`). LLM tidak pernah langsung mengubah state atau database, dan keluarannya wajib berupa data terstruktur yang divalidasi engine.
---
 
## 2. Prinsip Clean Code (Robert C. Martin)
 
1. **DRY (Don't Repeat Yourself):**
   * Semua perubahan makanan melewati **satu jalur kode** agar konservasi bisa diaudit.
   * Aksi didefinisikan sebagai data (`ActionDef`), bukan `if/else` berulang di banyak tempat.
   * Kurva dan rumus yang dipakai berulang diekstrak ke `Curves`.
2. **KISS (Keep It Simple, Stupid):**
   * Tulis kode paling sederhana yang memenuhi tiket.
   * Abstraksi baru boleh ditambahkan jika ada alasan konseptual yang jelas (mis. persiapan kontribusi banyak orang atau integrasi LLM), **tetapi alasan itu dicatat** (komentar atau ADR). Abstraksi tanpa alasan tertulis ditolak di review.
3. **SRP (Single Responsibility Principle):**
   * `NeedsSystem`: hanya mengubah need seiring waktu.
   * `UtilityBrain`: hanya memilih aksi (tidak mengubah state).
   * `ActionValidator`: hanya memeriksa kelayakan (tidak mengubah state).
   * `ActionSystem`: menjalankan siklus hidup aksi.
   * `MovementSystem`: hanya gerak dan pathfinding.
   * `EventLog`: hanya mencatat.
   * `AgentView`/UI: hanya menggambar dan meneruskan input.
4. **Fungsi dan file yang terbaca:**
   * Fungsi pendek (acuan: di bawah sekitar 40 baris) dan satu tujuan.
   * File di bawah sekitar 300 baris; lebih dari itu pertimbangkan dipecah.
   * Parameter fungsi maksimal sekitar 4; lebih dari itu gunakan objek/Dictionary bertipe jelas.
   * Hindari nesting dalam; gunakan *early return*.
5. **Tidak ada magic number.** Angka seperti laju decay, bobot skor, dan ambang ditaruh sebagai konstanta bernama (`SimConst`) atau data konfigurasi, bukan tersebar di kode.
6. **Komentar menjelaskan "kenapa", bukan "apa".** API publik di `sim/` diberi doc comment (`##`).
---
 
## 3. Konvensi Penamaan (Naming Conventions)
 
Mengikuti panduan gaya GDScript resmi.
 
* **Bahasa**: gunakan **Bahasa Inggris** secara konsisten untuk nama variabel, fungsi, class, file, dan key data. Komentar boleh Bahasa Indonesia atau Inggris, asal konsisten dalam satu file.
* **GDScript**:
  * File, folder, fungsi, variabel: `snake_case` (contoh: `agent_state.gd`, `utility_brain.gd`, `hunger_decay`).
  * `class_name`: `PascalCase` (contoh: `AgentState`, `UtilityBrain`, `ActionValidator`).
  * Konstanta dan nilai enum: `UPPER_SNAKE_CASE` (contoh: `TICKS_PER_DAY`, `NO_PATH`). Nama enum: `PascalCase`.
  * Signal: `snake_case`, bentuk lampau (contoh: `ticked`, `action_completed`).
  * Anggota privat: awalan underscore (contoh: `_accum`, `_score`).
  * ID aksi dan kunci need: `StringName` (contoh: `&"eat"`, `&"hunger"`), idealnya didefinisikan sebagai konstanta.
* **Scene dan resource**: `snake_case.tscn` / `.tres` (contoh: `agent_view.tscn`).
* **Tes (GUT)**: file `test_<subjek>.gd`, fungsi `test_<perilaku>` (contoh: `test_needs_system.gd`, `test_hunger_decays_per_tick`).
* **Data serialisasi (JSON, event log):** key dan tipe event memakai **`snake_case`** (contoh: `decision_trace`, `action_started`, `location_id`). Catatan: contoh JSON di dokumen konsep awal memakai `camelCase`; untuk implementasi, standar yang berlaku adalah `snake_case`.
* **ID entitas**: `agent_001`, `location_market`, `event_00042` (huruf kecil dengan garis bawah).
* **Tiket dan branch**: `SZ-204`, `feature/SZ-204-action-lifecycle`.
---
 
## 4. Standar Penulisan GDScript
 
1. **Static typing wajib di `sim/`.** Variabel, parameter, dan nilai kembalian diberi tipe; gunakan array bertipe (`Array[Vector2i]`).
```gdscript
var path: Array[Vector2i] = []
func hour_of_day() -> float:
```
2. **Hindari `Variant` tak terkontrol untuk state inti.** Dictionary boleh dipakai untuk need/inventori, tetapi kuncinya harus dari konstanta bernama, bukan string literal berserakan.
3. **Jangan memakai `get_node("...")` atau path string di `sim/`.** `sim/` tidak mengenal scene tree.
4. **`@export` hanya di `Resource` atau node `view/`**, bukan di kelas state simulasi.
5. **Penanganan kesalahan eksplisit.** Gunakan `assert` untuk asumsi internal yang tidak boleh dilanggar, dan `push_error` untuk kondisi tak terduga yang dilaporkan. Jangan menelan kegagalan secara diam-diam. Alasan penolakan aksi dikembalikan sebagai **kode alasan** (enum), bukan string bebas.
6. **Float:** jangan membandingkan dengan `==`; gunakan `is_equal_approx()` atau pembanding berambang. Untuk hash determinism, pastikan urutan operasi tetap.
7. **Hindari efek samping tersembunyi.** Fungsi yang mengubah state harus jelas dari namanya (`apply_`, `update_`, `consume_`); fungsi evaluasi (`score_`, `can_`) tidak boleh mengubah state.
---
 
## 5. Integritas Simulasi & Keamanan (Determinism & Safety Standards)
 
Di proyek ini, "keamanan" mencakup **integritas hasil simulasi** (agar eksperimen bisa dipercaya dan diulang) dan keamanan input/data.
 
### 5.1 Determinism
 
1. **Satu sumber randomness.** Hanya `RandomNumberGenerator` milik `Simulation` yang di-seed. Dilarang memakai `randf()`, `randi()`, `randf_range()`, `randi_range()` global di `sim/`.
   * **SALAH:** `if randf() < 0.1:` di dalam `UtilityBrain`.
   * **BENAR:** `if rng.randf() < 0.1:` dengan `rng` dikirim sebagai parameter.
2. **Urutan iterasi tetap.** Iterasi agent berdasarkan `id` terurut. Jangan mengandalkan urutan `Dictionary` yang tidak terdefinisi jelas.
3. **Pengurutan wajib punya tie-breaker.** Pengurutan kustom di Godot tidak dijamin stabil, sehingga skor yang sama dapat menghasilkan urutan berbeda.
   * **SALAH:**
```gdscript
scored.sort_custom(func(a, b): return a.score > b.score)
```
   * **BENAR:**
```gdscript
scored.sort_custom(_compare_scored)
 
static func _compare_scored(a: Dictionary, b: Dictionary) -> bool:
	if a.score != b.score:
		return a.score > b.score
	return String(a.id) < String(b.id)
```
4. **Tidak ada sumber nondeterministik di `sim/`:** waktu sistem (`Time`, `OS`), `delta` frame, urutan callback thread, atau data yang bergantung platform.
5. **Satu versi Godot, satu platform acuan (CI Linux).** Hash golden terikat pada keduanya.
### 5.2 Validasi input dan data
 
1. **Semua aksi divalidasi engine** sebelum dijalankan, termasuk aksi dari tes, UI debug, dan (kelak) LLM.
2. **Validasi konfigurasi dunia** saat dimuat (`default_world.json`): batas ukuran, jumlah agent, seed, tipe field. Tolak data tidak valid dengan pesan jelas.
3. **Event log mengikuti skema** dan divalidasi. Jangan menulis event tanpa field wajib.
4. **Data dari luar memakai JSON, bukan `Resource` (`.tres`).** File Resource dapat memuat skrip tertanam; jangan pernah memuat file `.tres`/`.tscn` dari sumber yang tidak dipercaya (mis. konfigurasi eksperimen kiriman pihak lain). `ActionDef` sebagai Resource hanya boleh berasal dari repo yang sudah melalui review.
5. **Keluaran LLM tidak dipercaya** (tahap mendatang): diurai ke format terstruktur, divalidasi skema dan aturan dunia, dan ditolak jika tidak valid. LLM tidak boleh punya akses langsung ke state.
6. **Rahasia:** API key dan token tidak pernah masuk kode, commit, atau event log.
### 5.3 Integritas data simulasi
 
1. **Konservasi sumber daya:** perubahan makanan melewati satu jalur; tidak ada pembuatan atau penghapusan barang "diam-diam".
2. **Entitas unik:** ID agent, lokasi, dan event unik dalam satu dunia (`event_id` bertambah monoton).
3. **Invariant dicek di tes** (lihat `development.md` bagian 3). Pelanggaran invariant adalah bug engine, bukan bug AI.
---
 
## 6. Formatting & Linting Automation
 
Setiap developer/agent wajib memformat dan melakukan lint sebelum commit:
 
* **GDScript (format dan lint)**: `gdtoolkit`
```bash
gdformat sim view autoload tests tools
gdlint sim view autoload tests tools
```
  Cek tanpa mengubah file (dipakai di CI):
```bash
gdformat --check sim view autoload tests tools
```
* **Indentasi:** tab (default Godot dan `gdformat`). Jangan mencampur tab dan spasi.
* **Konfigurasi:** simpan aturan di file konfigurasi gdtoolkit di root repo agar semua orang dan CI memakai aturan yang sama.
* **Tes:** jalankan GUT sebelum commit (lihat `development.md`).
* **Pemeriksaan arsitektur otomatis di CI:** tidak ada `extends Node` dan tidak ada RNG global di `sim/`.
* **Hook lokal (opsional):** pre-commit hook yang menjalankan `gdformat --check` dan `gdlint` untuk menangkap masalah lebih awal.
> Jika `gdlint`/`gdformat` gagal mem-parse sintaks yang valid di Godot 4.7, kemungkinan gdtoolkit belum mendukungnya. Laporkan dan catat di `docs/`; jangan mematikan lint tanpa alasan tertulis.
 
---
 
## 7. Checklist Review Kode
 
Reviewer (manusia atau agent) memeriksa:
 
- [ ] Perubahan sesuai satu tiket dan tidak melebar.
- [ ] `sim/` bebas `Node`, scene, dan RNG global; tidak ada referensi ke `view/`.
- [ ] State tetap data murni; view tidak menulis state.
- [ ] Semua aksi baru melewati validator.
- [ ] Pengurutan punya tie-breaker; iterasi agent terurut.
- [ ] Tidak ada magic number baru; konstanta/ konfigurasi dipakai.
- [ ] Static typing lengkap; penamaan sesuai bagian 3.
- [ ] Tes baru ada dan bermakna (bukan sekadar membuat hijau); invariant tidak dilonggarkan.
- [ ] Dampak ke hasil simulasi dijelaskan; golden hash tidak diubah tanpa alasan.
- [ ] Tidak ada rahasia atau file hasil run lokal.
 
