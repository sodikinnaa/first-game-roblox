# Stage 9 — Summit Approach PRD

## 1. Identity / Status

**Stage 9 — Summit Approach**

**Status: Draft — Pending Detailed Design Review**

[Global PRD](../prd.md) · [Previous: Stage 8](../stage-8/prd.md) · [Next: Stage 10](../stage-10/prd.md)

Dokumen desain/QA, bukan izin implementasi, build atau publish. Nama dan detail balancing belum final. Sumber dibaca: global `docs/prd.md` dan baseline feature `/home/dev/.hermes/cache/scratch/sky-island-map/prd.md`; detail source feature tidak menyatakan kesiapan main. Keputusan user terbaru mengatasi baseline lama hanya pada ascent dan appearance summit.

## 2. Objective

Ascent aman dan lebar menuju finish; menurunkan tekanan sebelum plaza.

## 3. Experience

Pemain memahami bahwa pendakian hampir selesai, tetap mengendalikan kamera dan tidak menghadapi ujian presisi baru.

## 4. Entry / Exit

**Proposed — pending approval:** CP_9 berada pada entry island 9. Exit Stage 9 terjadi saat arrival CP10 sah di entry island10: stage aktif10, checkpoint respawn CP10, `Completed=false`. Finish terpisah terjadi kemudian di Stage 10; tidak menunda exit Stage 9 sampai finish. Perilaku source feature berbeda (bagian 11/17).

## 5. Flow

**Proposed — pending approval:** CP_9 → ascent lebar bertahap → gerbang/arrival CP10 → simpan entry dan respawn CP10, stage10/Completed=false → pengalaman Stage 10 → finish terpisah bila sah.

## 6. Blueprint

Lintasan melebar menuju plaza; total beda tinggi dibagi langkah/lereng aman. Gerbang tidak menjadi bottleneck collision atau titik blind jump.

## 7. Obstacles

Ascent aman, bukan finale sulit. Tidak ada gap tersembunyi setelah gerbang, pagar yang wajib dilompati, atau celah sempit menuju finish.

## 8. Dimensions / Elevations

Koordinat X/Z, footprint, gap, slope, jumlah pijakan, spawn offset, collision clearance dan balancing final: **TBD — Requires Design Review**. Ukur gap dari tepi ke tepi dan rise dari top surface ke top surface, bukan selisih pusat.

Historical **Proposed** target island 9: Y=162 studs dari PRD feature read-only. Baseline PRD tidak mendefinisikan apakah Y pusat atau permukaan; snapshot StageConfig feature menggunakannya sebagai pusat dek setebal 2 studs, sehingga top surface historis Y=163. Ini bukan elevasi final atau koordinat yang disetujui. Selisih antarpulau bukan tinggi satu lompatan.

Historical **Proposed** baseline: safe island 20×20; landing 12×12 untuk Stage 1–3 dan 10×10 untuk Stage 4–9; bridge 8–10 studs. Gap 2–3 (Stage 1–3) atau 3–5 studs (Stage 4–9), rise 0–2 studs per langkah. Tidak menggabungkan batas gap dan rise; semua angka tunduk pada profil movement/avatar dan playtest touch.

## 9. Navigation / Camera

Dari ascent terakhir pemain melihat plaza dan ambang finish. Kamera dan joystick tetap bebas saat banner muncul; landmark summit tidak menutupi landing akhir.

## 10. Visual

Gerbang awan dan permukaan lebar menandai transisi; finish dibedakan dari dekorasi maupun pad checkpoint biasa.

## 11. Checkpoint

**Proposed — pending approval:** arrival CP10 yang sah mencatat LastCheckpoint=CP10, ActiveStage=10 dan history entry tanpa mengubah `Completed=false`. Finish bukan checkpoint arrival: SummitService memvalidasi karakter hidup, posisi di `SummitFinishZone` terpisah dan history CP1–10, lalu mencatat `Completed=true` idempoten. Touch CP10 sendiri tidak memberi finish/selebrasi. **Existing & Verified — feature source only:** ordinary CP10 tidak diaktifkan; finish memakai history1–9 dan menetapkan stage10. Runtime pending; kontrak usulan belum diimplementasikan.

## 12. Failure

**Proposed — pending approval:** jatuh sebelum CP10 sah kembali ke CP_9; setelah arrival CP10 sah (walau belum finish), kembali ke CP10. Kontak finish ketika mati/di luar zona/urutan tidak sah tidak menghasilkan Completed. Kegagalan FX setelah finish sah tidak membatalkan finish. Feature source saat ini tidak menyimpan arrival CP10 dan tetap memakai CP9 sebelum finish; runtime belum diuji.

## 13. Technical Dependencies

