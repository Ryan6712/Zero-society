# SOCIETY ZERO

## An Artificial Society Research Simulator

**Tagline:** Observe. Experiment. Discover.\
**Jenis proyek:** Artificial Society Simulation / Multi-Agent
Simulation\
**Dokumen:** Concept & System Overview\
**Versi:** 1.0

------------------------------------------------------------------------

## 1. Ringkasan Proyek

**Society Zero** adalah simulator masyarakat buatan yang dihuni oleh
individu-individu virtual (*agents*) dengan identitas, kepribadian,
kebutuhan, ingatan, pengetahuan, keterampilan, dan tujuan masing-masing.

Setiap agent mengambil keputusan berdasarkan kondisi dirinya, informasi
yang tersedia, lingkungan, serta interaksi dengan agent lain. Dari
interaksi tersebut, dapat muncul hubungan sosial, kelompok, norma,
ekonomi, kepemimpinan, konflik, dan bentuk organisasi masyarakat.

Pengguna bertindak sebagai peneliti atau pengamat. Pengguna dapat
membuat dunia, menentukan kondisi awal, menjalankan simulasi, mengamati
kejadian, mengubah variabel eksperimen, serta membandingkan hasil
beberapa simulasi.

Prinsip utama proyek:

> Pengguna tidak menulis cerita yang harus terjadi. Pengguna menciptakan
> kondisi dan aturan yang memungkinkan cerita terbentuk.

Society Zero bukan sekadar kumpulan chatbot. Sistem harus memiliki dunia
yang konsisten, sumber daya yang nyata di dalam simulasi, aturan
tindakan, catatan kejadian, serta mekanisme sebab-akibat yang dapat
ditelusuri.

## 2. Visi dan Tujuan

### 2.1 Visi

Menciptakan lingkungan simulasi tempat individu buatan dapat hidup dan
berinteraksi secara mandiri, sehingga dinamika sosial muncul dari
keputusan individu dan kondisi lingkungan.

### 2.2 Tujuan utama

1.  Mensimulasikan individu dengan karakteristik dan kebutuhan yang
    berbeda.
2.  Membentuk interaksi sosial yang dipengaruhi pengalaman dan hubungan.
3.  Mengamati pembentukan kelompok dan organisasi.
4.  Mensimulasikan pertukaran sumber daya dan aktivitas ekonomi.
5.  Mengamati kemunculan norma, kepemimpinan, dan struktur sosial.
6.  Menyimpan sejarah dunia dan riwayat kehidupan agent.
7.  Menyediakan alat eksperimen untuk mengubah kondisi awal dan
    membandingkan hasil.
8.  Menyediakan penjelasan yang dapat ditelusuri mengenai alasan suatu
    kejadian terjadi.

### 2.3 Bukan tujuan proyek

-   Membuktikan bahwa simulasi merupakan representasi akurat seluruh
    perilaku manusia.
-   Membuat agent selalu rasional atau selalu benar.
-   Memaksa masyarakat membentuk demokrasi, kerajaan, ekonomi, atau
    organisasi tertentu.
-   Menjadikan LLM sebagai sumber kebenaran tunggal untuk kondisi dunia.
-   Menghasilkan narasi dramatis dengan mengorbankan konsistensi
    simulasi.

## 3. Prinsip Desain

### 3.1 Individual Autonomy

Setiap agent memiliki keadaan internal, kebutuhan, tujuan, preferensi,
dan batas pengetahuan sendiri. Agent tidak otomatis mengetahui semua hal
yang terjadi di dunia.

### 3.2 Emergent Behavior

Kelompok, norma, kepemimpinan, konflik, dan fenomena sosial harus muncul
melalui mekanisme interaksi. Hasilnya tidak ditentukan secara langsung
oleh skrip cerita.

### 3.3 Persistent World

Dunia memiliki waktu dan sejarah. Keputusan dan kejadian sebelumnya
dapat memengaruhi keadaan berikutnya.

### 3.4 Local Knowledge

Agent hanya dapat menggunakan informasi yang diketahui, diamati,
disimpulkan, atau diterima dari pihak lain. Informasi pribadi tidak
boleh otomatis tersedia bagi semua agent.

### 3.5 Consistent Rules

Perubahan sumber daya, transaksi, perpindahan, usia, dan status harus
diproses oleh simulation engine dengan aturan yang konsisten. Agent
tidak boleh mengubah fakta dunia hanya melalui dialog.

### 3.6 Explainability

Kejadian penting harus memiliki catatan kondisi, tindakan, keputusan,
dan konsekuensi yang mendasarinya. Sistem tidak boleh mengarang alasan
setelah kejadian selesai.

### 3.7 Experimental Reproducibility

Simulasi perlu mendukung random seed, konfigurasi yang tersimpan, dan
pengulangan eksperimen. Satu hasil simulasi tidak cukup untuk
menyimpulkan pola umum.

------------------------------------------------------------------------

# 4. Model Dunia Simulasi

Dunia simulasi terdiri dari beberapa komponen.

## 4.1 Environment

Environment adalah ruang tempat agent hidup dan beraktivitas.

Informasi lingkungan dapat meliputi:

-   Wilayah atau lokasi.
-   Ketersediaan makanan dan air.
-   Tempat tinggal.
-   Bahan baku.
-   Kondisi cuaca atau iklim.
-   Keamanan wilayah.
-   Infrastruktur.
-   Jarak dan akses antarwilayah.

Untuk versi awal, dunia dapat berupa satu pemukiman sederhana dengan
beberapa lokasi, misalnya rumah, ladang, gudang, sumber air, dan area
berkumpul.

## 4.2 World State

World state menyimpan kondisi dunia pada waktu simulasi tertentu.

Contoh data:

-   Waktu simulasi saat ini.
-   Daftar agent yang masih hidup.
-   Populasi.
-   Lokasi setiap agent.
-   Persediaan sumber daya.
-   Kondisi lingkungan.
-   Daftar kelompok.
-   Organisasi yang terbentuk.
-   Kejadian aktif.
-   Kondisi ekonomi dan sosial.

World state merupakan sumber kebenaran utama bagi simulasi.

## 4.3 Simulation Time

Dunia memiliki waktu internal yang tidak harus sama dengan waktu nyata.

Contoh:

-   Satu tick dapat mewakili satu menit, satu jam, atau satu hari
    simulasi.
