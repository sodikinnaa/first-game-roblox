# Stage 8 — Sunset Walk PRD

## 1. Identity / Status

**Stage 8 — Sunset Walk**

**Status: Draft — Pending Detailed Design Review**

[Global PRD](../prd.md) · [Previous: Stage 7](../stage-7/prd.md) · [Next: Stage 9](../stage-9/prd.md)

Dokumen desain/QA, bukan izin implementasi, build atau publish. Nama dan detail balancing belum final. Sumber dibaca: global `docs/prd.md` dan baseline feature `/home/dev/.hermes/cache/scratch/sky-island-map/prd.md`; detail source feature tidak menyatakan kesiapan main. Keputusan user terbaru mengatasi baseline lama hanya pada ascent dan appearance summit.

## 2. Objective

Menggabungkan keterampilan sebelumnya dalam jalur senja yang tenang.

## 3. Experience

Pemain mengenali lompatan, belokan dan kenaikan yang sudah dipelajari, bukan menghadapi mekanik baru menjelang akhir.

## 4. Entry / Exit

Proposed convention: CP_8 berada pada entry island 8; Stage 8 adalah perjalanan menuju CP_9 pada entry island 9. Aktivasi tujuan mengakhiri perjalanan stage ini, bukan entry CP_8.

## 5. Flow

Entry senja → segmen familiar → jeda aman → kombinasi segmen familiar berikutnya → island 9.

## 6. Blueprint

Rute sedikit lebih panjang sebagai usulan; susunan segmen memberi respite dan sightline panorama tanpa meminta pemain melompat sambil melihat ke belakang.

## 7. Obstacles

Kombinasi consecutive landing, turning dan low-rise yang sudah diperkenalkan. Tidak ada timer, difficulty spike atau gap maksimum ditambah rise maksimum.

## 8. Dimensions / Elevations

Koordinat X/Z, footprint, gap, slope, jumlah pijakan, spawn offset, collision clearance dan balancing final: **TBD — Requires Design Review**. Ukur gap dari tepi ke tepi dan rise dari top surface ke top surface, bukan selisih pusat.

Historical **Proposed** target island 8: Y=136 studs dari PRD feature read-only. Baseline PRD tidak mendefinisikan apakah Y pusat atau permukaan; snapshot StageConfig feature menggunakannya sebagai pusat dek setebal 2 studs, sehingga top surface historis Y=137. Ini bukan elevasi final atau koordinat yang disetujui. Selisih antarpulau bukan tinggi satu lompatan.

Historical **Proposed** baseline: safe island 20×20; landing 12×12 untuk Stage 1–3 dan 10×10 untuk Stage 4–9; bridge 8–10 studs. Gap 2–3 (Stage 1–3) atau 3–5 studs (Stage 4–9), rise 0–2 studs per langkah. Tidak menggabungkan batas gap dan rise; semua angka tunduk pada profil movement/avatar dan playtest touch.

## 9. Navigation / Camera

Panorama pulau bawah tidak menjadi arah jalur palsu. Landing berikutnya tetap terlihat pada lighting senja; kamera bebas menikmati vista dari area aman.

## 10. Visual

Palet senja hangat dengan kontras permukaan/void tetap jelas; exposure dan bloom tidak mengorbankan keterbacaan tepi.

## 11. Checkpoint

CP_8 adalah kandidat checkpoint recovery aktif saat entry sah; CP_9 hanya sah setelah urutan wajib dipenuhi. Server memeriksa karakter hidup dan keberadaan dalam zona, bukan Touched/client request saja. Rest landing bukan checkpoint baru tanpa review.

## 12. Failure

Jatuh di segmen akhir kembali ke CP_8; amati biaya pengulangan jalur panjang sebelum memutuskan rest checkpoint tambahan.

## 13. Technical Dependencies

Kontrak yang perlu diverifikasi bersama pemilik teknis: StageConfig/MapBuilderService untuk geometri dan orientasi, CheckpointService untuk urutan/recovery, ObstacleService untuk fall recovery, PlayerCollisionService untuk tidak saling mendorong, HUDController untuk informasi progres. Geometri harus tersedia sebelum listener checkpoint/recovery mengikat; rebuild tidak boleh meninggalkan listener pada objek lama.

