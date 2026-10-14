# Stage 4 — Terrace Grove PRD

## 1. Identity / Status

**Stage 4 — Terrace Grove**

**Status: Draft — Pending Detailed Design Review**

[Global PRD](../prd.md) · [Previous: Stage 3](../stage-3/prd.md) · [Next: Stage 5](../stage-5/prd.md)

Dokumen desain/QA, bukan izin implementasi, build atau publish. Nama dan detail balancing belum final. Sumber dibaca: global `docs/prd.md` dan baseline feature `/home/dev/.hermes/cache/scratch/sky-island-map/prd.md`; detail source feature tidak menyatakan kesiapan main. Keputusan user terbaru mengatasi baseline lama hanya pada ascent dan appearance summit.

## 2. Objective

Kenaikan rendah bertahap dengan pendaratan lebar.

## 3. Experience

Pemain mengenali perbedaan tinggi tanpa diminta menggabungkan elevasi besar dengan celah sulit.

## 4. Entry / Exit

Proposed convention: CP_4 berada pada entry island 4; Stage 4 adalah perjalanan menuju CP_5 pada entry island 5. Aktivasi tujuan mengakhiri perjalanan stage ini, bukan entry CP_4.

## 5. Flow

Entry teras bawah → lihat permukaan teras berikutnya → naik satu langkah rendah → jeda di teras → ulangi → island 5.

## 6. Blueprint

Teras lebar berjenjang dengan ruang berhenti sebelum tiap kenaikan. Belokan merupakan usulan, bukan sudut final; setiap langkah menampilkan top surface penerima.

## 7. Obstacles

Langkah rendah statis; tidak ada dinding tinggi, presisi tepi sempit, atau maksimal gap sekaligus rise tinggi.

## 8. Dimensions / Elevations

Koordinat X/Z, footprint, gap, slope, jumlah pijakan, spawn offset, collision clearance dan balancing final: **TBD — Requires Design Review**. Ukur gap dari tepi ke tepi dan rise dari top surface ke top surface, bukan selisih pusat.

Historical **Proposed** target island 4: Y=52 studs dari PRD feature read-only. Baseline PRD tidak mendefinisikan apakah Y pusat atau permukaan; snapshot StageConfig feature menggunakannya sebagai pusat dek setebal 2 studs, sehingga top surface historis Y=53. Ini bukan elevasi final atau koordinat yang disetujui. Selisih antarpulau bukan tinggi satu lompatan.

Historical **Proposed** baseline: safe island 20×20; landing 12×12 untuk Stage 1–3 dan 10×10 untuk Stage 4–9; bridge 8–10 studs. Gap 2–3 (Stage 1–3) atau 3–5 studs (Stage 4–9), rise 0–2 studs per langkah. Tidak menggabungkan batas gap dan rise; semua angka tunduk pada profil movement/avatar dan playtest touch.

## 9. Navigation / Camera

Kamera dari teras bawah harus melihat permukaan atas, bukan hanya dinding teras. Respawn menghadap langkah pertama dengan clearance yang cukup.

## 10. Visual

Lapisan rumput/batu memperjelas tinggi; pohon ditempatkan di luar sightline lintasan dan collision landing.

## 11. Checkpoint

CP_4 adalah kandidat checkpoint recovery aktif saat entry sah; CP_5 hanya sah setelah urutan wajib dipenuhi. Server memeriksa karakter hidup dan keberadaan dalam zona, bukan Touched/client request saja. Rest landing bukan checkpoint baru tanpa review.

## 12. Failure

Tersangkut di riser atau jatuh di samping teras dicatat terpisah. Recovery ke CP_4 tidak membenarkan checkpoint melalui sentuhan underside.

## 13. Technical Dependencies

Kontrak yang perlu diverifikasi bersama pemilik teknis: StageConfig/MapBuilderService untuk geometri dan orientasi, CheckpointService untuk urutan/recovery, ObstacleService untuk fall recovery, PlayerCollisionService untuk tidak saling mendorong, HUDController untuk informasi progres. Geometri harus tersedia sebelum listener checkpoint/recovery mengikat; rebuild tidak boleh meninggalkan listener pada objek lama.