-   Pengguna dapat menghentikan, melanjutkan, atau mempercepat simulasi.
-   Aktivitas agent dapat berlangsung selama beberapa tick.
-   Agent tidak harus mengambil keputusan kompleks pada setiap tick.

Kecepatan simulasi dan durasi aktivitas harus dapat dikonfigurasi.

## 4.4 Locations

Lokasi memberi konteks pada tindakan agent.

Contoh:

  Lokasi             Fungsi
  ------------------ --------------------------------
  Residential Area   Tempat tinggal dan istirahat
  Farm               Produksi makanan
  Market             Perdagangan
  Warehouse          Penyimpanan sumber daya
  Workshop           Produksi alat
  Public Square      Pertemuan dan interaksi sosial

Lokasi dapat memiliki kapasitas, persediaan, pemilik, dan tingkat
keamanan.

------------------------------------------------------------------------

# 5. Individual Agent

Agent merupakan unit utama dalam Society Zero. Setiap agent adalah
individu virtual yang memiliki keadaan dan riwayat sendiri.

## 5.1 Identity

Identitas menyimpan informasi dasar:

-   ID unik.
-   Nama.
-   Umur.
-   Tanggal atau hari kelahiran simulasi.
-   Status kehidupan.
-   Lokasi saat ini.
-   Keluarga atau hubungan kekerabatan.
-   Peran sosial, jika ada.

Contoh:

  Atribut     Contoh
  ----------- ------------------
  ID          agent_001
  Nama        Adam
  Umur        27
  Status      Alive
  Lokasi      Residential Area
  Pekerjaan   Farmer
  Keluarga    Tidak diketahui

Identitas tidak sama dengan kepribadian. Nama dan umur adalah data
identitas, sedangkan kepribadian adalah karakteristik yang memengaruhi
kecenderungan tindakan.

## 5.2 Personality

Kepribadian memengaruhi preferensi dan kecenderungan keputusan. Nilai
atribut dapat menggunakan skala numerik, misalnya 0 sampai 100.

Atribut yang dapat digunakan:

  -----------------------------------------------------------------------
  Atribut                             Pengaruh
  ----------------------------------- -----------------------------------
  Openness                            Keterbukaan terhadap ide dan
                                      pengalaman baru

  Conscientiousness                   Disiplin dan konsistensi

  Extraversion                        Kecenderungan mencari interaksi
                                      sosial

  Agreeableness                       Kecenderungan bekerja sama dan
                                      mengakomodasi orang lain

  Neuroticism                         Sensitivitas terhadap tekanan dan
                                      ketidakpastian

  Ambition                            Dorongan memperoleh pencapaian atau
                                      pengaruh

  Trust                               Kecenderungan awal untuk
                                      mempercayai pihak lain

  Risk Tolerance                      Kesediaan mengambil risiko
  -----------------------------------------------------------------------

Nilai tersebut bukan ukuran psikologi manusia yang tervalidasi. Dalam
proyek ini, atribut merupakan parameter simulasi yang perlu diuji dan
disesuaikan.

Kepribadian sebaiknya memengaruhi keputusan secara probabilistik atau
melalui bobot utility, bukan menentukan satu tindakan secara mutlak.

## 5.3 Needs

Needs adalah kondisi internal yang mendorong agent melakukan tindakan.

Contoh kebutuhan:

  Need        Contoh respons
  ----------- ---------------------------------
  Hunger      Mencari atau memperoleh makanan
  Energy      Beristirahat
  Safety      Menghindari ancaman
  Social      Mencari interaksi
  Belonging   Mencari kelompok atau komunitas
  Knowledge   Mencari informasi atau belajar

Setiap kebutuhan memiliki nilai, ambang, dan laju perubahan.

Contoh: - Hunger meningkat seiring waktu. - Energy menurun ketika agent
bekerja. - Safety dapat memburuk ketika lingkungan berbahaya. - Social
dapat meningkat ketika agent lama tidak berinteraksi.

Nilai kebutuhan tinggi dapat berarti semakin mendesak. Konvensi ini
harus konsisten di seluruh sistem.

## 5.4 Goals

Goal adalah sasaran yang ingin dicapai agent.

Contoh:

-   Mendapatkan makanan.
-   Mencari tempat tinggal.
-   Mempelajari keterampilan.
-   Membangun hubungan.
-   Mengumpulkan kekayaan.
-   Memperoleh pengaruh.
-   Melindungi keluarga.
-   Bergabung dengan kelompok.

Goal dapat dibagi menjadi:

1.  **Immediate goal:** sasaran jangka pendek, seperti mencari makanan.
2.  **Long-term goal:** sasaran jangka panjang, seperti membangun usaha.
3.  **Social goal:** sasaran yang melibatkan hubungan atau kelompok.
4.  **Reactive goal:** sasaran sementara akibat kejadian, seperti
    mencari tempat aman setelah konflik.

Goal dapat berubah ketika kebutuhan, pengalaman, sumber daya, atau
prioritas agent berubah.

## 5.5 Memory

Memory menyimpan informasi yang diperoleh agent. Memori sebaiknya
memiliki sumber, waktu, tingkat keyakinan, dan tingkat kepentingan.

### Episodic Memory

Menyimpan kejadian spesifik.

Contoh: - Adam pernah ditolong Bella. - Cyrus pernah menolak
transaksi. - Diana pernah mengajari Adam membuat alat.

### Semantic Memory

Menyimpan pengetahuan yang dianggap benar oleh agent.

Contoh: - Adam mengetahui lokasi sumber air. - Bella mengetahui cara
membuat alat. - Cyrus mengetahui harga barang di pasar.

### Social Memory

Menyimpan penilaian atau informasi mengenai agent lain.

Contoh: - Adam menilai Bella dapat dipercaya. - Cyrus menganggap Diana
kompeten. - Bella mengingat bahwa Adam pernah melanggar janji.

Memory harus membedakan fakta, informasi dari orang lain, dan dugaan
agent. Rumor tidak boleh otomatis menjadi fakta dunia.

### Memory Management

Memori dapat memiliki: - Timestamp. - Importance score. - Confidence
score. - Source. - Retrieval tags. - Decay atau mekanisme pelupaan. -
Relasi dengan kejadian lain.

Tidak semua kejadian perlu disimpan selamanya. Sistem dapat melakukan
seleksi berdasarkan kepentingan dan relevansi.

## 5.6 Knowledge and Beliefs

Knowledge adalah informasi yang dimiliki agent. Belief adalah keyakinan
agent terhadap suatu informasi.

Contoh:

