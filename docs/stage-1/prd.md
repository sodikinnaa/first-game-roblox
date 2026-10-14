# Stage 1 — Welcome Meadow: PRD Detail

## 1. Identity / Status — Identitas dan Status

**Status: Draft Detailed Design — Critical Decisions Pending; proposal eksperimen graybox tersedia, implementation readiness belum terpenuhi.** **Implementation readiness: BLOCKED BY DECISION.** Dokumen ini hanya menyediakan **proposal eksperimen graybox**, bukan approval balancing, integrasi final, release, atau publish. **Release diblokir** sampai konfigurasi avatar/movement, kesepakatan kontrak boundary dengan Stage 2, dan playtest nyata diselesaikan. Tidak ada blocker tersembunyi yang diasumsikan selesai: dependensi tersebut dinyatakan eksplisit di bagian 13, 16, dan 17.

Stage 1, nama kerja **Welcome Meadow**, memperkenalkan perjalanan cozy pulau langit general untuk pemula PC/mobile. Konsep obby linear general dan **jalur pendakian menanjak** adalah **Approved Design** global; bentuk belokan 90°, posisi relatif, gap, varian spiral, dan balancing di dokumen ini adalah **Proposed / Requires Validation**. Varian pada worktree feature dibaca sebagai konteks rancangan, bukan bukti implementasi di checkout utama. Seluruh angka koordinat, bentuk belokan, tutorial, dan gate kuantitatif di dokumen ini adalah **usulan desain**, bukan keputusan final user. Tidak ada personalisasi, summit FX, monetisasi, atau checkpoint tambahan yang disahkan melalui dokumen ini.

Sumber inspeksi read-only:
- Baseline checkout: `roblox-game/docs/prd.md`, bagian 3–4 dan 6–10.
- Feature worktree `/home/dev/.hermes/cache/scratch/sky-island-map`: `prd.md`, `src/shared/StageConfig.luau`, `GameConfig.luau`, `src/server/services/MapBuilderService.luau`, `CheckpointService.luau`, serta `default.project.json`.
- Checkout utama masih memiliki layanan checkpoint awal; fitur map worktree tidak dianggap sudah tergabung. Dokumen ini tidak mengubah source, map, build, git, konfigurasi produksi, atau visibilitas experience.

## 2. Objective — Tujuan

Pemain memahami berjalan, mengarahkan kamera, mencoba lompat pendek, lalu mengulangi lompatan naik rendah sebelum mendapat zona istirahat dan CP2. Stage harus mengajar tanpa blind jump, deadline, platform bergerak, atau kehilangan koin saat jatuh.

Hasil belajar yang diuji: mengenali target berikutnya, menyiapkan posisi di tengah pijakan, dan menemukan belokan ke pulau tujuan. CP2 adalah hasil progres Stage 1; mencapai CP2 **bukan** finish seluruh game. Durasi sasaran usulan 60–180 detik untuk percobaan pertama pemula; bukan batas waktu dan bukan hasil pengukuran.

## 3. Experience — Pengalaman Pemain

Urutan emosi: aman di meadow → eksperimen kecil A → ritme sederhana B → pelepasan tekanan C → yakin memasuki Cloud Garden. Tutorial usulan singkat: “Arahkan kamera ke pijakan berikutnya”, kemudian “Coba tombol lompat”. PC memakai instruksi tombol yang sesuai binding aktual; mobile memakai ikon kontrol yang tidak menutup joystick/jump.

Rute dapat diselesaikan tanpa pickup. Marker jalur membantu arah, bukan memaksa pemain menepi. Bunga dan batu hias ada di luar koridor; tidak menambah hazard. Tidak ada camera takeover, timer, hukuman ekonomi, atau suara personal. Pengalaman “mudah” masih hipotesis: bidang lebar tidak membuktikan gap/rise nyaman bagi avatar tertentu.

## 4. Entry / Exit — Masuk dan Keluar

