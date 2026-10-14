# Sky Island Adventure — PRD Global

## 1. Overview / Ringkasan

Dokumen ini adalah **single source of truth global**; PRD per stage merinci kontrak lokal dan tidak boleh mengubah keputusan global tanpa audit. Status: draft konsolidasi dokumentasi; **implementation readiness: BLOCKED BY DECISION**, bukan izin implementasi, upload aset, build game, commit/push, atau publish. Root `prd.md` yang dihapus user tidak direstorasi atau dipindahkan.

- Judul kerja: Sky Island Adventure; alias historis/kode: AI Obby Adventure. Nama final belum dipilih.
- Genre: cozy 3D platformer / obby pulau langit; perangkat utama mobile sentuh dan PC keyboard/mouse.
- Target historis: Universe `10770632072`, Place `71239438116581`; identitas ini bukan otorisasi deployment.
- Batas saat ini: PRIVATE; tidak mengubah visibilitas, mengunggah aset, atau memublikasikan. Laporan inspeksi terdahulu PRIVATE bukan pemeriksaan live baru.
- Sumber: versi awal dokumen ini dibaca lengkap; PRD dan seluruh inventaris source worktree feature dibaca read-only sebagai pembanding. Baseline yang diberitahukan: main `fdae129`, feature `27d5216`; tidak dianggap sebagai versi place terpasang atau hasil runtime.

### Label bukti wajib

| Label | Makna |
|---|---|
| **Existing & Verified** | Keberadaan/isi source telah diinspeksi; hanya verifikasi source, runtime Roblox masih pending. Wajib menyebut main atau feature. |
| **Approved Design** | Keputusan desain user, bukan bukti implementasi atau persetujuan runtime. |
| **Proposed** | Rekomendasi/kontrak draft; belum disetujui. |
| **Requires Validation** | Memerlukan pengujian/perangkat/keputusan tambahan; tidak boleh diklaim lulus. |
| **Not Implemented** | Belum ditemukan implementasinya pada scope source yang disebut. |

### Audit perubahan dan konflik

| Topik | Catatan asal/konflik | Resolusi dokumentasi |
|---|---|---|
| Struktur lama 10 bagian | Global mencampur arsitektur, stage, penerimaan dan persistence | Direorganisasi menjadi tepat 23 bagian, tanpa persetujuan fitur baru. |
| Jalur linear | Dokumen utama lama tidak menjelaskan pendakian; pembanding merekam keputusan user menanjak | Linear berarti urutan progres, bukan semua pulau segaris. Pendakian disimpan sebagai Approved Design; spiral/zigzag dan angka Y tetap Proposed/Requires Validation. |
| Konfeti | Dokumen lama semua FX opsional off; pembanding merekam pilihan konfeti 3D lokal | Pilihan estetika general Approved Design, bukan ulang tahun. Neutral fallback tetap wajib; angka partikel bukan persetujuan performa. |
| Status summit/map | PRD pembanding mengatakan modul belum dibuat, tetapi source feature memuatnya | Bedakan main belum memiliki modul dan feature memiliki source; tidak menyimpulkan deployed/runtime. |
| Checkpoint | Lama “spawn awal & akhir pulau” ambigu; feature mengabaikan touch CP10 dan finish mensyaratkan CP9 | Kontrak CP_N di entry island N Proposed; keluar stage1 mengaktifkan CP2 dan stage aktif2. CP1 untuk spawn. CP10 bukan finish. Perubahan feature untuk CP10 belum diimplementasikan. |
| Nama summit | Special Summit di PRD, Sky Summit di StageConfig feature | Nama kerja/general; bukan bukti personalisasi aktif. Nama final terbuka. |
| Angka ekonomi | Kode reward 25/1, reset 15 detik | Nilai historis source, bukan approval ekonomi atau pickup. |
| Import aset | Pembanding menyamakan ID Model dengan MeshId dan menganggap collision menjamin FPS | Koreksi: ID Model berbeda dari ID mesh; loading/izin/moderasi/runtime dan performa harus divalidasi terpisah. |
| Lisensi/download | Pembanding mengklaim arsip Kenney tersedia serta autentikasi Quaternius wajib | Dicatat sebagai laporan historis, bukan audit file/lisensi baru; belum membuktikan autentikasi wajib. |
| Sumber global | Root PRD lama sudah dihapus user | Canonical tetap `docs/prd.md`; tautan source relatif; PRD stage berada `stage-N/prd.md`. |

## 2. Vision / Visi

**Approved Design:** perjalanan obby pulau langit general, menanjak menuju summit, hangat dan ramah pemula. Personalisasi hanya di summit dan dipilih user kemudian; tidak mengubah seluruh game menjadi ulang tahun. Finish memberi rasa pencapaian dan panorama, bukan memaksa grind.

