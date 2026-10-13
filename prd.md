# Sky Island Adventure - Product Requirements Document (PRD)

Status: draft desain berdasarkan diskusi user dan rekomendasi Codex. Disetujui: konsep linear obby pulau langit, game general, personalisasi hanya di summit dan ditentukan user nanti. Nama final, angka balancing, persistence, ekonomi, dan fitur tambahan masih usulan. Dokumen ini bukan izin implementasi atau publish.

## 1. Ringkasan Game
- **Judul Game**: Sky Island Adventure (AI Obby Adventure)
- **Target Universe ID**: 10770632072
- **Target Place ID**: 71239438116581
- **Platform Utama**: Mobile (Touch Controls) & PC (Keyboard/Mouse)
- **Genre**: Cozy 3D Platformer / Obstacle Course (Obby)
- **Target Audiens & Vibe**: Pemula-friendly, santai, estetika pulau langit cerah, minim stres/frustrasi.
- **Tujuan Khusus**: Game general yang dapat diadaptasi menjadi momen spesial/hadiah personal di area puncak (Stage 10 Summit) melalui konfigurasi modular terpisah. Visibilitas publik/private diputuskan terpisah; saat inspeksi sebelumnya experience berstatus PRIVATE.

---

## 2. Struktur Direktori & Arsitektur Proyek (Rojo)
Struktur berikut adalah target arsitektur. SummitConfig, SummitService, dan SummitController belum diimplementasikan. Saat ini repo berisi kerangka leaderboard dalam server (bukan leaderboard global), checkpoint, KillBrick, HUD, dan tes simulasi Python; belum ada peta atau persistence. Build Rojo berhasil tidak membuktikan gameplay berjalan.
```text
roblox-game/
├── default.project.json
├── prd.md
├── .gitignore
├── .github/workflows/ci-roblox.yml
├── src/
│   ├── shared/
│   │   ├── GameConfig.luau
│   │   └── SummitConfig.luau
│   ├── server/
│   │   ├── Main.server.luau
│   │   └── services/
│   │       ├── LeaderboardService.luau
│   │       ├── CheckpointService.luau
│   │       ├── ObstacleService.luau
│   │       └── SummitService.luau
│   └── client/
│       ├── Main.client.luau
│       └── controllers/
│           ├── HUDController.luau
│           └── SummitController.luau
└── tests/
    └── test_mechanics.py
```

---

## 3. Rincian 10 Stage (Sky Islands Journey)
Setiap stage dirancang bertingkat dengan pulau aman (*resting zone*), koin penunjuk arah, dan tanpa lompatan buta (*blind jumps*).

| Stage | Nama Pulau / Tema | Karakteristik Jalur & Mekanik | Checkpoint & Safe Zone |
|:---:|---|---|---|
| **1** | **Welcome Meadow** | Padang rumput & bunga. Pengenalan jalan, lompat dasar, kamera. Pijakan ekstra lebar (14x14+ studs). | Spawn awal & akhir pulau |
| **2** | **Cloud Garden** | Taman pulau melayang. Lompatan pendek berurutan (gap 2-3 studs) dengan target terlihat jelas. | Checkpoint 2 |
| **3** | **Breeze Bridge** | Jembatan kayu gantung warna hangat. Latihan berjalan lurus dan melompat celah tunggal. | Checkpoint 3 |
| **4** | **Terrace Grove** | Pulau bertingkat dengan elevasi rendah (+1 s.d. +2 studs). Pendaratan lebar. | Checkpoint 4 |
| **5** | **Pond Islands** | Kolam air dekoratif & batu loncatan berbelok. Koin ditempatkan di tengah batu sebagai penuntun jalur. | Checkpoint 5 |
| **6** | **Cloud Steps** | Serangkaian 3-4 pijakan awan empuk diselingi pulau istirahat kecil. | Checkpoint 6 |
| **7** | **Sky Orchard** | Kebun buah terapung. Kombinasi belokan ringan dan kenaikan bertahap. | Checkpoint 7 |
| **8** | **Sunset Walk** | Cahaya senja hangat. Jalur sedikit lebih panjang menggabungkan variasi pijakan stage sebelumnya. | Checkpoint 8 |
| **9** | **Summit Approach** | Tanjakan lebar menuju gerbang puncak. Jalur kembali melebar untuk transisi tenang. | Checkpoint 9 |
| **10** | **Special Summit** | Plaza puncak luas (minimal 48x48 studs). Area selebrasi, istirahat, dan panorama tanpa bahaya jatuh. | Summit Finish Zone |

