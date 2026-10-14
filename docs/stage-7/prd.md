# Stage 7 — Sky Orchard PRD

## 1. Identity / Status

**Stage 7 — Sky Orchard**

**Status: Draft — Pending Detailed Design Review**

[Global PRD](../prd.md) · [Previous: Stage 6](../stage-6/prd.md) · [Next: Stage 8](../stage-8/prd.md)

Dokumen desain/QA, bukan izin implementasi, build atau publish. Nama dan detail balancing belum final. Sumber dibaca: global `docs/prd.md` dan baseline feature `/home/dev/.hermes/cache/scratch/sky-island-map/prd.md`; detail source feature tidak menyatakan kesiapan main. Keputusan user terbaru mengatasi baseline lama hanya pada ascent dan appearance summit.

## 2. Objective

Belokan ringan dan kenaikan lembut di kebun terapung.

## 3. Experience

Pemain memadukan orientasi dan ascent sambil tetap punya ruang berhenti di luar kanopi.

## 4. Entry / Exit

Proposed convention: CP_7 berada pada entry island 7; Stage 7 adalah perjalanan menuju CP_8 pada entry island 8. Aktivasi tujuan mengakhiri perjalanan stage ini, bukan entry CP_7.

## 5. Flow

Entry kebun → lintasan naik lembut → landing untuk berbelok → lanjut melewati orchard → island 8.

## 6. Blueprint

Rute kebun membelok ringan dan naik bertahap; turn landing dipisahkan dari bagian yang membutuhkan jump presisi.

## 7. Obstacles

Kombinasi ringan belokan dan elevasi yang sudah dikenalkan, bukan buah jatuh, cabang bergerak, collectible gate, atau jumping ke pohon.

## 8. Dimensions / Elevations

Koordinat X/Z, footprint, gap, slope, jumlah pijakan, spawn offset, collision clearance dan balancing final: **TBD — Requires Design Review**. Ukur gap dari tepi ke tepi dan rise dari top surface ke top surface, bukan selisih pusat.

Historical **Proposed** target island 7: Y=112 studs dari PRD feature read-only. Baseline PRD tidak mendefinisikan apakah Y pusat atau permukaan; snapshot StageConfig feature menggunakannya sebagai pusat dek setebal 2 studs, sehingga top surface historis Y=113. Ini bukan elevasi final atau koordinat yang disetujui. Selisih antarpulau bukan tinggi satu lompatan.

Historical **Proposed** baseline: safe island 20×20; landing 12×12 untuk Stage 1–3 dan 10×10 untuk Stage 4–9; bridge 8–10 studs. Gap 2–3 (Stage 1–3) atau 3–5 studs (Stage 4–9), rise 0–2 studs per langkah. Tidak menggabungkan batas gap dan rise; semua angka tunduk pada profil movement/avatar dan playtest touch.

## 9. Navigation / Camera

Kanopi tidak memaksa kamera menembus pohon untuk melihat target. Respawn menghadap segmen baru setelah belokan, bukan +Z hardcoded.

## 10. Visual

Pohon buah memberi landmark arah; buah dekoratif tidak menyerupai reward wajib. Siluet rute tetap dominan terhadap tanaman.

## 11. Checkpoint

CP_7 adalah kandidat checkpoint recovery aktif saat entry sah; CP_8 hanya sah setelah urutan wajib dipenuhi. Server memeriksa karakter hidup dan keberadaan dalam zona, bukan Touched/client request saja. Rest landing bukan checkpoint baru tanpa review.

## 12. Failure

Jatuh setelah belokan pulih ke CP_7 dengan heading yang benar. Cabang dekoratif tidak menyangga avatar atau mengizinkan shortcut ke checkpoint atas.

## 13. Technical Dependencies

Kontrak yang perlu diverifikasi bersama pemilik teknis: StageConfig/MapBuilderService untuk geometri dan orientasi, CheckpointService untuk urutan/recovery, ObstacleService untuk fall recovery, PlayerCollisionService untuk tidak saling mendorong, HUDController untuk informasi progres. Geometri harus tersedia sebelum listener checkpoint/recovery mengikat; rebuild tidak boleh meninggalkan listener pada objek lama.