Masuk di deck Spawn, pusat lokal `(0,10,0)`, permukaan Y=11, CP1 pada `(0,11.25,-6)` menghadap +Z. Setelah join/respawn, pemain harus berada di area aman dan melihat FirstJump. SpawnLocation usulan bertumpu pada deck, tanpa permukaan kolisi tambahan yang menaikkan Y latihan. Offset root respawn usulan CP center +3.5 Y menghasilkan `(0,14.75,-6)`; ukuran/hip-height avatar harus diuji sebelum menetapkannya final.

Keluar Stage 1 saat server mengesahkan **CP2 di Destination, pulau Stage 2**, pusat deck `(24,22,143.6)`, permukaan Y=23. CP2 center `(24,23.25,143.6)`, ukuran usulan `8×0.5×8`, arah +X provisional untuk kelanjutan Stage 2. Root respawn usulan `(24,26.75,143.6)`. Stage 2 harus menyepakati departure +X atau mengubah orientasi CP2 secara eksplisit; jangan memaksakan posisi Stage 2 dari feature worktree.

Batas kepemilikan: Stage 1 menentukan jalur masuk sampai CP2; Stage 2 menentukan jalur keluar dari pulau Destination. Pulau Destination dan CP2 harus merupakan satu objek bersama, bukan dua deck/checkpoint duplikat.

## 5. Flow — Alur

1. Spawn dan CP1 aktif; pemain bebas berlatih berjalan/kamera di meadow.
2. **A / FirstJump:** tinggalkan tepi Spawn pada Z=12, gap 2, mendarat di FirstJump yang mulai Z=14; kedua permukaan Y=11.
3. **B / six stones:** FirstJump → Stone1 → Stone2 → Stone3 → Stone4 → Stone5 → Stone6 → Rest; tujuh sambungan, masing-masing gap 2.8 dan rise permukaan `12/7 ≈ 1.7143`.
4. **C / relaxing turn:** berhenti di Rest, berjalan ke tengah lalu belok 90° ke +X; Rest dan Destination bersentuhan tanpa gap atau rise. Bukan lompatan diagonal.
5. Sentuh CP2 di tengah Destination; server memvalidasi karakter hidup/posisi/urutan, memperbarui stage menjadi 2 tepat sekali.
6. Jika jatuh sebelum CP2, kembali CP1; setelah CP2 sah, kembali CP2. Tidak ada checkpoint pada FirstJump, stones, atau Rest.

## 6. Blueprint — Blueprint Lokal

Origin lokal O adalah **pusat deck Spawn**, bukan posisi kaki avatar: koordinat relatif `(0,0,0)` diterjemahkan ke tabel dengan anchor Y=10. Tabel memakai koordinat lokal peta ber-anchor `(0,10,0)`. +Y atas; +Z arah segmen A/B; +X arah C. Semua deck axis-aligned dengan yaw 0°, tidak mengikuti yaw marker. Transform dunia usulan `world = anchorWorld + (x, y−10, z)`; anchorWorld awal `(0,10,0)`. Jika seluruh layout diputar, putar semua deck, marker, trigger, dan recovery sebagai satu kesatuan, lalu ukur ulang proyeksi edge, bukan hanya jarak pusat.

Diagram top-down berikut **skematis, bukan skala**, label dan pusat harus mengikuti tabel:

```text
                    +Z (ke atas)
                    ^
          [Rest (0,143.6)] == C: +X, seam == [Destination (24,143.6), CP2 →]
                    ^
          [Stone6 (0,121.8)]
                    ^
          [Stone5 (0,105.0)]
                    ^
          [Stone4 (0,88.2)]       B: semua panah +Z
                    ^             tujuh gap 2.8, rise 12/7 per sambungan
          [Stone3 (0,71.4)]
                    ^
          [Stone2 (0,54.6)]
                    ^
          [Stone1 (0,37.8)]
                    ^
          [FirstJump (0,21)]
                    ^             A: gap 2, rise 0
          [Spawn (0,0), CP1 ↑]
                                            +X →
```

