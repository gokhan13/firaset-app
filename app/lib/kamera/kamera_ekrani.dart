import 'dart:async';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../l10n/app_localizations.dart';
import '../olcum/landmark_motoru.dart';
import 'kamera_denetleyici.dart';
import 'nokta_ustu_boyayici.dart';

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
    return Stack(
      fit: StackFit.expand,
      children: [
        CameraPreview(controller),
        CustomPaint(painter: NoktaUstuBoyayici(_noktalar)),
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