Movement/avatar, WalkSpeed, gravity, JumpHeight/JumpPower, ukuran collision, perangkat target dan respawn heading perlu dikonfirmasi. Economy, nilai reward, implementasi coin pickup dan persistence belum disetujui; tidak ada requirement implementasi baru untuk itu. Jangan menjanjikan resume lintas sesi. Snapshot feature lebih lanjut daripada main; keberadaan source bukan bukti runtime.

## 14. Assets

Variasi landing yang sudah dikenal, lighting senja, landmark island 9. Hindari tambahan mesh/FX berat hanya untuk memberi kesan finale.

Semua dekorasi di luar collision rute; catat lisensi dan budget sebelum integrasi. Asset ID, jumlah dan material final: **TBD — Requires Design Review**.

## 15. Acceptance

- **S8-AC01** — Given pemain mengenali keterampilan stage sebelumnya; when melewati kombinasi Sunset Walk; then tidak diwajibkan menggunakan mekanik baru atau lompatan presisi ekstrem.
- **S8-AC02** — Given pemain melihat panorama dari area jeda; when kembali ke jalur; then rute lanjut jelas dan tidak tertukar dengan pulau bawah.
- **S8-AC03** — Given pemain gagal dekat akhir; when mengulang dari CP_8; then biaya ulang dicatat untuk review, bukan disembunyikan dengan checkpoint baru tanpa persetujuan.

## 16. Playtests

Rekam kelelahan touch dan jumlah pengulangan segmen akhir; uji kontras senja pada kualitas rendah serta waktu orientasi setelah berhenti melihat panorama.

Gunakan Studio/runtime Roblox nyata pada PC dan mobile fisik, pemula tanpa arahan verbal, serta multiplayer. Catat device/OS, avatar/movement, input, kualitas grafis, FPS/frame-time dan video/titik kegagalan. Target historis Proposed 8/10 pemula mencapai summit dan 30 FPS bukan bukti lulus atau batas final stage; protokol, sampel serta threshold: **TBD — Requires Design Review**. Review safe area/notch dan kamera pada touch; build/headless geometry bukan pengganti playtest.

## 17. Risks / Open Questions

Panjang jalur memperbesar frustrasi meski tiap jump mudah; lighting menyamarkan gap; vista menarik kamera saat takeoff.

Panjang, urutan kombinasi dan kebutuhan jeda/checkpoint tambahan perlu review sebelum balancing. **TBD — Requires Design Review**.

**Kontrak global — Proposed, pending approval:** mengikuti [Global Checkpoint Contract](../prd.md#10-checkpoint-contract--kontrak-checkpoint), CP_N berada di entry island N. CP10 arrival sah menyimpan checkpoint respawn sesi CP10 dan stage aktif10 dengan `Completed=false`; exit Stage 9 / entry Stage 10 terjadi di sini. `SummitFinishZone` terpisah memvalidasi history CP1–10 dan mencatat `Completed=true` sekali. Save di sini bukan persistence lintas sesi atau approval reward. Recovery memakai checkpoint terakhir yang sah, termasuk CP10 setelah arrival. **Existing & Verified — feature source only:** CheckpointService mengabaikan ordinary touch stage≥10; SummitService memvalidasi history1–9 dan baru menetapkan stage10/Completed saat finish. Perilaku feature berbeda dari proposal, bukan mandat desain; runtime belum diuji. Persetujuan CP global/history/respawn tetap terbuka.

## 18. Handoff

Design handoff: setujui blueprint Stage 8, dimensi berbasis permukaan, sightline, collision safety dan checkpoint boundary sebelum implementasi. QA handoff: lampirkan hasil tiap S8-AC, touch video, geometri terukur, device/performance dan daftar defect; belum ada skenario yang dinyatakan lulus.

Koordinasikan sambungan dengan [Previous: Stage 7](../stage-7/prd.md) · [Next: Stage 9](../stage-9/prd.md) dan [Global PRD](../prd.md). Resolve ambiguity CP/finish bersama pemilik Stage 1/global/teknis. Scope dokumen tidak mengubah map, kode, ekonomi, data tersimpan, produksi atau otorisasi release.