Rest menyediakan ruang berjalan untuk mengganti arah. Tidak ada sambungan Stone6 langsung diagonal ke Destination. Dekorasi tidak membuat shortcut/bridge kolisi tambahan.

## 7. Obstacles — Rintangan

A adalah satu celah pertama berpermukaan setara, target minimal `14×14`. **Gap 2 mungkin dapat dilalui berjalan**, karena ukuran avatar, step behavior, atau autojump; jangan menyebutnya lompatan wajib sebelum pengujian. Uji berjalan tanpa input jump dan tanpa autojump secara terpisah dari autojump aktif. Jika walk-through terjadi, pilih bersama pemilik produk: menerima A sebagai latihan opsional atau merevisi gap/tutorial lalu menguji ulang. Jangan diam-diam membesarkan gap.

B terdiri dari tepat enam batu, lebar/depth baseline 14, tetapi tujuh transisi termasuk masuk batu pertama dan keluar ke Rest. Gap 2.8 dan rise sekitar 1.7 bukan balancing final. C tidak menambah hazard: deck 24 lebar, tanpa celah atau kenaikan, belokan dilakukan di ruang istirahat. Semua rintangan statis/anchored; tidak ada damage pada permukaan pijakan, conveyor, batu runtuh, atau jump yang bergantung pickup.

## 8. Dimensions / Elevations — Dimensi dan Elevasi

Semua unit studs. Posisi adalah **pusat deck**, ukuran `(X,Y,Z)`, tebal 2, top=`centerY+1`. Angka Y desimal dibulatkan untuk baca saja; implementasi usulan menggunakan rumus exact. Gap/rise dihitung dari **platform sebelumnya dalam urutan tabel**, bukan dari CP atau origin. Status semua baris **P = proposed, belum diimplementasikan/disetujui balancing**. K = deck `Anchored=true, CanCollide=true, CanTouch=false`; marker tidak mengubah bidang pendaratan.

| Platform / zona | Pusat (X,Y,Z) | Ukuran (X,Y,Z) | Top Y | Dari / arah | Gap edge | Rise top | Collision | Marker / status |
|---|---|---|---:|---|---:|---:|---|---|
| Spawn / awal A | (0,10,0) | (24,2,24) | 11 | masuk | — | — | K | CP1 + Spawn; P |
| FirstJump / A | (0,10,21) | (14,2,14) | 11 | Spawn / +Z | 2 | 0 | K | panah tengah; bukan CP; P |
| Stone1 / B | (0,11.7143,37.8) | (14,2,14) | 12.7143 | FirstJump / +Z | 2.8 | 12/7 | K | titik jalur; bukan CP; P |
| Stone2 / B | (0,13.4286,54.6) | (14,2,14) | 14.4286 | Stone1 / +Z | 2.8 | 12/7 | K | titik jalur; bukan CP; P |
| Stone3 / B | (0,15.1429,71.4) | (14,2,14) | 16.1429 | Stone2 / +Z | 2.8 | 12/7 | K | titik jalur; bukan CP; P |
| Stone4 / B | (0,16.8571,88.2) | (14,2,14) | 17.8571 | Stone3 / +Z | 2.8 | 12/7 | K | titik jalur; bukan CP; P |
| Stone5 / B | (0,18.5714,105.0) | (14,2,14) | 19.5714 | Stone4 / +Z | 2.8 | 12/7 | K | titik jalur; bukan CP; P |
| Stone6 / B | (0,20.2857,121.8) | (14,2,14) | 21.2857 | Stone5 / +Z | 2.8 | 12/7 | K | titik jalur; bukan CP; P |
| Rest / akhir B, awal C | (0,22,143.6) | (24,2,24) | 23 | Stone6 / +Z | 2.8 | 12/7 | K | panah belok +X; **bukan CP**; P |
| Destination / pulau Stage 2 | (24,22,143.6) | (24,2,24) | 23 | Rest / +X | 0 | 0 | K | CP2; arah +X provisional; P |