**Proposed:** keberhasilan playtest 8 dari 10 pemula mencapai summit tanpa bantuan verbal; minimal 30 FPS pada perangkat mobile target yang belum dipilih. **Requires Validation:** durasi perjalanan, kenyamanan, keterbacaan rute, motion dan performa. Tidak ada klaim bebas lag.

## 3. Audience / Audiens

Pemain pemula dan pemain kasual di PC/mobile; bermain sendiri atau bersama tanpa saling mendorong. Tidak menetapkan kelompok usia spesifik, avatar final, perangkat minimum, atau jumlah pemain server sebagai keputusan baru. Kontrol dasar Roblox menjadi konteks, bukan movement contract yang telah diuji. Profil avatar, ukuran collider, WalkSpeed, JumpPower/JumpHeight, gravitasi dan skala perlu ditetapkan sebelum balancing.

## 4. Core Loop / Loop Utama

Masuk → spawn aman → baca arah/target → jalan atau lompat → landing aman → checkpoint berikut → ulangi sampai plaza summit → finish tervalidasi → banner general/konfeti lokal → istirahat dan panorama. Jatuh mengembalikan pemain ke checkpoint terakhir tanpa menghapus progres sesi yang sah.

Koin sebagai penunjuk jalur/collectible opsional berasal dari rancangan lama; mengumpulkan semua bukan syarat finish. Nilai, reset pickup dan implementasi pickup belum disetujui. Tidak menambah timer wajib, platform bergerak/runtuh, blind jump, penalti koin, toko, monetisasi, leaderboard global, atau AI generatif saat bermain.

## 5. Player Journey / Perjalanan Pemain

**Proposed handoff Stage 1:** entry CP1/spawn → orientasi kamera/kontrol → jalan di area datar aman → latihan lompat dasar dengan target terlihat dan landing lebar → transisi bertahap ke Cloud Garden → sentuh CP2 → HUD stage aktif2. Ini tutorial konkret dalam desain, bukan tutorial/runtime yang sudah diterima. Detail bentuk/jumlah pijakan, copy, gate dan uji berada di [PRD Stage 1](stage-1/prd.md).

Stage 2–9 menerapkan variasi ringan tanpa mekanik baru. Pulau tujuan lebih tinggi; kenaikan antarpulau dipecah melalui landing bertahap. Masuk island10/CP10 tidak sama dengan selesai: pemain tetap harus mencapai `SummitFinishZone`. Setelah finish sah, kontrol/kamera tetap bebas dan tidak ada hadiah baru otomatis. Jatuh, respawn, join ulang dan kegagalan efek dibedakan; join ulang tidak dijanjikan memulihkan progres karena persistence belum disetujui.

## 6. Ten Stages / Sepuluh Stage

Tema/nama berikut mempertahankan rancangan lama; ukuran, koordinat dan rincian layout adalah **Proposed / Requires Validation**. Stage1–9 perjalanan, stage10 plaza finish, bukan rintangan kesepuluh. Angka Y historis pembanding adalah pusat deck feature, bukan tinggi permukaan injak dan bukan target final.

| Stage | Nama kerja | Tujuan dan karakter jalur | Y historis feature | Entry menurut kontrak usulan |
|---|---|---|---:|---|
| 1 | Welcome Meadow | Rumput/bunga; kamera, jalan, lompat dasar; landing ekstra lebar 14×14+ | 10 | CP1/spawn; keluar menuju CP2 |
| 2 | Cloud Garden | Taman melayang; lompatan pendek/anak tangga dengan target terlihat | 22 | CP2 |
| 3 | Breeze Bridge | Jembatan kayu hangat; berjalan dan celah tunggal | 36 | CP3 |
| 4 | Terrace Grove | Teras rendah, naik 1–2 studs per langkah, belokan ringan | 52 | CP4 |
| 5 | Pond Islands | Air dekoratif, batu belok; penuntun jalur di tengah landing | 70 | CP5 |
| 6 | Cloud Steps | Pijakan awan padat, diselingi istirahat; jumlah 3–4 pada draft lama bukan batas untuk kenaikan total | 90 | CP6 |
| 7 | Sky Orchard | Kebun buah; belokan ringan dan kenaikan bertahap | 112 | CP7 |
| 8 | Sunset Walk | Senja hangat; jalur lebih panjang dengan pola yang sudah dikenal | 136 | CP8 |
| 9 | Summit Approach | Pendekatan/gerbang lebar menuju puncak, transisi tenang | 162 | CP9; keluar menuju CP10 |
| 10 | Special Summit / Sky Summit | Plaza 48×48 minimum, panorama dan selebrasi general, tanpa rintangan baru | 190 | CP10, finish terpisah |