-   Adam melihat sumber air masih tersedia.
-   Bella mendengar bahwa sumber air telah kering.
-   Cyrus menduga sumber air tersebut dijaga kelompok lain.

Ketiganya dapat mengambil keputusan berbeda karena memiliki informasi
dan keyakinan berbeda.

Sistem harus menyediakan mekanisme: - Observasi langsung. -
Komunikasi. - Penyebaran informasi. - Rumor. - Verifikasi. - Perubahan
keyakinan.

## 5.7 Skills

Skills merupakan kemampuan yang dapat digunakan agent.

Contoh: - Farming. - Trading. - Crafting. - Negotiation. - Teaching. -
Medicine. - Leadership. - Gathering.

Skill dapat meningkat melalui praktik, pembelajaran, atau pengalaman.
Skill juga dapat memiliki prasyarat dan tingkat penguasaan.

## 5.8 Decision Making

Agent memilih tindakan berdasarkan keadaan internal dan kondisi yang
dapat diamati.

Pendekatan awal yang disarankan adalah utility-based decision making.

Contoh pilihan Adam:

  Action            Estimated Utility
  --------------- -------------------
  Find Food                        85
  Talk to Bella                    42
  Rest                             25

Utility dapat dipengaruhi oleh: - Urgensi kebutuhan. - Goal aktif. -
Kepribadian. - Skill. - Sumber daya. - Risiko. - Informasi yang
diketahui. - Hubungan dengan agent terkait. - Pengalaman sebelumnya.

Utility bukan angka kebenaran. Ia merupakan cara sistem membandingkan
alternatif tindakan.

Agent sebaiknya tidak selalu memilih tindakan dengan nilai tertinggi
secara deterministik. Sedikit variasi dapat digunakan agar perilaku
tidak terlalu kaku, selama variasi tersebut tetap dapat direproduksi
melalui random seed.

## 5.9 Life Cycle

Agent dapat memiliki tahapan kehidupan:

1.  Birth.
2.  Childhood.
3.  Education.
4.  Adulthood.
5.  Career.
6.  Aging.
7.  Death.

Tahapan ini dapat memengaruhi kebutuhan, kemampuan, peran sosial, dan
aktivitas.

Jika simulasi mendukung generasi, agent baru dapat mewarisi sebagian
karakteristik biologis atau sosial dari orang tuanya. Namun, ingatan
pribadi orang tua tidak otomatis diwariskan sebagai ingatan anak.

------------------------------------------------------------------------

# 6. Relationship System

Relationship System mengelola hubungan antaragent. Hubungan harus
bersifat terarah karena penilaian satu agent terhadap agent lain tidak
selalu sama.

Contoh:

Adam sangat mempercayai Bella, tetapi Bella belum tentu memiliki tingkat
kepercayaan yang sama terhadap Adam.

## 6.1 Relationship Attributes

  Atribut               Arti
  --------------------- ----------------------------------
  Trust                 Tingkat kepercayaan
  Respect               Tingkat penghargaan
  Affection             Kedekatan atau rasa suka
  Fear                  Tingkat rasa takut
  Resentment            Rasa kecewa atau dendam
  Familiarity           Seberapa mengenal satu sama lain
  Cooperation History   Riwayat kerja sama

Atribut dapat menggunakan rentang 0 sampai 100. Nilai harus diperbarui
berdasarkan kejadian yang relevan.

## 6.2 Relationship Changes

Contoh: 1. Adam dan Bella bertemu. 2. Mereka bekerja sama mencari
makanan. 3. Bella membantu Adam saat kesulitan. 4. Trust dan respect
Adam terhadap Bella meningkat. 5. Adam mulai membagikan informasi kepada
Bella. 6. Hubungan mereka menjadi lebih dekat.

Hubungan juga dapat memburuk akibat: - Pengkhianatan. - Janji yang tidak
dipenuhi. - Persaingan. - Konflik kepentingan. - Rumor. -
Kesalahpahaman.

## 6.3 Social Network

Hubungan dapat divisualisasikan sebagai graph.

Analisis yang dapat ditampilkan: - Individu dengan koneksi terbanyak. -
Individu yang menghubungkan dua kelompok. - Kelompok yang terisolasi. -
Perubahan jaringan dari waktu ke waktu. - Individu dengan pengaruh
sosial tinggi.

Jumlah koneksi tidak boleh dianggap sebagai satu-satunya ukuran
pengaruh. Posisi jaringan, kualitas hubungan, dan konteks sosial juga
penting.

------------------------------------------------------------------------

# 7. Social Interaction

Agent harus memiliki alasan untuk berinteraksi. Komunikasi tidak boleh
terjadi hanya karena sistem memerintahkan semua agent untuk mengobrol.

Jenis interaksi yang dapat disediakan:

## 7.1 Conversation

Bertukar informasi, pengalaman, pendapat, atau melakukan percakapan
sosial.

## 7.2 Cooperation

Bekerja sama untuk mencapai tujuan yang sulit dilakukan sendiri.

## 7.3 Transaction

Menukar barang, jasa, uang, atau sumber daya.

## 7.4 Conflict

Perselisihan akibat kepentingan, sumber daya, kepribadian, atau
kesalahpahaman.

## 7.5 Teaching

Membagikan pengetahuan dan keterampilan.

## 7.6 Information Sharing

Menyebarkan berita, rumor, informasi penting, dan pengalaman.

## 7.7 Alliance

Membentuk kerja sama jangka panjang berdasarkan kepentingan bersama.

## 7.8 Assistance

Membantu agent lain tanpa harus memperoleh keuntungan langsung.

Setiap interaksi sebaiknya direpresentasikan sebagai action atau event
yang memiliki pelaku, target, kondisi awal, hasil, dan konsekuensi.

------------------------------------------------------------------------

# 8. Social Emergence

Social emergence adalah kemunculan pola masyarakat dari interaksi
individu. Sistem menyediakan mekanisme, bukan hasil yang sudah
ditentukan.

## 8.1 Group Formation

Agent dapat membentuk kelompok berdasarkan: - Kesamaan tujuan. -
Kepentingan ekonomi. - Hubungan sosial. - Kepercayaan. - Keahlian. -
Kebutuhan keamanan.

Kelompok dapat memiliki: - Nama. - Anggota. - Tujuan. - Aturan
internal. - Sumber daya bersama. - Pemimpin atau struktur pengambilan
keputusan. - Sejarah dan reputasi.

