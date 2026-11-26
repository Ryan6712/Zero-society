# Society Zero --- Phase 0: Living Foundation

**Dokumen konsep pengembangan**\
**Versi:** 1.0\
**Status:** Draft konsep

------------------------------------------------------------------------

## 1. Gambaran Umum

Phase 0: Living Foundation adalah tahap untuk membangun sistem kehidupan
individu di dalam Society Zero. Fokusnya bukan masyarakat, hubungan
sosial, atau percakapan, melainkan NPC yang mampu menjalani kehidupan
dasar secara mandiri.

Kondisi awal repository memiliki tiga aktivitas utama: Work, Eat, dan
Rest. NPC mengevaluasi pilihan tersebut dan mengulang siklusnya. Ini
merupakan fondasi awal Utility AI, tetapi perilakunya masih terbatas
pada daftar aktivitas sederhana.

Phase 0 mengembangkan pendekatan tersebut menjadi sistem yang lebih
utuh. NPC memiliki kondisi internal, kebutuhan, akses terhadap sumber
daya, kemampuan menggunakan lingkungan, serta proses pengambilan
keputusan yang memiliki konsekuensi.

> NPC tidak seharusnya hanya mengulang daftar aktivitas. NPC harus
> memiliki kondisi yang mendorongnya melakukan sesuatu, lingkungan yang
> menyediakan kemungkinan tindakan, dan konsekuensi yang memengaruhi
> kondisi berikutnya.

### Tujuan Phase 0

Pada akhir fase ini, NPC diharapkan mampu: 1. Mempertahankan kondisi
hidup dasarnya. 2. Mengevaluasi kebutuhan dan kondisi dirinya. 3.
Memilih aktivitas sesuai kondisi dan lingkungan. 4. Menjalankan
aktivitas selama durasi tertentu. 5. Menggunakan objek dan sumber daya
dunia. 6. Menghadapi kegagalan ketika aktivitas tidak dapat dilakukan.
7. Menunjukkan variasi perilaku berdasarkan karakteristik individu. 8.
Menjalani siklus kehidupan tanpa perintah langsung dari pengguna.

## 2. Batasan Ruang Lingkup

### Termasuk dalam Phase 0

-   Identitas dan state individu.
-   Kebutuhan dasar dan kondisi fisik.
-   Sistem aktivitas dan action lifecycle.
-   Utility-based decision making.
-   Lingkungan dan objek interaktif.
-   Resource sederhana.
-   Personality dasar.
-   World clock.
-   Decision trace dan event logging.
-   Determinisme simulasi menggunakan seed.

### Belum menjadi fokus

-   Percakapan alami antar-NPC.
-   Friendship, romance, atau hubungan sosial kompleks.
-   Pembentukan kelompok dan organisasi.
-   Ekonomi masyarakat.
-   Politik, pemerintahan, dan hukum.
-   Generasi dan pewarisan budaya.
-   LLM atau generative AI.

Phase 0 berfokus pada individu dan interaksinya dengan lingkungan fisik.
Fitur sosial dikembangkan setelah fondasi individu stabil.

## 3. Needs System

### 3.1 Konsep

Needs merupakan representasi kondisi internal NPC yang berubah selama
simulasi. Needs harus dipisahkan dari aktivitas: Hunger adalah
kebutuhan, sedangkan Eat adalah salah satu tindakan untuk meresponsnya.

Dengan pemisahan ini, satu kebutuhan dapat memiliki beberapa respons dan
satu aktivitas dapat memengaruhi beberapa kebutuhan sekaligus.

### 3.2 Kebutuhan utama

Untuk implementasi awal, gunakan tiga kebutuhan/kondisi berikut:

  -----------------------------------------------------------------------
  Need                    Makna                   Contoh perubahan
  ----------------------- ----------------------- -----------------------
  Hunger                  Tingkat kebutuhan       Meningkat seiring waktu
                          terhadap makanan        dan aktivitas

  Energy                  Tingkat energi untuk    Berkurang saat bekerja,
                          melakukan aktivitas     pulih saat tidur

  Health                  Kondisi kesehatan fisik Dipengaruhi kondisi
                                                  buruk, cedera, atau
                                                  pemulihan
  -----------------------------------------------------------------------