Rumus reproduksi: Stone i untuk i=1..6 memiliki `Ycenter=10+12i/7`, `Zcenter=37.8+16.8(i−1)`, X=0. Contoh edge: FirstJump Zmax=28, Stone1 Zmin=30.8, gap=2.8. Stone6 Zmax=128.8, Rest Zmin=131.6, gap=2.8. Rest Xmax=12, Destination Xmin=12, seam=0. Total naik top Spawn→Destination=12; **bukan** 1.7 dari selisih pusat yang kebetulan benar tanpa memeriksa ketebalan.

Margin geometris usulan: FirstJump/stones menyisihkan 2 studs dari tiap sisi untuk koridor tengah `10×10`; Spawn/Rest/Destination menyisihkan 2 menjadi `20×20`. Ini area target desain, bukan jaminan reach atau keamanan avatar. CP1 square 8 berada Z=−10..−2, minimal 2 dari tepi Spawn; CP2 square 8 inset 8 dari tepi Destination. Koridor berbelok di Rest harus tetap bebas dekorasi.

Validasi aritmetika telah dieksekusi dengan Python Fraction di scratch `/home/dev/.hermes/cache/scratch/stage1_layout_validate.py`: **PASS, 10 deck, 9 sambungan, A gap2/rise0, B tujuh gap2.8/rise12/7, C gap0/rise0, total rise12, CP inset≥2**. Semua pasangan nonadjacent diperiksa tidak beririsan footprint. Pemeriksaan ini memvalidasi proposal tabel/urutan diagram, bukan source Luau, Roblox collision/physics, FPS, atau playtest. Skrip scratch bukan file proyek/deliverable implementasi.

## 9. Navigation / Camera — Navigasi dan Kamera

CP1 dan tutorial menghadap +Z; dari tepi Spawn target FirstJump terlihat. Panah/titik berada di pusat deck, bukan dekat tepi. Rest memiliki panah siku +X dengan label “Cloud Garden”; CP2 terlihat dari tengah Rest. Penanda boleh berupa decal/part tipis noncolliding, tidak wajib koin; koin ekonomi belum final.

Kamera default tetap dikendalikan pemain. Saat respawn pertahankan orientasi checkpoint, bukan hardcode +Z. Feature `CheckpointService` yang dibaca mengembalikan arah +Z hardcoded meski builder memberi arah jalur; ini **risiko integrasi diketahui**, bukan sudah diperbaiki. CP2 +X wajib diuji. Uji target terlihat setelah kamera default, zoom min/max yang diizinkan, dan saat touch drag; jangan membuat auto-rotation/cutscene sebagai solusi tanpa persetujuan. HUD/tutorial tidak menutup area aman controls.

## 10. Visuals — Visual

Spawn meadow hijau pastel, bunga kecil di perimeter, batu putih pucat pada B, Rest hijau netral, Destination memperkenalkan Cloud Garden. Tepi landing harus terbaca terhadap awan/sky; jangan menyamarkan gap dengan kabut padat atau menjadikan warna satu-satunya petunjuk. Marker bentuk panah dan tulisan singkat tetap ada pada graybox.

Visual pagar perimeter merupakan petunjuk, bukan klaim mencegah jatuh. Jangan memasang pagar kolisi pada departure/landing yang mengubah latihan atau seam C. Rock silhouette di bawah deck dan vegetasi noncolliding tidak boleh menutup target/kamera. Tidak ada FX summit/personal di Stage 1. Budget dekorasi/performa menunggu device target; mulai dengan primitive, tanpa menjanjikan low-poly otomatis ringan.

## 11. Checkpoint — Checkpoint dan Progres

