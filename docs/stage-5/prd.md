# Stage 5 — Pond Islands PRD

## 1. Identity / Status

**Stage 5 — Pond Islands**

**Status: Draft — Pending Detailed Design Review**

[Global PRD](../prd.md) · [Previous: Stage 4](../stage-4/prd.md) · [Next: Stage 6](../stage-6/prd.md)

Dokumen desain/QA, bukan izin implementasi, build atau publish. Nama dan detail balancing belum final. Sumber dibaca: global `docs/prd.md` dan baseline feature `/home/dev/.hermes/cache/scratch/sky-island-map/prd.md`; detail source feature tidak menyatakan kesiapan main. Keputusan user terbaru mengatasi baseline lama hanya pada ascent dan appearance summit.

## 2. Objective

Batu loncatan yang mengubah arah di sekitar kolam dekoratif.

## 3. Experience

Pemain berhenti di batu, membaca belokan, lalu mengatur arah baru dengan nyaman.

## 4. Entry / Exit

Proposed convention: CP_5 berada pada entry island 5; Stage 5 adalah perjalanan menuju CP_6 pada entry island 6. Aktivasi tujuan mengakhiri perjalanan stage ini, bukan entry CP_5.

## 5. Flow

Entry kolam → batu pertama → jeda dan arahkan ulang → batu di tikungan → rangkaian menuju island 6.

## 6. Blueprint

Batu solid dengan landing lebar mengikuti jalur berbelok; kolam adalah konteks visual, bukan shortcut atau mekanik berenang.

## 7. Obstacles

Turning stones statis. Tidak ada batu licin, dorongan air, batu tenggelam, atau kewajiban memungut koin agar jalur terbuka.

## 8. Dimensions / Elevations

Koordinat X/Z, footprint, gap, slope, jumlah pijakan, spawn offset, collision clearance dan balancing final: **TBD — Requires Design Review**. Ukur gap dari tepi ke tepi dan rise dari top surface ke top surface, bukan selisih pusat.

Historical **Proposed** target island 5: Y=70 studs dari PRD feature read-only. Baseline PRD tidak mendefinisikan apakah Y pusat atau permukaan; snapshot StageConfig feature menggunakannya sebagai pusat dek setebal 2 studs, sehingga top surface historis Y=71. Ini bukan elevasi final atau koordinat yang disetujui. Selisih antarpulau bukan tinggi satu lompatan.

Historical **Proposed** baseline: safe island 20×20; landing 12×12 untuk Stage 1–3 dan 10×10 untuk Stage 4–9; bridge 8–10 studs. Gap 2–3 (Stage 1–3) atau 3–5 studs (Stage 4–9), rise 0–2 studs per langkah. Tidak menggabungkan batas gap dan rise; semua angka tunduk pada profil movement/avatar dan playtest touch.

## 9. Navigation / Camera

Tikungan harus terbaca dari batu sebelum belok; panah/landmark netral mencukupi tanpa collectible. Kamera tidak otomatis memutar karakter saat landing.

## 10. Visual

Air dekoratif dipisahkan jelas dari batu solid. Refleksi/transparansi tidak boleh membuat landing terlihat seperti air atau awan.

## 11. Checkpoint

CP_5 adalah kandidat checkpoint recovery aktif saat entry sah; CP_6 hanya sah setelah urutan wajib dipenuhi. Server memeriksa karakter hidup dan keberadaan dalam zona, bukan Touched/client request saja. Rest landing bukan checkpoint baru tanpa review.

## 12. Failure

Salah arah ke air/void pulih ke CP_5; perilaku recovery area air harus ditetapkan konsisten sebelum uji. Area dekoratif tidak menjadi checkpoint.

## 13. Technical Dependencies

Kontrak yang perlu diverifikasi bersama pemilik teknis: StageConfig/MapBuilderService untuk geometri dan orientasi, CheckpointService untuk urutan/recovery, ObstacleService untuk fall recovery, PlayerCollisionService untuk tidak saling mendorong, HUDController untuk informasi progres. Geometri harus tersedia sebelum listener checkpoint/recovery mengikat; rebuild tidak boleh meninggalkan listener pada objek lama.