Spiral/zigzag halus, sudut belokan 45°, lereng dan dekorasi spesifik belum merupakan layout final. Selisih antarpulau 12–28 studs tidak boleh menjadi satu lompatan. Source feature berupa graybox dan bukan pembuktian tiap tema sudah terwujud.

## 7. Standards / Standar Geometri

**Proposed baseline yang dipertahankan:**
- Pulau checkpoint/istirahat: area datar minimal 20×20 studs; visual tepi aman tidak menggantikan collider pengaman bila diperlukan.
- Stage1 tutorial: pijakan 14×14+; stage1–3 umum minimal 12×12; stage4–9 minimal 10×10.
- Jembatan: lebar minimal 8–10 studs.
- Gap tepi-ke-tepi stage1–3: 2–3 studs; stage4–9: 3–5 studs, target maksimum 60% jangkauan yang konsisten dicapai pemula sentuh, bukan lompatan terbaik developer.
- Kenaikan permukaan injak per lompatan 0–2 studs; jangan gabungkan gap maksimum dan kenaikan maksimum tanpa validasi.
- Plaza summit minimal 48×48, landing/transisi aman dan tepi terlindungi.

**Requires Validation:** ukur actual oriented edges dan permukaan injak, bukan jarak pusat atau hanya Y config; periksa collider avatar dan margin landing. Feature memakai pulau 24×2×24, summit48×2×48, jumlah batu6–15 serta assertion gap sekitar2.5–4; angka source ini bukan jaminan kenyamanan atau kesesuaian semua gap per stage. Tidak mengunci jumlah batu hanya demi menyamai draft lama.

## 8. Accessibility / Aksesibilitas

**Desain target:** target landing selalu terlihat, instruksi singkat dan tidak hanya bergantung warna/audio; UI tidak menutupi joystick, tombol lompat atau jalur pandang. Teks/ikon dan arah jalur dapat dibaca pada layar kecil. Reduced motion memakai banner statis tanpa konfeti; mute menghentikan/tidak memutar audio bila kelak audio dipilih. Kamera tidak diambil alih oleh konfeti.

Opsi kamera tetap nonaktif. Bila kelak dipilih, tombol Lewati tersedia sejak awal; kamera/kontrol dipulihkan pada selesai, skip, mati, respawn atau kegagalan. **Requires Validation:** safe-area/inset, ukuran sentuh, kontras, perubahan setting saat efek aktif, akses ke preferensi reduced motion Roblox pada perangkat target. Source feature membaca setting/attribute ReducedMotion; hal itu bukan bukti pengaturan runtime kompatibel di semua perangkat.

## 9. Technical Architecture / Arsitektur Teknis

**Existing & Verified — main, inspeksi source saja:** [GameConfig](../src/shared/GameConfig.luau), [server entry](../src/server/Main.server.luau), [LeaderboardService](../src/server/services/LeaderboardService.luau), [CheckpointService](../src/server/services/CheckpointService.luau), [ObstacleService](../src/server/services/ObstacleService.luau), [client entry](../src/client/Main.client.luau), [HUDController](../src/client/controllers/HUDController.luau). Main memulai tiga service dan HUD; tidak ditemukan generator map, summit, konfeti, collision group pemain atau persistence pada inventaris source main yang dibaca.

**Existing & Verified — feature, tidak tersedia pada main:** source pembanding memiliki `src/shared/StageConfig.luau`, `src/shared/SummitConfig.luau`, `src/server/services/MapBuilderService.luau`, `PlayerCollisionService.luau`, `SummitService.luau`, serta `src/client/controllers/SummitController.luau` dan `ConfettiController.luau`. Path ini relatif terhadap root worktree feature, bukan tautan ke file main yang belum ada. Peta dibangkitkan saat server mulai, bukan geometry Workspace baked. Map dibangun sebelum binding checkpoint/obstacle; collision → leaderstats → checkpoint → summit → obstacle; client bind summit sebelum HUD menunggu leaderstats.

**Proposed architecture contract:** Rojo memisahkan server/services, client/controllers dan shared/config; progres/finish/reward di server, HUD/FX lokal di client. Shared configuration publik, tanpa rahasia. Map regeneration harus membersihkan geometry milik generator dan rebind listeners bila didukung. Build Rojo, adapter Luau/Python, inspeksi source, runtime Studio, playtest mobile dan deployment adalah bukti berbeda; tidak satu pun hasil eksekusi baru diklaim dalam revisi docs ini.