CP1 aktif saat join awal; CP2 hanya aktif pada Destination sebagai **exit Stage 1 / entry Stage 2**. Tidak ada CP tambahan di Rest atau stones. Baseline menyebut checkpoint istirahat tambahan sebagai kemungkinan general; dokumen ini tidak mengaktifkannya tanpa approval. Jika gagal B berulang, revisi layout/tutorial dahulu; usulan checkpoint baru harus dibahas terpisah.

Trigger usulan CP1/CP2 `CanCollide=false, CanTouch=true`, anchored, ukuran dan pusat di bagian 4. Dekorasi marker terpisah `CanTouch=false`. Server memeriksa identitas karakter aktif, health >0, posisi dalam zona, serta urutan CP1→CP2; sentuhan/client request saja bukan bukti sah. Touch berulang tidak memberi progres/reward kedua. Reward 25/1 pada source adalah nilai awal, bukan persetujuan ekonomi. Respawn CP2 harus mempertahankan yaw +X sesuai handoff final Stage 2. Tidak ada persistence lintas sesi yang diasumsikan.

## 12. Failure — Kegagalan dan Pemulihan

Jatuh sebelum CP2 memulihkan CP1 tanpa menghapus progres sah; setelah CP2 pulihkan CP2. Jangan memberi CP2 karena pemain melewati bawah pulau atau tersentuh dekorasi. Kematian ketika menyentuh trigger harus ditolak. Pemain dapat berhenti di Rest tanpa timer.

Recovery graybox usulan dua volume noncolliding, invisible, `CanTouch=true`: R1 pusat `(0,−5,65.8)`, ukuran `(40,4,171.6)` mencakup X −20..20, Z −20..151.6; R2 pusat `(24,−5,143.6)`, ukuran `(40,4,40)` mencakup pulau tujuan. Top volume Y=−3 berada di bawah semua deck; overlap ditangani idempoten dan tidak mengubah checkpoint. Volume adalah usulan awal, **bukan** bukti pemulihan cepat; bila durasi jatuh terlalu panjang, rancang tier lokal dan uji tanpa mengenai avatar di deck/silhouette. Uji reset manual, mati bersamaan touch CP, dua pemain overlap, dan tidak ada loop spawn mati. Trigger hilang/belum bound adalah blocker runtime, bukan alasan memberi progres gratis.

## 13. Dependencies — Dependensi dan Kontrak Teknis

Feature StageConfig menetapkan Spawn `(0,10,0)`, Stage 2 `(33.0253,22,123.2521)`, deck tebal 2, enam batu lebar 14. Builder membagi rise 12/7 di enam batu dan sambungan tujuan. **Menambahkan FirstJump dan Rest mengubah koneksi baseline enam batu**: layout baru mempertahankan enam batu sebagai B, menambah A, memindahkan kenaikan terakhir ke Rest, serta menyambung C datar. Stage 2 baru `(24,22,143.6)` adalah proposal anchor handoff; tidak dipaksa ke posisi lama. Stage 2 dan stage berikutnya perlu re-layout/transform yang disepakati, bukan auto-lerp lama.

Builder feature mengorientasikan stones ke arah diagonal serta memakai `size.Z/2` sebagai edge pulau; untuk deck axis-aligned diagonal proyeksi edge harus dihitung dari geometri sebenarnya. Proposal ini sengaja memakai +Z lalu +X dan yaw deck 0 agar tabel tidak mewarisi ambiguitas projected edges. Generic builder lama tidak diasumsikan dapat menghasilkan FirstJump/Rest tanpa perubahan implementasi terpisah.

