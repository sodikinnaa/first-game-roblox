# Skyward Isles (AI Obby Adventure)

[![Roblox CI](https://github.com/sodikinnaa/first-game-roblox/actions/workflows/ci-roblox.yml/badge.svg)](https://github.com/sodikinnaa/first-game-roblox/actions/workflows/ci-roblox.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

*Skyward Isles* adalah nama usulan untuk prototipe game 3D platformer santai (cozy obstacle course) di platform Roblox yang dibangun secara open source menggunakan Luau, Rojo, dan GitHub Actions CI/CD.

Status: graybox dalam pengembangan. Map dibuat saat server berjalan, bukan baked Workspace. Tes kode/geometry memakai adapter Roblox minimal; tampilan, physics, multiplayer dan kenyamanan PC/mobile masih membutuhkan playtest di Roblox Studio. Persistence dan pickup koin belum tersedia; modul personalisasi summit baru menyediakan konfigurasi netral/banner.

Pemain menjelajahi sepuluh pulau melayang bertingkat di atas awan dengan pijakan ramah pemula dan kontrol nyaman untuk perangkat mobile maupun PC, menuju area puncak selebrasi (Summit).

---

## Fitur Utama

- **10 Pulau Bertema**: Dari Welcome Meadow hingga Special Summit, dengan jarak lompatan aman yang dihitung secara matematis (gap 2.5 hingga 4 studs).
- **Mobile & Beginner Friendly**: Celah platform luas, tidak ada blind-jumps atau trap menghilang tiba-tiba.
- **Sistem Checkpoint & Respawn Teratur**: Respawn otomatis menghadap jalur berikutnya saat pemain terjatuh ke void recovery.
- **No Player-Player Collision**: Tabrakan antarpemain dinonaktifkan agar tidak ada pemain yang saling mendorong keluar jalur saat bermain bersama.
- **Modular Summit Celebration**: Area puncak dirancang netral secara default, dengan opsi personalisasi modular (ucapan, dekorasi) yang terpisah di konfigurasi.
- **Otomatisasi Penuh**: Struktur proyek berbasis file dengan sinkronisasi Rojo dan alur CI/CD GitHub Actions.

---

## Struktur Proyek

```text
roblox-game/
├── default.project.json           # Definisi struktur instance Rojo
├── LICENSE                        # Lisensi MIT
├── README.md                      # Dokumentasi publik proyek
├── prd.md                         # Product Requirements Document (PRD)
├── src/
│   ├── shared/                    # ReplicatedStorage (Shared)
│   │   ├── GameConfig.luau        # Pengaturan game & reward dasar
│   │   ├── StageConfig.luau       # Geometri pulau & checkpoint
│   │   └── SummitConfig.luau      # Konfigurasi modular area puncak
│   ├── server/                    # ServerScriptService (Server)
│   │   ├── Main.server.luau       # Server bootstrap
│   │   └── services/              # Layanan backend (Checkpoint, Map, Summit, dll)
│   └── client/                    # StarterPlayerScripts (Client)
│       ├── Main.client.luau       # Client bootstrap
│       └── controllers/           # Kontroler UI HUD & presentasi selebrasi
└── tests/                         # Suite tes otomatis
```

---

## Prasyarat & Pengembangan Lokal

1. **Rojo 7.7.1**
   Unduh executable Rojo dari [Rojo Releases](https://github.com/rojo-rbx/rojo/releases).

2. **Python (>= 3.10)**
   Digunakan untuk menjalankan unit test mekanik dan verifikasi geometri platform.

### Menjalankan Tes

Pasang Luau 0.742 terlebih dahulu mengikuti [panduan tes](tests/README.md). Tes memerlukan runtime Luau; Python saja tidak cukup.

```bash
python -m unittest discover -s tests -v
```

### Build File Place Roblox (.rbxl)

Untuk mengompilasi kode sumber menjadi file game Roblox yang bisa dibuka di Roblox Studio:

```bash
rojo build default.project.json --output Skyward_Isles.rbxl
```

Buka file `Skyward_Isles.rbxl` menggunakan **Roblox Studio** untuk menguji tampilan visual, fisika, dan gameplay multiplayer secara langsung.

---

## CI/CD & Deploy

Repositori ini dilengkapi alur kerja otomatis via GitHub Actions:
- Setiap *push* atau *pull request* ke branch `main` secara otomatis memvalidasi unit test dan menguji build file `.rbxl`.
- Build dan publish ke Roblox Open Cloud dapat dijalankan secara manual (*workflow_dispatch*) dengan GitHub Environment `roblox`. Environment tidak otomatis mewajibkan approval reviewer. Publish default nonaktif dan akan mengganti isi place tujuan bila diaktifkan.

Untuk fork: buat Environment `roblox` dan secrets `ROBLOX_API_KEY`, `UNIVERSE_ID`, `PLACE_ID` milikmu sendiri. Token GitHub pribadi tidak diperlukan untuk workflow. Jangan commit `.env` atau menyimpan token dalam source/config shared. Lisensi kode tidak memberi hak atas aset pihak ketiga; gunakan aset/audio berizin.

---

## Lisensi

Proyek ini dilisensikan di bawah [Lisensi MIT](LICENSE). Penggunaan personal, edukasi, komersial, modifikasi, distribusi, dan penjualan diizinkan dengan tetap menyertakan copyright dan lisensi.
