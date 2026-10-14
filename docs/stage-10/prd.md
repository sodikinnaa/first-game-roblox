# Stage 10 — Special Summit PRD

## 1. Identity / Status

**Stage 10 — Special Summit**

**Status: Draft — Pending Detailed Design Review**

[Global PRD](../prd.md) · [Previous: Stage 9](../stage-9/prd.md) · Next: none (finish plaza)

Dokumen desain/QA, bukan izin implementasi, build atau publish. Nama dan detail balancing belum final. Sumber dibaca: global `docs/prd.md` dan baseline feature `/home/dev/.hermes/cache/scratch/sky-island-map/prd.md`; detail source feature tidak menyatakan kesiapan main. Keputusan user terbaru mengatasi baseline lama hanya pada ascent dan appearance summit.

## 2. Objective

Plaza finish aman untuk selebrasi general, istirahat dan panorama; bukan obstacle stage.

## 3. Experience

Setelah validasi finish, pemain menerima banner general dan konfeti 3D lokal; tetap bebas bergerak, mengendalikan kamera dan menikmati plaza.

## 4. Entry / Exit

**Proposed — pending approval:** entry dari Stage 9 melalui arrival CP10 di plaza menyimpan respawn CP10 dan stage10, `Completed=false`. Menyentuh arrival bukan finish; pemain menuju `SummitFinishZone` terpisah. Tidak ada exit gameplay wajib setelah plaza. Feature source berbeda (bagian 11/17).

## 5. Flow

**Proposed — pending approval:** masuk dari ascent Stage 9 → validasi arrival CP10 → checkpoint respawn CP10/stage10/Completed=false → menuju zona finish terpisah → server memvalidasi history CP1–10 dan finish → Completed=true idempoten → banner general/konfeti lokal → istirahat atau replay presentasi jika tersedia.

## 6. Blueprint

Plaza aman dengan area arrival, zona finish, ruang beristirahat dan panorama. Spot foto/gazebo/lentera hanya usulan; tidak menambah tugas wajib setelah finish.

## 7. Obstacles

Tidak ada rintangan kesepuluh, lompatan wajib, hazard, atau gate collectible. Perlindungan tepi nyata perlu review; pagar visual saja bukan bukti aman.

## 8. Dimensions / Elevations

Koordinat X/Z, footprint, gap, slope, jumlah pijakan, spawn offset, collision clearance dan balancing final: **TBD — Requires Design Review**. Ukur gap dari tepi ke tepi dan rise dari top surface ke top surface, bukan selisih pusat.

Historical **Proposed** target island 10: Y=190 studs dari PRD feature read-only. Baseline PRD tidak mendefinisikan apakah Y pusat atau permukaan; snapshot StageConfig feature menggunakannya sebagai pusat dek setebal 2 studs, sehingga top surface historis Y=191. Ini bukan elevasi final atau koordinat yang disetujui. Selisih antarpulau bukan tinggi satu lompatan.

**Baseline global Proposed: footprint plaza minimal 48×48 studs; ukuran final pending dan perubahan baseline harus dicatat sebagai konflik global.** Durasi konfeti **Proposed 3–5 detik** termasuk umur partikel terakhir dan **Proposed 40–60 partikel aktif**: runtime validation pending; bukan budget mobile yang sudah terbukti.

## 9. Navigation / Camera

Tidak ada camera lock, cutscene wajib atau perubahan kontrol. Banner dan replay tidak menutup virtual joystick, jump atau safe area layar. Pemain boleh menolak efek gerak lewat reduced motion.

## 10. Visual

**Approved Design:** appearance general dan konfeti 3D sekitar karakter telah dipilih; bukan overlay konfeti UI 2D. Birthday, nama/pesan personal, kue, musik, fireworks dan efek kamera tetap nonaktif.

## 11. Checkpoint

**Proposed — pending approval:** arrival CP10 yang sah mencatat LastCheckpoint=CP10, ActiveStage=10 dan history entry tanpa mengubah `Completed=false`. Finish bukan checkpoint arrival: SummitService memvalidasi karakter hidup, posisi di `SummitFinishZone` terpisah dan history CP1–10, lalu mencatat `Completed=true` idempoten. Touch CP10 sendiri tidak memberi finish/selebrasi. **Existing & Verified — feature source only:** ordinary CP10 tidak diaktifkan; finish memakai history1–9 dan menetapkan stage10. Runtime pending; kontrak usulan belum diimplementasikan.

## 12. Failure

Asset/attachment/FX gagal: finish server tetap sah dan banner fallback tersedia. Mati, respawn atau karakter hilang membersihkan objek, emisi dan callback; tidak memutar event finish baru.

## 13. Technical Dependencies

Kontrak yang perlu diverifikasi bersama pemilik teknis: StageConfig/MapBuilderService untuk geometri dan orientasi, CheckpointService untuk urutan/recovery, ObstacleService untuk fall recovery, PlayerCollisionService untuk tidak saling mendorong, HUDController untuk informasi progres. SummitService, SummitController dan ConfettiController memisahkan validasi server dari presentasi lokal; lifecycle Ready → Playing → Cooldown → Ready, replay tidak menambah progres.