Nilai dapat menggunakan rentang 0--100, dengan interpretasi yang
konsisten. Hunger dan Energy dapat berubah secara rutin. Health lebih
tepat diperlakukan sebagai kondisi yang dipengaruhi kejadian, bukan
sekadar kebutuhan yang terus naik atau turun setiap tick.

### 3.3 Perubahan kebutuhan

-   Work mengurangi Energy dan dapat meningkatkan Hunger.
-   Eat mengurangi Hunger.
-   Sleep memulihkan Energy.
-   Aktivitas berat dapat mengurangi Energy lebih cepat.
-   Kondisi tertentu dapat menurunkan Health.

Perubahan kebutuhan harus menjadi konsekuensi dari simulasi, bukan angka
yang berubah tanpa hubungan dengan aktivitas.

### 3.4 Prioritas

Mulai dengan Hunger dan Energy sebagai kebutuhan aktif yang memengaruhi
keputusan. Health dapat dimasukkan sebagai kondisi dasar terlebih
dahulu, lalu diberi konsekuensi lebih lengkap setelah sistem aktivitas
stabil.

Jangan menambahkan banyak kebutuhan sekaligus. Lebih baik sedikit
kebutuhan yang benar-benar berpengaruh daripada banyak atribut yang
hanya ditampilkan di UI.

## 4. Activity System

### 4.1 Konsep

Activity merupakan tindakan atau rangkaian tindakan yang dapat dilakukan
NPC untuk memenuhi kebutuhan, memperoleh sesuatu, atau mengubah
kondisinya.

Sistem aktivitas perlu lebih fleksibel daripada tiga pilihan tetap Work,
Eat, dan Rest.

  -----------------------------------------------------------------------
  Activity          Tujuan            Persyaratan umum  Dampak
  ----------------- ----------------- ----------------- -----------------
  Work              Melakukan         Pekerjaan dan     Menghasilkan
                    pekerjaan         lokasi kerja      resource,
                                      tersedia          mengurangi Energy

  Eat               Mengonsumsi       Makanan tersedia  Mengurangi Hunger
                    makanan           dan dapat         
                                      dijangkau         

  Sleep             Memulihkan energi Tempat tidur atau Memulihkan Energy
                                      lokasi yang       
                                      sesuai tersedia   

  Wander            Berpindah atau    Lokasi tujuan     Mengubah lokasi
                    menjelajahi area  dapat dijangkau   

  Idle              Tidak melakukan   Tidak ada         Tidak ada
                    aktivitas         aktivitas         perubahan besar
                    produktif         prioritas         

  Recover           Memulihkan        Sarana pemulihan  Membantu
                    kondisi           tersedia          pemulihan Health
  -----------------------------------------------------------------------

Daftar ini bukan berarti semua aktivitas harus langsung dibuat.
Tambahkan aktivitas secara bertahap sesuai kebutuhan pengujian.

### 4.2 Aktivitas memiliki konsekuensi

Setiap aktivitas perlu mendefinisikan: - Persyaratan sebelum dimulai. -
Durasi atau kondisi penyelesaian. - Resource yang dibutuhkan. - Resource
yang dihasilkan atau dikonsumsi. - Perubahan kebutuhan. - Kondisi yang
menyebabkan aktivitas gagal. - Kondisi yang menyebabkan aktivitas
dihentikan.

Contoh alur Eat: 1. NPC memiliki Hunger tinggi. 2. NPC mencari sumber
makanan yang tersedia. 3. Sistem memeriksa ketersediaan makanan. 4. NPC
bergerak menuju sumber makanan. 5. Engine memvalidasi akses terhadap
makanan. 6. Makanan dikonsumsi. 7. Jumlah makanan berkurang. 8. Hunger
menurun. 9. Aktivitas selesai dan hasilnya dicatat.

