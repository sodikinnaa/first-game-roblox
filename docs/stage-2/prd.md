# Stage 2 — Cloud Garden PRD

## 1. Identity / Status

**Stage 2 — Cloud Garden**

**Status: Draft — Pending Detailed Design Review**

[Global PRD](../prd.md) · [Previous: Stage 1](../stage-1/prd.md) · [Next: Stage 3](../stage-3/prd.md)

Dokumen desain/QA, bukan izin implementasi, build atau publish. Nama dan detail balancing belum final. Sumber dibaca: global `docs/prd.md` dan baseline feature `/home/dev/.hermes/cache/scratch/sky-island-map/prd.md`; detail source feature tidak menyatakan kesiapan main. Keputusan user terbaru mengatasi baseline lama hanya pada ascent dan appearance summit.

## 2. Objective

Lompatan pendek berurutan dengan target berikutnya terlihat.

## 3. Experience

Pemain belajar berhenti di tiap pijakan, mengatur joystick, lalu melompat lagi tanpa tekanan waktu.

## 4. Entry / Exit

Proposed convention: CP_2 berada pada entry island 2; Stage 2 adalah perjalanan menuju CP_3 pada entry island 3. Aktivasi tujuan mengakhiri perjalanan stage ini, bukan entry CP_2.

**Boundary bersama — Proposed — Pending Agreement:** mengikuti [tabel Stage 1](../stage-1/prd.md#8-dimensions--elevations--dimensi-dan-elevasi): Destination center `(24,22,143.6)`, deck size `(24,2,24)`, top Y=23; CP2 center `(24,23.25,143.6)`, size `(8,0.5,8)`, heading departure/respawn +X provisional, root offset kandidat +3.5 Y `(24,26.75,143.6)`. Satu deck Destination dan satu CP2 milik boundary bersama: Stage 1 owns incoming route sampai CP2, Stage 2 owns outgoing route dari deck tersebut; jangan duplikasi deck/trigger. Angka cocok dengan proposal tabel Stage 1, **bukan agreement final**. Anchor feature historis berbeda; transform/re-layout downstream Stage2–10 dan departure +X tetap pending agreement sebelum integrasi.

## 5. Flow

Orientasi di taman aman → lihat pijakan pertama → lompat berurutan dengan jeda pilihan pemain → pulau penerima.

## 6. Blueprint

Pulau taman entry → rangkaian landing lebar → safe island tujuan. Jalur naik lembut; belokan keseluruhan tidak boleh menyembunyikan landing berikutnya.

## 7. Obstacles

Gap antarpijakan statis; bukan rangkaian lompatan wajib tanpa berhenti. Tidak ada platform runtuh atau moving platform.

## 8. Dimensions / Elevations

Koordinat X/Z, footprint, gap, slope, jumlah pijakan, spawn offset, collision clearance dan balancing final: **TBD — Requires Design Review**. Ukur gap dari tepi ke tepi dan rise dari top surface ke top surface, bukan selisih pusat.

Historical **Proposed** target island 2: Y=22 studs dari PRD feature read-only. Baseline PRD tidak mendefinisikan apakah Y pusat atau permukaan; snapshot StageConfig feature menggunakannya sebagai pusat dek setebal 2 studs, sehingga top surface historis Y=23. Ini bukan elevasi final atau koordinat yang disetujui. Selisih antarpulau bukan tinggi satu lompatan.

Historical **Proposed** baseline: safe island 20×20; landing 12×12 untuk Stage 1–3 dan 10×10 untuk Stage 4–9; bridge 8–10 studs. Gap 2–3 (Stage 1–3) atau 3–5 studs (Stage 4–9), rise 0–2 studs per langkah. Tidak menggabungkan batas gap dan rise; semua angka tunduk pada profil movement/avatar dan playtest touch.

## 9. Navigation / Camera

Dari entry dan setiap landing, target berikutnya terbaca tanpa swipe kamera darurat. Respawn menghadap pijakan pertama, bukan arah sumbu dunia tetap.

## 10. Visual

Bunga dan awan membingkai jalur, bukan menutupi tepi. Warna taman tetap kontras dengan permukaan landing.

## 11. Checkpoint

CP_2 adalah kandidat checkpoint recovery aktif saat entry sah; CP_3 hanya sah setelah urutan wajib dipenuhi. Server memeriksa karakter hidup dan keberadaan dalam zona, bukan Touched/client request saja. Rest landing bukan checkpoint baru tanpa review.

## 12. Failure

Jatuh pada lompatan kedua atau setelah berhenti kembali ke CP_2, bukan ke checkpoint tujuan yang belum sah. Zona pemulihan tidak menyentuh pulau lebih rendah.

## 13. Technical Dependencies

Kontrak yang perlu diverifikasi bersama pemilik teknis: StageConfig/MapBuilderService untuk geometri dan orientasi, CheckpointService untuk urutan/recovery, ObstacleService untuk fall recovery, PlayerCollisionService untuk tidak saling mendorong, HUDController untuk informasi progres. Geometri harus tersedia sebelum listener checkpoint/recovery mengikat; rebuild tidak boleh meninggalkan listener pada objek lama.

Movement/avatar, WalkSpeed, gravity, JumpHeight/JumpPower, ukuran collision, perangkat target dan respawn heading perlu dikonfirmasi. Economy, nilai reward, implementasi coin pickup dan persistence belum disetujui; tidak ada requirement implementasi baru untuk itu. Jangan menjanjikan resume lintas sesi. Snapshot feature lebih lanjut daripada main; keberadaan source bukan bukti runtime.

## 14. Assets

Pijakan taman statis, bunga non-collidable, penanda arah netral. Mesh dekoratif opsional; footprint collision tidak bergantung pada mesh.

Semua dekorasi di luar collision rute; catat lisensi dan budget sebelum integrasi. Asset ID, jumlah dan material final: **TBD — Requires Design Review**.

## 15. Acceptance

- **S2-AC01** — Given pemain berhenti di landing tengah; when melanjutkan lewat joystick dan tombol lompat; then target berikutnya terlihat dan dapat dituju tanpa momentum lompatan sebelumnya.
- **S2-AC02** — Given pemain jatuh sebelum pulau 3; when recovery dijalankan; then respawn tetap di CP_2 dengan arah menuju rangkaian, tanpa mengaktifkan CP_3.
- **S2-AC04** — Proposed pending agreement: Given boundary Stage1→Stage2 disetujui; when tabel/layout dan respawn diinspeksi; then tepat satu Destination 24×2×24 center(24,22,143.6), satu CP2 8×0.5×8 center(24,23.25,143.6), top23 dan heading departure +X sesuai keputusan; transform downstream tercatat tanpa deck duplikat.
- **S2-AC03** — Given dua pemain berhenti pada landing sama; when salah satu melompat; then tidak ada dorongan antarpemain atau dekorasi yang menghalangi takeoff.

## 16. Playtests

Bandingkan pemula yang melompat terus dengan yang berhenti tiap landing; rekam koreksi joystick, tepi takeoff, target yang tertutup kamera, serta titik jatuh per lompatan.

Gunakan Studio/runtime Roblox nyata pada PC dan mobile fisik, pemula tanpa arahan verbal, serta multiplayer. Catat device/OS, avatar/movement, input, kualitas grafis, FPS/frame-time dan video/titik kegagalan. Target historis Proposed 8/10 pemula mencapai summit dan 30 FPS bukan bukti lulus atau batas final stage; protokol, sampel serta threshold: **TBD — Requires Design Review**. Review safe area/notch dan kamera pada touch; build/headless geometry bukan pengganti playtest.

## 17. Risks / Open Questions

Rangkaian terasa seperti tantangan momentum; bunga menyamarkan batas landing; layar kecil membuat dua target tampak bertumpuk.

Jumlah pijakan, kebutuhan jeda aman dan distribusi kenaikan harus diputuskan berdasarkan touch playtest. **TBD — Requires Design Review**.

**Kontrak global — Proposed, pending approval:** mengikuti [Global Checkpoint Contract](../prd.md#10-checkpoint-contract--kontrak-checkpoint), CP_N berada di entry island N. CP10 arrival sah menyimpan checkpoint respawn sesi CP10 dan stage aktif10 dengan `Completed=false`; exit Stage 9 / entry Stage 10 terjadi di sini. `SummitFinishZone` terpisah memvalidasi history CP1–10 dan mencatat `Completed=true` sekali. Save di sini bukan persistence lintas sesi atau approval reward. Recovery memakai checkpoint terakhir yang sah, termasuk CP10 setelah arrival. **Existing & Verified — feature source only:** CheckpointService mengabaikan ordinary touch stage≥10; SummitService memvalidasi history1–9 dan baru menetapkan stage10/Completed saat finish. Perilaku feature berbeda dari proposal, bukan mandat desain; runtime belum diuji. Persetujuan CP global/history/respawn tetap terbuka.

## 18. Handoff

Design handoff: setujui blueprint Stage 2, dimensi berbasis permukaan, sightline, collision safety dan checkpoint boundary sebelum implementasi. QA handoff: lampirkan hasil tiap S2-AC, touch video, geometri terukur, device/performance dan daftar defect; belum ada skenario yang dinyatakan lulus.

Koordinasikan sambungan dengan [Previous: Stage 1](../stage-1/prd.md) · [Next: Stage 3](../stage-3/prd.md) dan [Global PRD](../prd.md). Resolve ambiguity CP/finish bersama pemilik Stage 1/global/teknis. Scope dokumen tidak mengubah map, kode, ekonomi, data tersimpan, produksi atau otorisasi release.