Movement/avatar, WalkSpeed, gravity, JumpHeight/JumpPower, ukuran collision, perangkat target dan respawn heading perlu dikonfirmasi. Economy, nilai reward, implementasi coin pickup dan persistence belum disetujui; tidak ada requirement implementasi baru untuk itu. Jangan menjanjikan resume lintas sesi. Snapshot feature lebih lanjut daripada main; keberadaan source bukan bukti runtime.

## 14. Assets

Pohon/buah non-collidable, lintasan solid dan landmark kebun. Kepadatan foliage menunggu anggaran mobile dan review lisensi.

Semua dekorasi di luar collision rute; catat lisensi dan budget sebelum integrasi. Asset ID, jumlah dan material final: **TBD — Requires Design Review**.

## 15. Acceptance

- **S7-AC01** — Given pemain naik sebelum tikungan; when mendarat dan berhenti; then dapat membaca serta mengarahkan belokan tanpa takeoff terburu-buru.
- **S7-AC02** — Given pemain respawn di orchard berorientasi berbeda dari sumbu dunia; when bergerak maju; then menghadap rute yang benar, bukan ke tepi atau pohon.
- **S7-AC03** — Given kamera mobile melewati kanopi; when pemain mencari target; then landing tetap terlihat atau penempatan pohon direvisi sebelum diterima.

## 16. Playtests

Uji jalur tanpa foliage lalu dengan foliage untuk memisahkan masalah geometri dan occlusion. Catat koreksi arah setelah respawn serta frame-time di kanopi.

Gunakan Studio/runtime Roblox nyata pada PC dan mobile fisik, pemula tanpa arahan verbal, serta multiplayer. Catat device/OS, avatar/movement, input, kualitas grafis, FPS/frame-time dan video/titik kegagalan. Target historis Proposed 8/10 pemula mencapai summit dan 30 FPS bukan bukti lulus atau batas final stage; protokol, sampel serta threshold: **TBD — Requires Design Review**. Review safe area/notch dan kamera pada touch; build/headless geometry bukan pengganti playtest.

## 17. Risks / Open Questions

Pohon menghalangi kamera; dekorasi buah mengesankan ekonomi; belokan dan rise bersama membuat kesulitan melonjak.

Kepadatan kebun, lokasi turn landing, dan kemiringan final membutuhkan review. **TBD — Requires Design Review**.

**Kontrak global — Proposed, pending approval:** mengikuti [Global Checkpoint Contract](../prd.md#10-checkpoint-contract--kontrak-checkpoint), CP_N berada di entry island N. CP10 arrival sah menyimpan checkpoint respawn sesi CP10 dan stage aktif10 dengan `Completed=false`; exit Stage 9 / entry Stage 10 terjadi di sini. `SummitFinishZone` terpisah memvalidasi history CP1–10 dan mencatat `Completed=true` sekali. Save di sini bukan persistence lintas sesi atau approval reward. Recovery memakai checkpoint terakhir yang sah, termasuk CP10 setelah arrival. **Existing & Verified — feature source only:** CheckpointService mengabaikan ordinary touch stage≥10; SummitService memvalidasi history1–9 dan baru menetapkan stage10/Completed saat finish. Perilaku feature berbeda dari proposal, bukan mandat desain; runtime belum diuji. Persetujuan CP global/history/respawn tetap terbuka.

## 18. Handoff

Design handoff: setujui blueprint Stage 7, dimensi berbasis permukaan, sightline, collision safety dan checkpoint boundary sebelum implementasi. QA handoff: lampirkan hasil tiap S7-AC, touch video, geometri terukur, device/performance dan daftar defect; belum ada skenario yang dinyatakan lulus.

Koordinasikan sambungan dengan [Previous: Stage 6](../stage-6/prd.md) · [Next: Stage 8](../stage-8/prd.md) dan [Global PRD](../prd.md). Resolve ambiguity CP/finish bersama pemilik Stage 1/global/teknis. Scope dokumen tidak mengubah map, kode, ekonomi, data tersimpan, produksi atau otorisasi release.