Movement/avatar, WalkSpeed, gravity, JumpHeight/JumpPower, ukuran collision, perangkat target dan respawn heading perlu dikonfirmasi. Economy, nilai reward, implementasi coin pickup dan persistence belum disetujui; tidak ada requirement implementasi baru untuk itu. Jangan menjanjikan resume lintas sesi. Snapshot feature lebih lanjut daripada main; keberadaan source bukan bukti runtime.

## 14. Assets

Teras collision sederhana, riser terbaca, grove non-collidable. Variasi pohon hanya jika tidak menutupi target.

Semua dekorasi di luar collision rute; catat lisensi dan budget sebelum integrasi. Asset ID, jumlah dan material final: **TBD — Requires Design Review**.

## 15. Acceptance

- **S4-AC01** — Given pemain berada di teras bawah; when melihat kamera default; then top surface teras berikutnya terlihat sebelum naik.
- **S4-AC02** — Given pemain berhenti setelah satu kenaikan; when melanjutkan naik; then ruang landing cukup untuk realign tanpa harus mundur ke tepi.
- **S4-AC03** — Given pemain menyentuh underside teras tujuan setelah jatuh; when sistem menerima kontak; then kontak itu tidak mengesahkan CP_5.

## 16. Playtests

Rekam lompatan menyentuh riser, koreksi kamera vertikal dan kebutuhan mundur di landing. Uji profil avatar final pada semua kenaikan, bukan satu contoh teras.

Gunakan Studio/runtime Roblox nyata pada PC dan mobile fisik, pemula tanpa arahan verbal, serta multiplayer. Catat device/OS, avatar/movement, input, kualitas grafis, FPS/frame-time dan video/titik kegagalan. Target historis Proposed 8/10 pemula mencapai summit dan 30 FPS bukan bukti lulus atau batas final stage; protokol, sampel serta threshold: **TBD — Requires Design Review**. Review safe area/notch dan kamera pada touch; build/headless geometry bukan pengganti playtest.

## 17. Risks / Open Questions

Ukuran rise berbasis pusat menyembunyikan permukaan tak rata; kanopi menutup target; belokan pada riser meningkatkan koreksi touch.

Profil teras, jumlah kenaikan, dan pemisahan belokan dari takeoff masih memerlukan review. **TBD — Requires Design Review**.

**Kontrak global — Proposed, pending approval:** mengikuti [Global Checkpoint Contract](../prd.md#10-checkpoint-contract--kontrak-checkpoint), CP_N berada di entry island N. CP10 arrival sah menyimpan checkpoint respawn sesi CP10 dan stage aktif10 dengan `Completed=false`; exit Stage 9 / entry Stage 10 terjadi di sini. `SummitFinishZone` terpisah memvalidasi history CP1–10 dan mencatat `Completed=true` sekali. Save di sini bukan persistence lintas sesi atau approval reward. Recovery memakai checkpoint terakhir yang sah, termasuk CP10 setelah arrival. **Existing & Verified — feature source only:** CheckpointService mengabaikan ordinary touch stage≥10; SummitService memvalidasi history1–9 dan baru menetapkan stage10/Completed saat finish. Perilaku feature berbeda dari proposal, bukan mandat desain; runtime belum diuji. Persetujuan CP global/history/respawn tetap terbuka.

## 18. Handoff

Design handoff: setujui blueprint Stage 4, dimensi berbasis permukaan, sightline, collision safety dan checkpoint boundary sebelum implementasi. QA handoff: lampirkan hasil tiap S4-AC, touch video, geometri terukur, device/performance dan daftar defect; belum ada skenario yang dinyatakan lulus.

Koordinasikan sambungan dengan [Previous: Stage 3](../stage-3/prd.md) · [Next: Stage 5](../stage-5/prd.md) dan [Global PRD](../prd.md). Resolve ambiguity CP/finish bersama pemilik Stage 1/global/teknis. Scope dokumen tidak mengubah map, kode, ekonomi, data tersimpan, produksi atau otorisasi release.