Movement/avatar, WalkSpeed, gravity, JumpHeight/JumpPower, ukuran collision, perangkat target dan respawn heading perlu dikonfirmasi. Economy, nilai reward, implementasi coin pickup dan persistence belum disetujui; tidak ada requirement implementasi baru untuk itu. Jangan menjanjikan resume lintas sesi. **Existing & Verified — feature source only:** StageConfig/MapBuilderService, SummitConfig/SummitService, SummitController dan ConfettiController tersedia pada feature. **Not Implemented — main:** modul map/summit/confetti tersebut belum tersedia. Runtime belum diuji; keberadaan source feature bukan readiness main.

## 14. Assets

Plaza solid dan perlindungan tepi, banner general, tekstur konfeti orisinal/berizin. Referensi visual https://devforum.roblox.com/t/confetti-effect/3592913 bukan izin menyalin kode atau asset.

Semua dekorasi di luar collision rute; catat lisensi dan budget sebelum integrasi. Asset ID, jumlah dan material final: **TBD — Requires Design Review**.

## 15. Acceptance

- **S10-AC01** — Given A finish sah dan B masih di ascent; when selebrasi A berjalan; then hanya A melihat konfeti/banner lokal; kamera dan kontrol A/B tetap bebas.
- **S10-AC02** — Given reduced motion aktif; when finish atau replay dipresentasikan; then banner statis tersedia tanpa emisi konfeti 3D dan tanpa pesan ulang tahun.
- **S10-AC03** — Given FX hilang atau gagal setelah finish sah; when controller melakukan fallback; then Completed tetap tercatat, banner general tersedia dan attachment/callback sementara dibersihkan.
- **S10-AC04** — Given presentasi Playing atau Cooldown; when sentuhan duplikat/replay berulang terjadi; then efek tidak menumpuk dan finish/reward tidak dihitung lagi.
- **S10-AC06** — Proposed pending approval: Given arrival CP10 sah tanpa finish; when pemain mati/respawn; then respawn di CP10, stage10/Completed=false dan tidak ada selebrasi; hanya finish terpisah sah dengan history CP1–10 memberi Completed=true sekali.
- **S10-AC05** — Given pemain berjalan ke sisi plaza setelah finish; when menikmati panorama; then tidak ada bahaya jatuh dalam area aman yang ditetapkan, tanpa kamera terkunci.

## 16. Playtests

Pada perangkat touch target, ukur frame-time/FPS sebelum, selama dan sesudah burst/replay, jumlah partikel puncak, umur partikel terakhir serta objek sisa setelah respawn. Uji safe-area banner/replay, dua pemain, reduced motion dan kualitas grafis rendah.

Gunakan Studio/runtime Roblox nyata pada PC dan mobile fisik, pemula tanpa arahan verbal, serta multiplayer. Catat device/OS, avatar/movement, input, kualitas grafis, FPS/frame-time dan video/titik kegagalan. Target historis Proposed 8/10 pemula mencapai summit dan 30 FPS bukan bukti lulus atau batas final stage; protokol, sampel serta threshold: **TBD — Requires Design Review**. Review safe area/notch dan kamera pada touch; build/headless geometry bukan pengganti playtest.

## 17. Risks / Open Questions

Confetti lokal tetap dapat membebani GPU; partikel menutup panorama/kontrol; pagar visual memberi rasa aman palsu; preset meriah keliru mengaktifkan birthday.

Budget partikel/durasi final, reduced-motion preference source, perlindungan perimeter, UX replay dan state pasca-finish masih perlu review. **TBD — Requires Design Review**.

**Kontrak global — Proposed, pending approval:** mengikuti [Global Checkpoint Contract](../prd.md#10-checkpoint-contract--kontrak-checkpoint), CP_N berada di entry island N. CP10 arrival sah menyimpan checkpoint respawn sesi CP10 dan stage aktif10 dengan `Completed=false`; exit Stage 9 / entry Stage 10 terjadi di sini. `SummitFinishZone` terpisah memvalidasi history CP1–10 dan mencatat `Completed=true` sekali. Save di sini bukan persistence lintas sesi atau approval reward. Recovery memakai checkpoint terakhir yang sah, termasuk CP10 setelah arrival. **Existing & Verified — feature source only:** CheckpointService mengabaikan ordinary touch stage≥10; SummitService memvalidasi history1–9 dan baru menetapkan stage10/Completed saat finish. Perilaku feature berbeda dari proposal, bukan mandat desain; runtime belum diuji. Persetujuan CP global/history/respawn tetap terbuka.

## 18. Handoff

Design handoff: setujui blueprint Stage 10, dimensi berbasis permukaan, sightline, collision safety dan checkpoint boundary sebelum implementasi. QA handoff: lampirkan hasil tiap S10-AC, touch video, geometri terukur, device/performance dan daftar defect; belum ada skenario yang dinyatakan lulus.

Koordinasikan sambungan dengan [Previous: Stage 9](../stage-9/prd.md) · Next: none (finish plaza) dan [Global PRD](../prd.md). Resolve ambiguity CP/finish bersama pemilik Stage 1/global/teknis. Scope dokumen tidak mengubah map, kode, ekonomi, data tersimpan, produksi atau otorisasi release.
