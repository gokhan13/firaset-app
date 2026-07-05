import 'dart:async';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../l10n/app_localizations.dart';
import '../olcum/landmark_motoru.dart';
import 'kamera_denetleyici.dart';
import 'nokta_ustu_boyayici.dart';
import 'onizleme_donusumu.dart';

// Kozmetik yönelim ayarları. Hizalama, doku ve noktaların AYNI dönüşümü
// paylaşmasıyla garanti; bunlar yalnızca görüntünün dik/aynalı görünmesini
// ayarlar. Cihazda debug işaretçileriyle (iris yeşil, çene kırmızı) ayarla:
// noktalar dururken yüze oturuyorsa dönüşüm doğrudur.
const int kOnizlemeCeyrekDonus =
    0; // 0..3 saat yönü; görüntü yan yatıksa artır.
const bool kOnizlemeAyna = true; // ön kamera selfie aynası.
// Landmark motoru mirrorHorizontal:true kullanıyor (lib/olcum) → x önceden aynalı.
// Bu, ingest'te tek seferlik geri alınır. Motor ayarı değişirse burayı çevir.
const bool kMotorAynaladi = true;
// Hizalama doğrulama işaretçileri (iris/çene). Doğrulama sonrası false yapılabilir.
const bool kDebugHizalama = true;

/// Kamera + yuz mesh POC ekrani.
///
/// GIZLILIK (CLAUDE.md Altin Kural 1): yalnizca `startImageStream` ile bellek-ici
/// kareler islenir. `takePicture` cagrilmaz, hicbir kare/landmark diske yazilmaz.
class KameraEkrani extends ConsumerStatefulWidget {
  const KameraEkrani({super.key});

  @override
  ConsumerState<KameraEkrani> createState() => _KameraEkraniState();
}

class _KameraEkraniState extends ConsumerState<KameraEkrani> {
  CameraController? _controller;
  StreamSubscription<LandmarkSonucu>? _sub;

  KameraAsama _asama = KameraAsama.yukleniyor;
  int _noktaSayisi = 0;
  bool _yuzVar = false;
  List<Landmark> _noktalar = const <Landmark>[];

  /// Bir kare islenirken sonrakini atla (reentrancy/backpressure korumasi).
  bool _mesgul = false;

  @override
  void initState() {
    super.initState();
    _baslat();
  }

  Future<void> _baslat() async {
    try {
      final motor = ref.read(landmarkMotoruProvider);
      await motor.baslat();
      _sub = motor.sonuclar.listen((s) {
        if (!mounted) return;
        setState(() {
          _noktaSayisi = s.noktaSayisi;
          _yuzVar = s.yuzVar;
          _noktalar = s.noktalar;
        });
      });

      final kameralar = await availableCameras();
      final onKamera = kameralar.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.front,
        orElse: () => kameralar.first,
      );
      final controller = CameraController(
        onKamera,
        ResolutionPreset.medium,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.bgra8888,
      );
      await controller.initialize();
      await controller.startImageStream(
        (img) => _kareGeldi(img, onKamera.sensorOrientation, motor),
      );
      if (!mounted) {
        await controller.dispose();
        return;
      }
      setState(() {
        _controller = controller;
        _asama = KameraAsama.hazir;
      });
    } on CameraException catch (e) {
      if (!mounted) return;
      final izinReddi =
          e.code == 'CameraAccessDenied' ||
          e.code == 'CameraAccessDeniedWithoutPrompt' ||
          e.code == 'CameraAccessRestricted';
      setState(
        () => _asama = izinReddi ? KameraAsama.izinYok : KameraAsama.hata,
      );
    } catch (_) {
      if (!mounted) return;
      setState(() => _asama = KameraAsama.hata);
    }
  }

  void _kareGeldi(CameraImage img, int rotation, LandmarkMotoru motor) {
    if (_mesgul) return;
    _mesgul = true;
    try {
      final plane = img.planes.first;
      // Yalniz bellek-ici donusum; diske yazma yok (Altin Kural 1).
      motor.kareVer(
        KameraKaresi(
          bytes: plane.bytes,
          width: img.width,
          height: img.height,
          format: KareFormati.bgra,
          bytesPerRow: plane.bytesPerRow,
          rotation: rotation,
        ),
      );
    } finally {
      _mesgul = false;
    }
  }

  @override
  void dispose() {
    _sub?.cancel();
    final controller = _controller;
    if (controller != null) {
      if (controller.value.isStreamingImages) {
        controller.stopImageStream();
      }
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Motoru ekran boyunca canli tut; ekran kapaninca autoDispose -> durdur().
    ref.watch(landmarkMotoruProvider);
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.pocTitle)),
      body: switch (_asama) {
        KameraAsama.yukleniyor => const Center(
          child: CircularProgressIndicator(),
        ),
        KameraAsama.izinYok => _mesaj(l10n.cameraPermissionDenied),
        KameraAsama.hata => _mesaj(l10n.cameraError),
        KameraAsama.hazir => _onizleme(l10n),
      },
    );
  }

  Widget _mesaj(String metin) => Padding(
    padding: const EdgeInsets.all(24),
    child: Center(child: Text(metin, textAlign: TextAlign.center)),
  );

  Widget _onizleme(AppLocalizations l10n) {
    final controller = _controller!;
    final ham = controller.value.previewSize;
    return Stack(
      fit: StackFit.expand,
      children: [
        if (ham != null) _kameraKatmani(controller, ham),
        Positioned(
          top: 16,
          left: 0,
          right: 0,
          child: Center(
            child: _rozet(
              _yuzVar
                  ? l10n.landmarkCountFound(_noktaSayisi)
                  : l10n.noFaceDetected,
            ),
          ),
        ),
        Positioned(
          bottom: 16,
          left: 16,
          right: 16,
          child: _rozet(l10n.entertainmentDisclaimer),
        ),
      ],
    );
  }

  /// Ham önizleme dokusu + landmark noktaları TEK ortak dönüşümle.
  ///
  /// `buildPreview()` (CameraPreview değil) sensör dokusunu ham verir; noktalar
  /// da aynı sensör uzayında olduğundan ikisi aynı [OnizlemeDonusumu] + saran
  /// `FittedBox(cover)` ile hizalı kalır. Cover kırpma en/boy oranını korur
  /// (ezme yok).
  Widget _kameraKatmani(CameraController controller, Size ham) {
    final donusum = OnizlemeDonusumu(
      hamBoyut: ham,
      ceyrekDonus: kOnizlemeCeyrekDonus,
      ayna: kOnizlemeAyna,
      motorAynaladi: kMotorAynaladi,
    );
    final disp = donusum.gosterimBoyutu;
    return ClipRect(
      child: FittedBox(
        fit: BoxFit.cover,
        child: SizedBox(
          width: disp.width,
          height: disp.height,
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Ham doku: noktalarla aynı rotasyon + kozmetik ayna.
              Transform.flip(
                flipX: kOnizlemeAyna,
                child: RotatedBox(
                  quarterTurns: kOnizlemeCeyrekDonus,
                  child: SizedBox(
                    width: ham.width,
                    height: ham.height,
                    child: controller.buildPreview(),
                  ),
                ),
              ),
              CustomPaint(
                painter: NoktaUstuBoyayici(
                  noktalar: _noktalar,
                  donusum: donusum,
                  debug: kDebugHizalama,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _rozet(String metin) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    decoration: BoxDecoration(
      color: Colors.black54,
      borderRadius: BorderRadius.circular(8),
    ),
    child: Text(
      metin,
      textAlign: TextAlign.center,
      style: const TextStyle(color: Colors.white),
    ),
  );
}