Kelompok juga dapat berubah, terpecah, bergabung, atau bubar.

## 8.2 Social Norms

Norma sosial adalah pola perilaku yang diterima atau diharapkan oleh
suatu kelompok.

Contoh: - Membagi makanan secara adil. - Membantu anggota yang sakit. -
Melarang pencurian. - Mengadakan pertemuan berkala.

Norma dapat muncul dari pengalaman bersama, kesepakatan, kebiasaan, atau
pengaruh individu tertentu.

Norma tidak harus berlaku untuk semua kelompok. Dua kelompok dapat
memiliki norma berbeda.

## 8.3 Leadership

Kepemimpinan dapat muncul karena: - Kemampuan mengorganisasi. -
Pengetahuan. - Keberanian. - Kekayaan. - Jaringan sosial. - Kepercayaan
masyarakat.

Pemimpin dapat kehilangan pengaruh akibat kegagalan, konflik, atau
turunnya kepercayaan.

Sistem tidak boleh otomatis memberikan jabatan kepada agent dengan
atribut tertinggi. Pengaruh dan legitimasi harus terbentuk melalui
proses sosial.

## 8.4 Social Hierarchy

Masyarakat dapat memiliki distribusi pengaruh dan sumber daya yang tidak
merata.

Analisis dapat mencakup: - Kepemilikan sumber daya. - Pengaruh sosial. -
Akses terhadap informasi. - Jabatan formal. - Keahlian yang
dibutuhkan. - Ketergantungan individu lain.

## 8.5 Culture Formation

Budaya dapat muncul dari kebiasaan yang diulang dan diwariskan.

Contoh: - Perayaan setelah panen. - Makan bersama. - Tradisi membantu
keluarga yang kesulitan. - Cara menyelesaikan konflik. - Simbol atau
identitas kelompok.

Budaya harus direpresentasikan sebagai informasi atau praktik yang dapat
dipelajari dan diteruskan, bukan sekadar label yang diberikan secara
acak.

## 8.6 Social Conflict

Konflik dapat muncul akibat: - Perebutan sumber daya. - Ketimpangan
ekonomi. - Perselisihan kelompok. - Ketidakpercayaan terhadap
pemimpin. - Perbedaan nilai. - Informasi yang salah. - Pelanggaran
norma.

Konflik tidak harus selalu berakhir dengan kekerasan. Bentuk
penyelesaian dapat berupa negosiasi, protes, boikot, mediasi, pemisahan
kelompok, atau perubahan aturan.

------------------------------------------------------------------------

# 9. Economy System

Ekonomi menghubungkan kebutuhan, kemampuan, produksi, dan interaksi
agent.

## 9.1 Resources

Contoh sumber daya: - Food. - Water. - Wood. - Stone. - Metal. -
Tools. - Currency, jika sistem uang digunakan.

Setiap sumber daya memiliki jumlah, lokasi, kualitas jika diperlukan,
serta aturan konsumsi dan produksi.

## 9.2 Production

Agent dapat menghasilkan barang atau jasa berdasarkan skill dan
ketersediaan bahan.

Contoh: - Petani menghasilkan makanan. - Penebang menghasilkan kayu. -
Penambang menghasilkan mineral. - Pengrajin membuat peralatan.

Produksi harus mengurangi input dan menambah output sesuai aturan yang
konsisten.

## 9.3 Trade

Agent dapat: - Menawarkan barang. - Menerima atau menolak tawaran. -
Menentukan harga. - Membuat kesepakatan. - Melakukan transaksi berulang.

Harga dapat dipengaruhi oleh persediaan, permintaan, akses, risiko, dan
negosiasi.

## 9.4 Wealth and Ownership

Agent dapat memiliki aset, barang, atau sumber daya. Kepemilikan perlu
dicatat secara eksplisit agar transaksi dan distribusi tidak ambigu.

Kekayaan dapat memengaruhi pilihan dan pengaruh sosial, tetapi tidak
harus otomatis menentukan status atau kepemimpinan.

## 9.5 Economic Events

Contoh kejadian: - Kekurangan makanan. - Kenaikan harga. - Kegagalan
produksi. - Munculnya spesialisasi pekerjaan. - Terbentuknya jalur
perdagangan. - Ketimpangan kepemilikan.

------------------------------------------------------------------------

# 10. Political and Governance System

Sistem politik memungkinkan masyarakat mengelola keputusan kolektif.

Pada kondisi awal, dunia dapat dimulai tanpa pemerintahan. Ketika
masalah bersama muncul, agent dapat mencoba membentuk mekanisme
pengambilan keputusan.

Bentuk organisasi yang mungkin muncul:

  Bentuk                    Karakteristik umum
  ------------------------- ------------------------------------------------
  Council                   Keputusan melalui kelompok perwakilan
  Monarchy                  Kekuasaan terpusat pada satu pemimpin
  Democracy                 Pemimpin atau keputusan dipilih
  Oligarchy                 Pengaruh terkonsentrasi pada kelompok kecil
  Tribal System             Struktur berdasarkan kelompok atau kekerabatan
  Decentralized Community   Keputusan tersebar di komunitas
  No Central Government     Tidak ada pemerintahan terpusat

Bentuk tersebut merupakan kategori analisis. Sistem tidak boleh memaksa
masyarakat memilih salah satunya.

## 10.1 Collective Decision Making

Keputusan bersama dapat terjadi melalui: - Diskusi. - Pemungutan
suara. - Kesepakatan. - Negosiasi. - Keputusan pemimpin. - Tekanan
kelompok.

## 10.2 Rules and Enforcement

Aturan dapat dibuat, diterima, dipatuhi, dilanggar, dan diperdebatkan.

Sistem dapat mengamati: - Siapa yang mengusulkan aturan. - Siapa yang
menyetujui. - Siapa yang menolak. - Bagaimana aturan ditegakkan. - Apa
konsekuensi pelanggaran. - Apakah aturan berubah.

------------------------------------------------------------------------

# 11. Simulation Engine

Simulation Engine bertanggung jawab menjaga konsistensi dunia. Agent
Intelligence bertanggung jawab memilih tindakan berdasarkan keadaan yang
tersedia.

Keduanya harus dipisahkan.

## 11.1 Simulation Cycle

Satu siklus simulasi dapat terdiri dari tahapan berikut:

1.  **World Update:** memperbarui waktu, lingkungan, cuaca, dan sumber
    daya.
