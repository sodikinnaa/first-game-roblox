# Stage 3 — Breeze Bridge PRD

## 1. Identity / Status

**Stage 3 — Breeze Bridge**

**Status: Draft — Pending Detailed Design Review**

[Global PRD](../prd.md) · [Previous: Stage 2](../stage-2/prd.md) · [Next: Stage 4](../stage-4/prd.md)

Dokumen desain/QA, bukan izin implementasi, build atau publish. Nama dan detail balancing belum final. Sumber dibaca: global `docs/prd.md` dan baseline feature `/home/dev/.hermes/cache/scratch/sky-island-map/prd.md`; detail source feature tidak menyatakan kesiapan main. Keputusan user terbaru mengatasi baseline lama hanya pada ascent dan appearance summit.

## 2. Objective

Berjalan di jembatan dan melompat satu celah yang terbaca jelas.

## 3. Experience

Pemain mendapat ritme lebih tenang: berjalan dahulu, mengenali celah tunggal, lalu kembali berjalan.

## 4. Entry / Exit

Proposed convention: CP_3 berada pada entry island 3; Stage 3 adalah perjalanan menuju CP_4 pada entry island 4. Aktivasi tujuan mengakhiri perjalanan stage ini, bukan entry CP_3.

## 5. Flow

Entry aman → berjalan di dek → berhenti sebelum celah → satu lompatan → dek lanjutan → pulau tujuan.

## 6. Blueprint

Dek jembatan lebar naik lembut → satu pemisahan yang disengaja → dek penerima kontinu. Sambungan dekoratif tidak dihitung sebagai gap gameplay.

## 7. Obstacles

Hanya satu celah lompatan. Kenaikan lain ditangani dek/lereng aman; bukan deretan papan terpisah, jembatan goyang fisik, atau celah tersembunyi.

## 8. Dimensions / Elevations

Koordinat X/Z, footprint, gap, slope, jumlah pijakan, spawn offset, collision clearance dan balancing final: **TBD — Requires Design Review**. Ukur gap dari tepi ke tepi dan rise dari top surface ke top surface, bukan selisih pusat.

Historical **Proposed** target island 3: Y=36 studs dari PRD feature read-only. Baseline PRD tidak mendefinisikan apakah Y pusat atau permukaan; snapshot StageConfig feature menggunakannya sebagai pusat dek setebal 2 studs, sehingga top surface historis Y=37. Ini bukan elevasi final atau koordinat yang disetujui. Selisih antarpulau bukan tinggi satu lompatan.

Historical **Proposed** baseline: safe island 20×20; landing 12×12 untuk Stage 1–3 dan 10×10 untuk Stage 4–9; bridge 8–10 studs. Gap 2–3 (Stage 1–3) atau 3–5 studs (Stage 4–9), rise 0–2 studs per langkah. Tidak menggabungkan batas gap dan rise; semua angka tunduk pada profil movement/avatar dan playtest touch.

## 9. Navigation / Camera

Railing tidak menutup pandangan celah. Kamera bebas sepanjang dek; arah pulang setelah recovery menunjuk sumbu dek menuju gap.

## 10. Visual

Kayu hangat dan tali dekoratif memberi tema jembatan; perubahan bahan/marking memperjelas tepi gap tanpa menuntut pengenalan warna saja.

## 11. Checkpoint

CP_3 adalah kandidat checkpoint recovery aktif saat entry sah; CP_4 hanya sah setelah urutan wajib dipenuhi. Server memeriksa karakter hidup dan keberadaan dalam zona, bukan Touched/client request saja. Rest landing bukan checkpoint baru tanpa review.

## 12. Failure

Jatuh di gap atau sisi dek kembali ke CP_3. Tali, penyangga, dan pulau di bawah tidak menjadi landing tak sengaja.

## 13. Technical Dependencies

Kontrak yang perlu diverifikasi bersama pemilik teknis: StageConfig/MapBuilderService untuk geometri dan orientasi, CheckpointService untuk urutan/recovery, ObstacleService untuk fall recovery, PlayerCollisionService untuk tidak saling mendorong, HUDController untuk informasi progres. Geometri harus tersedia sebelum listener checkpoint/recovery mengikat; rebuild tidak boleh meninggalkan listener pada objek lama.