Jika makanan tidak tersedia, NPC tidak boleh dianggap sudah makan.
Sistem harus mencatat kegagalan atau memungkinkan NPC mencari alternatif
yang valid.

## 5. Action Lifecycle

### 5.1 Masalah yang perlu dihindari

NPC tidak seharusnya mengevaluasi dan mengganti aktivitas secara membabi
buta pada setiap tick.

Contoh perilaku yang tidak diinginkan: - Tick 1: memilih Sleep. - Tick
2: memilih Eat. - Tick 3: memilih Work. - Tick 4: kembali memilih Sleep.

Perilaku ini membuat NPC terlihat tidak konsisten dan tidak pernah
menyelesaikan tindakan.

### 5.2 Siklus aktivitas

Setiap aktivitas memiliki lifecycle: 1. **Idle** --- NPC belum
menjalankan aktivitas. 2. **Evaluate** --- NPC mengevaluasi kondisi dan
kandidat aktivitas. 3. **Selected** --- sistem memilih aktivitas
terbaik. 4. **Validate** --- Simulation Engine memeriksa apakah
aktivitas dapat dilakukan. 5. **Execute** --- NPC menjalankan aktivitas.
6. **Complete** --- aktivitas selesai dengan hasil valid. 7. **Interrupt
atau Fail** --- aktivitas dihentikan atau gagal. 8. **Re-evaluate** ---
NPC mengevaluasi kebutuhan dan aktivitas berikutnya.

Aktivitas yang sedang berjalan sebaiknya dipertahankan sampai selesai,
kecuali ada alasan kuat untuk menghentikannya.

Contoh alasan interupsi: - Kebutuhan kritis muncul. - Objek yang
digunakan tidak lagi tersedia. - Jalur menuju tujuan terhalang. - NPC
kehilangan kemampuan untuk melanjutkan aktivitas. - Kondisi dunia
berubah sehingga aktivitas tidak lagi valid.

### 5.3 Evaluasi ulang

NPC tidak harus melakukan evaluasi penuh pada setiap tick. Evaluasi
dapat dipicu ketika: - Aktivitas selesai, gagal, atau diinterupsi. -
Kebutuhan melewati ambang tertentu. - Terjadi perubahan lingkungan yang
relevan. - NPC tiba di lokasi tujuan.

Pendekatan ini mengurangi pekerjaan komputasi dan menjaga perilaku tetap
stabil.

## 6. World Environment

### 6.1 Konsep

NPC harus hidup di lingkungan yang menyediakan objek dan sumber daya
yang benar-benar dapat digunakan. Lingkungan bukan sekadar dekorasi;
objek di dalamnya memiliki state dan fungsi yang diperiksa oleh
Simulation Engine.

Untuk Phase 0, cukup gunakan satu area kecil dengan beberapa objek.

  Object         Fungsi                 State yang mungkin
  -------------- ---------------------- ----------------------------------
  Bed            Tempat tidur           Tersedia atau sedang digunakan
  Food Storage   Menyimpan makanan      Jumlah dan kapasitas makanan
  Farm           Menghasilkan makanan   Kondisi produksi dan hasil panen
  Workplace      Tempat bekerja         Ketersediaan dan kapasitas
  House          Tempat tinggal         Lokasi dan objek yang tersedia

### 6.2 Interaksi dengan objek

NPC harus memenuhi persyaratan sebelum menggunakan objek.

**Food Storage** - Menyimpan jumlah makanan. - Memiliki kapasitas. - NPC
dapat mengambil makanan jika tersedia. - Jumlah makanan berkurang
setelah diambil atau dikonsumsi sesuai aturan.

**Bed** - Memiliki kapasitas penggunaan. - NPC harus berada dalam
jangkauan. - NPC tidak dapat menggunakan tempat tidur yang sudah penuh
kapasitasnya.

### 6.3 Prinsip penting