2.  **Agent Observation:** agent menerima informasi dari lingkungan
    sesuai kemampuan observasinya.
3.  **Decision Making:** agent mengevaluasi kebutuhan, tujuan, dan
    pilihan tindakan.
4.  **Action Execution:** sistem memvalidasi dan menjalankan tindakan.
5.  **Social Consequences:** sistem memperbarui hubungan, kelompok,
    ekonomi, dan kondisi sosial.
6.  **Memory Update:** agent menyimpan pengalaman dan memperbarui
    pengetahuan.
7.  **Event Logging:** kejadian penting dicatat untuk analisis dan
    penelusuran.

Urutan tersebut dapat disesuaikan. Jika tindakan beberapa agent saling
memengaruhi, sistem perlu menentukan aturan resolusi konflik dan urutan
eksekusi secara konsisten.

## 11.2 Event-driven Simulation

Tidak semua agent perlu mengambil keputusan kompleks pada setiap tick.

Contoh: - Agent tidur tidak perlu merencanakan tindakan sosial. - Agent
bekerja dapat melanjutkan aktivitas selama kondisinya tidak berubah. -
Agent menerima informasi penting dapat melakukan evaluasi ulang. - Agent
menghadapi bahaya dapat memprioritaskan respons. - Agent yang sedang
bernegosiasi dapat menunggu respons pihak lain.

Event-driven scheduling dapat mengurangi pekerjaan yang tidak
diperlukan.

## 11.3 Action Validation

Setiap tindakan harus divalidasi oleh simulation engine.

Contoh: - Agent tidak dapat membeli barang jika tidak memiliki alat
pembayaran yang disyaratkan. - Agent tidak dapat mengambil barang yang
tidak tersedia. - Agent tidak dapat berada di dua lokasi sekaligus. -
Agent tidak dapat melakukan tindakan yang membutuhkan skill atau alat
yang tidak dimiliki, kecuali aturan mengizinkan percobaan gagal. - Agent
tidak dapat mengetahui informasi privat tanpa sumber informasi yang sah.

LLM boleh mengusulkan tindakan, tetapi engine menentukan apakah tindakan
tersebut valid dan apa konsekuensinya.

## 11.4 Randomness and Reproducibility

Randomness dapat digunakan untuk variasi perilaku, kejadian lingkungan,
atau hasil yang tidak pasti.

Setiap eksperimen sebaiknya menyimpan: - Random seed. - Konfigurasi
awal. - Versi aturan simulasi. - Parameter agent. - Durasi. - Hasil dan
event log.

Dengan data tersebut, eksperimen dapat diulang atau dibandingkan.

------------------------------------------------------------------------

# 12. Agent Intelligence Architecture

Pendekatan yang direkomendasikan adalah Hybrid Intelligence.

## 12.1 Rule-based System

Digunakan untuk aturan yang jelas dan konsisten.

Contoh: - Konsumsi makanan. - Perubahan energi. - Pergerakan. - Batas
inventaris. - Aturan transaksi. - Perhitungan usia.

## 12.2 Utility-based AI

Digunakan untuk memilih tindakan berdasarkan kebutuhan, tujuan, risiko,
dan preferensi.

Contoh: - Memilih bekerja atau beristirahat. - Memilih mencari makanan
atau berdagang. - Memilih mendekati individu tertentu. - Memilih
menerima atau menolak tawaran.

## 12.3 Memory and Reflection

Digunakan untuk mengambil pengalaman relevan, menyimpulkan pola, dan
memperbarui pemahaman agent.

Reflection harus menghasilkan informasi yang dapat ditelusuri ke memori
atau kejadian sumbernya.

## 12.4 LLM / Generative AI

LLM bersifat opsional dan dapat digunakan untuk: - Menghasilkan
dialog. - Menafsirkan situasi kompleks. - Menyusun argumen dalam
negosiasi. - Menghasilkan alternatif strategi. - Membantu merangkum
pengalaman. - Menghasilkan ekspresi bahasa yang lebih alami.

LLM tidak boleh menjadi sumber kebenaran untuk: - Jumlah barang. -
Kepemilikan. - Lokasi. - Status kehidupan. - Hasil transaksi. - Hasil
tindakan. - Waktu simulasi.

Informasi tersebut harus berasal dari simulation engine.

## 12.5 Batasan dan Keamanan

Output LLM harus dibatasi dengan format terstruktur, misalnya usulan
action dan alasan. Sistem perlu memvalidasi output sebelum menjalankan
tindakan.

Jangan memberikan akses bebas kepada LLM untuk mengubah database atau
world state.

------------------------------------------------------------------------

# 13. Research Laboratory

Research Laboratory adalah antarmuka untuk membuat, menjalankan, dan
menganalisis eksperimen.

## 13.1 Experiment Builder

Pengguna dapat menentukan:

-   Jumlah populasi.
-   Distribusi kepribadian.
-   Ketersediaan sumber daya.
-   Kondisi lingkungan.
-   Aturan komunikasi.
-   Kondisi pemerintahan awal.
-   Aturan ekonomi.
-   Durasi simulasi.
-   Random seed.

Setiap konfigurasi harus disimpan sebagai eksperimen yang dapat
dijalankan kembali.

## 13.2 Experiment Analytics

Metrik yang dapat dianalisis:

### Population

-   Jumlah populasi.
-   Kelahiran.
-   Kematian.
-   Migrasi.
-   Usia rata-rata.

### Social

-   Jumlah hubungan aktif.
-   Rata-rata trust.
-   Jumlah kelompok.
-   Ukuran kelompok.
-   Jumlah konflik.
-   Frekuensi kerja sama.
-   Tingkat isolasi sosial.

### Economy

-   Total produksi.
-   Total konsumsi.
-   Persediaan sumber daya.
-   Distribusi kepemilikan.
-   Volume transaksi.
-   Perubahan harga.

### Governance

-   Jumlah aturan.
-   Tingkat kepatuhan.
-   Perubahan kepemimpinan.
-   Frekuensi keputusan kolektif.
-   Konflik terkait aturan.

### Information

-   Penyebaran informasi.
-   Jumlah rumor.
-   Kecepatan penyebaran berita.
-   Tingkat kesesuaian keyakinan dengan fakta dunia.

Metrik harus didefinisikan dengan jelas. Contohnya, jumlah konflik perlu
memiliki definisi operasional agar hasil antar-eksperimen dapat
dibandingkan.

## 13.3 Experiment Comparison