---

## 4. Standar Dimensi, Collision & Mobile Accessibility
- **Ukuran Pijakan**:
  - Pulau Checkpoint / Istirahat: Minimal area datar 20 x 20 studs (tepi aman berpagar visual).
  - Pijakan Stage 1–3: Minimal 12 x 12 studs.
  - Pijakan Stage 4–9: Minimal 10 x 10 studs.
  - Lebar Jembatan: Minimal 8–10 studs.
- **Toleransi Lompatan** (baseline prototipe, wajib divalidasi PC/mobile dengan profil avatar final):
  - Celah Horizontal Stage 1–3: 2–3 studs (tepi ke tepi).
  - Celah Horizontal Stage 4–9: 3–5 studs; target maksimum 60% jangkauan lompat yang konsisten dicapai pemula di perangkat sentuh, bukan lompatan terbaik developer.
  - Elevasi Vertikal: 0–2 studs. Tidak menggabungkan celah horizontal maksimum dengan elevasi vertikal tinggi.
- **Aturan Collision**:
  - Kolisi antarpemain dimatikan (*No Player-Player Collision*) agar pemain tidak saling dorong saat bermain bersama.
  - Part dekorasi (daun, bunga, balon, lentera) berstatus `CanCollide = false`.
  - Fall Recovery Zone: Void boundary dipasang tepat di bawah jalur agar pemain yang jatuh langsung respawn tanpa menunggu lama.

---

## 5. Arsitektur Summit Celebration System
Area Stage 10 (Summit) dirancang netral secara default, dengan opsi personalisasi modular yang dikendalikan melalui `src/shared/SummitConfig.luau`.

### A. Alur Validasi & Presentasi
1. Karakter pemain menyentuh `SummitFinishZone`.
2. `SummitService` (Server) memvalidasi keabsahan urutan checkpoint dan status hidup karakter.
3. Server mencatat penyelesaian stage 10 secara idempoten (mencegah duplikasi).
4. Server mengirimkan sinyal hanya ke pemain terkait via `RemoteEvent:FireClient`.
5. `SummitController` (Client) memicu selebrasi lokal (banner, FX, audio) hanya pada layar pemain tersebut tanpa mengganggu pemain lain.

### B. Kontrak Konfigurasi Modular (`SummitConfig.luau`)
```luau
local SummitConfig = {
    SchemaVersion = 1,
    PresetId = "Neutral", -- "Neutral" (Default) | "Birthday" | "Custom"

    Core = {
        Enabled = true,
        BannerTitle = "Puncak Tercapai!",
        BannerSubtitle = "Selamat! Kamu telah menaklukkan seluruh pulau langit.",
        BannerDurationSeconds = 5,
        FinishZoneName = "SummitFinishZone",
    },

    Personalization = {
        DisplayName = "",            -- Diisi nanti sesuai pilihan user
        CustomMessage = "",          -- Ucapan / pesan khusus
        Cake = {
            Enabled = false,         -- True jika memunculkan kue di anchor
            AnchorId = "CakeAnchor",
        },
        Decorations = {
            Enabled = false,
            AnchorId = "DecorationAnchor",
        },
        Confetti = {
            Enabled = false,
            DurationSeconds = 4,
            MaxLiveParticles = 80,
        },
        Fireworks = {
            Enabled = false,
            DurationSeconds = 5,
            AnchorId = "FireworksAnchor",
        },
        Audio = {
            Enabled = false,
            SoundId = "",
            Volume = 0.5,
        },
        Camera = {
            Enabled = false,
            DurationSeconds = 5,
            AllowSkip = true,
        },
    },

    Accessibility = {
        RespectReducedMotion = true,
        RespectAudioMute = true,
    },

    Replay = {
        Enabled = true,
        CooldownSeconds = 10,
        GrantRewards = false,
    },
}

return SummitConfig
```