## 10. Checkpoint Contract / Kontrak Checkpoint

**Proposed, bukan approval runtime:** `CP_N` berada di entry island N; alias instance historis `Checkpoint_N`. CP1 initial spawn. Aktivasi berurutan CP2…CP10 memperbarui checkpoint/stage aktif; keluar jalur stage1 → CP2 → stage aktif2. Arrival CP10 sah menyimpan `LastCheckpoint=CP10`, `ActiveStage=10`, history entry CP10 dan `Completed=false`. Save berarti state/respawn sesi, bukan persistence lintas sesi atau approval reward. `SummitFinishZone` terpisah dari CP10 memvalidasi history CP1–10 dan mengubah `Completed=true` sekali. Jatuh setelah arrival (termasuk sebelum finish) pulih ke CP10; finish tidak mengganti entry checkpoint.

Respawn memakai checkpoint aktif, offset Y+3.5 dari rancangan lama, orientasi mengikuti segmen berikutnya, bukan selalu +Z. Offset perlu diuji terhadap collider/trigger final. Checkpoint istirahat tambahan hanya bila dipilih; ID terpisah, tidak memajukan stage atau menggandakan reward utama.

**Existing & Verified — main, source only:** main memproses checkpoint n+1 termasuk10 tanpa summit terpisah. **Existing & Verified — feature source only:** feature mengabaikan touch stage≥10, menyimpan history1–9 dan mensyaratkan CP9 untuk finish; stage10 baru disetel saat finish. Generator feature membuat Checkpoint_10 tetapi service tidak mengaktifkannya. Kontrak entryCP10 membutuhkan revisi implementasi kemudian; belum dikerjakan/disetujui di sini. Posisi entry aktual tiap trigger juga perlu audit geometry, tidak otomatis benar karena namanya cocok.

## 11. State / State dan Invarian

**Proposed logical state:** `ActiveStage`, `LastCheckpoint`, `ReachedCheckpoints`, `Completed` dan state presentasi terpisah. Default sesi: stage1/CP1, Completed false. Server mengesahkan checkpoint berurutan; touch lama/duplikat tidak mengubah progres. Mati/respawn tidak menghapus checkpoint sesi. Finish sah mengubah Completed sekali; kegagalan presentasi tidak membatalkannya.

Presentasi: Ready → Playing → Cooldown → Ready. Replay hanya setelah finish, tidak saat Playing/Cooldown; tanpa perubahan checkpoint, Completed atau reward. Cleanup menghentikan emitter, timer/callback, koneksi dan attachment pada selesai, mati, karakter hilang, respawn atau error.

**Existing & Verified — main, source only:** main memakai IntValue `Stage`/`Coins`; tabel playerCheckpoints dideklarasikan tetapi bukan history progres aktif. **Existing & Verified — feature source only:** feature memakai history checkpoint dalam memori server, tabel completed/attribute Completed serta lifecycle client; bukan penyimpanan lintas sesi. Kontrak CP10 pada bagian10 belum tercermin dalam state feature. Coins bukan field ekonomi final yang disetujui.

## 12. Collision and Recovery / Kolisi dan Pemulihan

Desain target: kolisi antarpemain dimatikan agar tidak saling mendorong; dekorasi daun/bunga/balon/lentera non-collidable. Permukaan playable memiliki collider tersendiri dan tidak bergantung pada mesh dekorasi. Part trigger bukan landing. Tentukan CanCollide/CanTouch/CanQuery eksplisit berdasarkan peran.

Recovery mengikuti segmen/ketinggian rute agar jatuh tidak berlangsung lama atau menyentuh checkpoint pulau bawah secara salah. KillBrick memicu mati lalu respawn; bukan bukti respawn instan tanpa jeda. **Existing & Verified — main, source only:** main hanya bind KillBrick yang sudah ada di Workspace; **Existing & Verified — feature source only:** feature membuat recovery tiered sekitar25 studs di bawah dan collision group `SkyIslandPlayers`. **Requires Validation:** coverage void/tepi/belokan, waktu pulih, event dari anggota avatar, pemain mati/stale character, checkpoint bawah, pendaratan respawn, collider pagar summit dan pintu masuk. Angka25 bukan SLA recovery.

## 13. Visuals / Visual dan Art Direction

**Approved Design:** pulau langit cerah/cozy, perjalanan terasa makin tinggi, nuansa general dan selebrasi konfeti3D lokal di summit. Warna pastel, rumput/bunga, kayu hangat, batu/awan, kebun dan senja mempertahankan tema rancangan.