Pengguna dapat membuat dua atau lebih dunia dengan kondisi yang sama,
lalu mengubah satu atau beberapa variabel.

Contoh:

  Parameter       World A    World B
  --------------- ---------- ------------
  Population      30         30
  Resources       Limited    Limited
  Communication   Free       Restricted
  Government      None       None
  Duration        100 days   100 days

Hasil dapat dibandingkan melalui: - Grafik populasi. - Jumlah
kelompok. - Tingkat kerja sama. - Jumlah konflik. - Distribusi sumber
daya. - Stabilitas masyarakat.

Untuk mengurangi pengaruh randomness, eksperimen sebaiknya dijalankan
berulang kali dengan beberapa random seed. Bandingkan distribusi hasil,
bukan hanya satu hasil terbaik.

## 13.4 Event Timeline

Semua kejadian penting disimpan dalam timeline.

Contoh:

-   Day 08 --- First trading agreement.
-   Day 17 --- First social group formed.
-   Day 29 --- Leadership dispute.
-   Day 38 --- New community rules.
-   Day 45 --- Group separation.

Timeline harus mengarah ke data kejadian yang mendasarinya.

## 13.5 Causal Event Log

Untuk setiap kejadian penting, simpan:

-   Waktu kejadian.
-   Agent yang terlibat.
-   Kondisi sebelum kejadian.
-   Informasi yang tersedia bagi agent.
-   Tindakan yang dipilih.
-   Validasi engine.
-   Konsekuensi langsung.
-   Konsekuensi lanjutan.
-   Perubahan hubungan atau world state.

Fitur ini memungkinkan pengguna menelusuri alasan suatu kejadian tanpa
membuat penjelasan palsu setelah simulasi selesai.

------------------------------------------------------------------------

# 14. User Experience and Interface

Aplikasi dapat memiliki beberapa ruang observasi.

## 14.1 World Overview

Menampilkan: - Kondisi umum masyarakat. - Populasi. - Lokasi agent. -
Aktivitas yang sedang berjalan. - Persediaan sumber daya. - Kejadian
penting.

## 14.2 Agent Inspector

Ketika pengguna memilih agent, tampilkan: - Identitas. - Personality. -
Needs. - Goals. - Skills. - Memory. - Knowledge. - Relationships. -
Riwayat aktivitas.

## 14.3 Social Network

Menampilkan hubungan antaragent dalam bentuk graph.

Pengguna dapat melihat: - Kelompok. - Hubungan positif dan negatif. -
Individu yang berpengaruh. - Individu yang terisolasi. - Perubahan
jaringan dari waktu ke waktu.

## 14.4 Event Timeline

Menampilkan kejadian penting berdasarkan waktu, kategori, dan agent yang
terlibat.

## 14.5 Research Dashboard

Menampilkan: - Statistik populasi. - Grafik ekonomi. - Grafik hubungan
sosial. - Jumlah konflik. - Pembentukan kelompok. - Perbandingan
eksperimen.

## 14.6 Simulation Controls

Kontrol utama: - Start. - Pause. - Resume. - Stop. - Speed multiplier. -
Step one tick. - Save state. - Load state. - Create experiment snapshot.

------------------------------------------------------------------------

# 15. Experiment Scenarios

Berikut preset eksperimen yang dapat digunakan untuk menguji sistem.

## Experiment 01 --- The First Contact

**Pertanyaan:** Apa yang membuat individu mulai membentuk hubungan?

Kondisi: - 20 agent. - Tidak saling mengenal. - Sumber daya cukup. -
Tidak ada kelompok. - Tidak ada pemerintahan.

Hal yang diamati: - Frekuensi interaksi. - Hubungan yang terbentuk. -
Kelompok pertama. - Individu yang terisolasi.

## Experiment 02 --- Scarcity

**Pertanyaan:** Bagaimana kelangkaan sumber daya memengaruhi kerja sama
dan kompetisi?

Kondisi: - Populasi tetap. - Sumber daya terbatas. - Tidak ada aturan
distribusi awal.

Hal yang diamati: - Kerja sama. - Kompetisi. - Perubahan harga. -
Ketimpangan sumber daya. - Konflik.

## Experiment 03 --- The Rise of Power

**Pertanyaan:** Apakah kepemimpinan dapat muncul tanpa ditentukan sejak
awal?

Kondisi: - Tidak ada pemimpin. - Tidak ada pemerintahan. - Ada kebutuhan
untuk membuat keputusan bersama.

Hal yang diamati: - Individu berpengaruh. - Pembentukan mekanisme
kepemimpinan. - Kepercayaan. - Legitimasi. - Perubahan kekuasaan.

## Experiment 04 --- Information Divide

**Pertanyaan:** Bagaimana perbedaan informasi memengaruhi masyarakat?

Kondisi: - Beberapa kelompok memiliki informasi berbeda. - Komunikasi
memiliki batas. - Informasi dapat menyebar melalui rumor.

Hal yang diamati: - Penyebaran informasi. - Kesalahpahaman. -
Kepercayaan terhadap sumber. - Perubahan keyakinan. - Konflik akibat
informasi.

## Experiment 05 --- Generational Change

**Pertanyaan:** Bagaimana generasi baru mengubah budaya dan struktur
sosial?

Kondisi: - Agent memiliki umur. - Kelahiran dan kematian aktif. -
Pengetahuan dapat diajarkan. - Budaya dapat diwariskan melalui
interaksi.

Hal yang diamati: - Pewarisan keterampilan. - Perubahan norma. -
Perbedaan antargenerasi. - Perubahan kepemimpinan. - Perubahan nilai
kelompok.

## Experiment 06 --- Two Societies

**Pertanyaan:** Bagaimana dua masyarakat berbeda berinteraksi?

Kondisi: - Dua wilayah terpisah. - Setiap wilayah memiliki populasi dan
kondisi awal sendiri. - Komunikasi antarwilayah terbatas atau belum
tersedia. - Pertemuan dapat terjadi kemudian.

Hal yang diamati: - Perdagangan. - Aliansi. - Pertukaran budaya. -
Konflik. - Negosiasi. - Migrasi.

------------------------------------------------------------------------

# 16. Validasi dan Keterbatasan

Simulasi yang tampak realistis belum tentu menghasilkan perilaku sosial
yang valid.

Validasi harus menjadi bagian dari desain proyek.

## 16.1 Risiko Homogenitas Agent

Jika semua agent memiliki pola keputusan dan kepribadian yang mirip,
masyarakat akan terlihat seragam.