Simulation Engine adalah pemilik state dunia yang sebenarnya. NPC boleh
mengusulkan tindakan, tetapi Engine menentukan apakah tindakan tersebut
valid dan memperbarui state.

NPC tidak boleh menganggap telah mengonsumsi makanan jika stok tidak
tersedia atau proses konsumsi gagal.

## 7. Resource System

Resource merupakan sumber daya yang tersedia di dunia dan dapat
dihasilkan, disimpan, digunakan, atau dikonsumsi. Pada Phase 0, resource
belum perlu menjadi sistem ekonomi.

Resource awal: - Food. - Hasil pekerjaan sederhana jika dibutuhkan untuk
menguji Work.

Setiap resource setidaknya memiliki: - Identitas dan jenis resource. -
Jumlah. - Lokasi penyimpanan. - Batas kapasitas jika diperlukan.

Contoh alur: 1. NPC bekerja di Farm. 2. Pekerjaan selesai. 3. Farm
menghasilkan sejumlah Food. 4. Food ditambahkan ke penyimpanan. 5. NPC
dapat menggunakan Food tersebut. 6. Jumlah Food berkurang ketika
dikonsumsi.

Resource tidak boleh muncul atau hilang tanpa event yang jelas.

## 8. Personality System

### 8.1 Konsep

Personality memberikan variasi kecenderungan pengambilan keputusan
antar-NPC. Personality bukan aturan mutlak. Trait memengaruhi Utility
Score, bukan melarang NPC melakukan tindakan yang bertentangan dengan
sifatnya.

### 8.2 Personality awal

  Trait         Pengaruh potensial
  ------------- --------------------------------------------
  Industrious   Lebih menyukai aktivitas produktif
  Lazy          Cenderung menghindari aktivitas melelahkan
  Cautious      Lebih menghindari tindakan berisiko
  Adventurous   Lebih tertarik menjelajahi lingkungan

Trait dapat menggunakan rentang numerik, misalnya 0--100. Nilai tersebut
adalah parameter simulasi, bukan ukuran psikologi manusia yang
tervalidasi.

### 8.3 Contoh pengaruh

Dua NPC memiliki Hunger 70 dan Energy 60: - NPC A memiliki Industrious
tinggi. Ia mungkin menyelesaikan pekerjaan yang hampir selesai sebelum
makan. - NPC B memiliki Cautious tinggi. Ia mungkin memilih makan lebih
awal untuk mengurangi risiko kehabisan energi.

Keputusan tetap dipengaruhi kebutuhan, ketersediaan resource, kondisi
lingkungan, dan persyaratan aktivitas. Personality hanya salah satu
faktor evaluasi.

## 9. Utility-Based Decision Making

### 9.1 Tujuan

Utility AI menentukan aktivitas yang paling sesuai dengan kondisi NPC
pada saat evaluasi.

Sistem tidak cukup hanya menggunakan kondisi sederhana seperti "jika
lapar, makan; jika lelah, istirahat; selain itu bekerja". Sistem perlu
mempertimbangkan beberapa faktor sekaligus.

### 9.2 Alur pengambilan keputusan

1.  Membaca kondisi internal NPC.
2.  Membaca kebutuhan dan tujuan aktif.
3.  Mengamati lingkungan yang relevan.
4.  Mengumpulkan kandidat aktivitas.
5.  Memeriksa persyaratan aktivitas.
6.  Menghitung Utility setiap kandidat yang valid.
7.  Memilih aktivitas terbaik.
8.  Mengirim tindakan kepada Simulation Engine.
9.  Mencatat alasan pemilihan.

### 9.3 Faktor Utility

Utility suatu aktivitas dapat dipengaruhi oleh: - Tingkat kebutuhan yang
ingin dipenuhi. - Kondisi fisik NPC. - Personality. - Ketersediaan
resource. - Jarak menuju lokasi. - Risiko atau biaya aktivitas. -
Aktivitas yang sedang berlangsung. - Tujuan aktif NPC.

Rumus Utility tidak harus kompleks pada awalnya. Yang penting, setiap
faktor mempunyai alasan dan pengaruh yang dapat diuji.

