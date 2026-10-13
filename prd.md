# AI Obby Adventure - Product Requirements Document (PRD)

## 1. Ringkasan Game
- **Judul**: AI Obby Adventure
- **Target Universe ID**: 10770632072
- **Target Place ID**: 71239438116581
- **Platform**: PC (Desktop) & Mobile
- **Genre**: Obstacle Course (Obby) / Adventure

## 2. Struktur Direktori Proyek
```text
roblox-game/
├── default.project.json           # Rojo project configuration
├── prd.md                         # Dokumen PRD dan spesifikasi fitur
├── .gitignore                     # Proteksi file rahasia (.env, build artifacts)
├── src/
│   ├── shared/                    # ReplicatedStorage (Shared)
│   │   └── GameConfig.luau        # Konfigurasi reward, koin, stage
│   ├── server/                    # ServerScriptService (Backend)
│   │   ├── Main.server.luau       # Entry point server
│   │   └── services/
│   │       ├── LeaderboardService.luau  # State management Stage & Coins
│   │       ├── CheckpointService.luau   # Respawn & progression handler
│   │       └── ObstacleService.luau     # KillBrick collision & traps
│   └── client/                    # StarterPlayerScripts (Frontend)
│       ├── Main.client.luau       # Entry point client
│       └── controllers/
│           └── HUDController.luau # Visual overlay HUD (Stage & Coins)
└── tests/
    └── test_mechanics.py          # Unit test verifikasi logika mechanics
```

## 3. Fitur Utama
1. **Sistem Leaderboard & Stats**:
   - Menampilkan Stage dan Coins pemain di leaderboard global Roblox.
2. **Sistem Checkpoint & Respawn**:
   - Menyimpan posisi terakhir pemain saat menyentuh checkpoint secara berurutan.
   - Respawn otomatis ke checkpoint aktif saat pemain kalah.
3. **Mekanik Rintangan (KillBricks)**:
   - Part rintangan mematikan instan jika bersentuhan dengan pemain.
4. **Custom HUD Client**:
   - Antarmuka HUD bersih di pojok kiri atas yang menampilkan status koin dan stage secara real-time.