Mitigasi: - Variasi karakteristik awal. - Distribusi personality yang
dapat dikonfigurasi. - Perbedaan pengalaman dan pengetahuan. - Evaluasi
variasi perilaku.

## 16.2 Interaksi Palsu

Agent mungkin berbicara tanpa alasan atau tanpa konsekuensi.

Mitigasi: - Setiap interaksi harus memiliki konteks. - Komunikasi harus
mengubah atau mempertahankan keadaan secara terukur. - Hindari
percakapan yang tidak memiliki tujuan atau dampak.

## 16.3 Memory Drift

Agent dapat salah mengingat atau mencampur informasi.

Mitigasi: - Simpan sumber memori. - Pisahkan fakta dan rumor. - Simpan
confidence. - Gunakan retrieval berdasarkan relevansi. - Jangan mengubah
fakta world state berdasarkan ingatan agent.

## 16.4 Over-Scripting

Hasil simulasi dapat terlalu diarahkan oleh pembuat sistem.

Mitigasi: - Hindari aturan yang memaksa terbentuknya kelompok atau
pemerintahan. - Uji beberapa kondisi awal. - Bandingkan hasil dengan
konfigurasi berbeda. - Catat asumsi dan batasan model.

## 16.5 LLM Hallucination

LLM dapat menghasilkan informasi yang tidak sesuai dengan dunia.

Mitigasi: - LLM hanya mengusulkan tindakan atau teks. - Validasi seluruh
tindakan melalui engine. - Batasi informasi yang diberikan kepada
agent. - Simpan output dan keputusan validasi.

## 16.6 Reproducibility

Hasil yang berbeda dapat disebabkan oleh randomness, bukan perubahan
variabel yang diuji.

Mitigasi: - Gunakan random seed. - Jalankan eksperimen berulang. -
Simpan versi konfigurasi. - Bandingkan hasil agregat.

------------------------------------------------------------------------

# 17. Roadmap Pengembangan Berbasis Kemampuan

Roadmap berikut disusun berdasarkan kemampuan yang harus dimiliki dunia,
bukan berdasarkan teknologi tertentu.

## Phase 1 --- Individual Foundation

Tujuan: Membuat individu yang memiliki keadaan internal.

Fitur: - Identity. - Personality. - Needs. - Goals. - Basic skills. -
Basic decision making. - Life state.

Kriteria keberhasilan: - Agent dapat mengambil tindakan tanpa perintah
langsung dari pengguna. - Kebutuhan berubah seiring waktu. - Tindakan
memiliki konsekuensi. - Keputusan dapat ditelusuri.

## Phase 2 --- Interaction

Tujuan: Membuat agent dapat berinteraksi.

Fitur: - Conversation. - Relationship. - Memory. - Information
sharing. - Cooperation. - Conflict.

Kriteria keberhasilan: - Hubungan berubah karena kejadian. - Agent
memiliki pengetahuan yang berbeda. - Informasi dapat menyebar melalui
interaksi. - Interaksi memiliki konsekuensi yang tercatat.

## Phase 3 --- Society Formation

Tujuan: Mengamati pembentukan struktur sosial.

Fitur: - Group formation. - Group membership. - Social norms. -
Leadership. - Collective decisions.

Kriteria keberhasilan: - Kelompok dapat terbentuk dan bubar. -
Keanggotaan dapat berubah. - Aturan dapat diterima atau ditolak. -
Pengaruh sosial dapat berubah.

## Phase 4 --- Economy

Tujuan: Mengembangkan hubungan ekonomi.

Fitur: - Resource inventory. - Production. - Consumption. - Ownership. -
Trading. - Wealth. - Specialization.

Kriteria keberhasilan: - Barang diproduksi dan dikonsumsi secara
konsisten. - Transaksi mengubah kepemilikan. - Kelangkaan dapat
memengaruhi keputusan. - Aktivitas ekonomi dapat dianalisis.

## Phase 5 --- Governance and Culture

Tujuan: Mengembangkan struktur masyarakat jangka panjang.

Fitur: - Rules. - Enforcement. - Leadership transition. - Cultural
practices. - Generational knowledge transfer. - Social conflict
resolution.

Kriteria keberhasilan: - Aturan memiliki riwayat. - Kepemimpinan dapat
berubah. - Praktik sosial dapat bertahan atau menghilang. - Konflik
memiliki beberapa kemungkinan penyelesaian.

## Phase 6 --- Research Laboratory

Tujuan: Menjadikan simulasi sebagai alat eksperimen.

Fitur: - Experiment builder. - Configurable initial conditions. - Random
seed. - Simulation snapshots. - Analytics. - Event timeline. - Causal
event log. - Experiment comparison.

Kriteria keberhasilan: - Eksperimen dapat disimpan dan diulang. - Hasil
dapat dibandingkan. - Metrik memiliki definisi yang jelas. - Pengguna
dapat menelusuri kejadian penting.

------------------------------------------------------------------------

# 18. Rekomendasi Arsitektur Konseptual

Arsitektur sistem sebaiknya memisahkan tanggung jawab berikut.

## 18.1 World Simulation Layer

Mengelola: - World state. - Environment. - Simulation clock. - Resource
system. - Locations. - Event scheduling.

## 18.2 Agent Layer

Mengelola: - Identity. - Personality. - Needs. - Goals. - Skills. -
Memory. - Knowledge. - Decision making.

## 18.3 Interaction Layer

Mengelola: - Communication. - Relationship updates. - Transactions. -
Cooperation. - Conflict. - Group interactions.

## 18.4 Society Layer

Mengelola: - Groups. - Norms. - Leadership. - Governance. - Culture. -
Collective decisions.

## 18.5 Intelligence Layer

Mengelola: - Rule-based logic. - Utility evaluation. - Memory
retrieval. - Reflection. - Optional LLM integration.

## 18.6 Research Layer

Mengelola: - Experiment configuration. - Random seed. - Metrics. -
Snapshots. - Event logs. - Result comparison.

## 18.7 Presentation Layer

Mengelola: - World overview. - Agent inspector. - Social network. -
Event timeline. - Research dashboard. - Simulation controls.

Setiap layer sebaiknya berkomunikasi melalui kontrak data yang jelas.
Presentation layer tidak boleh menjadi tempat aturan simulasi utama
berada.

------------------------------------------------------------------------

# 19. Contoh Data Model Konseptual