### 9.4 Validitas kandidat

Aktivitas yang tidak memenuhi persyaratan tidak boleh dipilih hanya
karena Utility-nya tinggi.

Contoh: - Eat memiliki Utility 95, tetapi tidak ada makanan yang dapat
diakses. - Sleep memiliki Utility 80 dan terdapat tempat tidur kosong.

Eat harus dikeluarkan dari kandidat valid. NPC dapat memilih Sleep atau
tindakan lain yang memungkinkan.

### 9.5 Stabilitas keputusan

Hindari pergantian aktivitas terlalu sering. Beberapa pendekatan: -
Aktivitas yang sedang berjalan tetap dipertahankan. - Evaluasi ulang
dilakukan pada kondisi tertentu. - Gunakan ambang interupsi untuk
kebutuhan kritis. - Gunakan cooldown atau hysteresis jika perubahan skor
kecil menyebabkan pergantian aktivitas terus-menerus.

## 10. World Clock dan Waktu Simulasi

Dunia memiliki waktu internal yang berjalan konsisten.

World Clock menjadi acuan untuk: - Durasi aktivitas. - Perubahan
kebutuhan. - Siklus siang dan malam. - Waktu produksi resource. -
Timestamp event. - Pengujian simulasi.

Implementasi awal cukup mencakup: - Tick atau unit waktu simulasi. - Jam
dalam satu hari. - Pergantian hari. - Durasi aktivitas. - Day/night
cycle jika dibutuhkan.

Rutinitas harian belum harus menjadi jadwal wajib. Waktu dapat
memengaruhi Utility, tetapi keputusan tetap mempertimbangkan kebutuhan
dan kondisi aktual NPC.

## 11. Decision Trace dan Event Logging

### 11.1 Tujuan

Decision Trace dan Event Logging merupakan alat untuk memahami perilaku
simulasi. Setiap keputusan penting sebaiknya dapat diperiksa, bukan
hanya dilihat hasil akhirnya.

### 11.2 Informasi keputusan

Decision Trace dapat mencatat: - NPC yang mengambil keputusan. - Waktu
simulasi. - Kondisi kebutuhan saat evaluasi. - Kandidat aktivitas. -
Aktivitas yang tidak valid beserta alasannya. - Utility Score kandidat
valid. - Aktivitas yang dipilih. - Alasan utama pemilihan. - Hasil
validasi Engine.

### 11.3 Informasi event

Event Log mencatat kejadian yang benar-benar terjadi, misalnya: - NPC
memulai aktivitas. - NPC tiba di lokasi. - NPC mengonsumsi makanan. -
Resource bertambah atau berkurang. - Aktivitas selesai. - Aktivitas
gagal. - Aktivitas diinterupsi.

Bedakan keputusan yang diusulkan NPC dari event yang benar-benar
berhasil dieksekusi Engine.

Contoh: NPC mencoba Eat, tetapi stok makanan kosong. Decision Trace
mencatat keputusan atau percobaan tersebut. Event Log mencatat bahwa
pengambilan makanan gagal karena resource tidak tersedia.

Dengan pemisahan ini, riwayat simulasi tidak mencatat tindakan yang
sebenarnya tidak pernah terjadi.

## 12. Simulation Cycle

Siklus simulasi Phase 0: 1. World Clock memperbarui waktu simulasi. 2.
Environment memperbarui state yang perlu berubah. 3. Needs NPC
diperbarui berdasarkan waktu dan aktivitas. 4. NPC yang perlu mengambil
keputusan melakukan evaluasi. 5. Utility AI menghasilkan pilihan
aktivitas. 6. Simulation Engine memvalidasi tindakan. 7. Aktivitas
dijalankan atau ditolak. 8. Pergerakan dan interaksi dengan objek
diproses. 9. Perubahan kebutuhan dan resource diterapkan sesuai hasil
tindakan. 10. Event dan Decision Trace dicatat.