Kontrak yang perlu diverifikasi bersama pemilik teknis: StageConfig/MapBuilderService untuk geometri dan orientasi, CheckpointService untuk urutan/recovery, ObstacleService untuk fall recovery, PlayerCollisionService untuk tidak saling mendorong, HUDController untuk informasi progres. SummitService, SummitController dan ConfettiController memisahkan validasi server dari presentasi lokal; lifecycle Ready → Playing → Cooldown → Ready, replay tidak menambah progres.

Movement/avatar, WalkSpeed, gravity, JumpHeight/JumpPower, ukuran collision, perangkat target dan respawn heading perlu dikonfirmasi. Economy, nilai reward, implementasi coin pickup dan persistence belum disetujui; tidak ada requirement implementasi baru untuk itu. Jangan menjanjikan resume lintas sesi. Snapshot feature lebih lanjut daripada main; keberadaan source bukan bukti runtime.

## 14. Assets

Ascent collision sederhana, gerbang visual dengan clearance, zona finish terpisah dan plaza penerima. Ornament gerbang opsional.

Semua dekorasi di luar collision rute; catat lisensi dan budget sebelum integrasi. Asset ID, jumlah dan material final: **TBD — Requires Design Review**.

## 15. Acceptance

- **S9-AC01** — Given pemain berada di langkah terakhir; when melihat dan berjalan ke plaza; then tidak ada loncatan buta atau rintangan baru di balik gerbang.
- **S9-AC02** — Given pemain belum memiliki urutan wajib atau sudah mati; when menyentuh ambang finish/mengirim request; then SummitService menolak Completed.
- **S9-AC03** — Proposed pending approval: Given history CP1–9 sah; when arrival CP10 disentuh berulang; then stage10/checkpoint respawn CP10 tercatat satu kali dengan Completed=false, exit Stage9 sah tanpa finish; mati sebelum finish pulih ke CP10.
- **S9-AC04** — Proposed pending approval: Given history CP1–10 sah; when finish terpisah disentuh berulang bersama kontak CP10; then Completed=true sekali dan arrival tidak menggandakan finish/reward.

## 16. Playtests

Uji clearance gerbang untuk profil avatar final, kamera sebelum/di ambang, dan kontak simultaneous finish. Jalankan dua pemain untuk membedakan progres dan presentasi lokal.

Gunakan Studio/runtime Roblox nyata pada PC dan mobile fisik, pemula tanpa arahan verbal, serta multiplayer. Catat device/OS, avatar/movement, input, kualitas grafis, FPS/frame-time dan video/titik kegagalan. Target historis Proposed 8/10 pemula mencapai summit dan 30 FPS bukan bukti lulus atau batas final stage; protokol, sampel serta threshold: **TBD — Requires Design Review**. Review safe area/notch dan kamera pada touch; build/headless geometry bukan pengganti playtest.

## 17. Risks / Open Questions

Urutan checkpoint versus finish tidak jelas; gerbang menghalangi jalur; label Stage 10 keliru menyiratkan rintangan baru.

Resolve formal kapan Stage 9 exit versus Stage 10 entry dicatat, lokasi respawn pasca-finish dan representasi CP10. **TBD — Requires Design Review**.

**Kontrak global — Proposed, pending approval:** mengikuti [Global Checkpoint Contract](../prd.md#10-checkpoint-contract--kontrak-checkpoint), CP_N berada di entry island N. CP10 arrival sah menyimpan checkpoint respawn sesi CP10 dan stage aktif10 dengan `Completed=false`; exit Stage 9 / entry Stage 10 terjadi di sini. `SummitFinishZone` terpisah memvalidasi history CP1–10 dan mencatat `Completed=true` sekali. Save di sini bukan persistence lintas sesi atau approval reward. Recovery memakai checkpoint terakhir yang sah, termasuk CP10 setelah arrival. **Existing & Verified — feature source only:** CheckpointService mengabaikan ordinary touch stage≥10; SummitService memvalidasi history1–9 dan baru menetapkan stage10/Completed saat finish. Perilaku feature berbeda dari proposal, bukan mandat desain; runtime belum diuji. Persetujuan CP global/history/respawn tetap terbuka.

## 18. Handoff

Design handoff: setujui blueprint Stage 9, dimensi berbasis permukaan, sightline, collision safety dan checkpoint boundary sebelum implementasi. QA handoff: lampirkan hasil tiap S9-AC, touch video, geometri terukur, device/performance dan daftar defect; belum ada skenario yang dinyatakan lulus.

Koordinasikan sambungan dengan [Previous: Stage 8](../stage-8/prd.md) · [Next: Stage 10](../stage-10/prd.md) dan [Global PRD](../prd.md). Resolve ambiguity CP/finish bersama pemilik Stage 1/global/teknis. Scope dokumen tidak mengubah map, kode, ekonomi, data tersimpan, produksi atau otorisasi release.