Konfigurasi movement **tidak ditemukan ditetapkan** pada feature `src`/`default.project.json` dan pencarian source utama; ini tidak membuktikan nilai place/runtime. Sebelum menguji, baca dan catat runtime `Humanoid.RigType` (target uji R15), WalkSpeed, UseJumpPower, JumpPower, JumpHeight, Workspace.Gravity, body scale, HipHeight, collision footprint, dan AutoJumpEnabled. Nilai harus disepakati sebelum balancing final. Profil uji kandidat, **bukan approved defaults**: R15 scale 1, WalkSpeed=16, Gravity=196.2; mode P UseJumpPower=true/JumpPower=50; mode H UseJumpPower=false/JumpHeight=7.2. Catat kedua properti lompat tetapi hanya yang aktif memengaruhi hasil. Jangan memakai nilai kandidat sebagai klaim runtime existing. Avatar variasi ukuran mengikuti daftar scale yang disetujui; sebelum daftar tersedia lakukan exploratory kecil/besar dan tandai tidak memenuhi gate avatar final.

Urutan integrasi: bangun geometry → pasang/validasi CP dan recovery → bind layanan → spawn pemain. Rebuild memerlukan rebind listener. Integrasi collision antarpemain dan HUD diperlukan; persistence, pickup reward, dan upload aset tidak menghalangi graybox tetapi tidak boleh dianggap tersedia.

## 14. Assets — Aset dan Lisensi

Graybox menggunakan primitive/decal orisinal; tidak bergantung asset ID. Arsip Kenney tersedia lokal pada `roblox-game/assets/raw/kenney_nature-kit.zip` (ditemukan read-only), sumber referensi `https://kenney.nl/assets/nature-kit`, lisensi sumber **CC0**, terpisah dari lisensi source proyek **MIT**. Kandidat Stage 1: bunga kecil, semak, rock silhouette; pemilihan model, scale, pivot, triangle/material budget, dan verifikasi berkas lisensi arsip tetap tugas asset owner sebelum integrasi.

Keberadaan zip bukan bukti aset sudah diimport, moderasi selesai, asset ownership benar, atau dapat dimuat Roblox. Tidak ada upload/network Roblox atau asset ID yang dibuat oleh dokumen ini. Referensi Quaternius dari PRD feature bukan dependensi wajib Stage 1 dan status unduh/import tidak diasumsikan. Semua vegetasi dekoratif noncolliding/non-touch; collidable gameplay deck tetap primitive dengan dimensi tabel, bukan mesh visual yang mengubah gap.

## 15. Acceptance — Kriteria Penerimaan

Semua Then berikut **gate usulan, belum hasil lulus**. Toleransi geometry angka usulan ±0.01 studs; physics/movement memakai profil final, bukan asumsi reach analitis.

| ID | Given / When / Then |
|---|---|
| S1-01 | Given graybox proposal terpasang, When ukuran/posisi/top diinspeksi, Then 10 deck dan 9 link sesuai tabel ±0.01; enam Stone tidak hilang/bertambah; A gap2 rise0, B gap2.8 rise12/7, C seam0 rise0. |
| S1-02 | Given CP1 aktif dan karakter hidup, When 10 join/respawn dijalankan, Then 10/10 berada di Spawn, menghadap +Z, tidak mati/tersangkut otomatis dalam 5 detik tanpa input. |
| S1-03 | Given CP1 aktif, When pemain menyentuh Rest/FirstJump/keenam stones, Then stage tetap1 pada seluruh 8 lokasi; tidak ada checkpoint intermediate. |
| S1-04 | Given pemain hidup CP1→Destination, When CP2 disentuh 10 kali, Then stage2 dicatat satu kali, reward jika diaktifkan satu kali; CP2 bukan Completed seluruh game. |
| S1-05 | Given CP2 aktif, When 10 respawn diuji, Then 10/10 di Destination menghadap departure Stage2 final (+X provisional), offset root diuji bebas deck/void dan tidak hardcode +Z. |
| S1-06 | Given karakter mati/tidak sah/di luar zona CP2, When 10 percobaan aktivasi masing-masing dilakukan, Then 0 aktivasi CP2; request client tidak menggantikan pemeriksaan server. |
| S1-07 | Given fall pada tiap link sebelum CP2 dan setelah CP2, When recovery bekerja, Then 10/10 per kondisi kembali CP terakhir, tanpa rollback/reward duplikat; target kontrol pulih ≤5 detik dari kehilangan pijakan pada ≥95% sampel. |
| S1-08 | Given dua pemain, When berpapasan/overlap 20 kali di stones dan CP, Then 0 dorongan karena kolisi antarpemain; tiap progres tetap independen. |
| S1-09 | Given kamera/control default PC dan touch, When berhenti sebelum tiap link dan di Rest, Then tester dapat mengidentifikasi target berikutnya pada 9/9 link tanpa occlusion dekorasi atau camera takeover; C dapat dilewati berjalan tanpa jump. |
| S1-10 | Given tutorial A menjanjikan lompat, When no-jump/autojump matrix diuji, Then hasil traversal dilabel sesuai perilaku nyata; jika walk-through sukses, teks “wajib lompat” tidak dirilis sebelum keputusan revisi. |