Tidak semua NPC harus melakukan evaluasi penuh pada setiap tick. Gunakan
penjadwalan atau pemicu evaluasi agar simulasi tetap efisien.

## 13. Determinism dan Reproducibility

Society Zero merupakan simulasi yang perlu dapat diuji dan dibandingkan.
Karena itu, Phase 0 harus mempertahankan kemampuan menjalankan ulang
simulasi dengan konfigurasi dan seed yang sama.

Informasi yang perlu disimpan: - Random seed. - Konfigurasi dunia. -
Jumlah NPC. - State awal NPC. - Parameter personality. - Parameter
kebutuhan. - Aturan aktivitas. - Versi aturan simulasi. - Durasi
simulasi.

Jika menggunakan randomness untuk variasi keputusan, sumber randomness
harus dikendalikan oleh sistem simulasi. Hindari ketergantungan pada
random global yang tidak dapat direproduksi.

Determinisme berarti input dan konfigurasi yang sama menghasilkan urutan
hasil yang sama, selama versi aturan dan kondisi eksekusinya juga sama.

## 14. Skenario Pengujian Phase 0

### Scenario A --- Basic Survival

**Tujuan:** Memastikan NPC dapat mengelola Hunger dan Energy.

Kondisi awal: - Satu NPC. - Hunger cukup rendah. - Energy cukup
tinggi. - Tersedia makanan dan tempat tidur.

Ekspektasi: - Hunger meningkat seiring waktu. - NPC memilih makan ketika
diperlukan. - Energy berkurang ketika melakukan aktivitas. - NPC memilih
tidur ketika Energy membutuhkan pemulihan. - Kebutuhan berubah setelah
aktivitas berhasil dilakukan.

### Scenario B --- Resource Scarcity

**Tujuan:** Memastikan NPC menghadapi keterbatasan resource.

Kondisi awal: - Satu atau beberapa NPC. - Stok makanan terbatas. - Tidak
semua NPC dapat langsung memperoleh makanan.

Ekspektasi: - NPC tidak dapat makan tanpa makanan. - Resource berkurang
ketika dikonsumsi. - Kegagalan aktivitas tercatat. - NPC dapat memilih
alternatif yang valid.

Pada Phase 0, skenario ini hanya menguji ketersediaan resource dan
validasi tindakan, belum menguji ekonomi atau konflik sosial.

### Scenario C --- Activity Interruption

**Tujuan:** Memastikan aktivitas tidak berubah secara tidak stabil.

Kondisi awal: - NPC sedang bekerja. - Energy menurun selama pekerjaan. -
Energy melewati ambang kritis.

Ekspektasi: - Aktivitas berjalan selama kondisi masih memungkinkan. -
NPC dapat menghentikan pekerjaan jika kondisi kritis mengharuskannya. -
Interupsi tercatat. - NPC mengevaluasi tindakan berikutnya. - NPC tidak
berganti aktivitas secara acak setiap tick.

### Scenario D --- Personality Variation

**Tujuan:** Memastikan personality memengaruhi keputusan.

Kondisi awal: - Dua NPC memiliki kebutuhan dan lingkungan yang sama. -
Keduanya memiliki trait personality berbeda.

Ekspektasi: - Perbedaan personality dapat menghasilkan perbedaan Utility
Score. - Keputusan dapat berbeda jika perbedaan skor cukup berarti. -
Personality tidak menjadi aturan mutlak. - Kedua NPC tetap dapat memilih
tindakan yang sama jika kondisi lebih dominan daripada personality.

### Scenario E --- Reproducibility

**Tujuan:** Memastikan simulasi dapat diulang.

Kondisi awal: - Konfigurasi dunia yang sama. - State awal NPC yang
sama. - Random seed yang sama. - Durasi simulasi yang sama.

Ekspektasi: - Urutan keputusan dan event dapat direproduksi. - Perubahan
hasil dapat ditelusuri jika konfigurasi atau aturan diubah.

## 15. Milestone Pengembangan

### Milestone 0.1 --- Needs & Activity