---

## 6. Acceptance Criteria (Kriteria Keberterimaan)
- **AC-01 (Progression Order)**: Pemain hanya dapat mengaktifkan checkpoint n+1 jika checkpoint n sudah aktif.
- **AC-02 (Respawn Reliability)**: Saat karakter mati/jatuh, respawn terjadi di checkpoint aktif dengan posisi menghadap jalur berikutnya (offset Y +3.5).
- **AC-03 (Idempotent Reward)**: Sentuhan berulang atau respawn pada checkpoint/summit tidak melipatgandakan reward koin.
- **AC-04 (No Collision Griefing)**: Pemain tidak dapat saling mendorong keluar jalur saat bermain multiplayer.
- **AC-05 (Mobile-Friendly Platforming)**: Seluruh gap stage 1–9 dapat dilompati dengan konsisten menggunakan kontrol virtual joystick & tombol lompat mobile.
- **AC-06 (Per-Player Celebration)**: Event selebrasi di summit hanya terlihat dan terdengar oleh pemain yang menyelesaikannya.
- **AC-07 (Replay Presentation)**: Fitur replay di summit memutar ulang selebrasi visual tanpa menambah reward koin.
- **AC-08 (Configuration-Only Customization)**: Mengganti teks banner, nama ucapan, atau toggle dekorasi di `SummitConfig.luau` tidak membutuhkan perubahan layanan progres/finish. Perubahan tetap memerlukan build/publish; live editing tanpa publish tidak termasuk scope.

## 7. Alur Pemain dan Aturan Progres
Masuk → spawn/checkpoint → lewati jalur pulau → kumpulkan koin opsional → checkpoint berikutnya → summit → banner netral → nikmati panorama. Jatuh kembali ke checkpoint terakhir tanpa menghapus progres atau koin yang sudah sah.

- Stage 1–9 menjadi perjalanan; stage 10 adalah plaza finish, bukan rintangan kesepuluh. Stage aktif dan status Completed dipisahkan; mencapai checkpoint terakhir belum otomatis selesai.
- Checkpoint utama memiliki urutan stabil; checkpoint istirahat tambahan memakai ID terpisah dan tidak menggandakan reward stage.
- Rancangan dasar tidak mewajibkan timer, platform bergerak/runtuh, blind jump, atau hukuman kehilangan koin. Mekanik menantang dari konsep awal bukan persyaratan MVP cozy.
- Koin menunjukkan jalur aman; mengumpulkan semuanya bukan syarat finish. Nilai reward dan kebijakan reset pickup belum disetujui. Nilai 25/1 pada kode lama adalah konfigurasi awal, bukan keputusan ekonomi final.
- Core summit: plaza aman, validasi server, catatan selesai, banner netral. Kue, ucapan personal, dekorasi, musik, konfeti, kembang api, dan kamera hanyalah opsi nonaktif sampai dipilih user.

