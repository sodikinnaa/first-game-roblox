# Stage 6 — Cloud Steps PRD

## 1. Identity / Status

**Stage 6 — Cloud Steps**

**Status: Draft — Pending Detailed Design Review**

[Global PRD](../prd.md) · [Previous: Stage 5](../stage-5/prd.md) · [Next: Stage 7](../stage-7/prd.md)

Dokumen desain/QA, bukan izin implementasi, build atau publish. Nama dan detail balancing belum final. Sumber dibaca: global `docs/prd.md` dan baseline feature `/home/dev/.hermes/cache/scratch/sky-island-map/prd.md`; detail source feature tidak menyatakan kesiapan main. Keputusan user terbaru mengatasi baseline lama hanya pada ascent dan appearance summit.

## 2. Objective

Awan solid berurutan dengan jeda istirahat yang dapat dikenali.

## 3. Experience

Pemain merasa awan dapat dipercaya sebagai pijakan; perjalanan berurutan tetap memberi kesempatan berhenti.

## 4. Entry / Exit

Proposed convention: CP_6 berada pada entry island 6; Stage 6 adalah perjalanan menuju CP_7 pada entry island 7. Aktivasi tujuan mengakhiri perjalanan stage ini, bukan entry CP_6.

## 5. Flow

Entry → pijakan awan solid berurutan → pulau jeda → rangkaian lanjutan bila diperlukan → island 7.

## 6. Blueprint

Cloud landing memiliki collision konsisten dan siluet tepi jelas. Jumlah rangkaian/jeda mengikuti kebutuhan kenaikan, bukan angka awan tetap.

## 7. Obstacles

Gap dan langkah rendah berurutan; awan tidak memudar, runtuh, bergerak, atau mengubah collision selama pemain berdiri.

## 8. Dimensions / Elevations

Koordinat X/Z, footprint, gap, slope, jumlah pijakan, spawn offset, collision clearance dan balancing final: **TBD — Requires Design Review**. Ukur gap dari tepi ke tepi dan rise dari top surface ke top surface, bukan selisih pusat.

Historical **Proposed** target island 6: Y=90 studs dari PRD feature read-only. Baseline PRD tidak mendefinisikan apakah Y pusat atau permukaan; snapshot StageConfig feature menggunakannya sebagai pusat dek setebal 2 studs, sehingga top surface historis Y=91. Ini bukan elevasi final atau koordinat yang disetujui. Selisih antarpulau bukan tinggi satu lompatan.

Historical **Proposed** baseline: safe island 20×20; landing 12×12 untuk Stage 1–3 dan 10×10 untuk Stage 4–9; bridge 8–10 studs. Gap 2–3 (Stage 1–3) atau 3–5 studs (Stage 4–9), rise 0–2 studs per langkah. Tidak menggabungkan batas gap dan rise; semua angka tunduk pada profil movement/avatar dan playtest touch.

## 9. Navigation / Camera

Kabut tidak menyembunyikan target. Dari pulau jeda, pemain mengenali rangkaian lanjut dan bukan pulau bawah sebagai rute.

## 10. Visual

Permukaan solid dibedakan dari awan latar lewat tepi, bayangan atau bentuk; bukan warna putih identik tanpa batas.

## 11. Checkpoint

CP_6 adalah kandidat checkpoint recovery aktif saat entry sah; CP_7 hanya sah setelah urutan wajib dipenuhi. Server memeriksa karakter hidup dan keberadaan dalam zona, bukan Touched/client request saja. Rest landing bukan checkpoint baru tanpa review.

## 12. Failure

Jatuh dari cloud landing kembali ke CP_6, kecuali checkpoint istirahat terpisah disetujui nanti. Pulau jeda tidak diam-diam menjadi checkpoint utama.

## 13. Technical Dependencies

Kontrak yang perlu diverifikasi bersama pemilik teknis: StageConfig/MapBuilderService untuk geometri dan orientasi, CheckpointService untuk urutan/recovery, ObstacleService untuk fall recovery, PlayerCollisionService untuk tidak saling mendorong, HUDController untuk informasi progres. Geometri harus tersedia sebelum listener checkpoint/recovery mengikat; rebuild tidak boleh meninggalkan listener pada objek lama.