## 16. Playtests — Rencana Pengujian

**Belum ada playtest Roblox/Studio yang dijalankan untuk proposal ini.** Hasil aritmetika bukan pengganti gate berikut. Proposal graybox dapat direview sebagai eksperimen, tetapi eksekusi/integrasi memerlukan otorisasi dan penyelesaian keputusan kritis dengan profil eksplisit; release tetap diblokir sampai profil produksi dipilih dan gate PC/mobile terpenuhi.

| Matriks wajib | Sampel / pencatatan | Gate usulan |
|---|---|---|
| Runtime existing (read first) | PC dan mobile: rig, scale/footprint, speed, kedua jump properties + mode aktif, gravity, autojump, FPS, device/OS, camera zoom | Nilai aktual tercatat sebelum menginterpretasi reach; bila berbeda dari profil kandidat, uji sebagai sel tersendiri. |
| Kandidat P dan H | R15 scale1, 16 speed,196.2 gravity; P=power50 vs H=height7.2; PC keyboard dan physical mobile touch untuk kedua mode | Masing-masing link B 20 percobaan per sel; ≥18/20 landing berhasil pada koridor target tengah. Exploratory sebelum final avatar approval. |
| A tanpa jump / autojump off | Kedua profil, PC/mobile; 20 traversal per sel, input jump tidak dipakai, catat event jump runtime | Catat jumlah berjalan sukses, jatuh, jump otomatis yang tak diharapkan; **tidak** menetapkan harus gagal sebagai fakta. Walk-through memicu keputusan tutorial/layout. |
| A tanpa manual jump / autojump on | Mobile physical tiap profil, 20 traversal; pisahkan autojump dari berjalan | Laporkan sukses karena autojump terpisah; tidak dihitung bukti pemain belajar tombol jump. |
| A manual jump | Autojump off; 20 percobaan per sel PC/mobile | ≥18/20 berhasil untuk profil terpilih; catat overshoot dan titik landing, bukan hanya touch marker. |
| Avatar production terpilih | R15 seluruh scale/footprint yang diizinkan, properti movement final, PC dan mobile target | Ulang seluruh 9 link dan CP; revisi geometry bila ada sel final gagal. R6 bukan fallback diam-diam. |
| Pemula end-to-end | 10 peserta pemula, minimal 5 touch dan 5 PC, satu percobaan pertama tanpa bantuan verbal | ≥8/10 mencapai CP2 dalam ≤180 detik dengan ≤3 jatuh; per platform minimal4/5. Sasaran non-punitive, bukan timer gameplay. |
| Rest/C + navigasi | 10 peserta sama; catat arah salah, jump yang disangka wajib, target tersembunyi | ≥9/10 menemukan CP2 dari Rest dalam ≤20 detik tanpa instruksi verbal; 0 celah tersembunyi C. |
| Performa/control | Physical mobile target disepakati, 3 run ×180 detik, 2 pemain, HUD/dekorasi kandidat | ≥30 FPS pada ≥95% sampel, 0 overlap HUD menutup joystick/jump; device/FPS logger dicatat. Belum ada jaminan performance. |