## 8. Kontrak Sistem, Keamanan, dan Kegagalan
- Server memeriksa karakter hidup, posisi dalam zona, urutan checkpoint, dan riwayat progres; request client atau Touched saja tidak cukup untuk mengesahkan finish.
- Finish dan reward dideduplikasi berdasarkan identitas pemain dan event progres stabil; retry tidak membuat identitas reward baru. Replay hanya presentasi, memiliki cooldown, dan membersihkan efek sebelumnya.
- SummitConfig memakai validator versi, batas durasi/volume/partikel, asset allowlist, dan anchor. Asset/anchor hilang menonaktifkan modul terkait, bukan membatalkan finish; banner netral tetap tersedia.
- Modul efek memiliki Start/Stop dan cleanup koneksi/objek. Dekorasi personal serta audio/kamera dikendalikan lokal; dekorasi dunia bersama hanya netral.
- Jika kamera diaktifkan, tombol Lewati tersedia sejak awal; kamera/kontrol dipulihkan pada selesai, skip, mati, respawn, atau kegagalan. Reduced motion memakai banner statis; mute menghentikan audio aktif.
- Teks konfigurasi shared dapat dilihat client, bukan tempat menyimpan rahasia. Input pesan bebas oleh pemain tidak termasuk scope; bila ditambahkan, filtering/moderasi Roblox wajib dirancang.

Persistence direkomendasikan, tetapi menunggu persetujuan scope: profil per UserId dengan SchemaVersion, checkpoint/stage, Completed, Coins, dan penanda reward. Load gagal harus retry/menahan progres, tidak menimpa data lama dengan default. Jika diadopsi, gunakan UpdateAsync, penguncian sesi, retry terbatas, autosave data berubah, PlayerRemoving dan BindToClose. Uji menggunakan data development terpisah. Timer/personal best hanya ditambahkan bila disetujui.

## 9. Skenario Penerimaan Tambahan
| ID | Given / When / Then |
|---|---|
| AC-09 | Given pemain belum melewati checkpoint wajib, when memasuki summit atau mengirim request finish, then server menolak penyelesaian. |
| AC-10 | Given dua pemain bermain, when A mencapai summit, then kamera, banner personal, audio dan efek B tidak berubah. |
| AC-11 | Given kamera aktif, when skip/mati/respawn atau asset gagal, then kontrol dan kamera dipulihkan dan objek sementara dibersihkan. |
| AC-12 | Given reduced motion atau mute aktif, when presentasi dijalankan, then efek gerak dinonaktifkan atau audio tidak diputar/dihentikan. |
| AC-13 | Given modul opsional/anchor tidak valid, when finish sah, then Completed tetap tercatat dan banner netral muncul. |
| AC-14 | Given finish sudah tercatat, when sentuhan/replay diulang, then catatan dan reward tidak berulang serta efek tidak menumpuk. |
| AC-15 | Given persistence disetujui dan load gagal, when pemain join, then data lama tidak ditimpa; setelah retry berhasil progres dipulihkan. |

Target playtest usulan: 8 dari 10 pemain pemula dapat mencapai summit tanpa bantuan verbal; minimal 30 FPS pada perangkat mobile target yang kelak disepakati. Dimensi, spawn, safe area HUD, dan seluruh lompatan harus diuji nyata; tes Python tidak memenuhi penerimaan runtime Luau/Studio.

## 10. Milestone dan Keputusan Tertunda
1. Konfirmasi desain: nama final, avatar/movement, durasi perjalanan, checkpoint tambahan, persistence, koin/reward, perangkat minimum, visibilitas.
2. MVP general: graybox 9 stage + summit netral, progres/respawn, HUD, validasi finish; koin/persistence sesuai keputusan yang disetujui.
3. Polishing: visual pulau, aksesibilitas, multiplayer dan playtest mobile; modul personalisasi hanya yang dipilih user.
4. Release readiness: build reproducible, tes runtime dan kegagalan, pemeriksaan asset/audio berizin; publish hanya dengan otorisasi eksplisit.

Di luar scope saat ini: monetisasi/toko, leaderboard global, live editor summit, AI generatif saat bermain, serta personalisasi ulang tahun aktif. Dokumentasi ini tidak mengubah kode, visibilitas experience, atau konfigurasi produksi.