Movement/avatar, WalkSpeed, gravity, JumpHeight/JumpPower, ukuran collision, perangkat target dan respawn heading perlu dikonfirmasi. Economy, nilai reward, implementasi coin pickup dan persistence belum disetujui; tidak ada requirement implementasi baru untuk itu. Jangan menjanjikan resume lintas sesi. Snapshot feature lebih lanjut daripada main; keberadaan source bukan bukti runtime.

## 14. Assets

Dek kayu, railing/penyangga visual, marking celah. Tali tidak collidable; perlindungan sisi yang dibutuhkan dipisahkan dari ornamen.

Semua dekorasi di luar collision rute; catat lisensi dan budget sebelum integrasi. Asset ID, jumlah dan material final: **TBD — Requires Design Review**.

## 15. Acceptance

- **S3-AC01** — Given pemain berjalan tanpa melompat; when menyusuri dek sebelum celah; then tidak terhenti oleh sambungan papan atau collision tali.
- **S3-AC02** — Given pemain tiba di celah; when mengamati dari kamera default mobile; then satu gap dan dek penerima terlihat sebelum takeoff.
- **S3-AC03** — Given pemain sudah melewati gap; when meneruskan berjalan ke island 4; then tidak ada celah kedua atau loncatan tersembunyi yang diperlukan.

## 16. Playtests

Uji berjalan lurus dengan drift joystick, kamera dekat railing, dan stop-start sebelum gap. Catat apakah pemain mengira tali dapat dipijak atau sambungan papan adalah lubang.

Gunakan Studio/runtime Roblox nyata pada PC dan mobile fisik, pemula tanpa arahan verbal, serta multiplayer. Catat device/OS, avatar/movement, input, kualitas grafis, FPS/frame-time dan video/titik kegagalan. Target historis Proposed 8/10 pemula mencapai summit dan 30 FPS bukan bukti lulus atau batas final stage; protokol, sampel serta threshold: **TBD — Requires Design Review**. Review safe area/notch dan kamera pada touch; build/headless geometry bukan pengganti playtest.

## 17. Risks / Open Questions

Tema jembatan gantung menyiratkan gerakan yang tidak dirancang; railing bisa menutup target; ascent bisa tanpa sengaja menghasilkan gap tambahan.

Detail perlindungan sisi dan kemiringan dek aman perlu review; satu gap tetap batas mekanik. **TBD — Requires Design Review**.

**Kontrak global — Proposed, pending approval:** mengikuti [Global Checkpoint Contract](../prd.md#10-checkpoint-contract--kontrak-checkpoint), CP_N berada di entry island N. CP10 arrival sah menyimpan checkpoint respawn sesi CP10 dan stage aktif10 dengan `Completed=false`; exit Stage 9 / entry Stage 10 terjadi di sini. `SummitFinishZone` terpisah memvalidasi history CP1–10 dan mencatat `Completed=true` sekali. Save di sini bukan persistence lintas sesi atau approval reward. Recovery memakai checkpoint terakhir yang sah, termasuk CP10 setelah arrival. **Existing & Verified — feature source only:** CheckpointService mengabaikan ordinary touch stage≥10; SummitService memvalidasi history1–9 dan baru menetapkan stage10/Completed saat finish. Perilaku feature berbeda dari proposal, bukan mandat desain; runtime belum diuji. Persetujuan CP global/history/respawn tetap terbuka.

## 18. Handoff

Design handoff: setujui blueprint Stage 3, dimensi berbasis permukaan, sightline, collision safety dan checkpoint boundary sebelum implementasi. QA handoff: lampirkan hasil tiap S3-AC, touch video, geometri terukur, device/performance dan daftar defect; belum ada skenario yang dinyatakan lulus.

Koordinasikan sambungan dengan [Previous: Stage 2](../stage-2/prd.md) · [Next: Stage 4](../stage-4/prd.md) dan [Global PRD](../prd.md). Resolve ambiguity CP/finish bersama pemilik Stage 1/global/teknis. Scope dokumen tidak mengubah map, kode, ekonomi, data tersimpan, produksi atau otorisasi release.