Movement/avatar, WalkSpeed, gravity, JumpHeight/JumpPower, ukuran collision, perangkat target dan respawn heading perlu dikonfirmasi. Economy, nilai reward, implementasi coin pickup dan persistence belum disetujui; tidak ada requirement implementasi baru untuk itu. Jangan menjanjikan resume lintas sesi. Snapshot feature lebih lanjut daripada main; keberadaan source bukan bukti runtime.

## 14. Assets

Batu collision sederhana, material kolam dekoratif, landmark arah. Koin hanya gagasan penuntun dalam baseline, bukan izin membuat pickup/reward.

Semua dekorasi di luar collision rute; catat lisensi dan budget sebelum integrasi. Asset ID, jumlah dan material final: **TBD — Requires Design Review**.

## 15. Acceptance

- **S5-AC01** — Given pemain berada di batu sebelum tikungan; when berhenti dan melihat arah lanjut; then target tikungan dapat dikenali tanpa bantuan collectible.
- **S5-AC02** — Given pemain mendarat dengan arah lama; when memutar joystick di batu; then tersedia ruang realign tanpa jatuh otomatis.
- **S5-AC03** — Given pemain masuk area kolam yang bukan jalur; when recovery terjadi; then tidak ada shortcut progres atau pengesahan CP_6 dari air.

## 16. Playtests

Bandingkan belokan kiri/kanan pada touch; rekam target yang salah dipilih, swipe kamera saat landing, dan salah baca air sebagai lantai.

Gunakan Studio/runtime Roblox nyata pada PC dan mobile fisik, pemula tanpa arahan verbal, serta multiplayer. Catat device/OS, avatar/movement, input, kualitas grafis, FPS/frame-time dan video/titik kegagalan. Target historis Proposed 8/10 pemula mencapai summit dan 30 FPS bukan bukti lulus atau batas final stage; protokol, sampel serta threshold: **TBD — Requires Design Review**. Review safe area/notch dan kamera pada touch; build/headless geometry bukan pengganti playtest.

## 17. Risks / Open Questions

Kolam mengundang pemain berjalan keluar jalur; specular highlight menutupi tepi batu; perubahan arah menuntut dua jempol sekaligus.

Urutan belokan, sifat kolam saat disentuh, dan landmark non-koin perlu design review. **TBD — Requires Design Review**.

**Kontrak global — Proposed, pending approval:** mengikuti [Global Checkpoint Contract](../prd.md#10-checkpoint-contract--kontrak-checkpoint), CP_N berada di entry island N. CP10 arrival sah menyimpan checkpoint respawn sesi CP10 dan stage aktif10 dengan `Completed=false`; exit Stage 9 / entry Stage 10 terjadi di sini. `SummitFinishZone` terpisah memvalidasi history CP1–10 dan mencatat `Completed=true` sekali. Save di sini bukan persistence lintas sesi atau approval reward. Recovery memakai checkpoint terakhir yang sah, termasuk CP10 setelah arrival. **Existing & Verified — feature source only:** CheckpointService mengabaikan ordinary touch stage≥10; SummitService memvalidasi history1–9 dan baru menetapkan stage10/Completed saat finish. Perilaku feature berbeda dari proposal, bukan mandat desain; runtime belum diuji. Persetujuan CP global/history/respawn tetap terbuka.

## 18. Handoff

Design handoff: setujui blueprint Stage 5, dimensi berbasis permukaan, sightline, collision safety dan checkpoint boundary sebelum implementasi. QA handoff: lampirkan hasil tiap S5-AC, touch video, geometri terukur, device/performance dan daftar defect; belum ada skenario yang dinyatakan lulus.

Koordinasikan sambungan dengan [Previous: Stage 4](../stage-4/prd.md) · [Next: Stage 6](../stage-6/prd.md) dan [Global PRD](../prd.md). Resolve ambiguity CP/finish bersama pemilik Stage 1/global/teknis. Scope dokumen tidak mengubah map, kode, ekonomi, data tersimpan, produksi atau otorisasi release.