**Fokus:** Mengembangkan NPC dari pemilih tiga aktivitas menjadi
individu yang memiliki kebutuhan dan aktivitas dengan lifecycle.

Ruang lingkup: - Needs System untuk Hunger dan Energy. - Kondisi Health
dasar. - Activity System. - Action Lifecycle. - Utility evaluation yang
lebih terstruktur. - Validasi aktivitas. - Decision Trace dasar.

**Hasil yang diharapkan:** NPC dapat memilih, menjalankan,
menyelesaikan, dan menghentikan aktivitas dengan alasan yang jelas.

### Milestone 0.2 --- Environment & Resources

**Fokus:** Membuat aktivitas NPC bergantung pada lingkungan dan resource
yang nyata.

Ruang lingkup: - Objek lingkungan. - Food Storage. - Bed. - Workplace
atau Farm sederhana. - Resource inventory. - Resource consumption dan
production. - Validasi akses terhadap objek. - Penanganan aktivitas yang
gagal.

**Hasil yang diharapkan:** NPC tidak dapat melakukan aktivitas tanpa
memenuhi persyaratan lingkungan dan resource.

### Milestone 0.3 --- Personality & Decision

**Fokus:** Memberikan variasi perilaku berdasarkan karakteristik
individu.

Ruang lingkup: - Personality traits dasar. - Pengaruh personality
terhadap Utility Score. - Evaluasi kandidat aktivitas. - Pengaruh
risiko, jarak, dan kondisi fisik. - Pengendalian pergantian aktivitas. -
Pengujian variasi perilaku antar-NPC.

**Hasil yang diharapkan:** NPC dengan kondisi serupa dapat menunjukkan
kecenderungan perilaku yang berbeda.

### Milestone 0.4 --- Living Simulation

**Fokus:** Menyatukan sistem menjadi simulasi kehidupan dasar yang dapat
berjalan dalam durasi panjang.

Ruang lingkup: - World Clock. - Day/night cycle jika diperlukan. -
Integrasi Needs, Activity, Environment, Resource, dan Personality. -
Event Timeline. - Agent Inspector. - Simulation controls. - Seed dan
reproducibility. - Pengujian simulasi jangka panjang.

**Hasil yang diharapkan:** Beberapa NPC dapat menjalani aktivitas
sehari-hari secara mandiri di dunia yang sama tanpa harus mengikuti pola
aktivitas identik.

## 16. Definition of Done

Phase 0 dapat dianggap selesai ketika kriteria berikut terpenuhi:

-   [x] Setiap NPC memiliki identitas dan state individual.
-   [x] Hunger dan Energy berubah secara dinamis.
-   [x] Health tersedia sebagai kondisi dasar.
-   [x] NPC memiliki lebih dari tiga kemungkinan aktivitas.
-   [x] Setiap aktivitas memiliki persyaratan dan konsekuensi.
-   [x] Aktivitas mempunyai lifecycle yang jelas.
-   [x] NPC tidak mengganti aktivitas secara tidak stabil setiap tick.
-   [x] NPC dapat menggunakan objek lingkungan.
-   [x] Resource memiliki jumlah dan perubahan state yang valid.
-   [x] NPC tidak dapat menggunakan resource yang tidak tersedia.
-   [x] Personality dasar memengaruhi kecenderungan keputusan.
-   [x] Utility AI mengevaluasi kandidat aktivitas berdasarkan beberapa
    faktor.
-   [x] Aktivitas yang tidak valid dikeluarkan dari kandidat yang dapat
    dipilih.
-   [x] Dunia memiliki waktu simulasi.
-   [x] Keputusan NPC dapat diperiksa melalui Decision Trace.
-   [x] Kejadian yang benar-benar terjadi dicatat melalui Event Log.
-   [x] Simulasi dapat dijalankan ulang dengan seed dan konfigurasi yang
    sama.

## 17. Prinsip Arsitektur yang Harus Dipertahankan

### 17.1 Agent AI bukan pemilik state dunia