**Proposed:** siluet batu bertingkat, lentera hangat, plaza melingkar/marmer, gazebo/panggung pastel dan spot foto. Bukan klaim asset final sudah dipasang. Kue, nama pribadi, ucapan ulang tahun, kembang api, musik dan cutscene tidak aktif. **Requires Validation:** bentuk konfeti sesuai estetika pilihan user; native sparkle texture pada feature bukan bukti visual sudah identik referensi. Cahaya senja tidak boleh menurunkan keterbacaan landing; dekorasi tidak menghalangi kamera atau mengubah gap.

## 14. Assets and Licensing / Aset dan Lisensi

Referensi historis: [Kenney Nature Kit](https://kenney.nl/assets/nature-kit) dan [Quaternius Ultimate Platformer Pack](https://quaternius.itch.io/ultimate-platformer-pack), dicatat sebagai kandidat CC0. Pembanding melaporkan Kenney di `assets/raw/kenney_nature-kit.zip` sekitar11MB/329 model, tetapi revisi ini tidak mengaudit arsip atau mengesahkan angka/download/lisensinya. Catat provenance, berkas lisensi asli, hash, format, dependensi material/tekstur dan ID asset terverifikasi sebelum integrasi. CC0 asset berbeda dari lisensi kode MIT; lisensi repo bukan izin menyalin kode/tekstur DevForum. Status download Quaternius memerlukan validasi, tidak menyatakan login wajib tanpa bukti.

[Open Cloud Assets guide](https://create.roblox.com/docs/cloud/guides/usage-assets) mendukung `.fbx`, `.gltf`, `.glb` sebagai asset **Model**; Studio tidak wajib untuk upload format yang didukung. Upload belum diotorisasi: periksa izin creator/experience, key scopes, ukuran/tipe, operasi asynchronous, error/quota, moderation dan ownership. Jangan taruh raw FBX/GLB sebagai Rojo instance langsung.

**Koreksi wajib:** ID hasil upload Model/package **bukan MeshId**; jangan assign ID Model ke `MeshPart.MeshId` atau API pembuat mesh. Loader Model memerlukan kontrak API engine dan permission yang diverifikasi, staging non-live, allowlist kelas, penghapusan script executable, anchor, collision dekoratif, scale/pivot serta fallback primitive. `AssetService:LoadAssetAsync`/metode pemuatan lain harus diverifikasi terhadap dokumentasi engine yang berlaku sebelum implementasi; tidak menjamin `InsertService` bisa dipakai client/server tanpa batas. MeshPart-only property tidak diterapkan ke semua BasePart. Import readiness, upload aktual, moderation, engine load, visual acceptance dan FPS adalah gate terpisah. Tidak ada upload/publish pada scope ini.

## 15. HUD / Antarmuka

**Existing & Verified — main/feature:** HUD source menampilkan Stage/Coins dari leaderstats, panel220×70 pada offset20×20, ResetOnSpawn false, font Gotham. Itu bukti UI source, bukan safe-area mobile lulus. Belum ada tutorial lengkap di HUD main.

**Proposed:** stage aktif/nama pulau, arah/instruksi singkat tutorial serta banner general saat finish; angka Stage bukan bukti Completed. Kontrak CP2 berarti HUD stage2 setelah keluar tutorial, bukan setelah mulai stage1. Coins dipertahankan sebagai legacy display sampai keputusan ekonomi, bukan CTA pembelian. Replay selebrasi pada rancangan lama/feature hanya presentasi, cooldown baseline10 detik; bukan approval mekanik reward baru. **Requires Validation:** wait timeout leaderstats, loading/stale state, reconnect/respawn, layar kecil, inset, overlap kontrol dan tombol replay.

## 16. Summit / Sistem Puncak

Core desain: plaza aman → finish tervalidasi server → catatan idempoten → `FireClient` hanya pemain terkait → banner general dan konfeti World3D lokal. Neutral fallback tetap tersedia bila config/schema/preset/asset/anchor atau FX gagal. Kamera/kontrol bebas. Tidak ada nama/ucapan ultah pada preset general.

**Approved Design estetika:** konfeti3D di sekitar karakter, bukan overlay UI2D; referensi [DevForum #3592913](https://devforum.roblox.com/t/confetti-effect/3592913) hanya referensi visual. **Proposed teknis:** ParticleEmitter+Attachment lokal, modul Start/Stop terpisah. Baseline presentasi3–5 detik termasuk partikel terakhir dan40–60 partikel aktif; feature memakai4 detik/48. Bukan klaim lebih ringan atau aman di mobile.

Kontrak modular historis dipertahankan sebagai target, bukan schema final yang disetujui:
- `SchemaVersion=1`; preset Neutral/Festive general; Birthday/Custom hanya kandidat future, tidak aktif.
- Core: Enabled, BannerTitle/Subtitle, BannerDurationSeconds baseline5, FinishZoneName `SummitFinishZone`.
- Personalization: DisplayName/CustomMessage kosong; Cake off/`CakeAnchor`; Decorations personal off/`DecorationAnchor`; Confetti World3D sesuai pilihan estetika; Fireworks off/`FireworksAnchor` baseline5; Audio off/SoundId kosong/volume baseline0.5; Camera off/baseline5/AllowSkip true.
- Accessibility: RespectReducedMotion dan RespectAudioMute; Replay baseline enabled, cooldown10, GrantRewards false; parameter harus dibatasi/diuji, bukan ekonomi baru.

**Existing & Verified — feature:** preset `Neutral` dengan Confetti.Enabled true, resolver fallback banner, finish event, emitter texture native `rbxasset://textures/particles/sparkles_main.dds`, cleanup dan replay. Nama field Personalization historis tidak berarti konfeti general menjadi ulang tahun. **Not Implemented — main:** seluruh modul summit/config/confetti. **Requires Validation:** CP10 contract, isolasi dua client, reduced motion, fidelity konfeti, cleanup/error/replay, anchor optional, durasi dan FPS.

## 17. Security / Keamanan

Server memeriksa player/karakter terkini, hidup, posisi dalam zona, urutan checkpoint dan riwayat; request client atau Touched saja bukan otoritas finish. Validasi event dan perubahan progres/reward idempoten berdasarkan identitas pemain/event stabil, bukan timestamp retry baru. Client tidak memberikan Completed, checkpoint atau reward sendiri.

**Existing & Verified — main, source only:** main checkpoint hanya mengecek urutan setelah Touched/GetPlayerFromCharacter; tidak tampak validasi posisi/health/history lengkap. **Existing & Verified — feature source only:** feature checkpoint mengecek karakter/hidup/posisi dan history, finish memeriksa history9 serta zona/hidup dan mencatat tanpa yield sebelum FireClient. Ini bukan audit anti-cheat atau penerimaan security runtime dan tidak memenuhi kontrak CP10 usulan.

Config shared dapat dilihat client, bukan tempat rahasia. Asset allowlist, validator versi/batas durasi/volume/partikel dan cleanup menjadi kontrak target; source resolver feature bukan bukti semua validator/anchor/personal module selesai. Input pesan bebas pemain di luar scope; bila kelak ditambahkan perlu filtering/moderasi Roblox. Rate limiting/abuse tests yang diperlukan dirancang sebelum runtime acceptance, tanpa menambah mechanic baru.

## 18. Persistence / Penyimpanan

**Proposed, belum disetujui; Not Implemented pada source main dan feature yang diinspeksi:** profil perUserId berisi SchemaVersion, checkpoint/stage, Completed, Coins bila diadopsi, dan penanda reward. Progres saat ini sesi/memori; tidak menjanjikan restore saat rejoin.

Jika scope disetujui: UpdateAsync, session locking, retry terbatas, autosave data berubah, PlayerRemoving/BindToClose dan data development terpisah. Load gagal retry/menahan progres, tidak menimpa data lama dengan default. Completion/reward marker harus konsisten dan retry tidak menduplikasi. Kebijakan reset/migrasi/konflik sesi/rate limit perlu dirinci sebelum implementasi. Timer/personal best, global leaderboard dan ekonomi tidak otomatis ikut disetujui.

## 19. Acceptance / Kriteria Penerimaan

Semua skenario berikut **Requires Validation**, bukan test yang telah lulus. AC bersyarat tidak mengesahkan fitur yang belum dipilih.

| ID | Given / When / Then |
|---|---|
| AC-01 | CP_N sah → sentuh CP_N+1 → progres berurutan; skip/duplikat tidak memajukan stage atau memberi reward tambahan. CP10 mengikuti kontrak usulan bila diterima. |
| AC-02 | Checkpoint aktif → mati/jatuh → respawn checkpoint itu dengan orientasi segmen dan offset aman (baseline+3.5), tidak reset progres sesi. |
| AC-03 | Reward/pickup kelak disetujui → touch/retry berulang → satu grant per event sah, bukan nilai ekonomi baru. |
| AC-04 | Dua pemain → bertemu di jalur → tidak saling mendorong keluar. |
| AC-05 | Avatar/perangkat target → seluruh jalur1–9 → gap/kenaikan/landing dapat dilalui konsisten dengan joystick dan tombol lompat. |
| AC-06 | A finish sah → selebrasi → banner/konfeti/audio bila dipilih hanya A, kontrol/kamera B tidak berubah. |
| AC-07 | Finish tercatat → replay yang tersedia → presentasi saja, tanpa reward/progres tambahan. |
| AC-08 | Config modular diganti secara sah → presentasi berubah → tidak mengubah layanan progres; tetap perlu build/publish berotorisasi, bukan live editor. |
| AC-09 | Urutan wajib belum sah atau karakter tidak valid → masuk/request finish → server menolak Completed. |
| AC-10 | Dua pemain, A finish → presentasi personal/local → state/kamera/FX B tetap. |
| AC-11 | Kamera kelak dipilih → skip/mati/respawn/error → kontrol/kamera dipulihkan dan objek sementara dibersihkan. Default kamera off. |
| AC-12 | Reduced motion/mute → presentasi/setting berubah → banner statis tanpa konfeti / audio tidak diputar atau berhenti. |
| AC-13 | Config/modul/anchor tidak valid → finish sah → Completed tetap tercatat dan fallback banner general; kegagalan FX tidak membatalkan finish. |
| AC-14 | Finish/event/replay duplikat → retry → tidak ada catatan/reward/FX yang menumpuk; Playing/Cooldown menolak replay. |
| AC-15 | Persistence kelak disetujui, load gagal → join/retry → tidak overwrite data lama; restore hanya setelah load sah. |
| AC-16 | Pemula spawn CP1 → tutorial jalan/kamera/lompat Stage1 selesai dan CP2 tersentuh → stage aktif2, respawn CP2; bukan klaim tutorial sudah dibangun. |
| AC-17 | Masuk island10/CP10 pada kontrak diterima → belum menyentuh finish sah → stage aktif10 tetapi Completed false; finish terpisah menghasilkan true sekali. |
| AC-18 | Perpindahan pulau → naik/membelok → target terlihat dan setiap gap/kenaikan memenuhi margin; bukan semua pusat segaris, recovery tidak mengaktifkan CP bawah. |
| AC-19 | Finish/replay/respawn/error → konfeti3D lokal → total durasi terbatas, cleanup emitter/attachment/timer, kontrol bebas, tanpa copy ulang tahun. |

Gate bukti: inspeksi source → pemeriksaan Luau/geometry bila dilakukan → runtime Roblox PC → playtest sentuh dan multiplayer → profil performa/aksesibilitas → review aset/security. Tes Python simulasi, Luau adapter atau build Rojo tidak menggantikan runtime/physics/rendering. Target8/10 pemula dan30FPS tetap usulan sampai perangkat/protokol disepakati; hasil eksekusi belum dicatat sebagai lulus.

## 20. Risks / Risiko

| Risiko | Dampak / mitigasi desain |
|---|---|
| Source main/feature dianggap deployment | Salah klaim siap main; cantumkan scope source, versi place dan runtime terpisah. |
| CP10 vs finish ambigu | Progres/respawn salah; persetujuan kontrak dan regression checkpoint/finish wajib. |
| Kenaikan total dianggap satu jump | Jalur tidak terjangkau; pecah kenaikan, ukur edges/top surfaces dan uji avatar/touch. |
| Tutorial/map graybox dianggap selesai | UX pemula tidak terbukti; PRD Stage1 dan gate nyata tetap blocker. |
| Recovery/pagar hanya visual | Jatuh lama atau landing invalid; cek collider/coverage/orientasi dan multiplayer. |
| Konfeti/native texture dianggap estetika final/bebas lag | Visual/overdraw mobile salah; review visual, limit lifetime/count, cleanup/reduced motion dan profil target. |
| Import Model sebagai MeshId / script pihak ketiga | Load gagal/keamanan; staging, class allowlist, ID bertipe, fallback. |
| Lisensi/ownership/moderation belum sah | Aset tidak dapat dipakai; provenance/license/permission gate tanpa upload otomatis. |
| Persistence/economy tersirat disetujui | Data loss/scope creep; conditional acceptance, tanpa implementasi sebelum keputusan. |
| Draft dianggap acceptance gameplay | Seluruh 11 PRD tersedia dan isi/link dicek; review desain detail serta gameplay acceptance tetap pending. |

## 21. Milestones / Tonggak

1. **Dokumentasi sekarang:** konsolidasi global, tutorial Stage1, draft Stage2–10 dan audit read-only bukti. Selesai docs tidak berarti gameplay selesai; daftar blocker runtime/desain tetap.
2. **Konfirmasi desain, belum izin build:** nama, layout, movement/avatar, durasi, checkpointCP10, perangkat minimum, reward/pickup, persistence, visibilitas dan modul summit optional.
3. **MVP general setelah izin implementasi:** graybox9 jalur+plaza summit, checkpoint/respawn, HUD, validasi finish, general celebration sesuai keputusan; koin/persistence hanya jika disetujui.
4. **Polishing setelah izin:** visual, aksesibilitas, multiplayer dan playtest mobile; personalisasi hanya yang dipilih user.
5. **Release readiness setelah izin:** build reproducible, runtime/failure tests, asset/audio licensing, performance; upload aset/publish/perubahan visibilitas memerlukan otorisasi eksplisit terpisah. Tetap PRIVATE tanpa instruksi lain.

## 22. Open Decisions / Keputusan Terbuka

- Nama final, usia/perangkat minimum, jumlah pemain, avatar/movement/collider, target durasi perjalanan dan baseline performance.
- Persetujuan semantik entryCP_N termasukCP10, seluruh riwayat yang wajib untuk finish, recovery/respawn setelah Completed, checkpoint tambahan dan ID-nya.
- Layout pendakian spiral/zigzag/kurva, dimensi final, jumlah landing, tinggi permukaan, recovery coverage dan copy tutorial. Tema tidak membuktikan geometry final.
- Koin/reward/pickup/reset: status25/1/15 hanya source historis; apakah fitur dipertahankan dan bagaimana deduplikasi, bukan keputusan ekonomi baru.
- Persistence dan kebijakan load/save/reset/migrasi/konflik sesi; timer/personal best tetap future conditional.
- Konfeti estetika disetujui, tetapi tekstur final, jumlah/durasi, replay placement/cooldown dan acceptance visual/performance masih validasi. Pilihan konfeti tidak mengaktifkan birthday, musik, fireworks atau kamera.
- Aset final/provenance/izin/import loader dan moderation; dekorasi netral versus personal modular, nama/banner personal ditentukan user nanti.
- Approval runtime PC/touch/multiplayer/security dan visibility/release terpisah. Global leaderboard, toko/monetisasi, live editor dan AI runtime di luar scope.

## 23. Stage Index / Indeks PRD Stage

PRD lokal memakai standar, state/checkpoint, security dan status bukti global. Tidak menggandakan keputusan ekonomi/persistence atau menyatakan kontrak proposed sebagai runtime approved. Status di bawah membedakan dokumen tersedia, review isi/link dokumentasi dan acceptance gameplay; bukan approval desain detail. [Audit ledger](review.md) mencatat bukti dan blocker. Implementation readiness **BLOCKED BY DECISION**: movement/avatar, boundary CP2, CP global dan validasi fungsi first gap belum selesai.

| Stage | Dokumen relatif | Status handoff |
|---|---|---|
| 1 | [Welcome Meadow](stage-1/prd.md) | Draft Detailed Design — Critical Decisions Pending; **BLOCKED BY DECISION**, bukan READY; gameplay belum diuji. |
| 2 | [Cloud Garden](stage-2/prd.md) | Draft supplied — Pending Detailed Design Review; isi/link checked, acceptance gameplay pending. |
| 3 | [Breeze Bridge](stage-3/prd.md) | Draft supplied — Pending Detailed Design Review; isi/link checked, acceptance gameplay pending. |
| 4 | [Terrace Grove](stage-4/prd.md) | Draft supplied — Pending Detailed Design Review; isi/link checked, acceptance gameplay pending. |
| 5 | [Pond Islands](stage-5/prd.md) | Draft supplied — Pending Detailed Design Review; isi/link checked, acceptance gameplay pending. |
| 6 | [Cloud Steps](stage-6/prd.md) | Draft supplied — Pending Detailed Design Review; isi/link checked, acceptance gameplay pending. |
| 7 | [Sky Orchard](stage-7/prd.md) | Draft supplied — Pending Detailed Design Review; isi/link checked, acceptance gameplay pending. |
| 8 | [Sunset Walk](stage-8/prd.md) | Draft supplied — Pending Detailed Design Review; isi/link checked, acceptance gameplay pending. |
| 9 | [Summit Approach](stage-9/prd.md) | Draft supplied — Pending Detailed Design Review; isi/link checked, acceptance gameplay pending. |
| 10 | [Special Summit / Sky Summit](stage-10/prd.md) | Draft supplied — Pending Detailed Design Review; isi/link checked, acceptance gameplay pending. |

Audit read-only/source dan rekonsiliasi dokumentasi dicatat di [review ledger](review.md); keberadaan file bukan acceptance gameplay. Kontrak global CP10 tetap Proposed pending approval; perbedaan feature diberi label source-only, bukan diam-diam dipilih sebagai desain. Revisi integrasi ini hanya mengubah `docs/`; tidak mengubah source, map, produksi atau `.env`.