Berikut entitas utama yang dapat menjadi dasar perancangan data.

  Entity             Tanggung jawab
  ------------------ -----------------------------------
  World              Identitas dan konfigurasi dunia
  WorldState         Kondisi dunia pada waktu tertentu
  Agent              Identitas dan status individu
  AgentPersonality   Atribut kepribadian
  AgentNeed          Kondisi kebutuhan
  AgentGoal          Tujuan individu
  AgentMemory        Pengalaman dan ingatan
  AgentKnowledge     Informasi yang diketahui
  AgentSkill         Kemampuan individu
  Relationship       Hubungan terarah antaragent
  Location           Tempat dalam dunia
  Resource           Jenis sumber daya
  Inventory          Kepemilikan sumber daya
  Group              Kelompok sosial
  GroupMembership    Keanggotaan agent
  SocialRule         Aturan atau norma
  Organization       Organisasi masyarakat
  Transaction        Pertukaran sumber daya
  Event              Kejadian simulasi
  Experiment         Konfigurasi eksperimen
  SimulationRun      Eksekusi eksperimen
  MetricSnapshot     Hasil metrik pada waktu tertentu

## 19.1 Contoh Agent State

``` json
{
  "id": "agent_001",
  "name": "Adam",
  "age": 27,
  "status": "alive",
  "locationId": "location_market",
  "personality": {
    "openness": 60,
    "conscientiousness": 75,
    "extraversion": 55,
    "agreeableness": 70,
    "neuroticism": 35,
    "ambition": 80,
    "trust": 50,
    "riskTolerance": 35
  },
  "needs": {
    "hunger": 78,
    "energy": 63,
    "safety": 82,
    "social": 35,
    "belonging": 50,
    "knowledge": 72
  },
  "goals": [
    {
      "type": "acquire_resource",
      "target": "food",
      "priority": 85,
      "status": "active"
    }
  ],
  "skills": {
    "farming": 65,
    "trading": 40,
    "crafting": 25
  }
}
```

Contoh tersebut hanya representasi konseptual. Struktur produksi perlu
mempertimbangkan validasi, relasi, histori perubahan, dan versi skema.

## 19.2 Contoh Event

``` json
{
  "id": "event_00042",
  "worldId": "world_001",
  "tick": 120,
  "type": "trade_completed",
  "actors": [
    "agent_001",
    "agent_002"
  ],
  "context": {
    "locationId": "location_market"
  },
  "action": {
    "resource": "food",
    "quantity": 5,
    "price": 10
  },
  "consequences": [
    "inventory_updated",
    "relationship_updated"
  ]
}
```

Event adalah catatan kejadian, bukan sekadar pesan naratif. Konsekuensi
harus sesuai dengan perubahan state yang benar-benar dilakukan engine.

------------------------------------------------------------------------

# 20. Referensi Penelitian

Referensi berikut relevan untuk memahami pendekatan dan tantangan
proyek.

## 20.1 Generative Agents: Interactive Simulacra of Human Behavior

Penelitian oleh Joon Sung Park dan kolaboratornya.

Topik utama: - Agent memory. - Memory retrieval. - Reflection. -
Planning. - Social interaction. - Simulasi komunitas Smallville.

Referensi: https://dl.acm.org/doi/10.1145/3586183.3606763

## 20.2 Validation is the Central Challenge for Generative Social Simulation

Penelitian mengenai tantangan validasi simulasi sosial generatif.

Topik utama: - Validitas perilaku agent. - Keterbatasan simulasi
berbasis LLM. - Evaluasi hasil. - Risiko menarik kesimpulan berlebihan.

Referensi: https://link.springer.com/

Catatan: cari judul lengkap penelitian tersebut di situs penerbit untuk
menemukan versi dan metadata publikasinya.

## 20.3 PIMMUR Principles

Referensi mengenai prinsip validasi perilaku kolektif dalam simulasi
masyarakat berbasis LLM.

Topik utama: - Homogenitas agent. - Interaksi yang tidak alami. -
Memori. - Pengaruh instruksi. - Evaluasi perilaku kolektif.

Referensi: https://arxiv.org/

Catatan: cari judul atau istilah PIMMUR pada arXiv untuk menemukan
naskah yang relevan.

------------------------------------------------------------------------

# 21. Definisi Keberhasilan Proyek

Society Zero tidak dinilai hanya dari jumlah agent, panjang dialog, atau
tampilan visual.

Indikator keberhasilan yang lebih bermakna:

1.  Agent dapat mengambil keputusan berdasarkan keadaan internal dan
    informasi lokal.
2.  Agent yang berbeda dapat menghasilkan pilihan yang berbeda dalam
    kondisi yang sama.
3.  Hubungan sosial berubah karena pengalaman dan interaksi.
4.  Informasi dapat menyebar tanpa membuat semua agent mengetahui
    seluruh fakta.
5.  Kelompok dapat terbentuk, berubah, dan bubar.
6.  Aktivitas ekonomi memiliki konsekuensi yang konsisten.
7.  Aturan dan struktur sosial dapat muncul tanpa dipaksakan.
8.  Sejarah dunia dapat ditelusuri.
9.  Eksperimen dapat diulang dan dibandingkan.
10. Pengguna dapat memahami faktor yang berkontribusi terhadap kejadian
    penting.

Hasil simulasi tidak harus selalu berupa masyarakat yang stabil, damai,
atau maju. Kegagalan membentuk masyarakat, konflik berkepanjangan,
ketimpangan, atau runtuhnya organisasi juga merupakan hasil yang dapat
dianalisis.

------------------------------------------------------------------------

# 22. Penutup

Society Zero adalah proyek untuk mengeksplorasi bagaimana masyarakat
buatan dapat terbentuk dari kumpulan individu yang memiliki kepentingan,
keterbatasan, dan pengalaman berbeda.

Daya tarik utamanya bukan membuat AI yang mampu meniru percakapan
manusia, melainkan membangun sistem yang memungkinkan interaksi individu
menghasilkan konsekuensi sosial jangka panjang.

Prinsip yang harus terus dijaga:

> Do not script the society. Build the conditions that allow society to
> emerge.

Pengguna menciptakan lingkungan, menentukan kondisi awal, mengamati, dan
bereksperimen. Individu di dalamnya menjalani kehidupan berdasarkan
aturan dunia dan keadaan masing-masing.

Jika sistem berhasil, setiap simulasi dapat menghasilkan sejarah yang
berbeda, dan setiap sejarah dapat menjadi bahan penelitian baru.