Agent bertugas mengamati informasi yang tersedia, mengevaluasi kondisi,
dan mengusulkan tindakan.

Simulation Engine bertugas: - Memvalidasi tindakan. - Memeriksa
resource. - Memeriksa lokasi dan jarak. - Memastikan aturan dunia
dipatuhi. - Mengubah state dunia. - Mencatat hasil tindakan.

Agent tidak boleh langsung mengubah state dunia secara sembarangan.

### 17.2 Pisahkan kebutuhan, keputusan, dan tindakan

-   Needs menjelaskan kondisi internal NPC.
-   Decision Making menentukan tindakan yang paling sesuai.
-   Activity menjalankan tindakan dan menghasilkan konsekuensi.

Pemisahan ini memudahkan pengembangan tanpa membuat seluruh logika NPC
saling bergantung.

### 17.3 Pisahkan simulasi dan visualisasi

View bertugas menampilkan kondisi dunia dan NPC. View tidak boleh
menjadi sumber kebenaran simulasi. Perubahan visual harus mengikuti
state dari Simulation Engine.

### 17.4 Simulasi harus dapat diamati

Setiap keputusan dan perubahan penting perlu memiliki jejak yang dapat
diperiksa. Jangan hanya mengandalkan animasi untuk menilai apakah NPC
berperilaku benar.

### 17.5 Hindari kompleksitas prematur

Jangan menambahkan LLM, sistem emosi kompleks, hubungan sosial, atau
ekonomi masyarakat sebelum kebutuhan dasar, aktivitas, dan validasi
dunia bekerja dengan baik.

## 18. Gambaran Hasil Akhir Phase 0

Bayangkan sebuah dunia kecil berisi lima NPC. Setiap NPC memiliki
kondisi, kebutuhan, dan personality masing-masing.

Ketika simulasi dimulai: 1. Setiap NPC membaca kondisi dirinya. 2. NPC
mengevaluasi kebutuhan yang perlu dipenuhi. 3. NPC mengamati lingkungan
yang relevan. 4. NPC memilih aktivitas yang dapat dilakukan. 5.
Simulation Engine memvalidasi aktivitas. 6. NPC bergerak dan menggunakan
objek lingkungan. 7. Resource dan kebutuhan berubah sesuai hasil
tindakan. 8. Aktivitas selesai, gagal, atau diinterupsi. 9. NPC
mengevaluasi kondisi berikutnya. 10. Siklus berlanjut sepanjang
simulasi.

Tidak semua NPC harus melakukan aktivitas yang sama pada waktu yang
sama. Satu NPC dapat bekerja, NPC lain makan, dan NPC lainnya tidur.
Keputusan mereka muncul dari kondisi individual, bukan urutan aktivitas
yang ditentukan sebelumnya.

Pada tahap ini NPC belum perlu memiliki percakapan atau hubungan sosial.
Namun mereka sudah memiliki fondasi untuk kelak mengenali individu lain,
membangun hubungan, dan membentuk kehidupan bersama.

## 19. Arah Setelah Phase 0

Setelah Living Foundation stabil, pengembangan dapat dilanjutkan ke
**Phase 1 --- Social Life**, yang mencakup: - Social Need. -
Relationship System. - Interaksi antar-NPC. - Social Actions. - Episodic
Memory. - Memory Retrieval. - Pengaruh hubungan terhadap keputusan.

Phase 1 mengembangkan NPC dari individu yang mampu bertahan hidup
menjadi individu yang mulai mengenali dan berinteraksi dengan individu
lain.

------------------------------------------------------------------------

## Penutup

Phase 0 bukan tentang membuat NPC memiliki sebanyak mungkin aktivitas.
Phase 0 adalah tentang memastikan bahwa setiap aktivitas memiliki
alasan, persyaratan, proses, dan konsekuensi.

NPC harus mampu menjalani kehidupan dasar secara mandiri sebelum Society
Zero mulai membangun hubungan sosial dan masyarakat.

> Build individuals that can live on their own before building a society
> that can live together.