Catat per link start/landing, jumlah attempt/fall, waktu recovery, root/foot contact, jalur bypass, dan video bila diizinkan. Pisahkan latihan tester berpengalaman dari pemula. Jika B terlalu sulit, ubah gap/rise atau tambah landing dengan persetujuan; jangan mempertahankan enam batu demi angka sambil melanggar batas rise. Ulang validasi matematika dan gate terkait setiap revisi.

## 17. Risks / Open — Risiko dan Keputusan Terbuka

- **Release blocker:** profil R15/scale, WalkSpeed, UseJumpPower, JumpPower/JumpHeight dan Gravity belum disepakati/dibaca runtime; kandidat bukan defaults. Pemilik gameplay harus mengunci profil setelah exploratory matrix.
- **Integrasi Stage 2:** anchor Destination dan arah +X provisional wajib disepakati dengan pemilik Stage 2. Posisi Stage 2 lama tidak kompatibel otomatis setelah FirstJump/Rest; handoff graybox lokal tetap dapat diuji terisolasi.
- **A bisa walkable:** 2 studs mungkin bukan skill check lompat; keputusan menerima tutorial optional atau revisi belum final. Autojump mobile dapat menyembunyikan masalah ini.
- **B akumulasi kegagalan:** enam stones tanpa CP tengah berarti tujuh link naik; gate pemula menguji fatigue/restart, bukan asumsi “lebar pasti nyaman”. Tidak ada approval CP intermediate.
- **Respawn yaw:** feature checkpoint +Z hardcoded tidak cocok CP2 +X; wajib diperbaiki/diuji oleh implementer dalam scope implementasi terpisah sebelum integrasi lulus.
- **Recovery:** volume awal jauh di bawah deck tinggi; target ≤5 detik belum terbukti. Tiering boleh dirancang ulang tanpa mengaktifkan CP lain ketika jatuh.
- **Collision seam:** Rest→Destination terhubung numerik, tetapi Roblox contact di seam dan avatar besar tetap perlu uji. Dekorasi/Spawn pad tidak boleh menambah elevasi nyata tersembunyi.
- **Performa/assets:** physical device minimum, daftar avatar, budget dekorasi, dan kepastian izin asset belum final. Zip tersedia bukan izin upload/publish.
- **Ekonomi/persistence:** nominal source awal, pickup, dan save lintas sesi belum approved; jangan memakainya sebagai kriteria finish Stage 1.

## 18. Handoff — Serah Terima

Deliverable hanya dokumen ini. Implementer menerima proposal urutan 10 deck, tabel exact-formula, diagram axis-aligned, CP1/CP2, recovery usulan, serta daftar gate belum dijalankan. Tidak ada map/source/build baru yang diklaim; scratch Python hanya menguji matematika desain.

Urutan kerja implementasi selanjutnya (memerlukan otorisasi terpisah): (1) sepakati anchor/arah CP2 dengan Stage 2; (2) baca runtime avatar/movement dan pilih profil eksplorasi eksplisit; (3) graybox lokal dengan A/B/C dan tanpa intermediate checkpoint; (4) uji geometri/collision/trigger/respawn yaw runtime; (5) playtest PC dan physical touch, revisi gate yang gagal; (6) kunci konfigurasi final dan catat bukti; (7) baru pertimbangkan art/performa/release dengan persetujuan yang terpisah.

Pemilik implementasi harus mengembalikan tabel actual-vs-proposed, profil avatar/movement, log gate Given/When/Then, daftar gagal/open, dan keputusan CP2. Handoff saat ini **proposal dokumentasi; BLOCKED BY DECISION (movement, boundary CP2, CP global dan validasi fungsi first gap), pending playtest**, bukan tanda semua risiko lulus. Tidak ada akses jaringan Roblox, asset upload, perubahan visibility, atau izin publish melalui PRD ini.