Movement/avatar, WalkSpeed, gravity, JumpHeight/JumpPower, ukuran collision, perangkat target dan respawn heading perlu dikonfirmasi. Economy, nilai reward, implementasi coin pickup dan persistence belum disetujui; tidak ada requirement implementasi baru untuk itu. Jangan menjanjikan resume lintas sesi. Snapshot feature lebih lanjut daripada main; keberadaan source bukan bukti runtime.

## 14. Assets

Cloud platform solid, awan latar non-collidable, tanda pulau istirahat. Mesh visual tidak mengubah footprint collision yang sudah diuji.

Semua dekorasi di luar collision rute; catat lisensi dan budget sebelum integrasi. Asset ID, jumlah dan material final: **TBD — Requires Design Review**.

## 15. Acceptance

- **S6-AC01** — Given pemain diam pada awan jalur; when menunggu sebelum melompat; then awan tetap solid tanpa timer atau fade.
- **S6-AC02** — Given pemain mencapai pulau jeda; when berhenti lalu melanjutkan; then arah rangkaian berikutnya terbaca dan progres utama tidak bertambah karena jeda.
- **S6-AC03** — Given awan latar berdekatan dengan jalur; when pemain melihat dari layar kecil; then pijakan solid dan dekorasi dapat dibedakan sebelum takeoff.

## 16. Playtests

Uji kontras awan pada beberapa kualitas grafis; rekam salah pilih dekorasi, jeda sukarela, dan apakah rangkaian terlalu panjang untuk pemula.

Gunakan Studio/runtime Roblox nyata pada PC dan mobile fisik, pemula tanpa arahan verbal, serta multiplayer. Catat device/OS, avatar/movement, input, kualitas grafis, FPS/frame-time dan video/titik kegagalan. Target historis Proposed 8/10 pemula mencapai summit dan 30 FPS bukan bukti lulus atau batas final stage; protokol, sampel serta threshold: **TBD — Requires Design Review**. Review safe area/notch dan kamera pada touch; build/headless geometry bukan pengganti playtest.

## 17. Risks / Open Questions

Awan terasa tidak solid; bloom/fog menghapus tepi; jumlah awan tetap memaksa rise yang terlalu besar.

Jumlah rangkaian serta pulau jeda belum final; angka 3–4 dari baseline lama bukan batas desain. **TBD — Requires Design Review**.

**Kontrak global — Proposed, pending approval:** mengikuti [Global Checkpoint Contract](../prd.md#10-checkpoint-contract--kontrak-checkpoint), CP_N berada di entry island N. CP10 arrival sah menyimpan checkpoint respawn sesi CP10 dan stage aktif10 dengan `Completed=false`; exit Stage 9 / entry Stage 10 terjadi di sini. `SummitFinishZone` terpisah memvalidasi history CP1–10 dan mencatat `Completed=true` sekali. Save di sini bukan persistence lintas sesi atau approval reward. Recovery memakai checkpoint terakhir yang sah, termasuk CP10 setelah arrival. **Existing & Verified — feature source only:** CheckpointService mengabaikan ordinary touch stage≥10; SummitService memvalidasi history1–9 dan baru menetapkan stage10/Completed saat finish. Perilaku feature berbeda dari proposal, bukan mandat desain; runtime belum diuji. Persetujuan CP global/history/respawn tetap terbuka.

## 18. Handoff

Design handoff: setujui blueprint Stage 6, dimensi berbasis permukaan, sightline, collision safety dan checkpoint boundary sebelum implementasi. QA handoff: lampirkan hasil tiap S6-AC, touch video, geometri terukur, device/performance dan daftar defect; belum ada skenario yang dinyatakan lulus.

Koordinasikan sambungan dengan [Previous: Stage 5](../stage-5/prd.md) · [Next: Stage 7](../stage-7/prd.md) dan [Global PRD](../prd.md). Resolve ambiguity CP/finish bersama pemilik Stage 1/global/teknis. Scope dokumen tidak mengubah map, kode, ekonomi, data tersimpan, produksi atau otorisasi release.
